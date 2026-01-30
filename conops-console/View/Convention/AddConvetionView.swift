//
//  AddConvetionView.swift
//  conops-console
//
//  Created by April White on 1/4/25.
//  Copyright © 2025 April's Creature Workshop. All rights reserved.
//

import SwiftUI

struct AddConventionView: View {
    // MARK: - Props
    var onSave: (Convention) -> Void
    @Environment(\.dismiss) private var dismiss

    // MARK: - State
    @State private var active = true
    @State private var longName = ""
    @State private var shortName = ""
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(60 * 60 * 24 * 3)
    @State private var preRegStartDate = Date().addingTimeInterval(-60 * 60 * 24 * 30)
    @State private var preRegEndDate = Date().addingTimeInterval(-60 * 60 * 24 * 5)
    @State private var registrationOpen = true
    @State private var contactEmailAddress = ""
    @State private var minBadgeNumber = UInt32(100)

    var body: some View {
        NavigationStack {
            // Use our computed property that conditionally wraps the form
            formContent
                .navigationTitle("Add Convention")
                .toolbar(content: {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            // Create a new DTO with user-entered data
                            let newDTO = ConventionDTO(
                                id: ConventionIdentifier(),
                                lastModified: Date(),
                                active: active,
                                longName: longName,
                                shortName: shortName,
                                startDate: startDate,
                                endDate: endDate,
                                preRegStartDate: preRegStartDate,
                                preRegEndDate: preRegEndDate,
                                registrationOpen: registrationOpen,
                                headerExtras: nil,
                                headerGraphic: nil,
                                styleSheet: nil,
                                footerExtras: nil,
                                badgeClass: nil,
                                contactEmailAddress: contactEmailAddress,
                                replicationMode: nil,
                                slackWebHook: nil,
                                postmarkServerToken: nil,
                                messagingServiceEndpoint: nil,
                                messagingServiceApiKey: nil,
                                twilioAccountSID: nil,
                                twilioAuthToken: nil,
                                twilioOutgoingNumber: nil,
                                compareTo: nil,
                                minBadgeNumber: minBadgeNumber,
                                dealersDenPresent: false,
                                dealersDenRegText: nil,
                                paypalAPIUserName: nil,
                                paypalAPIPassword: nil,
                                paypalAPISignature: nil,
                                membershipLevels: [],
                                shirtSizes: [],
                                mailTemplates: [:]
                            )

                            // Convert the DTO to a local model object
                            let newConvention = Convention.fromDTO(newDTO)

                            // Perform the save operation
                            onSave(newConvention)

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

    /// This computed view wraps the form in ScrollView on macOS, but uses just Form on iOS.
    @ViewBuilder
    private var formContent: some View {
        #if os(macOS)
            ScrollView {
                baseForm
            }
        #else
            baseForm
        #endif
    }

    /// Our base form that contains all the fields.
    private var baseForm: some View {
        Form {
            Section("Basic Info") {
                Toggle("Active", isOn: $active)
                TextField("Long Name", text: $longName)
                TextField("Short Name", text: $shortName)
                    .autocorrectionDisabled(true)
                    #if os(iOS)
                        .textInputAutocapitalization(.never)
                    #endif
            }

            Section("Dates") {
                DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                DatePicker("Pre-Reg Start", selection: $preRegStartDate, displayedComponents: .date)
                DatePicker("Pre-Reg End", selection: $preRegEndDate, displayedComponents: .date)
            }

            Section("Registration") {
                Toggle("Registration Open", isOn: $registrationOpen)
                TextField("Contact Email Address", text: $contactEmailAddress)
                    .autocorrectionDisabled(true)
                    #if os(iOS)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                    #endif
                TextField("Min Badge Number", value: $minBadgeNumber, format: .number)
            }
        }
        .textFieldStyle(.roundedBorder)
    }
}

#Preview {
    AddConventionView(onSave: { _ in })
}
