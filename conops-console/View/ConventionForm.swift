//
//  ConventionForm.swift
//  conops-console
//
//  Created by April White on 1/4/25.
//  Copyright © 2025 April's Creature Workshop. All rights reserved.
//

import SwiftUI

struct ConventionFormView: View {
    @StateObject private var viewModel = ConventionFormViewModel()
    @Environment(\.dismiss) private var dismiss

    var onSave: (Convention) -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    Form {
                        Section(header: Text("Basic Information")) {
                            TextField("Long Name", text: $viewModel.longName)
                            TextField("Short Name", text: $viewModel.shortName)
                        }

                        Section(header: Text("Dates")) {
                            DatePicker("Start Date", selection: $viewModel.startDate, displayedComponents: .date)
                            DatePicker("End Date", selection: $viewModel.endDate, displayedComponents: .date)
                            DatePicker("Pre-Reg Start Date", selection: $viewModel.preRegStartDate, displayedComponents: .date)
                            DatePicker("Pre-Reg End Date", selection: $viewModel.preRegEndDate, displayedComponents: .date)
                        }

                        Section(header: Text("Registration")) {
                            Toggle("Registration Open", isOn: $viewModel.registrationOpen)
                        }

                        Section(header: Text("Contact Information")) {
                            TextField("Contact Email", text: $viewModel.contactEmailAddress)
                        }

                        Section(header: Text("Dealer's Den")) {
                            Toggle("Present", isOn: $viewModel.dealersDenPresent)
                        }

                        Section(header: Text("Badge Numbers")) {
                            TextField("Minimum Badge Number", value: $viewModel.minBadgeNumber, formatter: NumberFormatter())
                        }

                        Section(header: Text("Mail Templates")) {
                            ForEach(Array(viewModel.mailTemplates.keys), id: \.self) { key in
                                HStack {
                                    Text(key)
                                    Spacer()
                                    TextField("Template", text: Binding(
                                        get: { viewModel.mailTemplates[key] ?? "" },
                                        set: { viewModel.mailTemplates[key] = $0 }
                                    ))
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("New Convention")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let convention = viewModel.toConvention()
                        onSave(convention)
                        dismiss()
                    }
                    .disabled(viewModel.longName.isEmpty || viewModel.shortName.isEmpty)
                }
            }
        }
    }
}
