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
    @EnvironmentObject private var appState: AppState

    @Query(sort: \Convention.startDate, order: .reverse)
    private var conventions: [Convention]

    @State private var showingForm = false
    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""
    @State private var selectedRoute: SidebarRoute? = .dashboard

    @State private var eventStream = ConopsEventStream()
    @State private var isSyncing = false
    @State private var isShowingLogin = false
    @State private var hasStartedSession = false

    let logger = Logger(subsystem: "furry.enterprises.CreatureConsole", category: "TopContentView")

    var body: some View {

        NavigationSplitView {
            VStack {
                List(selection: $selectedRoute) {
                    Section("Navigation") {
                        NavigationLink(value: SidebarRoute.dashboard) {
                            Label("Dashboard", systemImage: "chart.bar.xaxis")
                        }

                        NavigationLink(value: SidebarRoute.attendees) {
                            Label("Attendees", systemImage: "person.3.fill")
                        }
                    }

                    Section("Controls") {
                        Button {
                            Task {
                                isSyncing = true
                                let syncResult = await performFullSync(forceFullSync: true)
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
                            Label("Force Full Sync", systemImage: "arrow.clockwise")
                        }

                        NavigationLink {
                            SettingsView()
                        } label: {
                            Label("Settings", systemImage: "gear")
                        }

                        Button {
                            Task {
                                let result = await MainActor.run {
                                    SessionManager.logout(context: context, logger: logger)
                                }
                                if case .failure(let error) = result {
                                    await MainActor.run {
                                        errorMessage = error.localizedDescription
                                        showErrorAlert = true
                                    }
                                }
                            }
                        } label: {
                            Label("Log Out", systemImage: "rectangle.portrait.and.arrow.right")
                        }
                    }
                }

                Spacer()

                HStack {
                    if isSyncing {
                        ProgressView()
                            .controlSize(.small)
                    }

                    Button {
                        showingForm = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .symbolRenderingMode(.multicolor)
                }
            }

        } detail: {
            switch selectedRoute {
            case .dashboard:
                if let convention = selectedConvention {
                    DashboardView(
                        conventionId: convention.id,
                        compareConventionId: convention.compareTo
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
            LoginView {
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
        .onDisappear {
            eventStream.stop()
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
            let preferredConvention = conventions.first(where: { $0.shortName == preferredShortName })
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
        let syncResult = await performFullSync()
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
                let result = await performFullSync()
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
