//
//  ConventionPreviewModifier.swift
//  Conops Console
//
//  Created by April White on 1/21/25.
//  Copyright © 2025 April's Creature Workshop. All rights reserved.
//

import Foundation
import SwiftData
import SwiftUI

struct ConventionPreviewModifier: PreviewModifier {
    typealias Context = ModelContainer

    static func makeSharedContext() async throws -> ModelContainer {
        Convention.preview
    }

    func body(content: Content, context: Context) -> some View {
        content.modelContainer(context)
    }
}
