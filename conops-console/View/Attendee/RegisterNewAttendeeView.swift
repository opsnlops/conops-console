//
//  RegisterNewAttendeeView.swift
//  Conops Console
//
//  Created by April White on 1/22/25.
//  Copyright © 2025 April's Creature Workshop. All rights reserved.
//

import SwiftUI

struct RegisterNewAttendeeView: View {

    // MARK: - Props
    var onAttendeeSave: (Attendee) -> Void
    @Environment(\.dismiss) private var dismiss

    // MARK: - State

    // Set up the defaults for this form since we don't have an existing attendee to work off of
    @State private var attendee = Attendee(
        id: UUID(),
        convention: nil,
        lastModified: Date(),
        active: true,
        badgeNumber: 0,
        firstName: "",
        lastName: "",
        badgeName: "",
        membershipLevel: UUID(),
        birthday: Calendar.current.date(byAdding: .year, value: -25, to: Date()) ?? Date(),
        addressLine1: "",
        addressLine2: nil,
        city: "",
        state: "",
        postalCode: "",
        shirtSize: nil,
        emailAddress: "",
        emergencyContact: nil,
        phoneNumber: nil,
        registrationDate: Date(),
        checkInTime: nil,
        staff: false,
        dealer: false,
        codeOfConductAccepted: false,
        secretCode: nil,
        transactions: []
    )

    var body: some View {
        NavigationStack {
            AttendeeForm(attendee: $attendee) {
                // Save action
                onAttendeeSave(attendee)
                dismiss()
            }
            .navigationTitle("Register New Attendee")
            .toolbar(content: {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            })
#if os(iOS)
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
#endif
        }
    }
}

#Preview {
    RegisterNewAttendeeView(onAttendeeSave: { _ in })
}
