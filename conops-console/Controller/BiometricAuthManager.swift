//
//  BiometricAuthManager.swift
//  conops-console
//
//  Created by Claude on 2/1/26.
//  Copyright © 2026 April's Creature Workshop. All rights reserved.
//

import Foundation
import LocalAuthentication
import OSLog

#if os(iOS)
import UIKit
#endif

@MainActor
final class BiometricAuthManager: ObservableObject {
    @Published private(set) var isUnlocked = false
    @Published private(set) var biometryType: LABiometryType = .none

    private let logger = Logger(
        subsystem: "furry.enterprises.CreatureConsole",
        category: "BiometricAuthManager"
    )

    var requiresBiometrics: Bool {
        #if os(iOS)
        // Only require on iPhone, not iPad (for now)
        return UIDevice.current.userInterfaceIdiom == .phone
        #else
        return false
        #endif
    }

    var biometryName: String {
        switch biometryType {
        case .faceID: return "Face ID"
        case .touchID: return "Touch ID"
        case .opticID: return "Optic ID"
        case .none: return "Passcode"
        @unknown default: return "Biometrics"
        }
    }

    init() {
        checkBiometryType()

        // If biometrics not required, auto-unlock
        if !requiresBiometrics {
            isUnlocked = true
        }
    }

    private func checkBiometryType() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            biometryType = context.biometryType
        } else {
            biometryType = .none
        }
    }

    func authenticate() {
        guard requiresBiometrics else {
            isUnlocked = true
            return
        }

        let context = LAContext()
        var error: NSError?

        // Check if biometrics or passcode is available
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let reason = "Unlock to access attendee information"

            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) {
                [weak self] success, authError in
                DispatchQueue.main.async {
                    if success {
                        self?.logger.info("Authentication successful")
                        self?.isUnlocked = true
                    } else {
                        self?.logger.warning(
                            "Authentication failed: \(authError?.localizedDescription ?? "unknown")"
                        )
                        self?.isUnlocked = false
                    }
                }
            }
        } else {
            logger.error("Authentication not available: \(error?.localizedDescription ?? "unknown")")
            // If no authentication is available, allow access (device has no security)
            isUnlocked = true
        }
    }

    func lock() {
        guard requiresBiometrics else { return }
        isUnlocked = false
    }
}
