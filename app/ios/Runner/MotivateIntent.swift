import AppIntents
import Foundation

// Must match WidgetService._appGroupId in the Flutter app and the widget.
private let mirraAppGroupId = "group.com.mirra.affirmations.shared"
private let mirraFallback = "You are exactly where you need to be."

/// Pulls an affirmation to speak. Prefers a per-type store when a type is asked
/// for, otherwise reads the shared feed the app mirrors for the widget.
@available(iOS 16.0, *)
private func mirraAffirmation(for type: MirraAffirmationType?) -> String {
    let defaults = UserDefaults(suiteName: mirraAppGroupId)

    if let type, type != .surprise,
       let raw = defaults?.string(forKey: "affirmations_by_category"),
       let data = raw.data(using: .utf8),
       let map = try? JSONDecoder().decode([String: [String]].self, from: data),
       let list = map[type.rawValue], !list.isEmpty {
        return list.randomElement() ?? mirraFallback
    }

    if let raw = defaults?.string(forKey: "affirmations"),
       let data = raw.data(using: .utf8),
       let list = try? JSONDecoder().decode([String].self, from: data),
       !list.isEmpty {
        return list.randomElement() ?? mirraFallback
    }

    return mirraFallback
}

/// The kinds of affirmation Siri can be asked for (mirrors the in-app screen).
@available(iOS 16.0, *)
enum MirraAffirmationType: String, AppEnum {
    case surprise
    case morning
    case positive
    case love
    case work
    case sports
    case workout

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Affirmation type")
    static var caseDisplayRepresentations: [MirraAffirmationType: DisplayRepresentation] = [
        .surprise: "Surprise me",
        .morning: "Morning",
        .positive: "Positive energy",
        .love: "Love",
        .work: "Work",
        .sports: "Sports",
        .workout: "Workout",
    ]
}

/// "Hey Siri, motivate me" — Siri reads one of your affirmations aloud.
@available(iOS 16.0, *)
struct MotivateMeIntent: AppIntent {
    static var title: LocalizedStringResource = "Motivate me"
    static var description = IntentDescription("Mirra reads you an affirmation.")
    static var openAppWhenRun = false

    @Parameter(title: "Type")
    var type: MirraAffirmationType?

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let text = mirraAffirmation(for: type)
        return .result(dialog: IntentDialog(stringLiteral: text))
    }
}

/// Registers the phrase with Siri automatically — no "Add to Siri" tap needed.
@available(iOS 16.0, *)
struct MirraAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: MotivateMeIntent(),
            phrases: [
                "Motivate me with \(.applicationName)",
                "\(.applicationName) motivate me",
                "Give me an affirmation with \(.applicationName)",
                "Read me an affirmation with \(.applicationName)",
                "Inspire me with \(.applicationName)",
            ],
            shortTitle: "Motivate me",
            systemImageName: "sparkles"
        )
    }
}
