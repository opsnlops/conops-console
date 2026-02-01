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

#if os(iOS)
    import UIKit
#endif

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
    @State private var selectedAttendeeId: AttendeeIdentifier?
    @State private var selectedAttendeeIds = Set<AttendeeIdentifier>()

    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""

    #if os(macOS)
        @State private var sortDescriptor = AttendeeSortDescriptor(key: .badgeName, ascending: true)
    #endif

    let logger = Logger(subsystem: "furry.enterprises.CreatureConsole", category: "AttendeeTable")

    // MARK: - In-Memory Filtering
    /// Filters the fetched attendees to only those that belong to the given convention.
    /// Also applies search filtering against firstName, lastName, or badgeName.
    private var filteredAttendees: [Attendee] {
        let filtered = attendees.filter { attendee in
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

        #if os(macOS)
            return filtered.sorted { sortDescriptor.compare($0, $1) }
        #else
            return filtered.sorted { lhs, rhs in
                lhs.badgeName.localizedCaseInsensitiveCompare(rhs.badgeName) == .orderedAscending
            }
        #endif
    }

    var body: some View {
        #if os(macOS)
            AttendeeTableMac(
                attendees: filteredAttendees,
                onDoubleClick: { attendee in
                    selectedAttendee = attendee
                    isEditing = true
                },
                onContextMenu: { attendee in
                    let menu = NSMenu()
                    let editItem = NSMenuItem(
                        title: "Edit",
                        action: #selector(NSApplication.shared.sendAction(_:to:from:)),
                        keyEquivalent: ""
                    )
                    menu.addItem(editItem)
                    return menu
                },
                selectedAttendeeId: $selectedAttendeeId,
                sortDescriptor: $sortDescriptor
            )
            .navigationDestination(isPresented: $isEditing) {
                if let detailAttendee = selectedAttendee {
                    EditAttendeeView(attendee: detailAttendee, convention: convention)
                }
            }
        #else
            if isPad {
                Table(of: Attendee.self, selection: $selectedAttendeeIds) {
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
                .onChange(of: selectedAttendeeIds) { _, newValue in
                    guard let attendeeId = newValue.first else { return }
                    if let attendee = filteredAttendees.first(where: { $0.id == attendeeId }) {
                        selectedAttendee = attendee
                        isEditing = true
                        selectedAttendeeIds = []
                    }
                }
            } else {
                List(filteredAttendees, id: \.id) { attendee in
                    NavigationLink {
                        EditAttendeeView(attendee: attendee, convention: convention)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(attendee.badgeName)
                                .font(.headline)
                            Text("\(attendee.firstName) \(attendee.lastName)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        #endif
    }

    #if os(iOS)
        private var isPad: Bool {
            UIDevice.current.userInterfaceIdiom == .pad
        }
    #else
        private var isPad: Bool { false }
    #endif

}

#Preview(traits: .modifier(AttendeePreviewModifier())) {
    let dummyConvention = Convention.mock()
    AttendeeTable(convention: dummyConvention, searchText: "")
}
