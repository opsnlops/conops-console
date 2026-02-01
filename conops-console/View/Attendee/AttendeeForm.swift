//
//  AttendeeBaseForm.swift
//  Conops Console
//
//  Created by April White on 1/24/25.
//  Copyright © 2026 April's Creature Workshop. All rights reserved.
//

import Foundation
import SwiftUI

struct AttendeeForm: View {
    @Binding var attendee: Attendee
    var membershipLevels: [MembershipLevel] = []
    var showTransactions: Bool = false
    var transactions: [Transaction] = []
    var pendingTransactions: [PendingTransaction] = []
    var currentBalance: Float = 0
    var onAddTransaction: (() -> Void)?

    var onSave: (() -> Void)?

    var body: some View {
        Form {
            Section(header: Text("Basic Info")) {
                TextField("Badge Name", text: $attendee.badgeName)
                    .autocorrectionDisabled(true)
                    #if os(iOS)
                        .textInputAutocapitalization(.never)
                    #endif
                TextField(
                    "Badge Number",
                    value: $attendee.badgeNumber,
                    formatter: NumberFormatter()
                )
                #if os(iOS)
                    .keyboardType(.numberPad)
                #endif
                TextField("First Name", text: $attendee.firstName)
                TextField("Last Name", text: $attendee.lastName)
                DatePicker("Birthday", selection: $attendee.birthday, displayedComponents: .date)
            }

            Section("Registration") {
                if membershipLevels.isEmpty {
                    Text("No membership levels available")
                        .foregroundStyle(.secondary)
                } else {
                    Picker("Membership Level", selection: $attendee.membershipLevel) {
                        ForEach(membershipLevels, id: \.id) { level in
                            Text(level.longName)
                                .tag(level.id)
                        }
                    }
                }
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
                    ForEach(AmericanState.allCases, id: \.rawValue) { state in
                        Text(state.displayName)
                            .tag(state.rawValue)
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

            if showTransactions {
                Section(header: transactionsHeader, footer: Text(transactionsFooterText)) {
                    if pendingTransactions.isEmpty == false {
                        ForEach(pendingTransactions) { pending in
                            pendingTransactionRow(pending)
                        }
                    }
                    if transactions.isEmpty {
                        Text("No transactions yet")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(sortedTransactions) { transaction in
                            transactionRow(transaction)
                        }
                    }
                }
            }
        }
        //.navigationTitle("Edit Attendee")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    onSave?()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        #if os(macOS)
            .padding()
        #endif
    }

    private var sortedTransactions: [Transaction] {
        transactions.sorted(by: >)
    }

    private var transactionsFooterText: String {
        let formatted = NumberFormatter.localizedString(
            from: NSNumber(value: currentBalance),
            number: .currency)
        if pendingTransactions.isEmpty {
            return "Total Balance: \(formatted)"
        }

        let pendingTotal = pendingTransactions.reduce(0) { $0 + $1.amount }
        let pendingFormatted = NumberFormatter.localizedString(
            from: NSNumber(value: pendingTotal),
            number: .currency)
        return "Total Balance: \(formatted) • Pending: \(pendingFormatted)"
    }

    private var transactionsHeader: some View {
        HStack {
            Text("Transactions")
            Spacer()
            if onAddTransaction != nil {
                Button("Add") {
                    onAddTransaction?()
                }
            }
        }
    }

    private func transactionRow(_ transaction: Transaction) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(transaction.typeDescription)
                    .font(.headline)
                Spacer()
                Text(transaction.amount, format: .currency(code: currencyCode))
                    .font(.headline)
            }
            Text(transaction.transactionTime.formatted(date: .abbreviated, time: .shortened))
                .font(.caption)
                .foregroundStyle(.secondary)
            if let userName = transaction.userName, userName.isEmpty == false {
                Text("User: \(userName)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            if let notes = transaction.notes, notes.isEmpty == false {
                Text(notes)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private func pendingTransactionRow(_ transaction: PendingTransaction) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(transaction.type.description)
                    .font(.headline)
                Spacer()
                Text(transaction.amount, format: .currency(code: currencyCode))
                    .font(.headline)
            }
            HStack(spacing: 8) {
                Text("Pending")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.orange.opacity(0.18))
                    .clipShape(Capsule())
                Text("Will be saved with attendee updates")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            if transaction.notes.isEmpty == false {
                Text(transaction.notes)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
        .listRowBackground(Color.orange.opacity(0.08))
    }

    private var currencyCode: String {
        Locale.current.currency?.identifier ?? "USD"
    }
}
