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
    @State private var active: Bool = true
    @State private var badgeNumber: UInt32 = 100
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var badgeName: String = ""
    //TODO: Fix this
    @State private var membershipLevel: MembershipLevel = .mock()
    @State private var birthday: Date = Date()
    @State private var addressLine1: String = ""
    @State private var addressLine2: String = ""
    @State private var city: String = ""
    @State private var state: AmericanState = .tennessee
    @State private var postalCode: String = ""
    @State private var shirtSize: String? = ""
    @State private var emailAddress: String = ""
    @State private var emergencyContact: String = ""
    @State private var phoneNumber: String = ""
    @State private var registrationDate: Date = Date()
    @State private var checkInTime: Date?
    @State private var staff: Bool = false
    @State private var dealer: Bool = false
    @State private var codeOfConductAccepted: Bool = false

    var body: some View {
        NavigationStack {
            // Use our computed property that conditionally wraps the form
            formContent
                .navigationTitle("Register New Attendee")
                .toolbar(content: {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            // Create a new DTO with user-entered data
                            let newDTO = AttendeeDTO(
                                id: UUID(),
                                lastModified: Date(),
                                active: active,
                                badgeNumber: badgeNumber,
                                firstName: firstName,
                                lastName: lastName,
                                badgeName: badgeName,
                                membershipLevel: membershipLevel,
                                birthday: birthday,
                                addressLine1: addressLine1,
                                addressLine2: addressLine2,
                                city: city,
                                state: state.rawValue,
                                postalCode: postalCode,
                                shirtSize: shirtSize,
                                emailAddress: emailAddress,
                                emergencyContact: emergencyContact,
                                phoneNumber: phoneNumber,
                                registrationDate: Date(),
                                checkInTime: nil,
                                staff: staff,
                                dealer: dealer,
                                codeOfConductAccepted: codeOfConductAccepted,
                                secretCode: "",
                                transactions: []
                            )

                            // Convert the DTO to a local model object
                            let newAttendee = Attendee.fromDTO(newDTO)

                            // Perform the save operation
                            onAttendeeSave(newAttendee)

                            // Dismiss the view
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

    // MARK: - Conditional Form
    @ViewBuilder
    private var formContent: some View {
        #if os(macOS)
            ScrollView {
                attendeeBaseForm
            }
        #else
            attendeeBaseForm
        #endif
    }

    private var attendeeBaseForm: some View {
        Form {
            // MARK: - Basic Info
            Section(header: Text("Basic Info")) {
                TextField("Badge Name", text: $badgeName)
                    .autocorrectionDisabled(true)
                    #if os(iOS)
                        .textInputAutocapitalization(.never)
                    #endif
                TextField("First Name", text: $firstName)
                TextField("Last Name", text: $lastName)
                DatePicker("Birthday", selection: $birthday, displayedComponents: .date)
            }

            Section("Communications") {
                TextField("Email", text: $emailAddress)
                    .autocorrectionDisabled(true)
                    #if os(iOS)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                    #endif

                TextField("Emergency Contact", text: $emergencyContact)
                    #if os(iOS)
                        .keyboardType(.phonePad)
                    #endif
            }

            // MARK: - Address
            Section("Address") {
                TextField("Street Address", text: $addressLine1)
                TextField("More Street Address", text: $addressLine2)
                TextField("City", text: $city)
                Picker("State", selection: $state) {
                    ForEach(AmericanState.allCases, id: \.self) { state in
                        Text("\(state.displayName)")
                    }
                }

                TextField("ZIP", text: $postalCode)
                    #if os(iOS)
                        .keyboardType(.numbersAndPunctuation)
                    #endif

            }

            Section("Meta") {
                Toggle("Active", isOn: $active)
                Toggle("Staff", isOn: $staff)
                Toggle("Dealer", isOn: $dealer)
            }

        }.textFieldStyle(.roundedBorder)
    }


}


#Preview {
    RegisterNewAttendeeView(onAttendeeSave: { _ in })
}
