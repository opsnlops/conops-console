//
//  EditAttendee.swift
//  Conops Console
//
//  Created by April White on 1/24/25.
//  Copyright © 2025 April's Creature Workshop. All rights reserved.
//

import SwiftUI

struct EditAttendeeView: View {

    // MARK: - Props
    @Binding var attendee: Attendee

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Edit Attendee")
                .toolbar(id: "editAttendeeToolbar", content: {

                    ToolbarItem(id: "printRegSlip", placement: .secondaryAction) {
                        Button {
                            // Do the thing
                        } label: {
                            Image(systemName: "printer.dotmatrix")
                        }
                        .symbolRenderingMode(.hierarchical)
                    }

                    ToolbarItem(id: "ban", placement: .secondaryAction) {
                        Button {
                            // Do the thing
                        } label: {
                            Image(systemName: "hammer")
                        }
                        .symbolRenderingMode(.hierarchical)
                    }

                    ToolbarItem(id: "checkInAttendee", placement: .secondaryAction) {
                        Button {
                            // Do the checkin
                        } label: {
                            Image(systemName: "person.fill.checkmark")
                        }
                        .symbolRenderingMode(.hierarchical)
                    }
                }).toolbarRole(.editor)
        }
    }

    @ViewBuilder
    private var content: some View {
#if os(macOS)
        ScrollView {
            AttendeeForm(attendee: $attendee) {
                // Save action
                // Pop the view by using the back navigation gesture or back button
            }.padding()
        }
#else
        AttendeeForm(attendee: $attendee) {
            // Save action
            // Pop the view by using the back navigation gesture or back button
        }
#endif
    }
}

#Preview {
    @Previewable @State var sampleAttendee = Attendee.mock()

    return NavigationStack {
        EditAttendeeView(attendee: $sampleAttendee)
    }
}
