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
        state: AmericanState.tennessee.rawValue,
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
            #if os(macOS)
            // Wrap the ScrollView in a VStack so that the navigationTitle can be attached to the VStack
            VStack {
                ScrollView {
                    AttendeeForm(attendee: $attendee) {
                        onAttendeeSave(attendee)
                        dismiss()
                    }
                }
            }
            #else
            AttendeeForm(attendee: $attendee) {
                onAttendeeSave(attendee)
                dismiss()
            }
            #endif
        }
        .navigationTitle("Register New Attendee")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
        #if os(iOS)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        #endif
    }
}

#Preview {
    RegisterNewAttendeeView(onAttendeeSave: { _ in })
}
