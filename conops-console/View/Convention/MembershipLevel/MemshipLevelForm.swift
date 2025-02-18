//
//  MemshipLevelForm.swift
//  Conops Console
//
//  Created by April White on 2/17/25.
//  Copyright © 2025 April's Creature Workshop. All rights reserved.
//

import Foundation
import SwiftUI

struct MemshipLevelForm: View {
    @Binding var membershipLevel: MembershipLevel

    var onSave: (() -> Void)?

    var body: some View {
        Form {
            Section(header: Text("Name")) {
                TextField("Long Name", text: $membershipLevel.longName)
                TextField("Short Name", text: $membershipLevel.shortName)
                    .autocorrectionDisabled(true)
                    #if os(iOS)
                        .textInputAutocapitalization(.never)
                    #endif
            }

            Section(header: Text("Price")) {
                TextField("Price", value: $membershipLevel.price, format: .currency(code: "USD"))
                    #if os(iOS)
                        .keyboardType(.numbersAndPunctuation)
                    #endif
            }

            Section("Metadata") {
                Toggle("Show on Web", isOn: $membershipLevel.showOnWeb)
                Toggle("Pre-Printed", isOn: $membershipLevel.prePrinted)
                Toggle("Shirt Included", isOn: $membershipLevel.shirtIncluded)
            }
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    onSave?()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        #if os(macOS)
            .padding()
        #endif
    }
}


#Preview {
    let dummyLevel = MembershipLevel.mock()
    return MemshipLevelForm(membershipLevel: .constant(dummyLevel))
}
