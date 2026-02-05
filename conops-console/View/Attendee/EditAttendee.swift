//
//  EditAttendee.swift
//  Conops Console
//
//  Created by April White on 1/24/25.
//  Copyright © 2026 April's Creature Workshop. All rights reserved.
//

import Foundation
import OSLog
import SwiftData
import SwiftUI

#if os(iOS)
    import UIKit
#endif

struct EditAttendeeView: View {

    @Environment(\.modelContext) var context
    @Environment(\.dismiss) var dismiss
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @EnvironmentObject var appState: AppState

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

    // MARK: - Check-In State
    @State private var checkInPaymentAmount: String = ""
    @State private var checkInPaymentType: TransactionTypeOption = .creditCardIn
    @State private var checkInConsentFormPresent: Bool = false
    @State private var checkInPrintBadge: Bool = true
    @State private var isCheckingIn: Bool = false

    private var isPad: Bool {
        #if os(iOS)
            return UIDevice.current.userInterfaceIdiom == .pad
        #else
            return false
        #endif
    }

    private var useRemotePrinter: Bool {
        appState.serverConfig(for: convention.shortName)?.useRemotePrinter ?? false
    }

    let logger = Logger(
        subsystem: "furry.enterprises.CreatureConsole", category: "EditAttendeeView")

    private var checkInSectionView: AnyView {
        AnyView(
            CheckInSection(
                attendee: $attendee,
                convention: convention,
                membershipLevels: convention.membershipLevels,
                useRemotePrinter: useRemotePrinter,
                remotePrinters: remotePrinters,
                paymentAmount: $checkInPaymentAmount,
                paymentType: $checkInPaymentType,
                consentFormPresent: $checkInConsentFormPresent,
                printBadge: $checkInPrintBadge,
                selectedPrinter: $selectedPrinter,
                isCheckingIn: $isCheckingIn,
                onCheckIn: { performCheckIn() }
            )
        )
    }

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

                        if useRemotePrinter && !remotePrinters.isEmpty {
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
                    setupCheckInDefaults()
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        #if os(macOS)
            ScrollView {
                AttendeeForm(
                    attendee: $attendee,
                    convention: convention,
                    membershipLevels: convention.membershipLevels,
                    showTransactions: true,
                    transactions: attendee.transactions,
                    pendingTransactions: pendingTransactions,
                    currentBalance: attendee.currentBalance,
                    checkInSection: checkInSectionView,
                    onAddTransaction: {
                        showTransactionSheet = true
                    }
                ) {
                    showSaveSheet = true
                }
                .padding()
            }
        #else
            if isPad {
                twoColumnContent
            } else {
                AttendeeForm(
                    attendee: $attendee,
                    convention: convention,
                    membershipLevels: convention.membershipLevels,
                    showTransactions: true,
                    transactions: attendee.transactions,
                    pendingTransactions: pendingTransactions,
                    currentBalance: attendee.currentBalance,
                    checkInSection: checkInSectionView,
                    onAddTransaction: {
                        showTransactionSheet = true
                    }
                ) {
                    showSaveSheet = true
                }
            }
        #endif
    }

    #if os(iOS)
        @ViewBuilder
        private var twoColumnContent: some View {
            HStack(alignment: .top, spacing: 0) {
                // Left column
                Form {
                    CheckInSection(
                        attendee: $attendee,
                        convention: convention,
                        membershipLevels: convention.membershipLevels,
                        useRemotePrinter: useRemotePrinter,
                        remotePrinters: remotePrinters,
                        paymentAmount: $checkInPaymentAmount,
                        paymentType: $checkInPaymentType,
                        consentFormPresent: $checkInConsentFormPresent,
                        printBadge: $checkInPrintBadge,
                        selectedPrinter: $selectedPrinter,
                        isCheckingIn: $isCheckingIn,
                        onCheckIn: { performCheckIn() }
                    )

                    Section("Registration") {
                        if convention.membershipLevels.isEmpty {
                            Text("No membership levels available")
                                .foregroundStyle(.secondary)
                        } else {
                            Picker("Membership Level", selection: $attendee.membershipLevel) {
                                ForEach(convention.membershipLevels, id: \.id) { level in
                                    Text(level.longName)
                                        .tag(level.id)
                                }
                            }
                        }
                    }

                    Section("Communications") {
                        TextField("Email", text: $attendee.emailAddress)
                            .autocorrectionDisabled(true)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)

                        TextField(
                            "Emergency Contact",
                            text: Binding(
                                get: { attendee.emergencyContact ?? "" },
                                set: { attendee.emergencyContact = $0.isEmpty ? nil : $0 }
                            ))
                    }

                    Section("Meta") {
                        Toggle("Active", isOn: $attendee.active)
                        Toggle("Staff", isOn: $attendee.staff)
                        Toggle("Dealer", isOn: $attendee.dealer)
                    }

                    Section("Dates") {
                        LabeledContent("Registered") {
                            Text(attendee.registrationDate.formatted(using: convention).dateTime)
                        }
                        LabeledContent("Checked In") {
                            if let checkIn = attendee.checkInTime {
                                Text(checkIn.formatted(using: convention).dateTime)
                            } else {
                                Text("Not yet")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .formStyle(.grouped)

                // Right column
                Form {
                    Section(header: Text("Basic Info")) {
                        TextField("Badge Name", text: $attendee.badgeName)
                            .autocorrectionDisabled(true)
                            .textInputAutocapitalization(.never)
                        TextField(
                            "Badge Number",
                            value: $attendee.badgeNumber,
                            formatter: NumberFormatter()
                        )
                        .keyboardType(.numberPad)
                        TextField("First Name", text: $attendee.firstName)
                        TextField("Last Name", text: $attendee.lastName)
                        DatePicker(
                            "Birthday", selection: $attendee.birthday, displayedComponents: .date)
                    }

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
                            .keyboardType(.numbersAndPunctuation)
                    }

                    Section(header: transactionsHeader, footer: Text(transactionsFooterText)) {
                        if pendingTransactions.isEmpty == false {
                            ForEach(pendingTransactions) { pending in
                                pendingTransactionRow(pending)
                            }
                        }
                        if attendee.transactions.isEmpty {
                            Text("No transactions yet")
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(sortedTransactions) { transaction in
                                transactionRow(transaction)
                            }
                        }
                    }
                }
                .formStyle(.grouped)
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        showSaveSheet = true
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }

        private var sortedTransactions: [Transaction] {
            attendee.transactions.sorted(by: >)
        }

        private var transactionsFooterText: String {
            let formatted = NumberFormatter.localizedString(
                from: NSNumber(value: attendee.currentBalance),
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
                Button("Add") {
                    showTransactionSheet = true
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
                Text(transaction.transactionTime.formatted(using: convention).dateTime)
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
    #endif


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

    private func setupCheckInDefaults() {
        // Pre-fill payment amount with balance if > 0
        if attendee.currentBalance > 0 {
            checkInPaymentAmount = String(format: "%.2f", attendee.currentBalance)
        }
        // Default print badge based on membership level's prePrinted flag,
        // but only if remote printing is enabled on the server
        if !useRemotePrinter || remotePrinters.isEmpty {
            checkInPrintBadge = false
        } else if let level = convention.membershipLevels.first(where: {
            $0.id == attendee.membershipLevel
        }) {
            checkInPrintBadge = !level.prePrinted
        }
    }

    func performCheckIn() {
        guard !isCheckingIn else { return }
        isCheckingIn = true

        Task {
            let client = ConopsServerClient()

            // Step 1: Set checkInTime and save attendee with all current edits
            attendee.checkInTime = Date()
            let attendeeDTO = attendee.toDTO()

            let updateResult = await client.updateAttendee(
                attendeeDTO,
                conventionShortName: convention.shortName,
                reason: "Check-in",
                notifyAttendee: false)

            switch updateResult {
            case .success:
                break
            case .failure(let error):
                logger.error("Check-in failed to update attendee: \(error)")
                await MainActor.run {
                    attendee.checkInTime = nil
                    errorMessage = "Check-in failed: \(error.localizedDescription)"
                    activeAlert = .error
                    isCheckingIn = false
                }
                return
            }

            // Step 2: Create payment transaction if balance > 0
            if attendee.currentBalance > 0 {
                let formatter = NumberFormatter()
                formatter.numberStyle = .decimal
                formatter.locale = Locale.current
                if let amount = formatter.number(from: checkInPaymentAmount)?.floatValue, amount > 0
                {
                    let txnResult = await client.createTransaction(
                        conventionShortName: convention.shortName,
                        attendeeId: attendee.id,
                        amount: -amount,
                        type: checkInPaymentType,
                        notes: "Check-in payment")

                    if case .failure(let error) = txnResult {
                        logger.error("Check-in payment failed: \(error)")
                        await MainActor.run {
                            errorMessage =
                                "Checked in, but payment failed: \(error.localizedDescription)"
                            activeAlert = .error
                        }
                    }
                }
            }

            // Step 3: Print badge if toggled on and printer selected
            if checkInPrintBadge && selectedPrinter.isEmpty == false {
                let printResult = await client.printBadge(
                    conventionShortName: convention.shortName,
                    attendeeId: attendee.id,
                    printerName: selectedPrinter)

                if case .failure(let error) = printResult {
                    logger.error("Check-in badge print failed: \(error)")
                    await MainActor.run {
                        errorMessage =
                            "Checked in, but badge print failed: \(error.localizedDescription)"
                        activeAlert = .error
                    }
                }
            }

            // Step 4: Refresh attendee from server
            let refreshResult = await client.getAttendee(
                conventionShortName: convention.shortName,
                attendeeId: attendee.id)

            await MainActor.run {
                switch refreshResult {
                case .success(let refreshedDTO):
                    let refreshed = Attendee.fromDTO(refreshedDTO)
                    attendee.update(from: refreshed)
                    do {
                        try context.save()
                    } catch {
                        logger.error("Failed to save checked-in attendee to SwiftData: \(error)")
                    }
                case .failure(let error):
                    logger.error("Failed to refresh attendee after check-in: \(error)")
                }

                isCheckingIn = false

                #if os(iOS)
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                #endif

                dismiss()
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
                    .buttonStyle(.borderedProminent)
                    .disabled(saveReason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        #if os(iOS)
            .presentationDetents([.large])
        #endif
    }

    private var transactionSheet: some View {
        NavigationStack {
            Form {
                Section(header: Text("Transaction")) {
                    TextField("Amount", text: $transactionAmount)
                        #if os(iOS)
                            .keyboardType(.numbersAndPunctuation)
                        #endif
                        .onChange(of: transactionAmount) { _, newValue in
                            let filtered = newValue.filter { "0123456789.-".contains($0) }
                            if filtered != newValue {
                                transactionAmount = filtered
                            }
                        }

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
                    .buttonStyle(.borderedProminent)
                    .disabled(
                        parsedTransactionAmount() == nil
                            || transactionReason.trimmingCharacters(
                                in: .whitespacesAndNewlines
                            ).isEmpty)
                }
            }
        }
        #if os(iOS)
            .presentationDetents([.large])
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
                    .buttonStyle(.borderedProminent)
                    .disabled(selectedPrinter.isEmpty)
                }
            }
        }
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
        // Skip loading printers if remote printing is disabled in server config
        guard useRemotePrinter else { return }

        // Check cache first
        if let cached = appState.remotePrinters(for: convention.shortName) {
            await MainActor.run {
                remotePrinters = cached
                if selectedPrinter.isEmpty, let first = cached.first {
                    selectedPrinter = first
                }
            }
            return
        }

        let client = ConopsServerClient()
        let result = await client.getRemotePrinters(conventionShortName: convention.shortName)
        switch result {
        case .success(let printers):
            await MainActor.run {
                remotePrinters = printers
                appState.cacheRemotePrinters(printers, for: convention.shortName)
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
    .environmentObject(AppState())
}
