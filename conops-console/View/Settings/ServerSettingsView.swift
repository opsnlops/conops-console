//
//  ServerSettingsView.swift
//  conops-console
//
//  Created by April White on 1/4/25.
//  Copyright © 2025 April's Creature Workshop. All rights reserved.
//

import SwiftUI

struct ServerSettingsView: View {
    @StateObject private var viewModel = ServerSettingsViewModel()

    var body: some View {
        Form {
            Section(header: Text("Server Configuration")) {
                TextField("Hostname", text: $viewModel.hostname)
                    .disableAutocorrection(true)
                #if os(iOS)
                    .textInputAutocapitalization(.none)
                #endif

                TextField("Port", value: $viewModel.port, format: .number)

                Toggle("Use TLS", isOn: $viewModel.useTLS)
            }

            Section {
                Button(action: {
                    viewModel.resetToDefaults()
                }) {
                    Text("Reset to Defaults")
                        .foregroundColor(.red)
                }
            }
        }
        .navigationTitle("Server Settings")
        #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

struct ServerSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ServerSettingsView()
    }
}
