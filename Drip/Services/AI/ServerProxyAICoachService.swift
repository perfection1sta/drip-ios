import Foundation

// MARK: - Server Proxy AI Coach Service
// Future path: calls a server proxy that holds the API key.
// Enables rate limiting, cost control, and shared key management.
// Currently a stub — swap in when a proxy endpoint is available.

final class ServerProxyAICoachService: AICoachServiceProtocol {

    private let proxyURL: URL

    init(proxyURL: URL) {
        self.proxyURL = proxyURL
    }

    func sendMessage(
        messages: [AIMessage],
        profile: UserProfile?,
        recentWorkouts: [WorkoutSession]
    ) async throws -> AIMessage {
        // TODO: implement when server proxy is live
        // The proxy should accept: { "messages": [...], "profile_context": {...} }
        // and return: { "content": "...", "model": "..." }
        throw AICoachError.networkError("Server proxy not yet configured.")
    }
}
