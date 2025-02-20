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
    @Environment(\.dismiss) var dismiss

    var convention: Convention

    @State private var showingRegisterSheet = false

    @State private var activeAlert: ActiveAlert?
    @State private var alertMessage: String = ""

    @State private var searchText: String = ""
    @State private var isShowingSearchPopover: Bool = false

    private let logger = Logger(
        subsystem: "furry.enterprises.CreatureConsole",
        category: "ConventionDetailView"
    )

    var body: some View {
        VStack {
            // Pass the current convention and searchText to the attendee table
            AttendeeTable(convention: convention, searchText: searchText)
        }
        .navigationTitle(convention.longName)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingRegisterSheet = true
                } label: {
                    Image(systemName: "person.fill.badge.plus")
                }
                .symbolRenderingMode(.multicolor)
            }

            ToolbarItem(placement: .primaryAction) {
                Button {
                    isShowingSearchPopover.toggle()
                } label: {
                    Image(systemName: "magnifyingglass")
                }
                .symbolRenderingMode(.hierarchical)
                .symbolEffect(
                    .wiggle.byLayer,
                    options: .repeat(.periodic(delay: 2.0)),
                    isActive: !searchText.isEmpty
                )
                .popover(isPresented: $isShowingSearchPopover) {
                    VStack {
                        TextField("Search Attendees", text: $searchText)
                            .padding()
                            .frame(width: 300)
                    }
                }
                .textFieldStyle(.roundedBorder)
            }

            ToolbarItem {
                NavigationLink(destination: ConventionEditView(convention: convention)) {
                    Image(systemName: "slider.horizontal.3")
                        .symbolRenderingMode(.hierarchical)
                }
            }
        }
        // MARK: - Sheet
        .sheet(isPresented: $showingRegisterSheet) {
            RegisterNewAttendeeView { newAttendee in
                Task {

                    // Update this attendee with the active convention ID
                    newAttendee.conventionId = convention.id

                    // Extract the Sendable DTO on the main actor.
                    let dto: AttendeeDTO = await MainActor.run {
                        newAttendee.toDTO()
                    }

                    // Also extract the convention's short name (a Sendable String)
                    let conventionShortName: String = await MainActor.run {
                        convention.shortName
                    }

                    let serverClient = ConopsServerClient()

                    // Perform the network call in a detached task (only sending Sendable data)
                    let result = await Task.detached(priority: .userInitiated) {
                        await serverClient.createNewAttendeeDTO(
                            dto, conventionShortName: conventionShortName)
                    }.value

                    // Update our UI and SwiftData context on the main actor via our async helper.
                    await updateContext(with: result, newAttendee: newAttendee)
                }
            }
        }
        .onAppear {
            logger.debug("ConventionDetailView appeared for \(convention.longName)")
        }
        .alert(item: $activeAlert) { alert in
            switch alert {
            case .success:
                return Alert(
                    title: Text("Registration Successful"),
                    message: Text(alertMessage),
                    dismissButton: .default(
                        Text("Hooray 🎉"),
                        action: {
                            // Do nothing
                        })
                )
            case .error:
                return Alert(
                    title: Text("Error"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }

    // MARK: - Helper Function for Updating the Context
    // Marked as async so it can be awaited when called from outside the main actor.
    @MainActor
    private func updateContext(with result: Result<AttendeeDTO, ServerError>, newAttendee: Attendee)
        async
    {
        switch result {
        case .success(let incomingAttendee):

            // Assign convention and update the local model.
            newAttendee.conventionId = convention.id

            // Log the old and new ID (and modified)
            let oldId = newAttendee.id
            newAttendee.id = incomingAttendee.id
            newAttendee.lastModified = incomingAttendee.lastModified

            logger.debug(
                "Generated fake id: \(oldId) -> now: \(newAttendee.id), lastModified: \(newAttendee.lastModified)"
            )

            context.insert(newAttendee)

            do {
                try context.save()
                logger.debug("Successfully saved attendee")

                alertMessage = "Registered \(newAttendee.badgeName)!"
                activeAlert = .success

            } catch {
                logger.error("Failed to save attendee locally: \(error)")
                alertMessage = error.localizedDescription
                activeAlert = .error
            }
        case .failure(let error):
            logger.error("Server update failed: \(error)")
            alertMessage = error.localizedDescription
            activeAlert = .error
        }
    }
}

#Preview(traits: .modifier(AttendeePreviewModifier())) {
    ConventionDetailView(convention: .mock())
}
