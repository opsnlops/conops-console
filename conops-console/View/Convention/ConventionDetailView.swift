//
//  ConventionDetailView.swift
//  Conops Console
//
//  Created by April White on 1/21/25.
//  Copyright © 2025 April's Creature Workshop. All rights reserved.
//

import Foundation
import OSLog
import SwiftData
import SwiftUI

struct ConventionDetailView: View {

    @Environment(\.modelContext) var context

    var convention: Convention

    @State private var showingRegisterSheet = false
    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""

    @State private var searchText: String = ""
    @State private var isShowingSearchPopover: Bool = false

    private let logger = Logger(
        subsystem: "furry.enterprises.CreatureConsole", category: "ConventionDetailView")

    var body: some View {

        VStack {
//            NavigationStack {
//                Text("Searching for \(searchText)")
//                    .navigationTitle("Searchable Example")
//            }
//            .searchable(text: $searchText)
            AttendeeTable()
        }
        .navigationTitle(convention.longName)
        .toolbar(id: "attendeeEditorToolbar") {

            ToolbarItem(id: "registerAttendee", placement: .primaryAction) {
                Button {
                    showingRegisterSheet = true
                } label: {
                    Image(systemName: "person.fill.badge.plus")
                }
                .symbolRenderingMode(.multicolor)
            }

            ToolbarItem(id: "searchAttendees", placement: .primaryAction) {
                Button {
                    isShowingSearchPopover.toggle()
                } label: {
                    Image(systemName: "magnifyingglass")
                }
                .symbolRenderingMode(.hierarchical)
                .popover(isPresented: $isShowingSearchPopover) {
                    VStack {
                        TextField("Search Attendees", text: $searchText)
                            .padding()
                            .frame(width: 320)
                    }

                }.textFieldStyle(.roundedBorder)
            }



        }
        .sheet(isPresented: $showingRegisterSheet) {
            RegisterNewAttendeeView { newAttendee in
                Task {
                    do {
                        newAttendee.convention = convention
                        logger.debug("Attendee saved: \(newAttendee)")
                        context.insert(newAttendee)
                        try context.save()
                    } catch {
                        logger.error("Failed to save convention to SwiftData: \(error)")
                        errorMessage = error.localizedDescription
                        showErrorAlert = true
                    }
                }
            }
        }
    }

}

#Preview {
    ConventionDetailView(convention: .mock())
}
