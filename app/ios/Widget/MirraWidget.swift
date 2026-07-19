import WidgetKit
import SwiftUI

// Must match WidgetService._appGroupId in the Flutter app.
private let appGroupId = "group.com.mirra.affirmations.shared"
private let fallbackText = "You are exactly where you need to be."

struct AffirmationEntry: TimelineEntry {
    let date: Date
    let text: String
    let category: String
}

private func sharedDefaults() -> UserDefaults? { UserDefaults(suiteName: appGroupId) }

private func loadAffirmations() -> [String] {
    guard let raw = sharedDefaults()?.string(forKey: "affirmations"),
          let data = raw.data(using: .utf8),
          let list = try? JSONDecoder().decode([String].self, from: data),
          !list.isEmpty
    else { return [] }
    return list
}

private func loadCategory() -> String {
    sharedDefaults()?.string(forKey: "category") ?? "MIRRA"
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> AffirmationEntry {
        AffirmationEntry(date: Date(), text: fallbackText, category: "MIRRA")
    }

    func getSnapshot(in context: Context, completion: @escaping (AffirmationEntry) -> Void) {
        let items = loadAffirmations()
        completion(AffirmationEntry(date: Date(),
                                    text: items.first ?? fallbackText,
                                    category: loadCategory()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<AffirmationEntry>) -> Void) {
        let items = loadAffirmations()
        let category = loadCategory()
        let now = Date()
        var entries: [AffirmationEntry] = []
        // Rotate through the day's affirmations, changing every 2 hours.
        let count = max(items.count, 1)
        for i in 0..<count {
            let date = Calendar.current.date(byAdding: .hour, value: i * 2, to: now) ?? now
            let text = items.isEmpty ? fallbackText : items[i % items.count]
            entries.append(AffirmationEntry(date: date, text: text, category: category))
        }
        completion(Timeline(entries: entries, policy: .atEnd))
    }
}

struct MirraWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: AffirmationEntry

    var body: some View {
        switch family {
        case .accessoryInline:
            Text(entry.text)
        case .accessoryRectangular:
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.category.uppercased())
                    .font(.caption2).opacity(0.7)
                Text(entry.text)
                    .font(.caption).lineLimit(3).minimumScaleFactor(0.8)
            }
        default:
            VStack(alignment: .leading, spacing: 8) {
                Text(entry.category.uppercased())
                    .font(.caption2).fontWeight(.semibold).opacity(0.65)
                Text(entry.text)
                    .font(family == .systemSmall ? .subheadline : .title3)
                    .fontWeight(.semibold)
                    .minimumScaleFactor(0.6)
                    .lineLimit(family == .systemSmall ? 5 : 4)
                Spacer(minLength: 0)
                Text("Mirra").font(.caption2).opacity(0.5)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .foregroundStyle(.white)
            .containerBackground(for: .widget) {
                LinearGradient(
                    colors: [Color(red: 0.12, green: 0.14, blue: 0.22),
                             Color(red: 0.23, green: 0.17, blue: 0.27)],
                    startPoint: .top, endPoint: .bottom)
            }
        }
    }
}

struct MirraWidget: Widget {
    let kind = "MirraWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            MirraWidgetView(entry: entry)
        }
        .configurationDisplayName("Mirra")
        .description("Your daily affirmation.")
        .supportedFamilies([.systemSmall, .systemMedium,
                            .accessoryRectangular, .accessoryInline])
    }
}

@main
struct MirraWidgetBundle: WidgetBundle {
    var body: some Widget { MirraWidget() }
}
