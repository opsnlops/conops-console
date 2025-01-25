//
//  AttendeeBaseForm.swift
//  Conops Console
//
//  Created by April White on 1/24/25.
//  Copyright © 2025 April's Creature Workshop. All rights reserved.
//

import Foundation
import SwiftUI

struct AttendeeForm: View {
    @Binding var attendee: Attendee

    var onSave: (() -> Void)?

    var body: some View {
        Form {
            Section(header: Text("Basic Info")) {
                TextField("Badge Name", text: $attendee.badgeName)
                    .autocorrectionDisabled(true)
                    #if os(iOS)
                        .textInputAutocapitalization(.never)
                    #endif
                TextField("First Name", text: $attendee.firstName)
                TextField("Last Name", text: $attendee.lastName)
                DatePicker("Birthday", selection: $attendee.birthday, displayedComponents: .date)
            }

            Section("Communications") {
                TextField("Email", text: $attendee.emailAddress)
                    .autocorrectionDisabled(true)
                    #if os(iOS)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                    #endif

                TextField(
                    "Emergency Contact",
                    text: Binding(
                        get: { attendee.emergencyContact ?? "" },
                        set: { attendee.emergencyContact = $0.isEmpty ? nil : $0 }
                    ))
            }

            // MARK: - Address
            Section("Address") {
                TextField("Street Address", text: $attendee.addressLine1)
                TextField(
                    "More Street Address",
                    text: Binding(
                        get: { attendee.addressLine2 ?? "" },
                        set: { attendee.addressLine2 = $0.isEmpty ? nil : $0 }
                    ))
                TextField("City", text: $attendee.city)
                Picker("State", selection: $attendee.state) {
                    ForEach(AmericanState.allCases, id: \.self) { state in
                        Text("\(state.displayName)")
                    }
                }
                TextField("ZIP", text: $attendee.postalCode)
                    #if os(iOS)
                        .keyboardType(.numbersAndPunctuation)
                    #endif
            }

            Section("Meta") {
                Toggle("Active", isOn: $attendee.active)
                Toggle("Staff", isOn: $attendee.staff)
                Toggle("Dealer", isOn: $attendee.dealer)
            }
        }
        //.navigationTitle("Edit Attendee")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    onSave?()
                }
            }
        }
    }
}
