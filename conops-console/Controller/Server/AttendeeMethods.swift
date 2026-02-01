//
//  AttendeeMethods.swift
//  Conops Console
//
//  Created by April White on 2/2/25.
//  Copyright © 2026 April's Creature Workshop. All rights reserved.
//

import Foundation

extension ConopsServerClient {

    /// Get all of the attendees for a specific convention
    func getAllAttendees(
        convention: ConventionDTO,
        since: Date? = nil
    ) async -> Result<[AttendeeDTO], ServerError> {

        var queryItems: [URLQueryItem] = []
        if let since {
            queryItems.append(
                URLQueryItem(name: "since", value: ISO8601DateFormatter().string(from: since)))
        }

        return await fetchData(
            "attendees/\(convention.shortName)",
            queryItems: queryItems,
            dtoType: [AttendeeDTO].self,
            returnType: [AttendeeDTO].self
        ) { $0 }
    }


    func createNewAttendeeDTO(_ dto: AttendeeDTO, conventionShortName: String) async -> Result<
        AttendeeDTO, ServerError
    > {

        guard conventionShortName.isEmpty == false else {
            logger.warning("Cannot create attendee without a convention short name")
            return .failure(
                .unprocessableEntity("Convention short name is required to create an attendee"))
        }

        let request = AttendeeCreateRequest(
            firstName: dto.firstName,
            lastName: dto.lastName,
            badgeName: dto.badgeName,
            membershipLevelId: dto.membershipLevel,
            birthday: dto.birthday,
            emailAddress: dto.emailAddress,
            addressLine1: dto.addressLine1,
            addressLine2: dto.addressLine2,
            city: dto.city,
            state: dto.state,
            postalCode: dto.postalCode,
            phoneNumber: dto.phoneNumber,
            emergencyContact: dto.emergencyContact,
            shirtSize: dto.shirtSize,
            referral: dto.referral
        )

        return await sendData(
            "attendees/\(conventionShortName)",
            method: .post,
            body: request,
            dtoType: AttendeeDTO.self,
            returnType: AttendeeDTO.self,
            transform: { $0 }
        )
    }


    func updateAttendee(
        _ attendee: AttendeeDTO,
        conventionShortName: String,
        reason: String,
        notifyAttendee: Bool
    ) async -> Result<
        Void, ServerError
    > {

        guard conventionShortName.isEmpty == false else {
            logger.warning("Cannot update attendee without a convention short name")
            return .failure(
                .unprocessableEntity("Convention short name is required to update an attendee"))
        }

        logger.info("Updating an existing attendee on the server")

        let request = AttendeeUpdateRequest(
            badgeNumber: attendee.badgeNumber,
            firstName: attendee.firstName,
            lastName: attendee.lastName,
            badgeName: attendee.badgeName,
            membershipLevelId: attendee.membershipLevel,
            birthday: attendee.birthday,
            emailAddress: attendee.emailAddress,
            addressLine1: attendee.addressLine1,
            addressLine2: attendee.addressLine2,
            city: attendee.city,
            state: attendee.state,
            postalCode: attendee.postalCode,
            phoneNumber: attendee.phoneNumber,
            emergencyContact: attendee.emergencyContact,
            shirtSize: attendee.shirtSize,
            referral: attendee.referral,
            staff: attendee.staff,
            active: attendee.active,
            checkInTime: attendee.checkInTime,
            reason: reason,
            notifyAttendee: notifyAttendee
        )

        return await sendData(
            "attendees/\(conventionShortName)/\(attendee.id)",
            method: .put,
            body: request,
            dtoType: EmptyDTO.self,
            returnType: Void.self
        ) { _ in
            ()
        }
    }

    func getAttendee(
        conventionShortName: String,
        attendeeId: AttendeeIdentifier
    ) async -> Result<AttendeeDTO, ServerError> {
        guard conventionShortName.isEmpty == false else {
            logger.warning("Cannot fetch attendee without a convention short name")
            return .failure(
                .unprocessableEntity("Convention short name is required to fetch an attendee"))
        }

        return await fetchData(
            "attendees/\(conventionShortName)/\(attendeeId)",
            dtoType: AttendeeDTO.self,
            returnType: AttendeeDTO.self
        ) { $0 }
    }

    func createTransaction(
        conventionShortName: String,
        attendeeId: AttendeeIdentifier,
        amount: Float,
        type: TransactionTypeOption,
        notes: String
    ) async -> Result<Void, ServerError> {
        guard conventionShortName.isEmpty == false else {
            logger.warning("Cannot create transaction without a convention short name")
            return .failure(
                .unprocessableEntity("Convention short name is required to create a transaction"))
        }

        let request = TransactionCreateRequest(
            amount: amount,
            typeCode: type.rawValue,
            notes: notes
        )

        return await sendData(
            "attendees/\(conventionShortName)/\(attendeeId)/transactions",
            method: .post,
            body: request,
            dtoType: EmptyDTO.self,
            returnType: Void.self
        ) { _ in
            ()
        }
    }

    func notifyAttendeeUpdated(
        conventionShortName: String,
        attendeeId: AttendeeIdentifier,
        reason: String
    ) async -> Result<Void, ServerError> {
        guard conventionShortName.isEmpty == false else {
            logger.warning("Cannot notify attendee without a convention short name")
            return .failure(
                .unprocessableEntity("Convention short name is required to notify an attendee"))
        }

        let request = AttendeeNotifyRequest(reason: reason)
        return await sendData(
            "attendees/\(conventionShortName)/\(attendeeId)/notify-updated",
            method: .post,
            body: request,
            dtoType: EmptyDTO.self,
            returnType: Void.self
        ) { _ in
            ()
        }
    }

    func resendWelcomeMessage(
        conventionShortName: String,
        attendeeId: AttendeeIdentifier,
        isVolunteer: Bool = false,
        isDealer: Bool = false
    ) async -> Result<Void, ServerError> {
        guard conventionShortName.isEmpty == false else {
            logger.warning("Cannot resend welcome message without a convention short name")
            return .failure(
                .unprocessableEntity("Convention short name is required to resend welcome message"))
        }

        let request = AttendeeWelcomeRequest(isVolunteer: isVolunteer, isDealer: isDealer)
        return await sendData(
            "attendees/\(conventionShortName)/\(attendeeId)/resend-welcome",
            method: .post,
            body: request,
            dtoType: EmptyDTO.self,
            returnType: Void.self
        ) { _ in
            ()
        }
    }

    func getRemotePrinters(
        conventionShortName: String
    ) async -> Result<[String], ServerError> {
        guard conventionShortName.isEmpty == false else {
            logger.warning("Cannot load printers without a convention short name")
            return .failure(
                .unprocessableEntity("Convention short name is required to load printers"))
        }

        return await fetchData(
            "printers/\(conventionShortName)",
            dtoType: [String].self,
            returnType: [String].self
        ) { $0 }
    }

    func printBadge(
        conventionShortName: String,
        attendeeId: AttendeeIdentifier,
        printerName: String
    ) async -> Result<Void, ServerError> {
        guard conventionShortName.isEmpty == false else {
            logger.warning("Cannot print badge without a convention short name")
            return .failure(
                .unprocessableEntity("Convention short name is required to print a badge"))
        }

        let request = PrintBadgeRequest(printerName: printerName)
        return await sendData(
            "attendees/\(conventionShortName)/\(attendeeId)/print-badge",
            method: .post,
            body: request,
            dtoType: EmptyDTO.self,
            returnType: Void.self
        ) { _ in
            ()
        }
    }

}
