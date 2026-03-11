import Foundation
import SwiftData

/// Represents a coaching chat session tied to a recording
@Model
final class ChatSession {
    // MARK: - Properties
    @Attribute(.unique) var id: UUID
    var title: String
    var createdAt: Date

    // MARK: - Relationships
    var recording: Recording?

    @Relationship(deleteRule: .cascade, inverse: \ChatMessage.session)
    var messages: [ChatMessage]?

    // MARK: - Computed Properties
    var sortedMessages: [ChatMessage] {
        (messages ?? []).sorted { $0.createdAt < $1.createdAt }
    }

    // MARK: - Initialization
    init(
        id: UUID = UUID(),
        title: String = "New Chat",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.createdAt = createdAt
        self.messages = []
    }
}

/// A single message in a coaching chat session
@Model
final class ChatMessage {
    // MARK: - Properties
    @Attribute(.unique) var id: UUID
    var role: String  // "user" or "assistant"
    var content: String
    var createdAt: Date

    // MARK: - Relationships
    var session: ChatSession?

    // MARK: - Computed Properties
    var isUser: Bool {
        role == "user"
    }

    var isAssistant: Bool {
        role == "assistant"
    }

    // MARK: - Initialization
    init(
        id: UUID = UUID(),
        role: String,
        content: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.role = role
        self.content = content
        self.createdAt = createdAt
    }
}
