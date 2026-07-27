import Foundation
import OSLog
import SwiftData

extension Notification.Name {
    static let authDidLogout = Notification.Name("AuthDidLogout")
    static let authSessionExpired = Notification.Name("AuthSessionExpired")
}

struct SessionManager {
    /// Ends the session and clears everything cached locally.
    ///
    /// - Parameter sessionIsValid: Pass `false` when the server has already
    ///   rejected our token. The push-token unregister call is skipped in that
    ///   case, since it would only 401 and re-post `.authSessionExpired`.
    @MainActor static func logout(
        context: ModelContext,
        appState: AppState,
        logger: Logger,
        sessionIsValid: Bool = true
    ) -> Result<Void, ServerError> {
        // Clear selection first so detail views stop rendering before data is deleted
        appState.selectedConventionId = nil
        let clearResult = SyncCache.clear(context: context, logger: logger)
        // Unregister push token before clearing auth (needs the token for the API call)
        if sessionIsValid {
            PushNotificationManager.shared.handleLogout()
        } else {
            PushNotificationManager.shared.handleSessionExpired()
        }
        AuthStore.shared.clear()
        NotificationCenter.default.post(name: .authDidLogout, object: nil)
        return clearResult
    }
}
