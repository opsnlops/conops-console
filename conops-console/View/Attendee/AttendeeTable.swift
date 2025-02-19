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
    // 🐰 Parameters for filtering:
    let convention: Convention
    let searchText: String

    @Environment(\.modelContext) var context

    // Fetch all attendees sorted by badgeName.
    @Query(sort: \Attendee.badgeName, order: .forward)
    private var attendees: [Attendee]

    @State private var selectedAttendee: Attendee?  // Tracks the attendee to edit
    @State private var isEditing: Bool = false

    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""

    let logger = Logger(subsystem: "furry.enterprises.CreatureConsole", category: "AttendeeTable")

    // MARK: - In-Memory Filtering
    /// Filters the fetched attendees to only those that belong to the given convention.
    /// Also applies search filtering against firstName, lastName, or badgeName.
    private var filteredAttendees: [Attendee] {
        attendees.filter { attendee in
            // Only include attendees that have a matching convention.
            guard attendee.conventionId == convention.id
            else {
                return false
            }
            // If there's no search text, we're happy with the attendee.
            guard !searchText.isEmpty else { return true }
            // Otherwise, check if any of the key fields contain the search text.
            return attendee.firstName.localizedCaseInsensitiveContains(searchText)
                || attendee.lastName.localizedCaseInsensitiveContains(searchText)
                || attendee.badgeName.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            Table(of: Attendee.self) {
                TableColumn("Name", value: \.badgeName)
                    .width(min: 120, ideal: 150)
                TableColumn("#") { attendee in
                    Text(attendee.badgeNumber, format: .number)
                }
                .width(60)
                TableColumn("First Name", value: \.firstName)
                    .width(min: 120, ideal: 250)
                TableColumn("Last Name", value: \.lastName)
            } rows: {
                ForEach(filteredAttendees, id: \.id) { attendee in
                    TableRow(attendee)
                        .contextMenu {
                            Button {
                                selectedAttendee = attendee
                                isEditing = true  // Trigger navigation to edit view
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }

                            Button {
                                // Ban action logic can go here 🐰🔨
                            } label: {
                                Label("Ban", systemImage: "hammer")
                            }
                        }
                }
            }
            .navigationDestination(isPresented: $isEditing) {
                if let detailAttendee = selectedAttendee {
                    EditAttendeeView(attendee: detailAttendee, convention: convention)
                }
            }
        }
    }

}

#Preview(traits: .modifier(AttendeePreviewModifier())) {
    let dummyConvention = Convention.mock()
    AttendeeTable(convention: dummyConvention, searchText: "")
}
