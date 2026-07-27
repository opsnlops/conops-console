//
//  ContentView.swift
//  conops-console
//
//  Created by April White on 1/4/25.
//

import OSLog
import SwiftData
import SwiftUI

struct TopContentView: View {

    enum SidebarRoute: Hashable {
        case dashboard
        case attendees
    }

    @Environment(\.modelContext) var context
    @EnvironmentObject var appState: AppState

    @Query(sort: \Convention.startDate, order: .reverse)
    private var conventions: [Convention]

    @State private var showingForm = false
    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""
    @State private var selectedRoute: SidebarRoute? = .dashboard

    @State private var eventStream = ConopsEventStream()
    @State private var isSyncing = false
    @State private var isShowingLogin = false
    @State private var loginNotice: String?
    @State private var hasStartedSession = false

    let logger = Logger(subsystem: "furry.enterprises.CreatureConsole", category: "TopContentView")

    var body: some View {

        NavigationSplitView {
            VStack(spacing: 0) {
                List(selection: $selectedRoute) {
                    NavigationLink(value: SidebarRoute.dashboard) {
                        Label("Dashboard", systemImage: "chart.bar.xaxis")
                    }

                    NavigationLink(value: SidebarRoute.attendees) {
                        Label("Attendees", systemImage: "person.3.fill")
                    }

                    #if os(iOS)
                        Section {
                            Button {
                                showingForm = true
                            } label: {
                                Label("Add Convention", systemImage: "plus")
                            }

                            Button {
                                Task {
                                    isSyncing = true
                                    let syncResult = await performSync(forceFullSync: true)
                                    isSyncing = false
                                    switch syncResult {
                                    case .success(let message):
                                        logger.debug("\(message)")
                                    case .failure(let error):
                                        logger.error("Failed to perform full sync: \(error)")
                                        errorMessage = error.localizedDescription
                                        showErrorAlert = true
                                    }
                                }
                            } label: {
                                HStack {
                                    Label("Force Full Sync", systemImage: "arrow.clockwise")
                                    if isSyncing {
                                        Spacer()
                                        ProgressView()
                                    }
                                }
                            }
                            .disabled(isSyncing)

                            NavigationLink {
                                SettingsView()
                            } label: {
                                Label("Settings", systemImage: "gear")
                            }

                            Button(role: .destructive) {
                                performLogout()
                            } label: {
                                Label("Log Out", systemImage: "rectangle.portrait.and.arrow.right")
                            }
                        }
                    #endif
                }
                #if os(macOS)
                    .listStyle(.sidebar)
                #endif

                #if os(macOS)
                    Divider()
                    HStack(spacing: 12) {
                        Button {
                            showingForm = true
                        } label: {
                            Image(systemName: "plus")
                        }
                        .buttonStyle(.borderless)
                        .help("Add Convention")

                        Button {
                            Task {
                                isSyncing = true
                                let syncResult = await performSync(forceFullSync: true)
                                isSyncing = false
                                switch syncResult {
                                case .success(let message):
                                    logger.debug("\(message)")
                                case .failure(let error):
                                    logger.error("Failed to perform full sync: \(error)")
                                    errorMessage = error.localizedDescription
                                    showErrorAlert = true
                                }
                            }
                        } label: {
                            if isSyncing {
                                ProgressView()
                                    .controlSize(.small)
                            } else {
                                Image(systemName: "arrow.clockwise")
                            }
                        }
                        .buttonStyle(.borderless)
                        .help("Force Full Sync")
                        .disabled(isSyncing)

                        Spacer()

                        Button {
                            performLogout()
                        } label: {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                        }
                        .buttonStyle(.borderless)
                        .help("Log Out")
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                #endif
            }
            .navigationTitle(selectedConvention.map { "\($0.shortName) Conops" } ?? "Conops")

        } detail: {
            switch selectedRoute {
            case .dashboard:
                if let convention = selectedConvention {
                    DashboardView(
                        conventionId: convention.id,
                        compareConventionId: convention.compareTo,
                        onNavigateToAttendees: { selectedRoute = .attendees }
                    )
                    .id("dashboard-\(convention.id)")
                } else {
                    Text("Select a convention to see the dashboard 🥕")
                        .padding()
                }
            case .attendees:
                if let convention = selectedConvention {
                    ConventionDetailView(convention: convention)
                        .id(convention.id)
                } else {
                    Text("Select a convention to see details 🥕")
                        .padding()
                }
            case .none:
                Text("Select a destination")
                    .padding()
            }
        }
        .onChange(of: conventions) { _, newValue in
            appState.conventions = newValue
            applyConventionSelection(from: newValue)
        }
        .alert(isPresented: $showErrorAlert) {
            Alert(
                title: Text("Whoa, Shit!"),
                message: Text(errorMessage),
                dismissButton: .default(Text("Fuck"))
            )
        }
        .sheet(isPresented: $showingForm) {
            AddConventionView { newConvention in
                Task {
                    let client = ConopsServerClient()
                    let saveResult = await client.createNewConvention(newConvention)
                    switch saveResult {
                    case .success(let dto):
                        logger.debug("new convention has id \(dto.id)")
                        let convention = Convention.fromDTO(dto)
                        do {
                            context.insert(convention)
                            try context.save()
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
        }
        .sheet(isPresented: $isShowingLogin) {
            // Not cancellable: this sheet only appears when there is no usable
            // session, so there is nothing to go back to. Logout and expiry both
            // clear the cache before presenting it.
            LoginView(canCancel: false, notice: loginNotice) {
                // On successful authentication
                loginNotice = nil
                Task {
                    await startSession()
                }
            }
        }
        .task {
            if !AuthStore.shared.hasToken {
                isShowingLogin = true
                return
            }

            await startSession()
        }
        .onAppear {
            appState.conventions = conventions
            appState.performSync = { [self] in await performSync() }
            applyConventionSelection(from: conventions)
        }
        .onReceive(NotificationCenter.default.publisher(for: .authDidLogout)) { _ in
            Task {
                await MainActor.run {
                    eventStream.stop()
                    hasStartedSession = false
                    isSyncing = false
                    isShowingLogin = true
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .authSessionExpired)) { _ in
            // Server rejected our token. Clear local data so the next user can't
            // browse it, then drop the user at the login screen.
            //
            // NotificationCenter delivers on the posting thread, and API 401s
            // are posted from a URLSession continuation. Hop to the main actor
            // before touching SwiftData or view state. Hopping also serializes
            // these handlers, which is what makes the re-entry guard below
            // reliable when several in-flight requests all return 401 at once.
            Task {
                await MainActor.run {
                    guard AuthStore.shared.hasToken else { return }
                    logger.warning("Session expired; clearing local data and forcing re-login")
                    eventStream.stop()
                    // Shown inside the login sheet rather than as an alert. The
                    // sheet is presented in the same turn by the .authDidLogout
                    // handler, and a simultaneous alert would leave one of the
                    // two unpresented.
                    loginNotice = "Your session has expired. Please log in again."
                    let result = SessionManager.logout(
                        context: context,
                        appState: appState,
                        logger: logger,
                        sessionIsValid: false
                    )
                    if case .failure(let error) = result {
                        logger.error("Failed to clear cache after session expiry: \(error)")
                    }
                }
            }
        }
        .onDisappear {
            eventStream.stop()
        }
    }

    /// Ends the session for real: clears the keychain token, the local cache,
    /// the event stream, and the push registration.
    ///
    /// This used to just set `isShowingLogin`, which meant the token and the
    /// cached attendee data survived until the user finished re-authenticating
    /// — and survived indefinitely if they cancelled. `SessionManager.logout`
    /// posts `.authDidLogout`, and the observer above presents the login sheet,
    /// so the same path serves this button and the one in Server Settings.
    private func performLogout() {
        logger.info("User requested logout")
        let result = SessionManager.logout(context: context, appState: appState, logger: logger)
        if case .failure(let error) = result {
            // Reported through the login sheet rather than an alert, which would
            // compete with the sheet the .authDidLogout observer is presenting.
            logger.error("Logout failed to clear local cache: \(error)")
            loginNotice =
                "Logged out, but clearing local data failed: \(error.localizedDescription)"
        }
    }

    private var selectedConvention: Convention? {
        guard let selectedId = appState.selectedConventionId else {
            return nil
        }
        return conventions.first { $0.id == selectedId }
    }

    private func applyConventionSelection(from conventions: [Convention]) {
        guard !conventions.isEmpty else {
            appState.selectedConventionId = nil
            return
        }

        if let selectedId = appState.selectedConventionId,
            conventions.contains(where: { $0.id == selectedId })
        {
            return
        }

        let preferredShortName = UserDefaults.standard.lastAuthConvention
        if !preferredShortName.isEmpty,
            let preferredConvention = conventions.first(where: {
                $0.shortName == preferredShortName
            })
        {
            appState.selectedConventionId = preferredConvention.id
            return
        }

        appState.selectedConventionId = conventions.first?.id
    }

    func startSession() async {
        let alreadyStarted = await MainActor.run {
            if hasStartedSession {
                return true
            }
            hasStartedSession = true
            return false
        }

        if alreadyStarted {
            return
        }

        await MainActor.run {
            isSyncing = true
        }
        let syncResult = await performSync()
        await MainActor.run {
            isSyncing = false
        }

        switch syncResult {
        case .success(let message):
            logger.debug("\(message)")
        case .failure(let error):
            logger.error("Failed to perform full sync: \(error)")
            await MainActor.run {
                errorMessage = error.localizedDescription
                showErrorAlert = true
            }
        }

        logger.debug("Starting SSE after initial sync")
        eventStream.onEvent = { _ in
            logger.info("SSE event received; starting incremental sync")
            Task {
                await MainActor.run {
                    isSyncing = true
                }
                let result = await performSync()
                await MainActor.run {
                    isSyncing = false
                }
                if case .failure(let error) = result {
                    logger.error("Incremental sync failed: \(error)")
                }
            }
        }
        eventStream.start()
    }

    // Full Sync is in FullSync.swift

}

#Preview(traits: .modifier(ConventionPreviewModifier())) {
    TopContentView()
        .environmentObject(AppState())
}
