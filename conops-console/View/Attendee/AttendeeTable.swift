//
//  AttendeeTable.swift
//  Conops Console
//
//  Created by April White on 1/21/25.
//  Copyright © 2025 April's Creature Workshop. All rights reserved.
//

import Foundation
import OSLog
import SwiftData
import SwiftUI

struct AttendeeTable: View {

    @Environment(\.modelContext) var context

    @Query(sort: \Attendee.badgeName, order: .forward)
    private var attendees: [Attendee]


    @State private var selectedAttendee: Attendee?  // Tracks the attendee to edit
    @State private var isEditing: Bool = false

    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""

    let logger = Logger(subsystem: "furry.enterprises.CreatureConsole", category: "AttendeeTable")

    /// This isn't using an actual table. Tables are goofy on iOS, even in 2025. If Apple finally
    /// makes things like swipes and context menus work on entire rows, maybe I will re-vist that
    /// some day.

    var body: some View {
        NavigationStack {

            Table(of: Attendee.self) {
                TableColumn("Name", value: \.badgeName)
                    .width(min: 120, ideal: 150)
                TableColumn("#") { a in
                    Text(a.badgeNumber, format: .number)
                }
                .width(60)
                TableColumn("First Name", value: \.firstName)
                    .width(min: 120, ideal: 250)
                TableColumn("Last Name", value: \.lastName)
            } rows: {
                ForEach(attendees, id: \.id) { attendee in
                    TableRow(attendee)
                        .contextMenu {
                            Button {
                                selectedAttendee = attendee
                                isEditing = true  // Trigger navigation
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }

                            Button {
                                // Do nothing
                            } label: {
                                Label("Ban", systemImage: "hammer")
                            }
                        }
                }
            }
            .navigationDestination(isPresented: $isEditing) {
                if let detailAttendee = selectedAttendee {
                    let binding = Binding<Attendee>(
                        get: { detailAttendee },
                        set: { updatedAttendee in
                            updateAttendee(detailAttendee, with: updatedAttendee)
                        }
                    )
                    EditAttendeeView(attendee: binding)
                }
            }
        }
    }


    private func updateAttendee(_ original: Attendee, with updated: Attendee) {
        original.update(from: updated)  // Use the `update(from:)` method
        original.lastModified = Date()

        context.insert(original)

        do {
            try context.save()
        } catch {
            logger.warning("unable to save updated attendee: \(error.localizedDescription)")
        }
    }
}

#Preview(traits: .modifier(AttendeePreviewModifier())) {
    AttendeeTable()
}
