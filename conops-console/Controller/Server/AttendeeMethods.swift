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
    func getAllAttendees(convention: Convention) async -> Result<[AttendeeDTO], ServerError> {

        await fetchData(
            "attendees/\(convention.shortName)",
            dtoType: [AttendeeDTO].self,
            returnType: [AttendeeDTO].self
        ) { $0 }  // No transformation needed here
    }

    func createNewAttendee(_ attendee: Attendee) async -> Result<AttendeeDTO, ServerError> {

        guard let conventionShortName = attendee.convention?.shortName else {
            logger.warning("Cannot create attendee without a convention short name")
            fatalError("Convention short name is required to create an attendee")
        }

        let dto = attendee.toDTO()  // Convert to DTO before sending
        return await sendData(
            "attendee/\(conventionShortName)",
            method: .post,
            body: dto,
            dtoType: AttendeeDTO.self,
            returnType: AttendeeDTO.self
        ) { $0 }  // No transformation needed here
    }

    func updateAttendee(_ attendee: Attendee) async -> Result<Attendee, ServerError> {


        guard let conventionShortName = attendee.convention?.shortName else {
            logger.warning("Cannot update attendee without a convention short name")
            fatalError("Convention short name is required to update an attendee")
        }

        logger.info("Updating an existing convention on the server")

        let dto = attendee.toDTO()

        return await sendData(
            "attendee/\(conventionShortName)",
            method: .put,
            body: dto,  // Use the DTO
            dtoType: AttendeeDTO.self,
            returnType: Attendee.self
        ) { dto in
            Attendee.fromDTO(dto)
        }
    }

}
