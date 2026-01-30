import Foundation
import SwiftData

@Model
final class SyncState {
    var id: String
    var lastSyncTime: Date?

    init(id: String = "default", lastSyncTime: Date? = nil) {
        self.id = id
        self.lastSyncTime = lastSyncTime
    }
}
