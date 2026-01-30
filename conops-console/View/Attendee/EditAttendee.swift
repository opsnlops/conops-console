//
//  EditAttendee.swift
//  Conops Console
//
//  Created by April White on 1/24/25.
//  Copyright © 2025 April's Creature Workshop. All rights reserved.
//

import Foundation
import OSLog
import SwiftData
import SwiftUI

struct EditAttendeeView: View {

    @Environment(\.modelContext) var context
    @Environment(\.dismiss) var dismiss

    // MARK: - Props
    @State var attendee: Attendee
    var convention: Convention

    @State private var activeAlert: ActiveAlert?
    @State private var errorMessage: String = ""
    @State private var showSaveSheet = false
    @State private var saveReason = ""
    @State private var notifyAttendee = true
    @State private var showTransactionSheet = false
    @State private var transactionAmount = ""
    @State private var transactionType: TransactionTypeOption = .other
    @State private var transactionReason = ""
    @State private var pendingTransactions: [PendingTransaction] = []
    @State private var remotePrinters: [String] = []
    @State private var showPrintSheet = false
    @State private var selectedPrinter = ""
    @State private var showResendWelcomeConfirm = false
    @State private var showActionAlert = false
    @State private var actionMessage = ""


    let logger = Logger(
        subsystem: "furry.enterprises.CreatureConsole", category: "EditAttendeeView")

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Edit Attendee")
                .toolbar {
                    ToolbarItemGroup(placement: .primaryAction) {
                        Button {
                            showResendWelcomeConfirm = true
                        } label: {
                            Image(systemName: "envelope.badge")
                        }
                        .symbolRenderingMode(.hierarchical)
                        .help("Resend Welcome Message")

                        if remotePrinters.isEmpty == false {
                            Button {
                                presentPrintSheet()
                            } label: {
                                Image(systemName: "printer.dotmatrix")
                            }
                            .symbolRenderingMode(.hierarchical)
                            .help("Print Badge")
                        }
                    }
                }
                .toolbarRole(.editor)
                .alert(item: $activeAlert) { alert in
                    switch alert {
                    case .success:
                        return Alert(
                            title: Text("Save Successful"),
                            message: Text("Attendee saved successfully!"),
                            dismissButton: .default(
                                Text("Hooray 🎉"),
                                action: {
                                    dismiss()
                                })
                        )
                    case .error:
                        return Alert(
                            title: Text("Error"),
                            message: Text(errorMessage),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                }
                .sheet(isPresented: $showSaveSheet) {
                    saveSheet
                }
                .sheet(isPresented: $showTransactionSheet) {
                    transactionSheet
                }
                .sheet(isPresented: $showPrintSheet) {
                    printBadgeSheet
                }
                .confirmationDialog(
                    "Resend the welcome message?",
                    isPresented: $showResendWelcomeConfirm,
                    titleVisibility: .visible
                ) {
                    Button("Resend Welcome Message") {
                        resendWelcomeMessage()
                    }
                    Button("Cancel", role: .cancel) {}
                }
                .alert("Done", isPresented: $showActionAlert) {
                    Button("OK") {}
                } message: {
                    Text(actionMessage)
                }
                .task {
                    await loadRemotePrinters()
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        #if os(macOS)
            ScrollView {
                AttendeeForm(
                    attendee: $attendee,
                    membershipLevels: convention.membershipLevels,
                    showTransactions: true,
                    transactions: attendee.transactions,
                    pendingTransactions: pendingTransactions,
                    currentBalance: attendee.currentBalance,
                    onAddTransaction: {
                        showTransactionSheet = true
                    }
                ) {
                    showSaveSheet = true
                }
                .padding()
            }
        #else
            AttendeeForm(
                attendee: $attendee,
                membershipLevels: convention.membershipLevels,
                showTransactions: true,
                transactions: attendee.transactions,
                pendingTransactions: pendingTransactions,
                currentBalance: attendee.currentBalance,
                onAddTransaction: {
                    showTransactionSheet = true
                }
            ) {
                showSaveSheet = true
            }
        #endif
    }


    func saveAttendee(reason: String, notifyAttendee: Bool) {
        logger.debug("in saveAttendee")

        logger.debug("pre-save attendee id: \(attendee.id)")
        Task {
            let client = ConopsServerClient()
            let attendeeDTO = attendee.toDTO()

            let saveResult = await client.updateAttendee(
                attendeeDTO,
                conventionShortName: convention.shortName,
                reason: reason,
                notifyAttendee: false)
            switch saveResult {
            case .success:
                let transactionResult = await createPendingTransactions()
                if transactionResult == false {
                    return
                }

                var notifyFailedMessage: String? = nil
                if notifyAttendee {
                    let notifyResult = await client.notifyAttendeeUpdated(
                        conventionShortName: convention.shortName,
                        attendeeId: attendee.id,
                        reason: reason)
                    if case .failure(let error) = notifyResult {
                        notifyFailedMessage = error.localizedDescription
                        logger.error("Failed to send attendee update email: \(error)")
                    }
                }

                let refreshResult = await client.getAttendee(
                    conventionShortName: convention.shortName,
                    attendeeId: attendee.id)
                switch refreshResult {
                case .success(let refreshedDTO):
                    let refreshed = Attendee.fromDTO(refreshedDTO)
                    await MainActor.run {
                        attendee.update(from: refreshed)
                        do {
                            try context.save()
                            saveReason = ""
                            self.notifyAttendee = true
                            if let notifyFailedMessage {
                                errorMessage = notifyFailedMessage
                                activeAlert = .error
                            } else {
                                activeAlert = .success
                            }
                        } catch {
                            logger.error("Failed to save attendee to SwiftData: \(error)")
                            errorMessage = error.localizedDescription
                            activeAlert = .error
                        }
                    }
                case .failure(let error):
                    logger.error("Failed to refresh attendee after save: \(error)")
                    await MainActor.run {
                        errorMessage = error.localizedDescription
                        activeAlert = .error
                    }
                }
            case .failure(let error):
                logger.error("Failed to save attendee to server: \(error)")
                errorMessage = error.localizedDescription
                activeAlert = .error
            }
        }
    }

    private var saveSheet: some View {
        NavigationStack {
            Form {
                Section(header: Text("Reason")) {
                    TextEditor(text: $saveReason)
                        .frame(minHeight: 120)
                }

                Section {
                    Toggle("Notify Attendee", isOn: $notifyAttendee)
                }
            }
            .navigationTitle("Confirm Save")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showSaveSheet = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let trimmedReason = saveReason.trimmingCharacters(
                            in: .whitespacesAndNewlines)
                        guard !trimmedReason.isEmpty else { return }
                        showSaveSheet = false
                        saveAttendee(reason: trimmedReason, notifyAttendee: notifyAttendee)
                    }
                    .disabled(saveReason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .presentationBackground(.thinMaterial)
        #if os(iOS)
            .presentationDetents([.medium])
        #endif
    }

    private var transactionSheet: some View {
        NavigationStack {
            Form {
                Section(header: Text("Transaction")) {
                    TextField("Amount", text: $transactionAmount)
                        #if os(iOS)
                            .keyboardType(.decimalPad)
                        #endif

                    Picker("Type", selection: $transactionType) {
                        ForEach(TransactionTypeOption.allCases) { option in
                            Text(option.description).tag(option)
                        }
                    }
                }

                Section(header: Text("Reason")) {
                    TextField("Reason", text: $transactionReason)
                }
            }
            .navigationTitle("Add Transaction")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showTransactionSheet = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let trimmedReason = transactionReason.trimmingCharacters(
                            in: .whitespacesAndNewlines)
                        guard let amount = parsedTransactionAmount(), amount != 0 else {
                            errorMessage = "Enter a non-zero amount."
                            activeAlert = .error
                            return
                        }
                        guard trimmedReason.isEmpty == false else {
                            errorMessage = "Enter a reason for this transaction."
                            activeAlert = .error
                            return
                        }
                        showTransactionSheet = false
                        let pending = PendingTransaction(
                            amount: amount,
                            type: transactionType,
                            notes: trimmedReason)
                        pendingTransactions.append(pending)
                        transactionAmount = ""
                        transactionReason = ""
                        transactionType = .other
                    }
                    .disabled(parsedTransactionAmount() == nil || transactionReason.trimmingCharacters(
                        in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .presentationBackground(.thinMaterial)
        #if os(iOS)
            .presentationDetents([.medium])
        #endif
    }

    private var printBadgeSheet: some View {
        NavigationStack {
            Form {
                Section(header: Text("Printer")) {
                    Picker("Printer", selection: $selectedPrinter) {
                        ForEach(remotePrinters, id: \.self) { printer in
                            Text(printer).tag(printer)
                        }
                    }
                }
            }
            .navigationTitle("Print Badge")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showPrintSheet = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Print") {
                        guard selectedPrinter.isEmpty == false else { return }
                        showPrintSheet = false
                        printBadge(printerName: selectedPrinter)
                    }
                    .disabled(selectedPrinter.isEmpty)
                }
            }
        }
        .presentationBackground(.thinMaterial)
        #if os(iOS)
            .presentationDetents([.medium])
        #endif
    }

    private func parsedTransactionAmount() -> Float? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale.current
        guard let number = formatter.number(from: transactionAmount) else {
            return nil
        }
        return number.floatValue
    }

    private func createPendingTransactions() async -> Bool {
        let pendingSnapshot = pendingTransactions
        guard pendingSnapshot.isEmpty == false else {
            return true
        }

        let client = ConopsServerClient()
        for pending in pendingSnapshot {
            let result = await client.createTransaction(
                conventionShortName: convention.shortName,
                attendeeId: attendee.id,
                amount: pending.amount,
                type: pending.type,
                notes: pending.notes)

            switch result {
            case .success:
                await MainActor.run {
                    pendingTransactions.removeAll { $0.id == pending.id }
                }
            case .failure(let error):
                logger.error("Failed to create transaction: \(error)")
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    activeAlert = .error
                }
                return false
            }
        }

        return true
    }

    private func loadRemotePrinters() async {
        let client = ConopsServerClient()
        let result = await client.getRemotePrinters(conventionShortName: convention.shortName)
        switch result {
        case .success(let printers):
            await MainActor.run {
                remotePrinters = printers
                if selectedPrinter.isEmpty, let first = printers.first {
                    selectedPrinter = first
                }
            }
        case .failure(let error):
            logger.error("Failed to load remote printers: \(error)")
        }
    }

    private func presentPrintSheet() {
        if selectedPrinter.isEmpty, let first = remotePrinters.first {
            selectedPrinter = first
        }
        showPrintSheet = true
    }

    private func printBadge(printerName: String) {
        Task {
            let client = ConopsServerClient()
            let result = await client.printBadge(
                conventionShortName: convention.shortName,
                attendeeId: attendee.id,
                printerName: printerName)

            switch result {
            case .success:
                await MainActor.run {
                    actionMessage = "Badge print request made."
                    showActionAlert = true
                }
            case .failure(let error):
                logger.error("Failed to print badge: \(error)")
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    activeAlert = .error
                }
            }
        }
    }

    private func resendWelcomeMessage() {
        Task {
            let client = ConopsServerClient()
            let result = await client.resendWelcomeMessage(
                conventionShortName: convention.shortName,
                attendeeId: attendee.id)

            switch result {
            case .success:
                await MainActor.run {
                    actionMessage = "Welcome message sent."
                    showActionAlert = true
                }
            case .failure(let error):
                logger.error("Failed to resend welcome message: \(error)")
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    activeAlert = .error
                }
            }
        }
    }


    // MARK: - Helper Function for Updating the Context
    // Marked as async so it can be awaited when called from outside the main actor.
    @MainActor
    private func updateContext(with result: Result<AttendeeDTO, ServerError>, newAttendee: Attendee)
        async
    {
        logger.debug("in updateContext")
        switch result {
        case .success:
            // Assign convention and update the local model.
            newAttendee.conventionId = convention.id
            context.insert(newAttendee)
            do {
                try context.save()
                logger.debug("Successfully saved attendee")
            } catch {
                logger.error("Failed to save attendee locally: \(error)")
                errorMessage = error.localizedDescription
                activeAlert = .error
            }
        case .failure(let error):
            logger.error("Server update failed: \(error)")
            errorMessage = error.localizedDescription
            activeAlert = .error
        }
    }
}

#Preview {
    @Previewable @State var sampleAttendee = Attendee.mock()
    return NavigationStack {
        EditAttendeeView(attendee: sampleAttendee, convention: .mock())
    }
}
