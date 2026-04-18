# Документация: In-App Review в SwiftUI-WorkoutApp

## Назначение

Документ описывает текущую реализацию запроса оценки приложения (`requestReview`) в `SwiftUI-WorkoutApp`, чтобы функционал было удобно сопровождать и безопасно расширять.

Цели реализации:

- централизованный контроль показа review;
- соблюдение ограничения Apple: не более одного запроса за сессию приложения;
- предсказуемое поведение при достижении порогов фильтра (2, 5, 15);
- поддержка догоняющего сценария между сессиями (если milestone достигнут в сессии, где запрос уже был показан).

## Архитектура

### Основные компоненты

- `SwiftUI-WorkoutApp/Services/ReviewService.swift`
- `SwiftUI-WorkoutApp/Extensions/View+reviewRequest.swift`
- `SwiftUI-WorkoutApp/SwiftUI_WorkoutAppApp.swift`
- `SwiftUI-WorkoutApp/Screens/Root/RootScreen.swift`

### ReviewService

`ReviewService` (`@MainActor`, `ObservableObject`) отвечает за:

- флаг pending-запроса: `pendingRequest`;
- ограничение «1 запрос за сессию»: `didRequestThisSession`;
- учёт применения фильтра: `reviewFilterApplyCount` в `UserDefaults`;
- учёт завершённых milestone фильтра: `reviewFilterAttemptedMilestones` в `UserDefaults`;
- фиксацию milestone только после фактического consume (`markConsumed()`).

Ключевая идея: milestone фильтра считается завершённым только когда система действительно обработала pending-запрос (через `markConsumed()`), а не в момент достижения счётчика.

### ReviewRequestModifier

`ReviewRequestModifier` подключён на корневом экране и:

- слушает `pendingRequest` через `.task(id: reviewService.pendingRequest)`;
- делает небольшую задержку (`0.8s`) перед вызовом `requestReview()`;
- повторно проверяет pending после задержки;
- вызывает `reviewService.markConsumed()` после вызова `requestReview()`.

## Правила показа review

### Общее правило

- За одну сессию приложения допускается не более одного запроса review.

### Триггеры контентных действий

`reviewService.requestReviewIfAppropriate()` вызывается после успешных операций:

- `ParkFormScreen.saveParkTask` (после `dismiss()`)
- `EventFormScreen.saveEventTask` (после `dismiss()`)
- `JournalsListScreen.update(journal:)`
- `JournalsListScreen.saveNewJournal()` (после `askForJournals(refresh: true)`)
- `JournalEntriesScreen.updateEntriesTask` (после `askForEntries(refresh: true)`)
- `DialogScreen.sendMessageTask` (после `askForMessages(refresh: true)`)

### Триггер фильтра

`ParkFilterScreen.applyButton` вызывает `reviewService.didApplyFilter()` после `dismiss()`.

Milestone для фильтра:

- 2
- 5
- 15

Если milestone достигнут в сессии, где запрос уже был показан по другому событию, milestone не теряется и будет запрошен в следующей сессии при следующем применении фильтра.

## Жизненный цикл pending-запроса

1. Бизнес-точка вызывает `requestReviewIfAppropriate()` или `didApplyFilter()`.
2. `ReviewService` выставляет `pendingRequest = true`, если сессионный лимит не исчерпан.
3. `ReviewRequestModifier` получает pending и вызывает `requestReview()`.
4. После вызова `requestReview()` модификатор вызывает `markConsumed()`.
5. `markConsumed()` сбрасывает pending и фиксирует milestone фильтра (если запрос пришёл из фильтра).

## Интеграция в приложение

- В `SwiftUI_WorkoutAppApp.swift` создан и прокинут `@StateObject reviewService` через `.environmentObject(...)`.
- В `RootScreen.swift` подключён `.reviewRequestHandling()`.

Это гарантирует единый обработчик review на уровне корневого дерева приложения.

## Тестовое покрытие

Файл: `WorkoutAppTests/Services/ReviewServiceTests.swift`.

Покрыто:

- первичный и повторный вызов `requestReviewIfAppropriate()` в одной сессии;
- поведение `markConsumed()`;
- пороги фильтра 2/5/15 и непороговые значения;
- персистентность счётчика и milestone через `UserDefaults(suiteName:)`;
- межсессионный догоняющий сценарий для пропущенного milestone.

## Поддержка и изменения

### Что важно не ломать

- Не фиксировать milestone фильтра до `markConsumed()`.
- Не вызывать `didApplyFilter()` до `dismiss()` в `ParkFilterScreen`.
- Не обходить `ReviewService` прямыми вызовами StoreKit из экранов.

### Как добавлять новую точку триггера

1. В нужном экране получить `@EnvironmentObject private var reviewService: ReviewService`.
2. Вставить вызов `requestReviewIfAppropriate()` строго после успешного завершения бизнес-операции.
3. Обновить превью/DI при необходимости.
4. Добавить/обновить тест в `ReviewServiceTests` или тест экрана, если изменяется порядок вызовов.

### Рекомендованная проверка после изменений

- `make format`
- `make build`
- `make test`
- ручная проверка сценариев:
  - контентный триггер;
  - фильтр на 2/5/15;
  - не более одного запроса в сессии;
  - догоняющий milestone в следующей сессии.
