//
//  WebUserEditView.swift
//  Conops Console
//
//  Created by April White on 2/10/25.
//  Copyright © 2025 April's Creature Workshop. All rights reserved.
//

import Foundation
import OSLog
import SwiftData
import SwiftUI

struct WebUserEditView: View {

    @Environment(\.modelContext) var context

    @State var convention: Convention

    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""


    private let logger = Logger(
        subsystem: "furry.enterprises.CreatureConsole",
        category: "WebUserEditView"
    )

    var body: some View {
        VStack {
            Text("Web User Edit View: \(convention.shortName)")
        }
        .navigationTitle("Web Users • \(convention.shortName)")
    }
}

#Preview(traits: .modifier(AttendeePreviewModifier())) {
    WebUserEditView(convention: .mock())
}

