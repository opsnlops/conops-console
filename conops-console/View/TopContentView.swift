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

    @Environment(\.modelContext) var context

    @Query(sort: \Convention.startDate, order: .forward)
    private var conventions: [Convention]

    @State private var showingForm = false
    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""

    let logger = Logger(subsystem: "furry.enterprises.CreatureConsole", category: "TopContentView")

    var body: some View {
        NavigationSplitView {
            List {
                Section(
                    header: HStack {
                        Text("Conventions")
                            .font(.headline)
                        Spacer()
                        Button {
                            showingForm = true
                        } label: {
                            Image(systemName: "plus")
                        }
                        .buttonStyle(.borderless)
                    }
                ) {
                    ForEach(conventions) { convention in
                        NavigationLink(value: convention) {
                            Label(convention.shortName, systemImage: "pawprint.circle")
                        }
                    }
                }

                Section("Controls") {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Label("Settings", systemImage: "gear")
                    }
                }
            }
            .navigationDestination(for: Convention.self) { convention in
                createConventionDetailView(for: convention)
            }

        } detail: {
            Text(context.container.configurations.debugDescription)
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
        .task {


            let syncResult = await performFullSync()
            switch syncResult {
            case .success(let message):
                logger.debug("\(message)")
            case .failure(let error):
                logger.error("Failed to perform full sync: \(error)")
                errorMessage = error.localizedDescription
                showErrorAlert = true
            }

        }
    }

    func createConventionDetailView(for convention: Convention) -> some View {
        return AnyView(ConventionDetailView(convention: convention))

    }

    // Full Sync is in FullSync.swift

}

#Preview(traits: .modifier(ConventionPreviewModifier())) {
    TopContentView()
}
