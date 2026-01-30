import SwiftUI

struct ConventionCommands: Commands {
    @ObservedObject var appState: AppState

    var body: some Commands {
        CommandMenu("Convention") {
            if appState.conventions.isEmpty {
                Text("No conventions available")
            } else {
                Picker("Active Convention", selection: $appState.selectedConventionId) {
                    ForEach(appState.conventions) { convention in
                        Text(convention.longName)
                            .tag(Optional(convention.id))
                    }
                }
            }
        }
    }
}
