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

        switch conventionFetchResult {
        case .success(let dtos):
            for dto in dtos {
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

            return .success("Loaded \(dtos.count) conventions from the server")

        case .failure(let error):
            logger.error("Unable to perform full sync: \(error)")
            return .failure(.databaseError(error.localizedDescription))
        }

    }
    //
    //            func performFullSync() async -> Result<String, ServerError> {
    //                return .success("performFullSync skipped")
    //            }
}
