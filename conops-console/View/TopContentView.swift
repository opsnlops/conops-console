//
//  ContentView.swift
//  conops-console
//
//  Created by April White on 1/4/25.
//

import OSLog
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
                Section("Conventions") {
                    ForEach(conventions) { convention in
                        NavigationLink(value: convention.id) {
                            Label(convention.shortName, systemImage: "pawprint.circle")
                        }
                    }
                } // End convention section

                Section("Controls") {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Label("Settings", systemImage: "gear")
                    }
                } // end controls section
            }
        } detail: {
            Text("hi")
        }
        .alert(isPresented: $showErrorAlert) {
            Alert(
                title: Text("Oooooh Shit"),
                message: Text(errorMessage),
                dismissButton: .default(Text("Fuck"))
            )
        }
        .task {

            // TODO: Debugging code
            do {
                let emptyData = try JSONDecoder().decode([Convention].self, from: "[]".data(using: .utf8)!)
                logger.debug("Successfully decoded empty array: \(emptyData)")
            } catch {
                logger.error("Failed to decode empty array: \(error.localizedDescription)")
            }


            let client = ConopsServerClient()

            logger.info("attempting to load conventions")
            let conventionFetchResult = await client.getAllConventions()

            switch conventionFetchResult {
            case .success(let convention):
                self.conventions = convention;
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
