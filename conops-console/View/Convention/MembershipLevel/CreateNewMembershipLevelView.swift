//
//  CreateNewMembershipLevelView.swift
//  Conops Console
//
//  Created by April White on 2/17/25.
//  Copyright © 2025 April's Creature Workshop. All rights reserved.
//

import SwiftUI

struct CreateNewMembershipLevelView: View {
    // MARK: - Props
    var onMembershipLevelSave: (MembershipLevel) -> Void
    @Environment(\.dismiss) private var dismiss


    // MARK: - State

    // Create a blank membership level to feed into the form

    @State private var membershipLevel = MembershipLevel(
        id: MembershipLevelIdentifier(),
        longName: "",
        shortName: "",
        price: 50.0,
        showOnWeb: true,
        prePrinted: false,
        shirtIncluded: true
    )

    var body: some View {
        NavigationStack {
            #if os(macOS)
                // Wrap the ScrollView in a VStack so that the navigationTitle can be attached to the VStack
                VStack {
                    ScrollView {
                        MemshipLevelForm(membershipLevel: $membershipLevel) {
                            onMembershipLevelSave(membershipLevel)
                            dismiss()
                        }
                    }
                }
            #else
                MemshipLevelForm(membershipLevel: $membershipLevel) {
                    onMembershipLevelSave(membershipLevel)
                    dismiss()
                }
            #endif
        }
        .navigationTitle("Create new Membership Level")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
        #if os(iOS)
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        #endif
    }


}


#Preview {
    CreateNewMembershipLevelView(onMembershipLevelSave: { _ in })
}
