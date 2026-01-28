import SwiftUI
import SwiftData
import UniformTypeIdentifiers

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
            // Migrate incomplete technique names from older analyses
            services.techniqueService.migrateIncompleteTeechniqueNames(context: modelContext)
        }
    }
}

// MARK: - Main View (Authenticated)

struct MainView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.serviceContainer) private var services
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Recording.createdAt, order: .reverse) private var recordings: [Recording]

    @State private var selectedRecording: Recording?
    @State private var showingNewRecording = false
    @State private var showingFileImporter = false
    @State private var showingVideoImporter = false

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
                WelcomeView(showingNewRecording: $showingNewRecording) { recording in
                    selectedRecording = recording
                }
            }
        }
        .frame(minWidth: 900, minHeight: 600)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        showingNewRecording = true
                        selectedRecording = nil
                    } label: {
                        Label("New Recording", systemImage: "record.circle")
                    }

                    Button {
                        showingFileImporter = true
                    } label: {
                        Label("Import Audio", systemImage: "waveform")
                    }

                    Button {
                        showingVideoImporter = true
                    } label: {
                        Label("Import Video", systemImage: "video")
                    }
                } label: {
                    Label("Add", systemImage: "plus")
                }
            }
        }
        .fileImporter(
            isPresented: $showingFileImporter,
            allowedContentTypes: AudioImportService.supportedTypes,
            allowsMultipleSelection: false
        ) { result in
            handleFileImport(result)
        }
        .sheet(isPresented: $showingVideoImporter) {
            VideoImportView { recording in
                selectedRecording = recording
                showingNewRecording = false
            }
        }
    }

    private func handleFileImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            Task {
                do {
                    let recording = try await services.audioImportService.importAudioFile(from: url)
                    modelContext.insert(recording)
                    selectedRecording = recording
                    showingNewRecording = false
                } catch let error as ImportError {
                    appState.handleError(.importError(error))
                } catch {
                    appState.handleError(.importError(.copyFailed(error)))
                }
            }
        case .failure(let error):
            appState.handleError(.importError(.copyFailed(error)))
        }
    }
}

// MARK: - Sidebar View

struct SidebarView: View {
    let recordings: [Recording]
    @Binding var selectedRecording: Recording?
    @Binding var showingNewRecording: Bool

    @EnvironmentObject private var appState: AppState
    @Environment(\.modelContext) private var modelContext

    @State private var recordingToRename: Recording?
    @State private var renameText = ""

    var body: some View {
        List(selection: $selectedRecording) {
            // Home button
            Button {
                selectedRecording = nil
                showingNewRecording = false
            } label: {
                Label("Home", systemImage: "house")
                    .font(.headline)
            }
            .buttonStyle(.plain)
            .listRowInsets(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))

            Section("Sessions") {
                ForEach(recordings) { recording in
                    RecordingRowView(recording: recording)
                        .tag(recording)
                        .contextMenu {
                            Button {
                                renameText = recording.title
                                recordingToRename = recording
                            } label: {
                                Label("Rename", systemImage: "pencil")
                            }
                        }
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
        .alert("Rename Session", isPresented: .init(
            get: { recordingToRename != nil },
            set: { if !$0 { recordingToRename = nil } }
        )) {
            TextField("Session name", text: $renameText)
            Button("Cancel", role: .cancel) {
                recordingToRename = nil
            }
            Button("Rename") {
                if let recording = recordingToRename, !renameText.trimmingCharacters(in: .whitespaces).isEmpty {
                    recording.title = renameText.trimmingCharacters(in: .whitespaces)
                    try? modelContext.save()
                }
                recordingToRename = nil
            }
        } message: {
            Text("Enter a new name for this session.")
        }
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

                if recording.isVideo {
                    MediaTypeBadge(mediaType: .video)
                }

                if recording.isImported {
                    ImportedBadge()
                }

                StatusBadge(status: recording.status)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Media Type Badge

struct MediaTypeBadge: View {
    let mediaType: MediaType

    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: mediaType == .video ? "video" : "waveform")
                .font(.caption2)
            Text(mediaType == .video ? "Video" : "Audio")
                .font(.caption2)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(mediaType == .video ? Color.purple.opacity(0.2) : Color.blue.opacity(0.2))
        .foregroundStyle(mediaType == .video ? .purple : .blue)
        .clipShape(Capsule())
    }
}

// MARK: - Imported Badge

struct ImportedBadge: View {
    var body: some View {
        Text("Imported")
            .font(.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Color.gray.opacity(0.2))
            .foregroundStyle(.gray)
            .clipShape(Capsule())
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
        case .uploading, .transcribing, .analyzing: return .blue.opacity(0.2)
        case .transcribed: return .purple.opacity(0.2)
        case .complete: return .green.opacity(0.2)
        case .failed: return .red.opacity(0.2)
        }
    }

    private var foregroundColor: Color {
        switch status {
        case .recording: return .red
        case .recorded: return .orange
        case .uploading, .transcribing, .analyzing: return .blue
        case .transcribed: return .purple
        case .complete: return .green
        case .failed: return .red
        }
    }
}

// MARK: - Welcome View

struct WelcomeView: View {
    @Binding var showingNewRecording: Bool
    var onImportComplete: ((Recording) -> Void)?
    @EnvironmentObject private var appState: AppState
    @Environment(\.serviceContainer) private var services
    @Environment(\.modelContext) private var modelContext

    @State private var showingFileImporter = false
    @State private var showingVideoImporter = false

    private let columns = [
        GridItem(.adaptive(minimum: 160, maximum: 200), spacing: 16)
    ]

    var body: some View {
        VStack(spacing: 32) {
            // Header
            VStack(spacing: 12) {
                Image(systemName: "waveform.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(.tint)

                Text("Welcome, \(appState.currentUser?.displayName.components(separatedBy: " ").first ?? "Teacher")!")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Record your teaching sessions to receive AI-powered feedback.")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 450)
            }

            // Action Tiles
            LazyVGrid(columns: columns, spacing: 16) {
                ActionTile(
                    title: "New Recording",
                    subtitle: "Record a lesson",
                    icon: "record.circle.fill",
                    color: .red
                ) {
                    showingNewRecording = true
                }

                ActionTile(
                    title: "Import Audio",
                    subtitle: "Voice memo or audio",
                    icon: "waveform",
                    color: .blue
                ) {
                    showingFileImporter = true
                }

                ActionTile(
                    title: "Import Video",
                    subtitle: "Classroom recording",
                    icon: "video.fill",
                    color: .purple
                ) {
                    showingVideoImporter = true
                }
            }
            .frame(maxWidth: 560)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .fileImporter(
            isPresented: $showingFileImporter,
            allowedContentTypes: AudioImportService.supportedTypes,
            allowsMultipleSelection: false
        ) { result in
            handleFileImport(result)
        }
        .sheet(isPresented: $showingVideoImporter) {
            VideoImportView { recording in
                onImportComplete?(recording)
            }
        }
    }

    private func handleFileImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            Task {
                do {
                    let recording = try await services.audioImportService.importAudioFile(from: url)
                    modelContext.insert(recording)
                    onImportComplete?(recording)
                } catch let error as ImportError {
                    appState.handleError(.importError(error))
                } catch {
                    appState.handleError(.importError(.copyFailed(error)))
                }
            }
        case .failure(let error):
            appState.handleError(.importError(.copyFailed(error)))
        }
    }
}

// MARK: - Action Tile

struct ActionTile: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void

    @State private var isHovering = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundStyle(color)

                VStack(spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(color.opacity(isHovering ? 0.15 : 0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(color.opacity(isHovering ? 0.4 : 0.2), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovering = hovering
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
        .environment(ServiceContainer.shared)
}
