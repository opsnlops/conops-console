import Foundation
import OSLog
import UserNotifications

#if canImport(UIKit)
import UIKit
#endif

@MainActor
final class PushNotificationManager: ObservableObject {
    static let shared = PushNotificationManager()

    private let logger = Logger(
        subsystem: "furry.enterprises.ConopsConsole",
        category: "PushNotificationManager"
    )

    @Published private(set) var deviceToken: String?

    private static let savedTokenKey = "conops.push.savedDeviceToken"
    private static let savedConventionKey = "conops.push.savedConventionShortName"

    private var pendingConventionShortName: String?

    private init() {}

    func requestPermissionAndRegister() {
        logger.info("requestPermissionAndRegister() called")
        Task {
            let center = UNUserNotificationCenter.current()
            do {
                let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
                if granted {
                    logger.info("Push notification permission granted, registering for remote notifications")
                    registerForRemoteNotifications()
                } else {
                    logger.info("Push notification permission denied by user")
                }
            } catch {
                logger.error("Failed to request notification permission: \(error.localizedDescription)")
            }
        }
    }

    private func registerForRemoteNotifications() {
        #if os(iOS)
        UIApplication.shared.registerForRemoteNotifications()
        #elseif os(macOS)
        NSApplication.shared.registerForRemoteNotifications()
        #endif
    }

    func didRegisterForRemoteNotifications(tokenData: Data) {
        let tokenString = tokenData.map { String(format: "%02x", $0) }.joined()
        logger.info("Received APNs device token: \(tokenString.prefix(8))...")
        self.deviceToken = tokenString

        // If we were waiting for a token to register with the server, do it now
        if let conventionShortName = pendingConventionShortName {
            logger.info("Had pending convention '\(conventionShortName)', sending token now")
            pendingConventionShortName = nil
            sendTokenToServer(conventionShortName: conventionShortName)
        }
    }

    func didFailToRegisterForRemoteNotifications(error: Error) {
        logger.error("Failed to register for remote notifications: \(error.localizedDescription)")
    }

    func sendTokenToServer(conventionShortName: String) {
        logger.info(
            "sendTokenToServer called for '\(conventionShortName)' (deviceToken=\(self.deviceToken != nil ? "present" : "nil"))"
        )

        guard let token = deviceToken else {
            logger.info("No device token yet, saving pending convention '\(conventionShortName)'")
            pendingConventionShortName = conventionShortName
            return
        }

        // Skip if we already registered this exact token for this convention
        let savedToken = UserDefaults.standard.string(forKey: Self.savedTokenKey)
        let savedConvention = UserDefaults.standard.string(forKey: Self.savedConventionKey)
        if savedToken == token && savedConvention == conventionShortName {
            logger.info("Device token already registered for '\(conventionShortName)', skipping")
            return
        }

        logger.info(
            "Registering token \(token.prefix(8))... for '\(conventionShortName)' (savedToken=\(savedToken?.prefix(8) ?? "nil"), savedConvention=\(savedConvention ?? "nil"))"
        )

        #if os(iOS)
        let platform = "ios"
        #elseif os(macOS)
        let platform = "macos"
        #else
        let platform = "ios"
        #endif

        let deviceName = Self.currentDeviceName()

        Task {
            logger.info("Starting device token registration API call")
            let client = ConopsServerClient()
            let result = await client.registerDeviceToken(
                shortName: conventionShortName,
                token: token,
                platform: platform,
                deviceName: deviceName
            )

            switch result {
            case .success:
                logger.info("Device token registered with server for '\(conventionShortName)'")
                UserDefaults.standard.set(token, forKey: Self.savedTokenKey)
                UserDefaults.standard.set(conventionShortName, forKey: Self.savedConventionKey)
            case .failure(let error):
                logger.error(
                    "Failed to register device token with server: \(error.localizedDescription)")
            }
        }
    }

    func handleLogout() {
        logger.info(
            "handleLogout called (deviceToken=\(self.deviceToken != nil ? "present" : "nil"))")

        guard let token = deviceToken ?? UserDefaults.standard.string(forKey: Self.savedTokenKey),
            let conventionShortName = UserDefaults.standard.string(forKey: Self.savedConventionKey),
            !conventionShortName.isEmpty
        else {
            logger.info("No token or convention to unregister, clearing saved state")
            clearSavedToken()
            return
        }

        logger.info(
            "Unregistering token \(token.prefix(8))... from '\(conventionShortName)' on logout")

        // Clear saved token immediately so re-login always re-registers
        clearSavedToken()

        Task {
            let client = ConopsServerClient()
            let result = await client.unregisterDeviceToken(
                shortName: conventionShortName,
                token: token
            )

            switch result {
            case .success:
                logger.info("Device token unregistered from server on logout")
            case .failure(let error):
                logger.warning(
                    "Failed to unregister device token on logout: \(error.localizedDescription)")
            }
        }
    }

    private func clearSavedToken() {
        UserDefaults.standard.removeObject(forKey: Self.savedTokenKey)
        UserDefaults.standard.removeObject(forKey: Self.savedConventionKey)
    }

    private static func currentDeviceName() -> String {
        #if os(iOS)
        return UIDevice.current.name
        #elseif os(macOS)
        return Host.current().localizedName ?? "Mac"
        #else
        return "Unknown"
        #endif
    }
}
