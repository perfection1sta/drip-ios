import Foundation

// MARK: - AI Coach Service Protocol
// Abstracts the transport layer so ViewModels don't care whether
// we're calling the API directly or via a server proxy.

protocol AICoachServiceProtocol {
    func sendMessage(
        messages: [AIMessage],
        profile: UserProfile?,
        recentWorkouts: [WorkoutSession]
    ) async throws -> AIMessage
}

// MARK: - Errors

enum AICoachError: LocalizedError {
    case noAPIKey
    case rateLimited
    case networkError(String)
    case invalidResponse
    case contentFiltered

    var errorDescription: String? {
        switch self {
        case .noAPIKey:
            return "No API key found. Add your Claude API key in Settings → AI Coach."
        case .rateLimited:
            return "Too many requests. Please wait a moment before sending another message."
        case .networkError(let msg):
            return "Network error: \(msg)"
        case .invalidResponse:
            return "Received an unexpected response. Please try again."
        case .contentFiltered:
            return "Message couldn't be processed. Please rephrase and try again."
        }
    }
}
