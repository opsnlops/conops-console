//
//  LockScreenView.swift
//  conops-console
//
//  Created by Claude on 2/1/26.
//  Copyright © 2026 April's Creature Workshop. All rights reserved.
//

import SwiftUI

struct LockScreenView: View {
    @ObservedObject var authManager: BiometricAuthManager

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: lockIcon)
                .font(.system(size: 64))
                .foregroundStyle(.secondary)

            Text("Conops Console")
                .font(.title)
                .fontWeight(.semibold)

            Text("Authenticate to access attendee data")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button(action: { authManager.authenticate() }) {
                Label("Unlock with \(authManager.biometryName)", systemImage: buttonIcon)
                    .font(.headline)
                    .frame(maxWidth: 280)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.regularMaterial)
        .onAppear {
            // Auto-prompt on appear
            authManager.authenticate()
        }
    }

    private var lockIcon: String {
        switch authManager.biometryType {
        case .faceID: return "faceid"
        case .touchID: return "touchid"
        case .opticID: return "opticid"
        default: return "lock.fill"
        }
    }

    private var buttonIcon: String {
        switch authManager.biometryType {
        case .faceID: return "faceid"
        case .touchID: return "touchid"
        case .opticID: return "opticid"
        default: return "key.fill"
        }
    }
}

#Preview {
    LockScreenView(authManager: BiometricAuthManager())
}
