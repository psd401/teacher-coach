import SwiftUI
import SwiftData

struct RecordingDetailView: View {
    @Bindable var recording: Recording

    @Environment(\.serviceContainer) private var services
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appState: AppState

    @State private var showingDeleteConfirmation = false
    @State private var showingAnalysisConfig = false
    @State private var isProcessing = false
    @State private var processingMessage = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                RecordingHeaderView(recording: recording)

                Divider()

                // Actions based on status
                switch recording.status {
                case .recorded:
                    ActionPromptView(
                        title: "Ready for Transcription",
                        description: "Transcribe this recording to prepare it for analysis.",
                        buttonTitle: "Start Transcription",
                        isLoading: isProcessing,
                        action: startTranscription
                    )

                case .transcribing:
                    ProcessingView(
                        title: "Transcribing...",
                        progress: services.transcriptionService.progress
                    )

                case .transcribed:
                    if let transcript = recording.transcript {
                        TranscriptSection(transcript: transcript)

                        ActionPromptView(
                            title: "Ready for Analysis",
                            description: "Analyze this transcript for teaching technique feedback.",
                            buttonTitle: "Configure & Analyze",
                            isLoading: isProcessing,
                            action: { showingAnalysisConfig = true }
                        )
                    }

                case .analyzing:
                    if let transcript = recording.transcript {
                        TranscriptSection(transcript: transcript)
                    }

                    ProcessingView(
                        title: "Analyzing...",
                        progress: services.analysisService.progress
                    )

                case .complete:
                    if let analysis = recording.analysis {
                        AnalysisFeedbackView(analysis: analysis)
                    }

                    if let transcript = recording.transcript {
                        TranscriptSection(transcript: transcript, collapsed: true)
                    }

                case .recording, .failed:
                    if recording.status == .failed {
                        FailedRecordingView()
                    }
                }
            }
            .padding(24)
        }
        .navigationTitle(recording.title)
        .toolbar {
            ToolbarItemGroup {
                if recording.status == .transcribed || recording.status == .complete {
                    Button {
                        // Re-analyze
                        startAnalysis()
                    } label: {
                        Label("Re-analyze", systemImage: "arrow.clockwise")
                    }
                    .disabled(isProcessing)
                }

                Button(role: .destructive) {
                    showingDeleteConfirmation = true
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
        .alert("Delete Recording?", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteRecording()
            }
        } message: {
            Text("This will permanently delete the recording and all associated data.")
        }
        .sheet(isPresented: $showingAnalysisConfig) {
            AnalysisConfigurationSheet { framework, techniqueIds in
                startAnalysis(framework: framework, techniqueIds: techniqueIds)
            }
        }
    }

    // MARK: - Actions

    private func startTranscription() {
        isProcessing = true
        recording.status = .transcribing

        Task {
            do {
                try modelContext.save()

                let transcript = try await services.transcriptionService.transcribe(recording: recording)

                // Save transcript
                recording.transcript = transcript
                recording.status = .transcribed
                try modelContext.save()

            } catch {
                recording.status = .recorded
                appState.handleError(.transcription(.processingFailed(error)))
            }

            isProcessing = false
        }
    }

    private func startAnalysis(framework: TeachingFramework, techniqueIds: [String]) {
        guard let transcript = recording.transcript,
              let session = services.authService.getCurrentSession() else {
            return
        }

        isProcessing = true
        recording.status = .analyzing

        Task {
            do {
                try modelContext.save()

                // Get enabled techniques for the selected framework
                let techniques = services.techniqueService.getEnabledTechniques(
                    for: framework,
                    enabledIds: techniqueIds
                )

                let analysis = try await services.analysisService.analyze(
                    transcript: transcript,
                    techniques: techniques,
                    sessionToken: session.accessToken
                )

                // Save analysis
                recording.analysis = analysis
                recording.status = .complete
                try modelContext.save()

            } catch {
                recording.status = .transcribed
                appState.handleError(.analysis(.apiError(500, error.localizedDescription)))
            }

            isProcessing = false
        }
    }

    /// Legacy method for re-analysis from toolbar
    private func startAnalysis() {
        // Load the saved framework and technique preferences
        guard let email = appState.currentUser?.email else { return }

        let descriptor = FetchDescriptor<UserSettings>(
            predicate: #Predicate { $0.userEmail == email }
        )

        if let settings = try? modelContext.fetch(descriptor).first {
            let framework = settings.selectedFramework
            let techniqueIds = settings.enabledTechniqueIds(for: framework)
            startAnalysis(framework: framework, techniqueIds: techniqueIds)
        } else {
            // Default to TLAC with all techniques
            startAnalysis(framework: .tlac, techniqueIds: FrameworkRegistry.defaultEnabledIds(for: .tlac))
        }
    }

    private func deleteRecording() {
        services.recordingService.deleteAudioFile(for: recording)
        modelContext.delete(recording)
        try? modelContext.save()
    }
}

// MARK: - Recording Header

struct RecordingHeaderView: View {
    let recording: Recording

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(recording.title)
                    .font(.title)
                    .fontWeight(.bold)

                Spacer()

                StatusBadge(status: recording.status)
            }

            HStack(spacing: 16) {
                Label(recording.formattedDuration, systemImage: "clock")
                Label {
                    Text(recording.createdAt, format: .dateTime.month().day().year())
                } icon: {
                    Image(systemName: "calendar")
                }
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Action Prompt View

struct ActionPromptView: View {
    let title: String
    let description: String
    let buttonTitle: String
    let isLoading: Bool
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)

            Text(description)
                .font(.body)
                .foregroundStyle(.secondary)

            Button {
                action()
            } label: {
                HStack {
                    if isLoading {
                        ProgressView()
                            .controlSize(.small)
                    }
                    Text(buttonTitle)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isLoading)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Processing View

struct ProcessingView: View {
    let title: String
    let progress: Double

    var body: some View {
        VStack(spacing: 16) {
            ProgressView(value: progress)
                .progressViewStyle(.linear)

            HStack {
                Text(title)
                    .font(.headline)

                Spacer()

                Text("\(Int(progress * 100))%")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Transcript Section

struct TranscriptSection: View {
    let transcript: Transcript
    var collapsed: Bool = false

    @State private var isExpanded = true

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                withAnimation {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Text("Transcript")
                        .font(.headline)

                    Spacer()

                    Text("\(transcript.wordCount) words")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)

            if isExpanded && !collapsed {
                Text(transcript.fullText)
                    .font(.body)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.background)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .onAppear {
            isExpanded = !collapsed
        }
    }
}

// MARK: - Failed Recording View

struct FailedRecordingView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundStyle(.red)

            Text("Recording Failed")
                .font(.headline)

            Text("There was an error processing this recording. Please try again.")
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.red.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    let recording = Recording(
        title: "Math Lesson",
        duration: 1800,
        audioFilePath: "test.m4a",
        status: .complete
    )

    return NavigationStack {
        RecordingDetailView(recording: recording)
    }
    .environmentObject(AppState())
    .environment(ServiceContainer.shared)
}
