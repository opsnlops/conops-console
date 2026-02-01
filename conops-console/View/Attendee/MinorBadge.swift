//
//  MinorBadge.swift
//  Conops Console
//
//  Created by April White on 2/1/26.
//  Copyright © 2026 April's Creature Workshop. All rights reserved.
//

import SwiftUI

struct MinorBadge: View {
    var body: some View {
        Text("Minor")
            .font(.caption2)
            .fontWeight(.semibold)
            .foregroundStyle(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Capsule().fill(.red))
    }
}

#Preview {
    MinorBadge()
}
