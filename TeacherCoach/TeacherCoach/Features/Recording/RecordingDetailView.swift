import SwiftUI
import SwiftData

struct RecordingDetailView: View {
    @Bindable var recording: Recording

    @Environment(\.serviceContainer) private var services
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appState: AppState

    @State private var showingDeleteConfirmation = false
    @State private var showingAnalysisConfig = false
    @State private var showingExportConfig = false
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
                if recording.status == .complete {
                    Button {
                        showingExportConfig = true
                    } label: {
                        Label("Export", systemImage: "square.and.arrow.up")
                    }
                    .disabled(isProcessing)
                }

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
            AnalysisConfigurationSheet { framework, techniqueIds, includeRatings in
                startAnalysis(framework: framework, techniqueIds: techniqueIds, includeRatings: includeRatings)
            }
        }
        .sheet(isPresented: $showingExportConfig) {
            if let analysis = recording.analysis {
                ExportConfigurationSheet(
                    analysis: analysis,
                    recording: recording
                ) { configuration in
                    exportAnalysis(configuration: configuration)
                }
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

    private func startAnalysis(framework: TeachingFramework, techniqueIds: [String], includeRatings: Bool = true) {
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
                    sessionToken: session.accessToken,
                    includeRatings: includeRatings
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
            let includeRatings = settings.includeRatingsInAnalysis
            startAnalysis(framework: framework, techniqueIds: techniqueIds, includeRatings: includeRatings)
        } else {
            // Default to TLAC with all techniques and ratings enabled
            startAnalysis(framework: .tlac, techniqueIds: FrameworkRegistry.defaultEnabledIds(for: .tlac), includeRatings: true)
        }
    }

    private func deleteRecording() {
        services.recordingService.deleteAudioFile(for: recording)
        modelContext.delete(recording)
        try? modelContext.save()
    }

    private func exportAnalysis(configuration: ExportConfiguration) {
        guard let analysis = recording.analysis else { return }

        Task {
            do {
                let url = try await services.exportService.export(
                    analysis: analysis,
                    recording: recording,
                    configuration: configuration
                )
                print("Exported to: \(url)")
            } catch ExportService.ExportError.saveCancelled {
                // User cancelled, no error to show
            } catch {
                print("Export error: \(error.localizedDescription)")
            }
        }
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
    @State private var showPauses = true

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
                // Pause Summary (if pauses exist)
                if !transcript.pauses.isEmpty {
                    PauseSummaryView(pauses: transcript.pauses, recordingDuration: transcript.recording?.duration ?? 0)
                }

                // Transcript content with inline pause markers
                TranscriptContentView(transcript: transcript, showPauses: showPauses)
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

// MARK: - Transcript Content View

struct TranscriptContentView: View {
    let transcript: Transcript
    let showPauses: Bool

    var body: some View {
        Group {
            if showPauses && !transcript.pauses.isEmpty {
                // Use flow layout with interleaved pause markers
                flowLayoutContent
            } else {
                // Simple text display when no pauses
                Text(transcript.fullText)
                    .font(.body)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    @ViewBuilder
    private var flowLayoutContent: some View {
        let items = buildTranscriptItems()

        VStack(alignment: .leading, spacing: 8) {
            ForEach(items) { item in
                switch item.type {
                case .segment(let text):
                    HStack(alignment: .top, spacing: 4) {
                        Text(text)
                            .font(.body)
                        if let pause = item.followingPause {
                            PauseMarkerView(pause: pause)
                        }
                    }
                }
            }
        }
    }

    private func buildTranscriptItems() -> [TranscriptItem] {
        let segments = transcript.segments.sorted { $0.startTime < $1.startTime }
        let pauses = transcript.pauses.sorted { $0.startTime < $1.startTime }

        var items: [TranscriptItem] = []
        var pauseIndex = 0

        for segment in segments {
            var followingPause: TranscriptPause? = nil

            // Check if there's a pause after this segment
            if pauseIndex < pauses.count {
                let pause = pauses[pauseIndex]
                if abs(pause.startTime - segment.endTime) < 0.5 {
                    followingPause = pause
                    pauseIndex += 1
                }
            }

            items.append(TranscriptItem(
                type: .segment(segment.text),
                followingPause: followingPause
            ))
        }

        return items
    }
}

struct TranscriptItem: Identifiable {
    let id = UUID()
    let type: TranscriptItemType
    let followingPause: TranscriptPause?

    init(type: TranscriptItemType, followingPause: TranscriptPause? = nil) {
        self.type = type
        self.followingPause = followingPause
    }
}

enum TranscriptItemType {
    case segment(String)
}

// MARK: - Pause Marker View

struct PauseMarkerView: View {
    let pause: TranscriptPause

    var body: some View {
        Text("[\(pause.formattedDuration) pause]")
            .font(.caption)
            .fontWeight(.medium)
            .foregroundStyle(.orange)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(.orange.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

// MARK: - Pause Summary View

struct PauseSummaryView: View {
    let pauses: [TranscriptPause]
    let recordingDuration: TimeInterval

    private var totalPauseTime: TimeInterval {
        pauses.reduce(0) { $0 + $1.duration }
    }

    private var averageDuration: TimeInterval {
        guard !pauses.isEmpty else { return 0 }
        return totalPauseTime / Double(pauses.count)
    }

    private var maxDuration: TimeInterval {
        pauses.map(\.duration).max() ?? 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("Wait Time Pauses", systemImage: "pause.circle")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                Text("\(pauses.count) detected")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 16) {
                PauseStatView(label: "Average", value: String(format: "%.1fs", averageDuration))
                PauseStatView(label: "Longest", value: String(format: "%.1fs", maxDuration))
                PauseStatView(label: "Total", value: String(format: "%.1fs", totalPauseTime))
            }

            // Timeline visualization
            if recordingDuration > 0 {
                PauseTimelineView(pauses: pauses, duration: recordingDuration)
            }
        }
        .padding(10)
        .background(.orange.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct PauseStatView: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
        }
    }
}

// MARK: - Pause Timeline View

struct PauseTimelineView: View {
    let pauses: [TranscriptPause]
    let duration: TimeInterval

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: 2)
                    .fill(.secondary.opacity(0.2))
                    .frame(height: 8)

                // Pause markers
                ForEach(pauses) { pause in
                    let startPosition = (pause.startTime / duration) * geometry.size.width
                    let pauseWidth = max(4, (pause.duration / duration) * geometry.size.width)

                    RoundedRectangle(cornerRadius: 2)
                        .fill(.orange)
                        .frame(width: pauseWidth, height: 8)
                        .offset(x: startPosition)
                }
            }
        }
        .frame(height: 8)
    }
}

// MARK: - Flow Layout

struct FlowLayout: Layout {
    var alignment: HorizontalAlignment = .leading
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )

        for (index, subview) in subviews.enumerated() {
            let position = result.positions[index]
            subview.place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }

                positions.append(CGPoint(x: currentX, y: currentY))
                lineHeight = max(lineHeight, size.height)
                currentX += size.width + spacing

                self.size.width = max(self.size.width, currentX)
            }

            self.size.height = currentY + lineHeight
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
