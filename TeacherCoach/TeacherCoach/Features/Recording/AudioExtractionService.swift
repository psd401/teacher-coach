import Foundation
import AVFoundation

/// Service for extracting audio from video files
@MainActor
final class AudioExtractionService: ObservableObject {
    @Published var isExtracting = false
    @Published var progress: Double = 0
    @Published var error: AudioExtractionError?

    private var exportSession: AVAssetExportSession?

    // Recording directory (same as RecordingService)
    private lazy var recordingsDirectory: URL = {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = appSupport
            .appendingPathComponent("com.peninsula.teachercoach")
            .appendingPathComponent("Recordings")

        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }()

    /// Extracts audio from a video file and saves as m4a
    /// - Parameter videoURL: The URL of the video file
    /// - Returns: URL of the extracted audio file
    func extractAudio(from videoURL: URL) async throws -> URL {
        isExtracting = true
        progress = 0
        error = nil

        defer {
            isExtracting = false
        }

        // Create the asset
        let asset = AVURLAsset(url: videoURL)

        // Check for audio tracks
        let audioTracks = try await asset.loadTracks(withMediaType: .audio)
        guard !audioTracks.isEmpty else {
            throw AudioExtractionError.noAudioTrack
        }

        // Create output URL
        let outputFilename = "\(UUID().uuidString).m4a"
        let outputURL = recordingsDirectory.appendingPathComponent(outputFilename)

        // Remove existing file if present
        try? FileManager.default.removeItem(at: outputURL)

        // Create export session
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) else {
            throw AudioExtractionError.exportSessionFailed
        }

        self.exportSession = exportSession
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .m4a

        // Start progress monitoring
        let progressTask = Task {
            while !Task.isCancelled && exportSession.status == .exporting {
                await MainActor.run {
                    self.progress = Double(exportSession.progress)
                }
                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
            }
        }

        // Export
        do {
            try await exportSession.export(to: outputURL, as: .m4a)
            progressTask.cancel()
            progress = 1.0

            // Verify output file exists
            guard FileManager.default.fileExists(atPath: outputURL.path) else {
                throw AudioExtractionError.exportFailed
            }

            return outputURL

        } catch {
            progressTask.cancel()

            if exportSession.status == .cancelled {
                throw AudioExtractionError.cancelled
            }

            throw AudioExtractionError.exportFailed
        }
    }

    /// Cancels the current extraction
    func cancelExtraction() {
        exportSession?.cancelExport()
        exportSession = nil
        isExtracting = false
        progress = 0
    }

    /// Gets the relative filename for the extracted audio
    func relativeFilename(from outputURL: URL) -> String {
        outputURL.lastPathComponent
    }
}

// MARK: - Audio Extraction Errors

enum AudioExtractionError: Error, LocalizedError {
    case noAudioTrack
    case exportSessionFailed
    case exportFailed
    case cancelled

    var errorDescription: String? {
        switch self {
        case .noAudioTrack:
            return "Video file does not contain an audio track"
        case .exportSessionFailed:
            return "Failed to create audio export session"
        case .exportFailed:
            return "Failed to extract audio from video"
        case .cancelled:
            return "Audio extraction was cancelled"
        }
    }
}
