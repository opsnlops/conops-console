//
//  AttendeeTableiPad.swift
//  Conops Console
//
//  Created by April White on 2/1/26.
//  Copyright © 2026 April's Creature Workshop. All rights reserved.
//

#if os(iOS)
    import OSLog
    import SwiftUI

    struct AttendeeTableiPad: View {
        let attendees: [Attendee]
        let convention: Convention

        @Binding var selectedAttendee: Attendee?
        @Binding var isEditing: Bool
        @Binding var sortOrder: [KeyPathComparator<Attendee>]

        @State private var selectedAttendeeIds = Set<AttendeeIdentifier>()

        private let logger = Logger(
            subsystem: "furry.enterprises.CreatureConsole",
            category: "AttendeeTableiPad"
        )

        private func membershipLevelName(for id: MembershipLevelIdentifier) -> String {
            convention.membershipLevels.first { $0.id == id }?.shortName ?? ""
        }

        var body: some View {
            table
                .navigationDestination(isPresented: $isEditing) {
                    if let detailAttendee = selectedAttendee {
                        EditAttendeeView(attendee: detailAttendee, convention: convention)
                    }
                }
                .onChange(of: selectedAttendeeIds) { _, newValue in
                    guard let attendeeId = newValue.first else { return }
                    if let attendee = attendees.first(where: { $0.id == attendeeId }) {
                        selectedAttendee = attendee
                        isEditing = true
                        selectedAttendeeIds = []
                    }
                }
                .onChange(of: sortOrder) { _, newValue in
                    logger.debug(
                        "Sort order changed to: \(String(describing: newValue.first?.keyPath))")
                }
        }

        private var table: some View {
            Table(attendees, selection: $selectedAttendeeIds, sortOrder: $sortOrder) {
                // WORKAROUND: iPadOS 26 bug - first column header doesn't respond to taps for sorting.
                // This invisible column sacrifices itself so the real columns work. Remove when Apple fixes.
                TableColumn("") { (_: Attendee) in EmptyView() }
                    .width(1)
                TableColumn("Name", value: \.badgeName) { attendee in
                    HStack {
                        Text(attendee.badgeName)
                        if attendee.minor {
                            MinorBadge()
                        }
                        if attendee.staff {
                            StaffBadge()
                        }
                        if attendee.dealer {
                            DealerBadge()
                        }
                    }
                }
                .width(min: 250, ideal: 400)
                TableColumn("#", value: \.badgeNumber) { attendee in
                    Text(attendee.badgeNumber, format: .number)
                }
                .width(60)
                TableColumn("Level", value: \.membershipLevel) { attendee in
                    Text(membershipLevelName(for: attendee.membershipLevel))
                }
                .width(min: 100, ideal: 150)
                TableColumn("Shirt", value: \.shirtSizeSortKey) { attendee in
                    Text(attendee.shirtSize ?? "")
                }
                .width(70)
                TableColumn("ID Name", value: \.idName)
                    .width(min: 120, ideal: 180)
                TableColumn("Balance", value: \.currentBalance) { attendee in
                    Text(attendee.currentBalance, format: .currency(code: "USD"))
                }
                .width(min: 80, ideal: 100)
            }
        }
    }
#endif
