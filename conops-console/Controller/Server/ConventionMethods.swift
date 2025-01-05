//
//  ConventionMethods.swift
//  conops-console
//
//  Created by April White on 1/4/25.
//  Copyright © 2025 April's Creature Workshop. All rights reserved.
//

extension ConopsServerClient {

    func getAllConventions() async -> Result<[Convention], ServerError> {
        // Notice we're passing `[Convention].self` here
        let result: Result<[Convention], ServerError> = await fetchData(
            "conventions",
            returnType: [Convention].self
        )

        // Now `result` either holds [Convention] on .success
        // or a ServerError on .failure
        switch result {
        case .success(let conventions):
            logger.debug(
                "getAllConventions() was a success! Got \(conventions.count) convention(s).")
            return .success(conventions)
        case .failure(let error):
            logger.warning(
                "We couldn't get the data we wanted from the server: \(error.localizedDescription)")
            return .failure(error)
        }
    }
}
