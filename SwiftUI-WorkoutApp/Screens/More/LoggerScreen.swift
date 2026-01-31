#if DEBUG
import OSLog
import SWDesignSystem
import SwiftUI

private final class LogStore: ObservableObject, @unchecked Sendable {
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: LogStore.self)
    )

    @Published private(set) var state = State.empty
    var logs: [State.LogModel] {
        switch state {
        case .empty, .loading: []
        case let .ready(array): array
        }
    }

    /// Все категории, которые есть в логах
    @Published private(set) var categories = [String]()
    /// Все уровни, которые есть в логах
    @Published private(set) var levels = [State.LogModel.Level]()

    func getLogs() async {
        await MainActor.run { state = .loading }
        do {
            let store = try OSLogStore(scope: .currentProcessIdentifier)
            let position = store.position(timeIntervalSinceLatestBoot: 1)
            let entries: [State.LogModel] = try store
                .getEntries(at: position)
                .compactMap { $0 as? OSLogEntryLog }
                .filter { $0.subsystem == Bundle.main.bundleIdentifier! }
                .map {
                    .init(
                        dateString: $0.date.formatted(date: .long, time: .standard),
                        category: $0.category,
                        level: .init(rawValue: $0.level.rawValue) ?? .undefined,
                        message: $0.composedMessage
                    )
                }
            try Task.checkCancellation()
            await MainActor.run {
                categories = Array(Set(entries.map(\.category)))
                levels = Array(Set(entries.map(\.level)))
                state = .ready(entries)
            }
        } catch {
            logger.error("\(error.localizedDescription, privacy: .public)")
            await MainActor.run { state = .empty }
        }
    }

    enum State: Equatable {
        case empty, loading, ready([LogModel])

        var isLoading: Bool {
            self == .loading
        }

        struct LogModel: Identifiable, Equatable {
            let id = UUID()
            let dateString: String
            let category: String
            let level: Level
            let message: String

            enum Level: Int, CaseIterable {
                case undefined = 0
                case debug = 1
                case info = 2
                case notice = 3
                case error = 4
                case fault = 5

                var emoji: String {
                    switch self {
                    case .undefined: "🤨"
                    case .debug: "🛠️"
                    case .info: "ℹ️"
                    case .notice: "💁‍♂️"
                    case .error: "⚠️"
                    case .fault: "⛔️"
                    }
                }
            }
        }
    }
}

struct LoggerScreen: View {
    @StateObject private var logStore = LogStore()
    @State private var categoriesToShow = [String]()
    @State private var levelsToShow = [LogStore.State.LogModel.Level]()
    @State private var showFilter = false
    private var isFilterOn: Bool {
        !categoriesToShow.isEmpty || !levelsToShow.isEmpty
    }

    private var filteredLogs: [LogStore.State.LogModel] {
        if isFilterOn {
            let filterCategories = !categoriesToShow.isEmpty
            let filterLevels = !levelsToShow.isEmpty
            return logStore.logs.filter { log in
                let hasCategory = filterCategories
                    ? categoriesToShow.contains(log.category)
                    : true
                let hasLevel = filterLevels
                    ? levelsToShow.contains(log.level)
                    : true
                return hasCategory && hasLevel
            }
        } else {
            return logStore.logs
        }
    }

    var body: some View {
        contentView
            .animation(.default, value: logStore.state)
            .loadingOverlay(if: logStore.state.isLoading)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Логи")
            .background(Color.swBackground)
            .task { await logStore.getLogs() }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showFilter = true
                    } label: {
                        Icons.Regular.filter.view
                            .symbolVariant(isFilterOn ? .fill : .none)
                    }
                    .tint(.accent)
                    .disabled(logStore.state.isLoading)
                }
            }
            .sheet(isPresented: $showFilter) {
                ContentInSheet(title: "Фильтр логов", spacing: 0) {
                    filterView
                }
            }
    }

    private var contentView: some View {
        ZStack {
            switch logStore.state {
            case .empty:
                Text("Логов пока нет")
            case .loading:
                Text("Загружаем логи...")
            case .ready:
                if filteredLogs.isEmpty {
                    Text("С такими фильтрами логов нет")
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 16) {
                            ForEach(Array(zip(filteredLogs.indices, filteredLogs)), id: \.0) { index, log in
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack(spacing: 8) {
                                        Text(log.level.emoji)
                                        Text(log.dateString)
                                    }
                                    Text(log.category).bold()
                                    Text(log.message)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .multilineTextAlignment(.leading)
                                .withDivider(if: index != filteredLogs.indices.last, spacing: 12)
                            }
                        }
                        .padding([.top, .horizontal])
                    }
                }
            }
        }
    }

    private var filterView: some View {
        ScrollView {
            VStack(spacing: 32) {
                SectionView(header: "Категория", mode: .card()) {
                    VStack(spacing: 0) {
                        ForEach(Array(zip(logStore.categories.indices, logStore.categories)), id: \.0) { index, category in
                            Button {
                                if categoriesToShow.contains(category) {
                                    categoriesToShow = categoriesToShow.filter { $0 != category }
                                } else {
                                    categoriesToShow.append(category)
                                }
                            } label: {
                                TextWithCheckmarkRowView(
                                    text: .init(category),
                                    isChecked: categoriesToShow.contains(category)
                                )
                            }
                            .withDivider(if: index != logStore.categories.endIndex - 1)
                        }
                    }
                }
                SectionView(header: "Уровень", mode: .card()) {
                    VStack(spacing: 0) {
                        ForEach(Array(zip(logStore.levels.indices, logStore.levels)), id: \.0) { index, level in
                            Button {
                                if levelsToShow.contains(level) {
                                    levelsToShow = levelsToShow.filter { $0 != level }
                                } else {
                                    levelsToShow.append(level)
                                }
                            } label: {
                                TextWithCheckmarkRowView(
                                    text: .init(level.emoji),
                                    isChecked: levelsToShow.contains(level)
                                )
                            }
                            .withDivider(if: index != logStore.levels.endIndex - 1)
                        }
                    }
                }
                Button("Сбросить") {
                    categoriesToShow = []
                    levelsToShow = []
                }
                .buttonStyle(SWButtonStyle(mode: .filled, size: .large))
                .disabled(!isFilterOn)
            }
            .padding([.top, .horizontal])
        }
    }
}

#Preview { LoggerScreen() }
#endif
