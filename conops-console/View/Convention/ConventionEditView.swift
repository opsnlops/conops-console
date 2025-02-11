//
//  ConventionEditView.swift
//  Conops Console
//
//  Created by April White on 2/10/25.
//  Copyright © 2025 April's Creature Workshop. All rights reserved.
//

import Foundation
import OSLog
import SwiftData
import SwiftUI

struct ConventionEditView: View {

    @Environment(\.modelContext) var context
    @Environment(\.dismiss) var dismiss

    @State var convention: Convention

    @State private var showingRegisterSheet = false
    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""

    @State private var showSuccessAlert: Bool = false


    private let logger = Logger(
        subsystem: "furry.enterprises.CreatureConsole",
        category: "ConventionEditView"
    )

    var body: some View {

        VStack {
#if os(macOS)
            ScrollView {
                baseForm
            }
#else
            baseForm
#endif
        }
        .navigationTitle("Edit Convention • \(convention.shortName)")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                NavigationLink(destination: EmailTemplateEditView(convention: convention)) {
                    Image(systemName: "envelope.and.arrow.trianglehead.branch.fill")
                        .symbolRenderingMode(.hierarchical)
                }
            }

            ToolbarItem(placement: .primaryAction) {
                NavigationLink(destination: MembershipLevelEditView(convention: convention)) {
                    Image(systemName: "person.text.rectangle")
                        .symbolRenderingMode(.hierarchical)
                }
            }

            ToolbarItem(placement: .primaryAction) {
                NavigationLink(destination: ShirtSizeEditView(convention: convention)) {
                    Image(systemName: "tshirt")
                        .symbolRenderingMode(.hierarchical)
                }
            }

            ToolbarItem(placement: .primaryAction) {
                NavigationLink(destination: WebUserEditView(convention: convention)) {
                    Image(systemName: "person.3")
                        .symbolRenderingMode(.hierarchical)
                }
            }

            ToolbarItem(placement: .primaryAction) {
                NavigationLink(destination: APIKeyEditView(convention: convention)) {
                    Image(systemName: "key.radiowaves.forward")
                        .symbolRenderingMode(.hierarchical)
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {

                    logger.debug("Saving convention")

                    // Perform the save operation
                    saveConvention()
                }
            }

        }
        .alert("Save Successful", isPresented: $showSuccessAlert) {
            Button("Hooray 🎉", role: .cancel) {
                dismiss()
            }
        } message: {
            Text("Convention saved successfully!")
        }
    }


    private func saveConvention() {
        Task {
            let client = ConopsServerClient()

            // Turn this into a DTO to send over the wire
            let conventionDto = convention.toDTO()

            let saveResult = await client.updateConvention(conventionDto)
            switch saveResult {
            case .success(let conventionFromServer):
                logger.debug("convention has id \(conventionFromServer.id)")
                do {
                    context.insert(convention)
                    try context.save()
                    showSuccessAlert = true
                } catch {
                    logger.error("Failed to save convention to SwiftData: \(error)")
                    errorMessage = error.localizedDescription
                    showErrorAlert = true
                }
            case .failure(let error):
                logger.error("Failed to save convention to server: \(error)")
                errorMessage = error.localizedDescription
                showErrorAlert = true
            }
        }

    }


    /// Our base form that contains all the fields.
    private var baseForm: some View {
        Form {
            Section("Basic Info") {
                Toggle("Active", isOn: $convention.active)
                TextField("Long Name", text: $convention.longName)
                TextField("Short Name", text: $convention.shortName)
                    .autocorrectionDisabled(true)
                    #if os(iOS)
                        .textInputAutocapitalization(.never)
                    #endif
            }

            Section("Dates") {
                DatePicker("Start Date", selection: $convention.startDate, displayedComponents: .date)
                DatePicker("End Date", selection: $convention.endDate, displayedComponents: .date)
                DatePicker("Pre-Reg Start", selection: $convention.preRegStartDate, displayedComponents: .date)
                DatePicker("Pre-Reg End", selection: $convention.preRegEndDate, displayedComponents: .date)
            }

            Section("Registration") {
                Toggle("Registration Open", isOn: $convention.registrationOpen)
                TextField("Contact Email Address", text: $convention.contactEmailAddress)
                    .autocorrectionDisabled(true)
                    #if os(iOS)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                    #endif
                TextField("Min Badge Number", value: $convention.minBadgeNumber, format: .number)
            }
        }
        .textFieldStyle(.roundedBorder)
    }

}


#Preview(traits: .modifier(AttendeePreviewModifier())) {
    ConventionEditView(convention: .mock())
}
