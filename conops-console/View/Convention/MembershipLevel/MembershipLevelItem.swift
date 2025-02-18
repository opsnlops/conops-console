//
//  MembershipLevelItem.swift
//  Conops Console
//
//  Created by April White on 2/17/25.
//  Copyright © 2025 April's Creature Workshop. All rights reserved.
//

import Foundation
import OSLog
import SwiftData
import SwiftUI

struct MembershipLevelItem: View {

    var membershipLevel: MembershipLevel

    var body: some View {
        Grid {
            GridRow {
                Text("Long Name")
                    .fontWeight(.bold)
                    .gridColumnAlignment(.trailing)
                Text(membershipLevel.longName)
                    .gridColumnAlignment(.leading)

            }
            GridRow {
                Text("Short Name")
                    .fontWeight(.bold)
                    .gridColumnAlignment(.trailing)
                Text(membershipLevel.shortName)
                    .gridColumnAlignment(.leading)
            }
            GridRow {
                Text("Price")
                    .fontWeight(.bold)
                    .gridColumnAlignment(.trailing)
                Text(membershipLevel.price, format: .currency(code: "USD"))
                    .gridColumnAlignment(.leading)
            }
            GridRow {
                Text("Show on Web")
                    .fontWeight(.bold)
                    .gridColumnAlignment(.trailing)
                Text(membershipLevel.showOnWeb ? "✅" : "🚫")
                    .gridColumnAlignment(.leading)
            }
            GridRow {
                Text("Shirt Included")
                    .fontWeight(.bold)
                    .gridColumnAlignment(.trailing)
                Text(membershipLevel.shirtIncluded ? "✅" : "🚫")
                    .gridColumnAlignment(.leading)
            }
            GridRow {
                Text("Pre-Printed")
                    .fontWeight(.bold)
                    .gridColumnAlignment(.trailing)
                Text(membershipLevel.prePrinted ? "✅" : "🚫")
                    .gridColumnAlignment(.leading)
            }
        }
    }

}

#Preview {
    MembershipLevelItem(membershipLevel: .mock())
}
