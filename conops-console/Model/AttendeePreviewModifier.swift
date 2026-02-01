//
//  AttendeePreviewModifier.swift
//  Conops Console
//
//  Created by April White on 1/21/25.
//  Copyright © 2026 April's Creature Workshop. All rights reserved.
//

import Foundation
import SwiftData
import SwiftUI

struct AttendeePreviewModifier: PreviewModifier {
    typealias Context = ModelContainer

    static func makeSharedContext() async throws -> ModelContainer {
        Attendee.preview
    }

    func body(content: Content, context: Context) -> some View {
        content.modelContainer(context)
    }
}
