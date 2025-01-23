//
//  ConventionDetailView.swift
//  Conops Console
//
//  Created by April White on 1/21/25.
//  Copyright © 2025 April's Creature Workshop. All rights reserved.
//

import Foundation
import OSLog
import SwiftData
import SwiftUI

struct ConventionDetailView: View {

    @Environment(\.modelContext) var context

    var convention: Convention

    @State private var showingRegisterSheet = false
    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""

    private let logger = Logger(
        subsystem: "furry.enterprises.CreatureConsole", category: "ConventionDetailView")

    var body: some View {

        VStack {
            AttendeeTable()
        }
        .navigationTitle(convention.longName)
        .toolbar(id: "ConventionViewToolbar") {
            ToolbarItem(id: "registerAttendee", placement: .primaryAction) {
                Button {
                    showingRegisterSheet = true
                } label: {
                    Image(systemName: "plus")
                }
                .buttonStyle(.borderless)
            }
        }
        .sheet(isPresented: $showingRegisterSheet) {
            RegisterNewAttendeeView { newAttendee in
                Task {
                    do {
                        logger.info("saving new attendee")
                        newAttendee.convention = convention
                        logger.debug("Attendee saved: \(newAttendee)")
                        context.insert(newAttendee)
                        try context.save()
                    } catch {
                        logger.error("Failed to save convention to SwiftData: \(error)")
                        errorMessage = error.localizedDescription
                        showErrorAlert = true
                    }
                }
            }
        }
    }

}

#Preview {
    ConventionDetailView(convention: .mock())
}
