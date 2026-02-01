//
//  RegisterNewAttendeeView.swift
//  Conops Console
//
//  Created by April White on 1/22/25.
//  Copyright © 2026 April's Creature Workshop. All rights reserved.
//

import SwiftUI

struct RegisterNewAttendeeView: View {
    // MARK: - Props
    let convention: Convention
    var onAttendeeSave: (Attendee) -> Void
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) var context

    // MARK: - State
    @State private var attendee = Attendee(
        id: AttendeeIdentifier(),
        conventionId: ConventionIdentifier(),
        lastModified: Date(),
        active: true,
        badgeNumber: 0,
        firstName: "",
        lastName: "",
        badgeName: "",
        membershipLevel: MembershipLevelIdentifier(),
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
        referral: nil,
        registrationDate: Date(),
        checkInTime: nil,
        staff: false,
        dealer: false,
        codeOfConductAccepted: false,
        secretCode: nil,
        attendeeType: .staff,
        minor: false,
        currentBalance: 0.0,
        transactions: []
    )

    private var membershipLevels: [MembershipLevel] {
        convention.membershipLevels.sorted()
    }

    var body: some View {
        NavigationStack {
            #if os(macOS)
                // Wrap the ScrollView in a VStack so that the navigationTitle can be attached to the VStack
                VStack {
                    ScrollView {
                        AttendeeForm(attendee: $attendee, membershipLevels: membershipLevels) {
                            onAttendeeSave(attendee)
                            dismiss()
                        }
                    }
                }
            #else
                AttendeeForm(attendee: $attendee, membershipLevels: membershipLevels) {
                    onAttendeeSave(attendee)
                    dismiss()
                }
            #endif
        }
        .navigationTitle("Register New Attendee")
        .onAppear {
            attendee.conventionId = convention.id
            if attendee.membershipLevel == 0, let first = membershipLevels.first {
                attendee.membershipLevel = first.id
            }
        }
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
    RegisterNewAttendeeView(convention: Convention.mock()) { _ in }
}
