import SwiftUI
import SwiftData

struct ContentView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.serviceContainer) private var services
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        Group {
            if appState.isAuthenticated {
                MainView()
            } else {
                LoginView()
            }
        }
        .alert("Error", isPresented: $appState.showingError) {
            Button("OK") {
                appState.currentError = nil
            }
        } message: {
            if let error = appState.currentError {
                Text(error.localizedDescription)
            }
        }
        .onAppear {
            // Initialize techniques in database
            services.techniqueService.initializeTechniquesInDatabase(context: modelContext)
        }
    }
}

// MARK: - Main View (Authenticated)

struct MainView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Recording.createdAt, order: .reverse) private var recordings: [Recording]

    @State private var selectedRecording: Recording?
    @State private var showingNewRecording = false

    var body: some View {
        NavigationSplitView {
            SidebarView(
                recordings: recordings,
                selectedRecording: $selectedRecording,
                showingNewRecording: $showingNewRecording
            )
        } detail: {
            if let recording = selectedRecording {
                RecordingDetailView(recording: recording)
            } else if showingNewRecording {
                NewRecordingView(
                    isPresented: $showingNewRecording,
                    onComplete: { recording in
                        selectedRecording = recording
                        showingNewRecording = false
                    }
                )
            } else {
                WelcomeView(showingNewRecording: $showingNewRecording)
            }
        }
        .frame(minWidth: 900, minHeight: 600)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingNewRecording = true
                    selectedRecording = nil
                } label: {
                    Label("New Recording", systemImage: "plus")
                }
            }
        }
    }
}

// MARK: - Sidebar View

struct SidebarView: View {
    let recordings: [Recording]
    @Binding var selectedRecording: Recording?
    @Binding var showingNewRecording: Bool

    @EnvironmentObject private var appState: AppState

    var body: some View {
        List(selection: $selectedRecording) {
            Section("Sessions") {
                ForEach(recordings) { recording in
                    RecordingRowView(recording: recording)
                        .tag(recording)
                }
            }
        }
        .listStyle(.sidebar)
        .frame(minWidth: 250)
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Menu {
                    Button("Sign Out") {
                        appState.signOut()
                    }
                } label: {
                    Label(
                        appState.currentUser?.displayName ?? "Account",
                        systemImage: "person.circle"
                    )
                }
            }
        }
        .navigationTitle("Teacher Coach")
    }
}

// MARK: - Recording Row

struct RecordingRowView: View {
    let recording: Recording

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(recording.title)
                .font(.headline)

            HStack {
                Text(recording.createdAt, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                StatusBadge(status: recording.status)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Status Badge

struct StatusBadge: View {
    let status: RecordingStatus

    var body: some View {
        Text(status.displayText)
            .font(.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(backgroundColor)
            .foregroundStyle(foregroundColor)
            .clipShape(Capsule())
    }

    private var backgroundColor: Color {
        switch status {
        case .recording: return .red.opacity(0.2)
        case .recorded: return .orange.opacity(0.2)
        case .transcribing, .analyzing: return .blue.opacity(0.2)
        case .transcribed: return .purple.opacity(0.2)
        case .complete: return .green.opacity(0.2)
        case .failed: return .red.opacity(0.2)
        }
    }

    private var foregroundColor: Color {
        switch status {
        case .recording: return .red
        case .recorded: return .orange
        case .transcribing, .analyzing: return .blue
        case .transcribed: return .purple
        case .complete: return .green
        case .failed: return .red
        }
    }
}

// MARK: - Welcome View

struct WelcomeView: View {
    @Binding var showingNewRecording: Bool
    @EnvironmentObject private var appState: AppState

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "waveform.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.tint)

            Text("Welcome, \(appState.currentUser?.displayName.components(separatedBy: " ").first ?? "Teacher")!")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Record your teaching sessions to receive AI-powered feedback on your instructional techniques.")
                .font(.title3)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 500)

            Button {
                showingNewRecording = true
            } label: {
                Label("Start New Session", systemImage: "plus.circle.fill")
                    .font(.title3)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
        .environment(ServiceContainer.shared)
}
