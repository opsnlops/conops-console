//
//  MembershipLevelDetailView.swift
//  Conops Console
//
//  Created by April White on 2/17/25.
//  Copyright © 2026 April's Creature Workshop. All rights reserved.
//

import SwiftUI

public struct MembershipLevelDetailView: View {

    @Binding var membershipLevel: MembershipLevel

    // MARK: - Props
    var onMembershipLevelSave: (MembershipLevel) -> Void
    @Environment(\.dismiss) private var dismiss

    public var body: some View {
        NavigationStack {
            #if os(macOS)
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
    let mockMembershipLevel = MembershipLevel.mock()
    return MembershipLevelDetailView(
        membershipLevel: .constant(mockMembershipLevel), onMembershipLevelSave: { _ in })
}
