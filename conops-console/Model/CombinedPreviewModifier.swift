//
//  CombinedPreviewModifier.swift
//  Conops Console
//
//  Created by April White on 1/21/25.
//  Copyright © 2026 April's Creature Workshop. All rights reserved.
//


///
/// There are dragons here. This crashes Xcode's preivew generator. While that's cool, it's not what we need.
///
/// ChatGPT mostly came up with this (I gave it a few fixes myself), so I'm just gonna abandon it for now.
///


import SwiftData
import SwiftUI

struct CombinedPreviewModifier: PreviewModifier {
    typealias Context = ModelContainer

    static func makeSharedContext() async throws -> ModelContainer {
        let attendeeContainer = Attendee.preview
        let conventionContainer = Convention.preview

        // Create a container with both models (variadic form).
        // No explicit 'inMemory' config at all—just the default store.
        let container = try ModelContainer(
            for: Convention.self,
            Attendee.self
        )


        // Merge data from each old container into the new container
        let attendeeFetch = FetchDescriptor<Attendee>()
        let existingAttendees = try attendeeContainer.mainContext.fetch(attendeeFetch)
        for attendee in existingAttendees {
            container.mainContext.insert(attendee)
        }

        let conventionFetch = FetchDescriptor<Convention>()
        let existingConventions = try conventionContainer.mainContext.fetch(conventionFetch)
        for convention in existingConventions {
            container.mainContext.insert(convention)
        }

        return container
    }

    func body(content: Content, context: Context) -> some View {
        content.modelContainer(context)
    }
}
