//
//  CheckInSection.swift
//  Conops Console
//
//  Created by April White on 2/4/26.
//  Copyright © 2026 April's Creature Workshop. All rights reserved.
//

import Foundation
import SwiftUI

struct CheckInSection: View {
    @Binding var attendee: Attendee
    let convention: Convention
    let membershipLevels: [MembershipLevel]
    let useRemotePrinter: Bool
    let remotePrinters: [String]

    @Binding var paymentAmount: String
    @Binding var paymentType: TransactionTypeOption
    @Binding var consentFormPresent: Bool
    @Binding var printBadge: Bool
    @Binding var selectedPrinter: String
    @Binding var isCheckingIn: Bool

    var onCheckIn: () -> Void

    private var attendeeMembershipLevel: MembershipLevel? {
        membershipLevels.first(where: { $0.id == attendee.membershipLevel })
    }

    private var hasBalance: Bool {
        attendee.currentBalance > 0
    }

    private var parsedPaymentAmount: Float? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale.current
        guard let number = formatter.number(from: paymentAmount) else {
            return nil
        }
        return number.floatValue
    }

    private var canCheckIn: Bool {
        if isCheckingIn { return false }
        if hasBalance {
            guard let amount = parsedPaymentAmount, amount > 0 else { return false }
        }
        if attendee.minor && !consentFormPresent { return false }
        return true
    }

    private static let paymentTypeOptions: [TransactionTypeOption] = [
        .cashIn, .creditCardIn, .payPalIn,
    ]

    var body: some View {
        if attendee.checkInTime != nil {
            alreadyCheckedInSection
        } else {
            checkInFormSection
        }
    }

    // MARK: - Already Checked In

    private var alreadyCheckedInSection: some View {
        Section {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .font(.title2)
                if let checkIn = attendee.checkInTime {
                    Text("Checked in at \(checkIn.formatted(using: convention).dateTime)")
                        .font(.headline)
                        .foregroundStyle(.green)
                }
                Spacer()
            }
            .padding(.vertical, 4)
        }
    }

    // MARK: - Check-In Form

    private var checkInFormSection: some View {
        Section(header: Text("Check In")) {
            // Identity verification
            VStack(alignment: .leading, spacing: 8) {
                Text("\(attendee.firstName) \(attendee.lastName)")
                    .font(.title2)
                    .fontWeight(.semibold)
                Text("Birthday: \(attendee.birthday.formatted(date: .long, time: .omitted))")
                    .font(.title3)
            }
            .padding(.vertical, 4)

            // Balance status
            if hasBalance {
                balancePaymentView
            } else {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("No balance due")
                        .foregroundStyle(.green)
                        .fontWeight(.medium)
                }
            }

            // Minor consent
            if attendee.minor {
                Toggle("Consent Form Present", isOn: $consentFormPresent)
            }

            // Badge printing (only when remote printing is enabled in server config)
            if useRemotePrinter && !remotePrinters.isEmpty {
                Toggle("Print Badge", isOn: $printBadge)
                if printBadge {
                    Picker("Printer", selection: $selectedPrinter) {
                        ForEach(remotePrinters, id: \.self) { printer in
                            Text(printer).tag(printer)
                        }
                    }
                }
            }

            // Check-in button
            Button(action: onCheckIn) {
                HStack {
                    if isCheckingIn {
                        ProgressView()
                            #if os(macOS)
                                .controlSize(.small)
                            #endif
                    }
                    Text(isCheckingIn ? "Checking In..." : "Check In")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
            .controlSize(.large)
            .disabled(!canCheckIn)
            .padding(.vertical, 4)
        }
    }

    // MARK: - Balance / Payment

    private var balancePaymentView: some View {
        Group {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
                let formatted = NumberFormatter.localizedString(
                    from: NSNumber(value: attendee.currentBalance),
                    number: .currency)
                Text("Balance due: \(formatted)")
                    .foregroundStyle(.orange)
                    .fontWeight(.medium)
            }

            TextField("Payment Amount", text: $paymentAmount)
                #if os(iOS)
                    .keyboardType(.decimalPad)
                #endif
                .onChange(of: paymentAmount) { _, newValue in
                    let filtered = newValue.filter { "0123456789.".contains($0) }
                    if filtered != newValue {
                        paymentAmount = filtered
                    }
                }

            Picker("Payment Type", selection: $paymentType) {
                ForEach(Self.paymentTypeOptions) { option in
                    Text(option.description).tag(option)
                }
            }
        }
    }
}

#Preview("Not Checked In") {
    @Previewable @State var attendee = Attendee.mock()
    @Previewable @State var paymentAmount = ""
    @Previewable @State var paymentType: TransactionTypeOption = .creditCardIn
    @Previewable @State var consent = false
    @Previewable @State var printBadge = true
    @Previewable @State var selectedPrinter = "Printer 1"
    @Previewable @State var isCheckingIn = false

    let convention = Convention.mock()

    Form {
        CheckInSection(
            attendee: $attendee,
            convention: convention,
            membershipLevels: convention.membershipLevels,
            useRemotePrinter: true,
            remotePrinters: ["Printer 1", "Printer 2"],
            paymentAmount: $paymentAmount,
            paymentType: $paymentType,
            consentFormPresent: $consent,
            printBadge: $printBadge,
            selectedPrinter: $selectedPrinter,
            isCheckingIn: $isCheckingIn,
            onCheckIn: {}
        )
    }
}
