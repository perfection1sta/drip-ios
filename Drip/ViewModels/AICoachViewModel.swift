import SwiftUI
import SwiftData

@Observable
final class AICoachViewModel {

    // MARK: State
    var conversations: [AIConversation] = []
    var currentConversation: AIConversation?
    var inputText: String = ""
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var suggestedWorkout: WorkoutPlan? = nil
    var adoptedWorkout: Workout? = nil

    // Suggested starter prompts shown on empty state
    let starterPrompts = [
        "Build me a 30-minute workout for today",
        "My lower back is tight — what should I avoid?",
        "How should I structure my week?",
        "I only have 20 minutes, what can I do?",
        "Help me with a recovery day routine"
    ]

    var hasAPIKey: Bool = false

    private var service: AICoachServiceProtocol = DirectAPIAICoachService()
    private var modelContext: ModelContext?

    // MARK: - Setup

    func setup(context: ModelContext) {
        self.modelContext = context
        hasAPIKey = KeychainService.hasAPIKey
        loadConversations(context: context)
    }

    func refreshAPIKeyState() {
        hasAPIKey = KeychainService.hasAPIKey
    }

    // MARK: - Conversations

    func loadConversations(context: ModelContext) {
        var descriptor = FetchDescriptor<AIConversation>(
            sortBy: [SortDescriptor(\.updatedDate, order: .reverse)]
        )
        descriptor.fetchLimit = 50
        conversations = (try? context.fetch(descriptor)) ?? []
    }

    func startNewConversation(context: ModelContext) {
        let conv = AIConversation()
        context.insert(conv)
        try? context.save()
        currentConversation = conv
        conversations.insert(conv, at: 0)
        suggestedWorkout = nil
    }

    func selectConversation(_ conversation: AIConversation) {
        currentConversation = conversation
        suggestedWorkout = nil
        // Check if the last assistant message had a workout suggestion
        if let last = conversation.messages.last(where: { $0.role == .assistant }) {
            let parsed = AIResponseParser.parse(last.content)
            suggestedWorkout = parsed.suggestedWorkout
        }
    }

    func deleteConversation(_ conversation: AIConversation, context: ModelContext) {
        conversations.removeAll { $0.id == conversation.id }
        if currentConversation?.id == conversation.id {
            currentConversation = nil
        }
        context.delete(conversation)
        try? context.save()
    }

    // MARK: - Sending Messages

    func sendMessage(context: ModelContext) {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isLoading else { return }

        // Create conversation if none active
        if currentConversation == nil {
            startNewConversation(context: context)
        }
        guard let conversation = currentConversation else { return }

        // Append user message
        let userMessage = AIMessage(role: .user, content: text)
        var messages = conversation.messages
        messages.append(userMessage)
        conversation.messages = messages

        // Auto-title from first message
        if conversation.title == "New Conversation" {
            conversation.title = String(text.prefix(40)) + (text.count > 40 ? "…" : "")
        }

        inputText = ""
        isLoading = true
        errorMessage = nil
        HapticManager.shared.light()

        // Fetch profile and recent workouts for context
        let profile = (try? context.fetch(FetchDescriptor<UserProfile>()))?.first
        var sessionDesc = FetchDescriptor<WorkoutSession>(
            sortBy: [SortDescriptor(\.startDate, order: .reverse)]
        )
        sessionDesc.fetchLimit = 5
        let recentWorkouts = (try? context.fetch(sessionDesc)) ?? []

        Task { @MainActor in
            do {
                let response = try await service.sendMessage(
                    messages: messages,
                    profile: profile,
                    recentWorkouts: recentWorkouts
                )

                // Parse for workout suggestion
                let parsed = AIResponseParser.parse(response.content)
                let displayMessage = AIMessage(role: .assistant, content: parsed.text)

                var updated = conversation.messages
                updated.append(displayMessage)
                conversation.messages = updated

                if let plan = parsed.suggestedWorkout {
                    suggestedWorkout = plan
                    HapticManager.shared.success()
                } else {
                    HapticManager.shared.selection()
                }

                try? context.save()
                loadConversations(context: context)

                // Prune old conversations
                SwiftDataService.shared.pruneAIConversations(context: context)

            } catch let error as AICoachError {
                errorMessage = error.errorDescription
                HapticManager.shared.error()
            } catch {
                errorMessage = "Something went wrong. Please try again."
                HapticManager.shared.error()
            }
            isLoading = false
        }
    }

    // MARK: - Adopt AI Workout

    func adoptWorkout(_ plan: WorkoutPlan, context: ModelContext) {
        let exercises = (try? context.fetch(FetchDescriptor<Exercise>())) ?? []
        let profile = (try? context.fetch(FetchDescriptor<UserProfile>()))?.first

        guard let workout = AIResponseParser.buildWorkout(from: plan, exercises: exercises, profile: profile) else {
            errorMessage = "Couldn't build this workout — some exercises weren't found in your library."
            return
        }

        context.insert(workout)
        try? context.save()
        adoptedWorkout = workout
        suggestedWorkout = nil
        HapticManager.shared.success()
    }
}
