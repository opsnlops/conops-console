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
    @State private var conventions: [Convention] = []
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
                        NavigationLink(value: convention.id) {
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
        } detail: {
            Text("hi")
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
                        conventions.append(convention)
                    case .failure(let error):
                        logger.error("Failed to save convention: \(error)")
                        errorMessage = error.localizedDescription
                        showErrorAlert = true
                    }
                }
            }
        }
        .task {
            let client = ConopsServerClient()
            logger.info("attempting to load conventions")
            let conventionFetchResult = await client.getAllConventions()

            switch conventionFetchResult {
            case .success(let dtos):
                // Map DTOs to Conventions on the main actor
                self.conventions = dtos.map { Convention.fromDTO($0) }
            case .failure(let error):
                logger.error("Failed to fetch conventions: \(error)")
                errorMessage = error.localizedDescription
                showErrorAlert = true
            }
        }
    }
}

#Preview {
    TopContentView()
}
