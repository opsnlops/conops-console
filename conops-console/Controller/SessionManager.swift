import Foundation
import OSLog
import SwiftData

extension Notification.Name {
    static let authDidLogout = Notification.Name("AuthDidLogout")
}

struct SessionManager {
    @MainActor static func logout(
        context: ModelContext,
        appState: AppState,
        logger: Logger
    ) -> Result<Void, ServerError> {
        // Clear selection first so detail views stop rendering before data is deleted
        appState.selectedConventionId = nil
        let clearResult = SyncCache.clear(context: context, logger: logger)
        // Unregister push token before clearing auth (needs the token for the API call)
        PushNotificationManager.shared.handleLogout()
        AuthStore.shared.clear()
        NotificationCenter.default.post(name: .authDidLogout, object: nil)
        return clearResult
    }
}
