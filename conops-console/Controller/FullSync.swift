//
//  FullSync.swift
//  Conops Console
//
//  Created by April White on 1/22/25.
//  Copyright © 2025 April's Creature Workshop. All rights reserved.
//

extension TopContentView {

    /// Something is weird with this. It makes the preview provider crash by just being present in the file. It's not needed for a preview, so let's tell the compiler to leave it out
    func performFullSync() async -> Result<String, ServerError> {

        logger.info("attempting to perform a full sync of the database")

        let client = ConopsServerClient()
        let conventionFetchResult = await client.getAllConventions()

        // Keep track of the DTOs we've found so we can go fetch their attendees
        var conventionDTOs: [ConventionDTO] = []

        switch conventionFetchResult {
        case .success(let dtos):
            for dto in dtos {
                conventionDTOs.append(dto)
                context.insert(Convention.fromDTO(dto))
                logger.debug("Inserted \(dto.shortName) into the SwiftData model")
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

        case .failure(let error):
            logger.error("Unable to perform full sync: \(error)")
            return .failure(.databaseError(error.localizedDescription))
        }

        // Now go fetch the attendees
        for conventionDTO in conventionDTOs {
            let fetchResult = await fetchAttendees(for: conventionDTO)
            switch fetchResult {
            case .success(let message):
                logger.debug("\(message)")
                break
            case .failure(let error):
                return .failure(.databaseError(error.localizedDescription))
            }
        }

        return .success("Full sync successful")

    }

    private func fetchAttendees(for convention: ConventionDTO) async -> Result<String, ServerError>
    {

        logger.info("fetching all attendeess for \(convention.longName)")

        let client = ConopsServerClient()
        let attendeeFetchResult = await client.getAllAttendees(convention: convention)

        switch attendeeFetchResult {
        case .success(let dtos):

            if dtos.isEmpty {
                logger.debug("No attendees found for \(convention.longName)")
                return .success(
                    "Call to database was a success, but no attendees found for \(convention.longName)"
                )
            }

            for dto in dtos {
                logger.trace("Inserting \(dto.badgeName)")

                // Flag this attendee with the convention ID before putting it into the model
                let attendee = Attendee.fromDTO(dto)
                attendee.conventionId = convention.id

                context.insert(Attendee.fromDTO(dto))
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


    //
    //            func performFullSync() async -> Result<String, ServerError> {
    //                return .success("performFullSync skipped")
    //            }
}
