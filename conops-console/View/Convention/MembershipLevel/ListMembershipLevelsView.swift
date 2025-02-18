//
//  MembershipLevelEditView.swift
//  Conops Console
//
//  Created by April White on 2/10/25.
//  Copyright © 2025 April's Creature Workshop. All rights reserved.
//

import Foundation
import OSLog
import SwiftData
import SwiftUI

/// I tried using a LazyVGrid here, but macOS kept getting stuck in a loop when showing the grid. I don't really care since this isn't viewed often, so I switched to a VStack

struct ListMembershipLevelsView: View {

    @Environment(\.modelContext) var context

    @State var convention: Convention

    @State private var showingNewLevelSheet = false
    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""

    @State private var showSuccessAlert: Bool = false

    private let logger = Logger(
        subsystem: "furry.enterprises.CreatureConsole",
        category: "MembershipLevelEditView"
    )

    var body: some View {

        ScrollView {
            if convention.membershipLevels.isEmpty {
                Text("No membership levels found.")
                    .font(.title3)
                    .foregroundColor(.secondary)
            } else {
                VStack {
                    ForEach(convention.membershipLevels) { level in
                        MembershipLevelItem(membershipLevel: level)
                            .padding()
                            .background(.secondary.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 100, alignment: .top)
                .padding()
            }
        }
        .navigationTitle("Membership Levels • \(convention.shortName)")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingNewLevelSheet = true
                } label: {
                    Image(systemName: "plus")
                }
                .symbolRenderingMode(.palette)
            }
        }
        .sheet(isPresented: $showingNewLevelSheet) {
            CreateNewMembershipLevelView { newMembershipLevel in
                Task {

                    convention.membershipLevels.append(newMembershipLevel)

                    // Update our UI and SwiftData context on the main actor via our async helper.
                    saveConvention()
                }
            }
        }
        .alert(isPresented: $showErrorAlert) {
            Alert(
                title: Text("‼️"),
                message: Text(errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }

    }


    // MARK: - Helper Function for Updating the Context
    // Marked as async so it can be awaited when called from outside the main actor.
    @MainActor
    private func saveConvention() {

        do {
            context.insert(convention)
            try context.save()
            showSuccessAlert = true
        } catch {
            logger.error("Failed to save convention to SwiftData: \(error)")
            errorMessage = error.localizedDescription
            showErrorAlert = true
        }

    }
}

#Preview(traits: .modifier(AttendeePreviewModifier())) {
    ListMembershipLevelsView(convention: .mock())
}
