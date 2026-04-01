import Foundation

// MARK: - Direct API AI Coach Service
// Calls the Claude API directly using the user's own API key stored in Keychain.
// This is the beta path — future versions will use ServerProxyAICoachService.

final class DirectAPIAICoachService: AICoachServiceProtocol {

    private let apiURL = URL(string: "https://api.anthropic.com/v1/messages")!
    private let model = "claude-sonnet-4-6"
    private let maxTokens = 1024
    private let maxHistoryMessages = 20   // context window management

    func sendMessage(
        messages: [AIMessage],
        profile: UserProfile?,
        recentWorkouts: [WorkoutSession]
    ) async throws -> AIMessage {

        guard let apiKey = KeychainService.read(for: .claudeAPIKey), !apiKey.isEmpty else {
            throw AICoachError.noAPIKey
        }

        let systemPrompt = AIPromptBuilder.buildSystemPrompt(
            profile: profile,
            recentWorkouts: recentWorkouts
        )

        // Build the message history — keep last N messages for context window
        let historyMessages = messages
            .filter { $0.role != .system }
            .suffix(maxHistoryMessages)
            .map { msg -> [String: String] in
                let content: String
                if msg.role == .user {
                    content = AIPromptBuilder.wrapUserMessage(msg.content)
                } else {
                    content = msg.content
                }
                return ["role": msg.role.rawValue, "content": content]
            }

        let requestBody: [String: Any] = [
            "model": model,
            "max_tokens": maxTokens,
            "system": systemPrompt,
            "messages": historyMessages
        ]

        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        request.timeoutInterval = 30

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AICoachError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200:
            break
        case 429:
            throw AICoachError.rateLimited
        default:
            let body = String(data: data, encoding: .utf8) ?? ""
            throw AICoachError.networkError("HTTP \(httpResponse.statusCode): \(body)")
        }

        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let content = json["content"] as? [[String: Any]],
              let firstBlock = content.first,
              let text = firstBlock["text"] as? String else {
            throw AICoachError.invalidResponse
        }

        return AIMessage(role: .assistant, content: text)
    }
}
