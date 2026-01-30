import OSLog
import SwiftData

struct SyncCache {
    static func clear(
        context: ModelContext,
        logger: Logger
    ) -> Result<Void, ServerError> {
        (try? context.fetch(FetchDescriptor<Attendee>()))?.forEach { context.delete($0) }
        (try? context.fetch(FetchDescriptor<Convention>()))?.forEach { context.delete($0) }
        (try? context.fetch(FetchDescriptor<SyncState>()))?.forEach { context.delete($0) }

        do {
            try context.save()
            logger.info("Cleared local cache")
            return .success(())
        } catch {
            logger.error("Failed to clear local cache: \(error)")
            return .failure(.databaseError(error.localizedDescription))
        }
    }
}
