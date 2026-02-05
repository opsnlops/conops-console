//
//  FullSync.swift
//  Conops Console
//
//  Created by April White on 1/22/25.
//  Copyright © 2026 April's Creature Workshop. All rights reserved.
//

import Foundation
import SwiftData

extension TopContentView {

    @MainActor
    private func ensureSyncState() -> SyncState {
        let existing = (try? context.fetch(FetchDescriptor<SyncState>())) ?? []
        if let state = existing.first {
            return state
        }
        let state = SyncState()
        context.insert(state)
        return state
    }

    /// Something is weird with this. It makes the preview provider crash by just being present in the file. It's not needed for a preview, so let's tell the compiler to leave it out
    func performSync(forceFullSync: Bool = false) async -> Result<String, ServerError> {

        logger.info("attempting to perform a full sync of the database")

        let client = ConopsServerClient()
        var existingConventions = (try? context.fetch(FetchDescriptor<Convention>())) ?? []
        let includeInactive = UserDefaults.standard.includeInactiveConventions
        let syncState = ensureSyncState()
        let isFullSync = forceFullSync || existingConventions.isEmpty

        if isFullSync {
            (try? context.fetch(FetchDescriptor<Attendee>()))?.forEach { context.delete($0) }
            existingConventions.forEach { context.delete($0) }
            syncState.lastSyncTime = nil
            do {
                try context.save()
                existingConventions = []
            } catch {
                logger.error("Failed to clear SwiftData cache: \(error)")
                return .failure(.databaseError(error.localizedDescription))
            }
        }

        let since = isFullSync ? nil : syncState.lastSyncTime

        logger.info("Sync mode: \(isFullSync ? "full" : "incremental")")
        if let since {
            logger.info("Sync since: \(since)")
        } else {
            logger.info("Sync since: <nil>")
        }
        logger.info("Include inactive: \(includeInactive)")

        let conventionFetchResult = await client.getAllConventions(
            since: since,
            includeInactive: includeInactive
        )

        // Keep track of the DTOs we've found so we can go fetch their attendees
        var conventionDTOs: [ConventionDTO] = []
        var conventionsToSync: [ConventionDTO] = []

        switch conventionFetchResult {
        case .success(let dtos):
            var existingById: [ConventionIdentifier: Convention] = [:]
            existingConventions.forEach { existingById[$0.id] = $0 }

            for dto in dtos {
                conventionDTOs.append(dto)
                let convention = Convention.fromDTO(dto)
                if let existing = existingById[convention.id] {
                    existing.update(from: convention)
                    logger.debug("Updated \(dto.shortName) in the SwiftData model")
                } else {
                    context.insert(convention)
                    existingById[convention.id] = convention
                    logger.debug("Inserted \(dto.shortName) into the SwiftData model")
                }
            }
            logger.info("successfully loaded the conventions from the server")

            // Now go save the context
            do {
                try context.save()
                logger.debug("Successfully saved the SwiftData model")
            } catch {
                logger.error("Failed to save the SwiftData model: \(error)")
                return .failure(.databaseError(error.localizedDescription))
            }

            logger.info("Loaded \(dtos.count) conventions from the server")

            if let primaryConvention = resolvePrimaryConvention(from: dtos) {
                let compareToDtos = await ensureCompareToConventions(
                    client: client,
                    compareToIds: Set([primaryConvention.compareTo].compactMap { $0 }),
                    existingById: &existingById
                )

                switch compareToDtos {
                case .success(let compareTo):
                    conventionsToSync = [primaryConvention] + compareTo
                case .failure(let error):
                    return .failure(error)
                }
            }

        case .failure(let error):
            logger.error("Unable to perform full sync: \(error)")
            return .failure(.databaseError(error.localizedDescription))
        }

        if conventionsToSync.isEmpty {
            let storedConventions = ((try? context.fetch(FetchDescriptor<Convention>())) ?? [])
                .filter { includeInactive || $0.active }
            let preferredShortName = UserDefaults.standard.lastAuthConvention.trimmingCharacters(
                in: .whitespacesAndNewlines)
            let primaryConvention =
                storedConventions.first(where: {
                    !$0.shortName.isEmpty
                        && $0.shortName.caseInsensitiveCompare(preferredShortName) == .orderedSame
                }) ?? storedConventions.first

            if let primaryConvention {
                conventionsToSync = [primaryConvention.toDTO()]
                if let compareToId = primaryConvention.compareTo,
                    let compareToConvention = storedConventions.first(where: {
                        $0.id == compareToId
                    })
                {
                    conventionsToSync.append(compareToConvention.toDTO())
                }
            }
        }

        logger.info("Syncing attendees for \(conventionsToSync.count) conventions")

        // Now go fetch the attendees
        for conventionDTO in conventionsToSync {
            let fetchResult = await fetchAttendees(for: conventionDTO, since: since)
            switch fetchResult {
            case .success(let message):
                logger.debug("\(message)")
                break
            case .failure(let error):
                return .failure(.databaseError(error.localizedDescription))
            }
        }

        syncState.lastSyncTime = Date()
        do {
            try context.save()
        } catch {
            logger.error("Failed to save sync state: \(error)")
        }


        return .success("Sync successful")

    }

    @MainActor
    private func fetchAttendees(
        for convention: ConventionDTO,
        since: Date?
    ) async -> Result<String, ServerError> {

        logger.info("fetching all attendeess for \(convention.longName)")

        let client = ConopsServerClient()
        logger.info(
            "Fetching attendees for \(convention.shortName) since \(since?.description ?? "<nil>")"
        )
        let attendeeFetchResult = await client.getAllAttendees(convention: convention, since: since)

        switch attendeeFetchResult {
        case .success(let dtos):

            if dtos.isEmpty {
                logger.debug("No attendees found for \(convention.longName)")
                return .success(
                    "Call to database was a success, but no attendees found for \(convention.longName)"
                )
            }

            let existingAttendees = (try? context.fetch(FetchDescriptor<Attendee>())) ?? []
            var existingById: [AttendeeIdentifier: Attendee] = [:]
            existingAttendees
                .filter { $0.conventionId == convention.id }
                .forEach { existingById[$0.id] = $0 }

            for dto in dtos {
                logger.trace("Inserting \(dto.badgeName)")

                // Flag this attendee with the convention ID before putting it into the model
                let attendee = Attendee.fromDTO(dto)
                attendee.conventionId = convention.id

                if let existing = existingById[attendee.id] {
                    existing.update(from: attendee)
                } else {
                    context.insert(attendee)
                    existingById[attendee.id] = attendee
                }
            }

            // Now save to the model
            do {
                try context.save()
                logger.debug(
                    "Saved \(dtos.count) attendees for \(convention.longName) to SwiftData")
            } catch {
                logger.error("Failed to save the SwiftData model: \(error)")
                return .failure(.databaseError(error.localizedDescription))
            }

        case .failure(let error):
            logger.error("Unable to fetch attendees: \(error)")
            return .failure(.databaseError(error.localizedDescription))
        }

        return .success("Fetch attendees successful")
    }

    private func ensureCompareToConventions(
        client: ConopsServerClient,
        compareToIds: Set<ConventionIdentifier>,
        existingById: inout [ConventionIdentifier: Convention]
    ) async -> Result<[ConventionDTO], ServerError> {
        guard !compareToIds.isEmpty else {
            return .success([])
        }

        var compareToDtos: [ConventionDTO] = compareToIds.compactMap { id in
            existingById[id]?.toDTO()
        }
        let missingCompareToIds = compareToIds.subtracting(existingById.keys)

        guard !missingCompareToIds.isEmpty else {
            return .success(compareToDtos)
        }

        logger.info("Fetching \(missingCompareToIds.count) compare-to conventions")

        for conventionId in missingCompareToIds {
            let fetchResult = await client.getConvention(id: conventionId)
            switch fetchResult {
            case .success(let dto):
                compareToDtos.append(dto)
                await MainActor.run {
                    let convention = Convention.fromDTO(dto)
                    if let existing = existingById[convention.id] {
                        existing.update(from: convention)
                    } else {
                        context.insert(convention)
                        existingById[convention.id] = convention
                    }
                }
                logger.debug("Loaded compare-to convention \(dto.shortName)")
            case .failure(let error):
                logger.error("Failed to load compare-to convention \(conventionId): \(error)")
                return .failure(.databaseError(error.localizedDescription))
            }
        }

        do {
            try await MainActor.run {
                try context.save()
            }
            logger.debug("Saved compare-to conventions to SwiftData")
        } catch {
            logger.error("Failed to save compare-to conventions: \(error)")
            return .failure(.databaseError(error.localizedDescription))
        }

        return .success(compareToDtos)
    }

    private func resolvePrimaryConvention(from conventions: [ConventionDTO]) -> ConventionDTO? {
        let preferredShortName = UserDefaults.standard.lastAuthConvention.trimmingCharacters(
            in: .whitespacesAndNewlines)
        if !preferredShortName.isEmpty,
            let preferred = conventions.first(where: {
                $0.shortName.caseInsensitiveCompare(preferredShortName) == .orderedSame
            })
        {
            return preferred
        }

        if conventions.count == 1 {
            return conventions.first
        }

        return conventions.first(where: { $0.active }) ?? conventions.first
    }


    //
    //            func performSync() async -> Result<String, ServerError> {
    //                return .success("performSync skipped")
    //            }
}
