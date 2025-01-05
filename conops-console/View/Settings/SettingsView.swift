//
//  SettingsView.swift
//  conops-console
//
//  Created by April White on 1/4/25.
//  Copyright © 2025 April's Creature Workshop. All rights reserved.
//

import Foundation
import SwiftUI

struct SettingsView: View {
    private enum Tabs: Hashable {
        case network, advanced
    }
    var body: some View {
        TabView {
            ServerSettingsView()
                .tabItem {
                    Label("Server", systemImage: "network")
                }
                .tag(Tabs.network)
//            InterfaceSettings()
//                .tabItem {
//                    Label("Interface", systemImage: "paintpalette")
//                }
//                .tag(Tabs.interface)
//            AdvancedSettingsView()
//                .tabItem {
//                    Label("Advanced", systemImage: "wand.and.stars")
//                }
//                .tag(Tabs.advanced)
        }
        .padding(20)
        .navigationTitle("Settings")
        #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
        #endif
        #if os(macOS)
            .frame(width: 600, height: 400)
        #endif
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
