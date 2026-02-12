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

    private var logoutObserver: NSObjectProtocol?

    private init() {
        logoutObserver = NotificationCenter.default.addObserver(
            forName: .authDidLogout,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.handleLogout()
            }
        }
    }

    func requestPermissionAndRegister() {
        Task {
            let center = UNUserNotificationCenter.current()
            do {
                let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
                if granted {
                    logger.info("Push notification permission granted")
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
    }

    func didFailToRegisterForRemoteNotifications(error: Error) {
        logger.error("Failed to register for remote notifications: \(error.localizedDescription)")
    }

    func sendTokenToServer(conventionShortName: String) {
        guard let token = deviceToken else {
            logger.debug("No device token available to send to server")
            return
        }

        // Skip if we already registered this exact token for this convention
        let savedToken = UserDefaults.standard.string(forKey: Self.savedTokenKey)
        let savedConvention = UserDefaults.standard.string(forKey: Self.savedConventionKey)
        if savedToken == token && savedConvention == conventionShortName {
            logger.debug("Device token already registered for this convention, skipping")
            return
        }

        #if os(iOS)
        let platform = "ios"
        #elseif os(macOS)
        let platform = "macos"
        #else
        let platform = "ios"
        #endif

        let deviceName = Self.currentDeviceName()

        Task {
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
                logger.error("Failed to register device token with server: \(error.localizedDescription)")
            }
        }
    }

    private func handleLogout() {
        guard let token = deviceToken ?? UserDefaults.standard.string(forKey: Self.savedTokenKey),
              let conventionShortName = UserDefaults.standard.string(forKey: Self.savedConventionKey),
              !conventionShortName.isEmpty
        else {
            clearSavedToken()
            return
        }

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
                logger.warning("Failed to unregister device token on logout: \(error.localizedDescription)")
            }

            clearSavedToken()
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
