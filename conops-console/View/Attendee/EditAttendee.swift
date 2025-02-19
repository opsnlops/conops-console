//
//  EditAttendee.swift
//  Conops Console
//
//  Created by April White on 1/24/25.
//  Copyright © 2025 April's Creature Workshop. All rights reserved.
//

import Foundation
import OSLog
import SwiftData
import SwiftUI

struct EditAttendeeView: View {

    @Environment(\.modelContext) var context
    @Environment(\.dismiss) var dismiss

    // MARK: - Props
    @State var attendee: Attendee
    var convention: Convention

    @State private var activeAlert: ActiveAlert?
    @State private var errorMessage: String = ""


    let logger = Logger(
        subsystem: "furry.enterprises.CreatureConsole", category: "EditAttendeeView")

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Edit Attendee")
                .toolbar(
                    id: "editAttendeeToolbar",
                    content: {

                        ToolbarItem(id: "printRegSlip", placement: .secondaryAction) {
                            Button {
                                // Do the thing
                            } label: {
                                Image(systemName: "printer.dotmatrix")
                            }
                            .symbolRenderingMode(.hierarchical)
                        }

                        ToolbarItem(id: "ban", placement: .secondaryAction) {
                            Button {
                                // Do the thing
                            } label: {
                                Image(systemName: "hammer")
                            }
                            .symbolRenderingMode(.hierarchical)
                        }

                        ToolbarItem(id: "checkInAttendee", placement: .secondaryAction) {
                            Button {
                                // Do the checkin
                            } label: {
                                Image(systemName: "person.fill.checkmark")
                            }
                            .symbolRenderingMode(.hierarchical)
                        }
                    }
                ).toolbarRole(.editor)
                .alert(item: $activeAlert) { alert in
                    switch alert {
                    case .success:
                        return Alert(
                            title: Text("Save Successful"),
                            message: Text("Attendee saved successfully!"),
                            dismissButton: .default(
                                Text("Hooray 🎉"),
                                action: {
                                    dismiss()
                                })
                        )
                    case .error:
                        return Alert(
                            title: Text("Error"),
                            message: Text(errorMessage),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        #if os(macOS)
            ScrollView {
                AttendeeForm(attendee: $attendee) {
                    saveAttendee()
                }.padding()
            }
        #else
            AttendeeForm(attendee: $attendee) {
                saveAttendee()
            }
        #endif
    }


    func saveAttendee() {
        logger.debug("in saveAttendee")

        logger.debug("pre-save attendee id: \(attendee.id)")
        Task {
            let client = ConopsServerClient()
            let attendeeDTO = attendee.toDTO()

            let saveResult = await client.updateAttendee(
                attendeeDTO, conventionShortName: convention.shortName)
            switch saveResult {
            case .success(let attendeeFromServer):
                logger.debug("Attendee from server has id \(attendeeFromServer.id)")
                do {
                    context.insert(Attendee.fromDTO(attendeeFromServer))
                    try context.save()
                    activeAlert = .success
                } catch {
                    logger.error("Failed to save convention to SwiftData: \(error)")
                    errorMessage = error.localizedDescription
                    activeAlert = .error
                }
            case .failure(let error):
                logger.error("Failed to save convention to server: \(error)")
                errorMessage = error.localizedDescription
                activeAlert = .error
            }
        }
    }


    // MARK: - Helper Function for Updating the Context
    // Marked as async so it can be awaited when called from outside the main actor.
    @MainActor
    private func updateContext(with result: Result<AttendeeDTO, ServerError>, newAttendee: Attendee)
        async
    {
        logger.debug("in updateContext")
        switch result {
        case .success:
            // Assign convention and update the local model.
            newAttendee.conventionId = convention.id
            context.insert(newAttendee)
            do {
                try context.save()
                logger.debug("Successfully saved attendee")
            } catch {
                logger.error("Failed to save attendee locally: \(error)")
                errorMessage = error.localizedDescription
                activeAlert = .error
            }
        case .failure(let error):
            logger.error("Server update failed: \(error)")
            errorMessage = error.localizedDescription
            activeAlert = .error
        }
    }
}

#Preview {
    @Previewable @State var sampleAttendee = Attendee.mock()

    return NavigationStack {
        EditAttendeeView(attendee: sampleAttendee, convention: .mock())
    }
}
