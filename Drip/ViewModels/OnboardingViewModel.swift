import SwiftUI
import SwiftData

enum OnboardingStep: Int, CaseIterable {
    case welcome        = 0
    case archetype      = 1
    case experience     = 2
    case equipment      = 3
    case goals          = 4
    case injuries       = 5
    case preferences    = 6
    case complete       = 7

    var title: String {
        switch self {
        case .welcome:     return "Welcome to Drip"
        case .archetype:   return "Your Training Style"
        case .experience:  return "Your Experience"
        case .equipment:   return "Your Equipment"
        case .goals:       return "Your Goals"
        case .injuries:    return "Any Injuries?"
        case .preferences: return "Your Schedule"
        case .complete:    return "You're All Set"
        }
    }

    var headline: String {
        switch self {
        case .welcome:     return "What should we call you?"
        case .archetype:   return "What kind of training gets you fired up?"
        case .experience:  return "How long have you been training?"
        case .equipment:   return "What do you have to work with?"
        case .goals:       return "What are you working towards?"
        case .injuries:    return "Any areas we should be careful with?"
        case .preferences: return "How often do you want to train?"
        case .complete:    return "Let's get to work."
        }
    }

    var subtitle: String? {
        switch self {
        case .injuries:    return "This helps your AI Coach suggest safe exercises."
        case .preferences: return "We'll build your schedule around your life."
        default:           return nil
        }
    }

    var isOptional: Bool {
        self == .injuries
    }
}

@Observable
final class OnboardingViewModel {

    // MARK: Navigation
    var currentStep: OnboardingStep = .welcome
    var isTransitioning = false

    // MARK: Step data
    var name: String = ""
    var selectedArchetype: UserArchetype? = nil
    var selectedExperience: DifficultyLevel = .intermediate
    var selectedEquipment: Set<Equipment> = []
    var selectedGoals: Set<FitnessGoal> = []
    var selectedInjuries: Set<InjuryArea> = []
    var injuryNotes: String = ""
    var preferredDurationMinutes: Int = 45
    var preferredFrequencyDays: Int = 4
    var preferredWorkoutDays: Set<Int> = [2, 3, 4, 5] // Mon-Thu

    // MARK: Derived
    var canAdvance: Bool {
        switch currentStep {
        case .welcome:     return name.trimmingCharacters(in: .whitespaces).count >= 2
        case .archetype:   return selectedArchetype != nil
        case .experience:  return true
        case .equipment:   return !selectedEquipment.isEmpty
        case .goals:       return !selectedGoals.isEmpty
        case .injuries:    return true  // optional
        case .preferences: return preferredFrequencyDays >= 1
        case .complete:    return true
        }
    }

    var progress: Double {
        let total = Double(OnboardingStep.complete.rawValue)
        return Double(currentStep.rawValue) / total
    }

    // Equipment options filtered by chosen archetype
    var relevantEquipment: [Equipment] {
        guard let archetype = selectedArchetype else { return Equipment.allCases }
        return Equipment.allCases.filter { $0.relevantArchetypes.contains(archetype) || $0 == .bodyweight }
    }

    // Goals filtered by archetype
    var relevantGoals: [FitnessGoal] {
        guard let archetype = selectedArchetype else { return FitnessGoal.allCases }
        return FitnessGoal.allCases.filter { $0.relevantArchetypes.contains(archetype) }
    }

    // MARK: Navigation
    func advance() {
        guard canAdvance, currentStep != .complete else { return }
        withAnimation(.snappy) {
            currentStep = OnboardingStep(rawValue: currentStep.rawValue + 1) ?? .complete
        }
        // Pre-select archetype defaults when archetype is chosen
        if currentStep == .equipment, let archetype = selectedArchetype, selectedEquipment.isEmpty {
            selectedEquipment = Set(archetype.defaultEquipment)
        }
        if currentStep == .goals, let archetype = selectedArchetype, selectedGoals.isEmpty {
            selectedGoals = Set(archetype.defaultGoals)
        }
    }

    func goBack() {
        guard currentStep.rawValue > 0 else { return }
        withAnimation(.snappy) {
            currentStep = OnboardingStep(rawValue: currentStep.rawValue - 1) ?? .welcome
        }
    }

    // MARK: Completion
    func completeOnboarding(context: ModelContext) {
        let profile: UserProfile
        if let existing = (try? context.fetch(FetchDescriptor<UserProfile>()))?.first {
            profile = existing
        } else {
            profile = UserProfile()
            context.insert(profile)
        }

        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        profile.name = trimmedName.isEmpty ? "Athlete" : trimmedName
        profile.archetype = selectedArchetype ?? .gymBro
        profile.fitnessLevel = selectedExperience
        profile.availableEquipment = Array(selectedEquipment)
        profile.fitnessGoals = Array(selectedGoals)
        profile.injuries = Array(selectedInjuries)
        profile.injuryNotes = injuryNotes
        profile.preferredWorkoutDurationMinutes = preferredDurationMinutes
        profile.weeklyGoalDays = preferredFrequencyDays
        profile.preferredWorkoutDaysRaw = Array(preferredWorkoutDays).sorted()
        profile.hasCompletedOnboarding = true

        // Reseed exercises for chosen archetype
        SwiftDataService.shared.reseedForArchetype(profile.archetype, context: context)

        try? context.save()

        withAnimation(.bouncy) {
            currentStep = .complete
        }
    }
}
