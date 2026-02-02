import Foundation

final class AppState: ObservableObject {
    @Published var selectedConventionId: ConventionIdentifier?
    @Published var conventions: [Convention] = []

    /// Cached remote printers keyed by convention short name.
    /// Cleared on logout; the user can log out and back in to refresh the list.
    private(set) var cachedRemotePrinters: [String: [String]] = [:]

    private var logoutObserver: NSObjectProtocol?

    init() {
        logoutObserver = NotificationCenter.default.addObserver(
            forName: .authDidLogout,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.clearPrinterCache()
        }
    }

    deinit {
        if let observer = logoutObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    func remotePrinters(for conventionShortName: String) -> [String]? {
        cachedRemotePrinters[conventionShortName]
    }

    func cacheRemotePrinters(_ printers: [String], for conventionShortName: String) {
        cachedRemotePrinters[conventionShortName] = printers
    }

    func clearPrinterCache() {
        cachedRemotePrinters.removeAll()
    }
}
