import Foundation
import WhisperKit

/// Service for transcribing audio using WhisperKit
@MainActor
final class TranscriptionService: ObservableObject {
    private let config: AppConfiguration
    private var whisperKit: WhisperKit?
    private var transcriptionTask: Task<Transcript, Error>?

    @Published var isLoading = false
    @Published var isTranscribing = false
    @Published var progress: Double = 0
    @Published var error: TranscriptionError?

    private var isModelLoaded = false
    private var loadedModelName: String = ""

    init(config: AppConfiguration) {
        self.config = config
    }

    // MARK: - Public Methods

    /// Loads the WhisperKit model (should be called on app launch or before first transcription)
    func loadModel() async throws {
        guard !isModelLoaded else { return }

        isLoading = true
        error = nil

        do {
            let whisperConfig: WhisperKitConfig

            if config.devUseBundledModel,
               let bundledModelPath = Bundle.main.path(forResource: "openai_whisper-base", ofType: nil, inDirectory: "Models") {
                // Use bundled model for development
                loadedModelName = "openai_whisper-base"
                whisperConfig = WhisperKitConfig(
                    model: loadedModelName,
                    modelFolder: bundledModelPath,
                    computeOptions: .init(
                        melCompute: .cpuAndGPU,
                        audioEncoderCompute: .cpuAndGPU,
                        textDecoderCompute: .cpuAndGPU
                    ),
                    download: false  // Don't attempt network download
                )
            } else {
                // Production: download model on demand
                loadedModelName = config.whisperModel
                whisperConfig = WhisperKitConfig(
                    model: loadedModelName,
                    computeOptions: .init(
                        melCompute: .cpuAndGPU,
                        audioEncoderCompute: .cpuAndGPU,
                        textDecoderCompute: .cpuAndGPU
                    )
                )
            }

            whisperKit = try await WhisperKit(whisperConfig)
            isModelLoaded = true
            isLoading = false
        } catch {
            isLoading = false
            let transcriptionError = TranscriptionError.modelLoadFailed(error)
            self.error = transcriptionError
            throw transcriptionError
        }
    }

    /// Transcribes audio from a recording
    func transcribe(recording: Recording) async throws -> Transcript {
        // Ensure model is loaded
        if !isModelLoaded {
            try await loadModel()
        }

        guard let whisper = whisperKit else {
            throw TranscriptionError.modelLoadFailed(NSError(
                domain: "TranscriptionService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "WhisperKit not initialized"]
            ))
        }

        guard let audioURL = recording.absoluteAudioPath else {
            throw TranscriptionError.processingFailed(NSError(
                domain: "TranscriptionService",
                code: -2,
                userInfo: [NSLocalizedDescriptionKey: "Audio file not found"]
            ))
        }

        isTranscribing = true
        progress = 0
        error = nil

        let startTime = Date()

        do {
            // Create a task for cancellation support
            transcriptionTask = Task {
                try await performTranscription(whisper: whisper, audioURL: audioURL)
            }

            let transcript = try await transcriptionTask!.value

            isTranscribing = false
            progress = 1.0

            // Update processing time
            let processingTime = Date().timeIntervalSince(startTime)
            return Transcript(
                id: transcript.id,
                fullText: transcript.fullText,
                createdAt: transcript.createdAt,
                modelUsed: loadedModelName,
                processingTime: processingTime,
                segments: transcript.segments
            )

        } catch is CancellationError {
            isTranscribing = false
            throw TranscriptionError.cancelled
        } catch {
            isTranscribing = false
            let transcriptionError = TranscriptionError.processingFailed(error)
            self.error = transcriptionError
            throw transcriptionError
        }
    }

    /// Cancels the current transcription
    func cancelTranscription() {
        transcriptionTask?.cancel()
        transcriptionTask = nil
        isTranscribing = false
        progress = 0
    }

    // MARK: - Private Methods

    private func performTranscription(whisper: WhisperKit, audioURL: URL) async throws -> Transcript {
        // Transcribe with progress tracking
        let result = try await whisper.transcribe(
            audioPath: audioURL.path,
            decodeOptions: DecodingOptions(
                task: .transcribe,
                language: "en",
                temperature: 0,
                temperatureIncrementOnFallback: 0.2,
                temperatureFallbackCount: 3,
                topK: 5,
                usePrefillPrompt: true,
                usePrefillCache: true,
                skipSpecialTokens: true,
                withoutTimestamps: false,
                wordTimestamps: true,
                clipTimestamps: [],
                chunkingStrategy: .vad  // Voice Activity Detection for natural breaks
            )
        ) { progressInfo in
            // Update progress on main thread
            Task { @MainActor in
                // Estimate progress based on transcription info
                let timings = progressInfo.timings
                let currentTime = timings.fullPipeline
                let totalTime = timings.audioLoading
                self.progress = min(currentTime / max(totalTime, 1), 0.99)
            }
            return true  // Continue transcription
        }

        // Check for cancellation
        try Task.checkCancellation()

        // Convert WhisperKit result to our Transcript model
        let segments = result.flatMap { transcriptionResult -> [TranscriptSegment] in
            transcriptionResult.segments.map { segment in
                TranscriptSegment(
                    startTime: TimeInterval(segment.start),
                    endTime: TimeInterval(segment.end),
                    text: segment.text,
                    confidence: Float(exp(segment.avgLogprob))  // Convert log prob to probability
                )
            }
        }

        let fullText = result.map { $0.text }.joined(separator: " ").trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

        return Transcript(
            fullText: fullText,
            createdAt: Date(),
            modelUsed: loadedModelName,
            processingTime: 0,  // Will be updated by caller
            segments: segments
        )
    }

    /// Estimates transcription time based on audio duration
    func estimateTranscriptionTime(audioDuration: TimeInterval) -> TimeInterval {
        // Rough estimate: WhisperKit processes at ~0.3-0.5x real-time on Apple Silicon
        // For a 50-minute recording, expect ~15-25 minutes
        return audioDuration * 0.4
    }

    /// Checks if sufficient memory is available for transcription
    func checkMemoryAvailability() -> Bool {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4

        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }

        guard result == KERN_SUCCESS else { return true }  // Default to allowing if check fails

        // WhisperKit large-v3 needs ~2-3GB RAM
        let usedMemory = info.resident_size
        let availableMemory = ProcessInfo.processInfo.physicalMemory - usedMemory

        // Require at least 3GB available
        return availableMemory > 3 * 1024 * 1024 * 1024
    }
}
