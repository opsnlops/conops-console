import Foundation

final class AppState: ObservableObject {
    @Published var selectedConventionId: ConventionIdentifier?
    @Published var conventions: [Convention] = []
}
