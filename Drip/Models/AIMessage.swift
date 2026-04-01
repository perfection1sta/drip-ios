import Foundation

enum AIMessageRole: String, Codable {
    case user      = "user"
    case assistant = "assistant"
    case system    = "system"
}

struct AIMessage: Codable, Identifiable {
    let id: UUID
    let role: AIMessageRole
    let content: String
    let timestamp: Date
    var suggestedWorkoutID: UUID?  // set when assistant suggests a workout

    init(role: AIMessageRole, content: String, suggestedWorkoutID: UUID? = nil) {
        self.id = UUID()
        self.role = role
        self.content = content
        self.timestamp = Date()
        self.suggestedWorkoutID = suggestedWorkoutID
    }
}
