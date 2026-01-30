import Foundation
import OSLog
import SwiftData

extension Notification.Name {
    static let authDidLogout = Notification.Name("AuthDidLogout")
}

struct SessionManager {
    static func logout(
        context: ModelContext,
        logger: Logger
    ) -> Result<Void, ServerError> {
        let clearResult = SyncCache.clear(context: context, logger: logger)
        AuthStore.shared.clear()
        NotificationCenter.default.post(name: .authDidLogout, object: nil)
        return clearResult
    }
}
