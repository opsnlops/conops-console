//
//  AttendeeMethods.swift
//  Conops Console
//
//  Created by April White on 2/2/25.
//  Copyright © 2025 April's Creature Workshop. All rights reserved.
//

import Foundation

extension ConopsServerClient {

    /// Get all of the attendees for a specific convention
    func getAllAttendees(convention: ConventionDTO) async -> Result<[AttendeeDTO], ServerError> {

        await fetchData(
            "attendees/\(convention.shortName)",
            dtoType: [AttendeeDTO].self,
            returnType: [AttendeeDTO].self
        ) { $0 }  // No transformation needed here
    }


    func createNewAttendeeDTO(_ dto: AttendeeDTO, conventionShortName: String) async -> Result<
        AttendeeDTO, ServerError
    > {

        guard conventionShortName.isEmpty == false else {
            logger.warning("Cannot create attendee without a convention short name")
            return .failure(
                .unprocessableEntity("Convention short name is required to create an attendee"))
        }

        return await sendData(
            "attendee/\(conventionShortName)",
            method: .post,
            body: dto,
            dtoType: AttendeeDTO.self,
            returnType: AttendeeDTO.self,
            transform: { $0 }
        )
    }


    func updateAttendee(_ attendee: AttendeeDTO, conventionShortName: String) async -> Result<
        AttendeeDTO, ServerError
    > {

        guard conventionShortName.isEmpty == false else {
            logger.warning("Cannot update attendee without a convention short name")
            return .failure(
                .unprocessableEntity("Convention short name is required to update an attendee"))
        }

        logger.info("Updating an existing convention on the server")

        return await sendData(
            "attendee/\(conventionShortName)",
            method: .put,
            body: attendee,
            dtoType: AttendeeDTO.self,
            returnType: AttendeeDTO.self
        ) { $0 }
    }

}
