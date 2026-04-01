import Foundation
import SwiftData

@Model
final class AIConversation {
    var id: UUID
    var createdDate: Date
    var updatedDate: Date
    var title: String          // auto-generated from first user message
    var messagesData: Data     // JSON-encoded [AIMessage]

    init(title: String = "New Conversation") {
        self.id = UUID()
        self.createdDate = Date()
        self.updatedDate = Date()
        self.title = title
        self.messagesData = (try? JSONEncoder().encode([AIMessage]()))  ?? Data()
    }

    // MARK: Computed
    var messages: [AIMessage] {
        get { (try? JSONDecoder().decode([AIMessage].self, from: messagesData)) ?? [] }
        set {
            messagesData = (try? JSONEncoder().encode(newValue)) ?? Data()
            updatedDate = Date()
        }
    }

    var lastMessage: AIMessage? { messages.last }

    var preview: String {
        guard let last = messages.last(where: { $0.role == .assistant }) else {
            return "No messages yet"
        }
        let text = last.content
        return text.count > 80 ? String(text.prefix(80)) + "…" : text
    }
}
