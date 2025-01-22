//
//  AttendeeTable.swift
//  Conops Console
//
//  Created by April White on 1/21/25.
//  Copyright © 2025 April's Creature Workshop. All rights reserved.
//

import Foundation
import OSLog
import SwiftData
import SwiftUI

struct AttendeeTable: View {

    @Environment(\.modelContext) var context

    @Query(sort: \Attendee.badgeName, order: .forward)
    private var attendees: [Attendee]

    @State private var showingForm = false
    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""

    let logger = Logger(subsystem: "furry.enterprises.CreatureConsole", category: "AttendeeTable")

    var body: some View {

        Table(attendees) {
            TableColumn("Badge Name", value: \.badgeName)
            TableColumn("First Name", value: \.firstName)
            TableColumn("Last Name", value: \.lastName)
        }

    }
}


#Preview(traits: .modifier(AttendeePreviewModifier())) {
    AttendeeTable()
}
