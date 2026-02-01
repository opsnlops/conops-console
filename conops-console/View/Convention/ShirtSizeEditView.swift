//
//  ShirtSizeEditView.swift
//  Conops Console
//
//  Created by April White on 2/10/25.
//  Copyright © 2026 April's Creature Workshop. All rights reserved.
//

import Foundation
import OSLog
import SwiftData
import SwiftUI

struct ShirtSizeEditView: View {

    @Environment(\.modelContext) var context

    @State var convention: Convention

    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""


    private let logger = Logger(
        subsystem: "furry.enterprises.CreatureConsole",
        category: "ShirtSizeEditView"
    )

    var body: some View {
        VStack {
            Text("Shirt Size View: \(convention.shortName)")
        }
        .navigationTitle("Shirt Sizes • \(convention.shortName)")
    }
}

#Preview(traits: .modifier(AttendeePreviewModifier())) {
    ShirtSizeEditView(convention: .mock())
}
