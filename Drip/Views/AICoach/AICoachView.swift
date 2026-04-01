import SwiftUI
import SwiftData

struct AICoachView: View {
    @Environment(\.modelContext) private var context
    @Environment(AICoachViewModel.self) private var vm
    @Environment(ActiveWorkoutViewModel.self) private var workoutVM
    @Environment(\.scenePhase) private var scenePhase

    @FocusState private var inputFocused: Bool
    @State private var showConversationList = false

    var body: some View {
        ZStack {
            LinearGradient.darkSurface.ignoresSafeArea()

            VStack(spacing: 0) {
                // Nav bar
                navBar

                // Content
                if !vm.hasAPIKey {
                    noAPIKeyState
                } else if let conversation = vm.currentConversation {
                    chatView(conversation: conversation)
                } else {
                    AICoachEmptyState(starterPrompts: vm.starterPrompts) { prompt in
                        vm.inputText = prompt
                        vm.sendMessage(context: context)
                    }
                }
            }

            // Workout suggestion card (floats above chat)
            if let plan = vm.suggestedWorkout {
                VStack {
                    Spacer()
                    AIWorkoutSuggestionCard(
                        plan: plan,
                        onStart: { vm.adoptWorkout(plan, context: context) },
                        onDismiss: { vm.suggestedWorkout = nil }
                    )
                    .padding(.bottom, Spacing.huge)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .onAppear { vm.setup(context: context) }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { vm.refreshAPIKeyState() }
        }
        .sheet(isPresented: $showConversationList) {
            ConversationListView(
                conversations: vm.conversations,
                onSelect: { conv in
                    vm.selectConversation(conv)
                    showConversationList = false
                },
                onDelete: { conv in vm.deleteConversation(conv, context: context) },
                onNew: {
                    vm.startNewConversation(context: context)
                    showConversationList = false
                }
            )
        }
        .fullScreenCover(item: Binding(get: { vm.adoptedWorkout }, set: { vm.adoptedWorkout = $0 })) { (workout: Workout) in
            ActiveWorkoutViewWrapper(workout: workout)
        }
        .animation(.smooth, value: vm.suggestedWorkout != nil)
    }

    // MARK: No API Key State
    private var noAPIKeyState: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()
            Image(systemName: "key.slash")
                .font(.system(size: 48, weight: .light))
                .foregroundStyle(.textTertiary)
            VStack(spacing: Spacing.xs) {
                Text("API Key Required")
                    .font(.titleMedium)
                    .foregroundStyle(.textPrimary)
                Text("Add your Claude API key in Settings → AI Coach to start chatting.")
                    .font(.bodyMedium)
                    .foregroundStyle(.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.xl)
            }
            Spacer()
        }
    }

    // MARK: Nav Bar
    private var navBar: some View {
        HStack {
            Button {
                showConversationList = true
                HapticManager.shared.light()
            } label: {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 18))
                    .foregroundStyle(.textSecondary)
            }

            Spacer()

            HStack(spacing: Spacing.xs) {
                Text("Drip Coach")
                    .font(.titleSmall)
                    .foregroundStyle(.textPrimary)
                BetaBadge()
            }

            Spacer()

            Button {
                vm.startNewConversation(context: context)
                HapticManager.shared.light()
            } label: {
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 18))
                    .foregroundStyle(.textSecondary)
            }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
    }

    // MARK: Chat View
    @ViewBuilder
    private func chatView(conversation: AIConversation) -> some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: Spacing.sm) {
                        ForEach(conversation.messages) { message in
                            ChatBubbleView(message: message)
                                .id(message.id)
                        }

                        if vm.isLoading {
                            AITypingIndicator()
                                .id("typing")
                        }

                        if let error = vm.errorMessage {
                            Text(error)
                                .font(.bodySmall)
                                .foregroundStyle(.error)
                                .padding(.horizontal, Spacing.lg)
                                .multilineTextAlignment(.center)
                        }

                        Color.clear.frame(height: 1).id("bottom")
                    }
                    .padding(.vertical, Spacing.md)
                }
                .onChange(of: conversation.messages.count) { _, _ in
                    withAnimation(.smooth) {
                        proxy.scrollTo("bottom")
                    }
                }
                .onChange(of: vm.isLoading) { _, _ in
                    withAnimation(.smooth) {
                        proxy.scrollTo("bottom")
                    }
                }
            }

            // Input bar
            inputBar
        }
    }

    // MARK: Input Bar
    private var inputBar: some View {
        HStack(spacing: Spacing.sm) {
            TextField("Ask your coach...", text: Binding(
                get: { vm.inputText },
                set: { vm.inputText = $0 }
            ), axis: .vertical)
            .font(.bodyMedium)
            .foregroundStyle(.textPrimary)
            .lineLimit(1...4)
            .focused($inputFocused)
            .submitLabel(.send)
            .onSubmit {
                if !vm.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    vm.sendMessage(context: context)
                }
            }

            Button {
                vm.sendMessage(context: context)
                inputFocused = false
            } label: {
                Image(systemName: vm.isLoading ? "stop.circle.fill" : "arrow.up.circle.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(vm.inputText.isEmpty ? .textTertiary : .energyOrange)
                    .animation(.snappy, value: vm.inputText.isEmpty)
            }
            .disabled(vm.inputText.isEmpty || vm.isLoading)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .background(.ultraThinMaterial)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(Color.surfaceTertiary),
            alignment: .top
        )
    }
}

// MARK: - Conversation List
struct ConversationListView: View {
    let conversations: [AIConversation]
    let onSelect: (AIConversation) -> Void
    let onDelete: (AIConversation) -> Void
    let onNew: () -> Void

    var body: some View {
        NavigationView {
            ZStack {
                Color.surfacePrimary.ignoresSafeArea()
                List {
                    ForEach(conversations) { conv in
                        Button { onSelect(conv) } label: {
                            VStack(alignment: .leading, spacing: Spacing.xxs) {
                                Text(conv.title)
                                    .font(.titleSmall)
                                    .foregroundStyle(.textPrimary)
                                    .lineLimit(1)
                                Text(conv.preview)
                                    .font(.bodySmall)
                                    .foregroundStyle(.textSecondary)
                                    .lineLimit(2)
                                Text(conv.updatedDate, style: .relative)
                                    .font(.caption)
                                    .foregroundStyle(.textTertiary)
                            }
                            .padding(.vertical, Spacing.xxs)
                        }
                        .listRowBackground(Color.surfaceSecondary)
                        .swipeActions { Button(role: .destructive) { onDelete(conv) } label: { Label("Delete", systemImage: "trash") } }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Conversations")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: onNew) {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
        }
    }
}

// MARK: - Active Workout Wrapper
private struct ActiveWorkoutViewWrapper: View {
    let workout: Workout
    @Environment(\.dismiss) private var dismiss
    @Environment(ActiveWorkoutViewModel.self) private var workoutVM
    @Environment(\.modelContext) private var context

    var body: some View {
        ActiveWorkoutView()
            .onAppear {
                workoutVM.startSession(workout: workout, context: context)
            }
    }
}
