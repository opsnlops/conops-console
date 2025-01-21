//
//  ConopsServerProtocol.swift
//  conops-console
//
//  Created by April White on 1/4/25.
//  Copyright © 2025 April's Creature Workshop. All rights reserved.
//

import Foundation

/// This is a bit weird. In order to mock out this class, we need to make a protocol that our implementation
/// will conform to. The mock version can implement this protocol, too, and be able to mock up a class
/// that's broken up into a bunch of files via extentions.
protocol ConopsServerProtocol: AnyObject {

    func getAllConventions() async -> Result<[ConventionDTO], ServerError>
    func createNewConvention(_ convention: Convention) async -> Result<ConventionDTO, ServerError>
}
