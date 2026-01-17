import SwiftUI
import SwiftData

@main
struct TeacherCoachApp: App {
    @StateObject private var appState = AppState()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Recording.self,
            Transcript.self,
            Analysis.self,
            TechniqueEvaluation.self,
            Technique.self,
            UserSettings.self
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environment(ServiceContainer.shared)
        }
        .modelContainer(sharedModelContainer)
        .commands {
            CommandGroup(replacing: .newItem) { }
        }

        #if os(macOS)
        Settings {
            SettingsView()
                .environmentObject(appState)
                .environment(ServiceContainer.shared)
        }
        .modelContainer(sharedModelContainer)
        #endif
    }
}
