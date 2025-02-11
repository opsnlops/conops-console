//
//  ConventionMethods.swift
//  conops-console
//
//  Created by April White on 1/4/25.
//  Copyright © 2025 April's Creature Workshop. All rights reserved.
//

import Foundation

extension ConopsServerClient {

    func getAllConventions() async -> Result<[ConventionDTO], ServerError> {
        await fetchData(
            "conventions",
            dtoType: [ConventionDTO].self,
            returnType: [ConventionDTO].self
        ) { $0 }  // No transformation needed here
    }

    func createNewConvention(_ convention: Convention) async -> Result<ConventionDTO, ServerError> {
        let dto = convention.toDTO()  // Convert to DTO before sending
        return await sendData(
            "convention",
            method: .post,
            body: dto,
            dtoType: ConventionDTO.self,
            returnType: ConventionDTO.self
        ) { $0 }  // No transformation needed here
    }


    func updateConvention(_ updateConvention: ConventionDTO) async -> Result<ConventionDTO, ServerError> {

        logger.info("Updating an existing convention on the server")

        return await sendData(
            "convention/\(updateConvention.id)",
            method: .put,
            body: updateConvention,  // Use the DTO
            dtoType: ConventionDTO.self,
            returnType: ConventionDTO.self
        ) { $0 }
    }


    func deleteConvention(withId id: UUID) async -> Result<Void, ServerError> {
        logger.info("Deleting a convention with ID \(id) from the server")

        return await sendData(
            "convention/\(id)",
            method: .delete,
            body: "",
            dtoType: EmptyDTO.self,  // Assuming EmptyDTO is defined for cases with no response
            returnType: Void.self
        ) { _ in
            ()
        }
    }
}
