//
//  APIKeyEditView.swift
//  Conops Console
//
//  Created by April White on 2/10/25.
//  Copyright © 2026 April's Creature Workshop. All rights reserved.
//

import Foundation
import OSLog
import SwiftData
import SwiftUI

struct APIKeyEditView: View {

    @Environment(\.modelContext) var context

    @State var convention: Convention

    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""


    private let logger = Logger(
        subsystem: "furry.enterprises.CreatureConsole",
        category: "APIKeyEditView"
    )

    var body: some View {
        VStack {
            Text("API Key: \(convention.shortName)")
        }
        .navigationTitle("API Keys • \(convention.shortName)")
    }
}

#Preview(traits: .modifier(AttendeePreviewModifier())) {
    APIKeyEditView(convention: .mock())
}
