import Foundation
import AVFoundation
import UniformTypeIdentifiers

/// Service for importing audio files from external sources (e.g., Voice Memos)
@MainActor
final class AudioImportService: ObservableObject {
    private let config: AppConfiguration

    /// Supported audio file types for import
    static let supportedTypes: [UTType] = [
        .mpeg4Audio,      // .m4a
        .mp3,             // .mp3
        .wav,             // .wav
        .aiff,            // .aiff
        UTType(filenameExtension: "caf") ?? .audio  // .caf (Core Audio Format)
    ]

    // Recording directory (same as RecordingService)
    private lazy var recordingsDirectory: URL = {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = appSupport
            .appendingPathComponent("com.peninsula.teachercoach")
            .appendingPathComponent("Recordings")

        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }()

    init(config: AppConfiguration) {
        self.config = config
    }

    /// Imports an audio file from an external URL
    /// - Parameter sourceURL: The URL of the audio file to import (security-scoped)
    /// - Returns: A Recording model with status .recorded
    /// - Throws: ImportError if validation or import fails
    func importAudioFile(from sourceURL: URL) async throws -> Recording {
        // Start accessing security-scoped resource
        let didStartAccessing = sourceURL.startAccessingSecurityScopedResource()
        defer {
            if didStartAccessing {
                sourceURL.stopAccessingSecurityScopedResource()
            }
        }

        // Validate file is readable
        guard FileManager.default.isReadableFile(atPath: sourceURL.path) else {
            throw ImportError.fileNotReadable
        }

        // Validate audio format
        guard isValidAudioFormat(sourceURL) else {
            throw ImportError.invalidAudioFormat
        }

        // Get duration
        let duration = try await getAudioDuration(from: sourceURL)

        // Validate duration
        if let validationError = validateDuration(duration) {
            throw validationError
        }

        // Generate unique filename preserving original extension
        let originalExtension = sourceURL.pathExtension.lowercased()
        let filename = "\(UUID().uuidString).\(originalExtension)"
        let destinationURL = recordingsDirectory.appendingPathComponent(filename)

        // Copy file to recordings directory
        do {
            try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
        } catch {
            throw ImportError.copyFailed(error)
        }

        // Generate title from original filename
        let originalFilename = sourceURL.deletingPathExtension().lastPathComponent
        let title = originalFilename.isEmpty ? "Imported Recording" : originalFilename

        // Create Recording model
        let recording = Recording(
            title: title,
            createdAt: Date(),
            duration: duration,
            audioFilePath: filename,
            status: .recorded,
            isImported: true
        )

        return recording
    }

    /// Checks if the file has a valid audio format
    private func isValidAudioFormat(_ url: URL) -> Bool {
        let ext = url.pathExtension.lowercased()
        let validExtensions = ["m4a", "mp3", "wav", "aiff", "caf"]
        return validExtensions.contains(ext)
    }

    /// Gets the duration of an audio file
    private func getAudioDuration(from url: URL) async throws -> TimeInterval {
        let asset = AVURLAsset(url: url)

        do {
            let duration = try await asset.load(.duration)
            let seconds = CMTimeGetSeconds(duration)

            // Check if duration is valid
            guard seconds.isFinite && seconds > 0 else {
                throw ImportError.durationUnavailable
            }

            return seconds
        } catch _ as ImportError {
            throw ImportError.durationUnavailable
        } catch {
            throw ImportError.durationUnavailable
        }
    }

    /// Validates the duration against configured limits
    private func validateDuration(_ duration: TimeInterval) -> ImportError? {
        if duration < config.minRecordingDuration {
            return .durationTooShort
        }
        if duration > config.maxRecordingDuration {
            return .durationTooLong
        }
        return nil
    }
}
