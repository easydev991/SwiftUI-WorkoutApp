# Firebase Analytics Architecture

Документ фиксирует архитектуру и рабочие правила Firebase Analytics/Crashlytics в `SwiftUI-WorkoutApp`.

## 1. Назначение

- Основная цель аналитики: техническая диагностика ошибок и сбоев.
- Аналитика используется как breadcrumbs-контекст для Crashlytics:
  - какой экран был открыт перед сбоем;
  - какие ключевые действия выполнял пользователь;
  - какие ошибки приложения (`app_error`) произошли в сценарии.
- Продуктовая персонализация на базе этих событий не является целью.

## 2. Архитектура

- Единая модель событий: `AnalyticsEvent`
  - `screenView(screen: AppScreen, source: AppScreen? = nil)`
  - `userAction(action: UserAction)`
  - `appError(kind: AppErrorKind, error: Error)`
- Провайдерная схема:
  - `AnalyticsProvider` (протокол)
  - `FirebaseAnalyticsProvider` (отправка в Firebase)
  - `NoopAnalyticsProvider` (тесты/превью/UITest-конфигурации)
- `AnalyticsService` делает fan-out во все подключенные провайдеры.

## 3. Интеграция и DI

- `AnalyticsService` создается в `SwiftUI_WorkoutAppApp`.
- Сервис прокидывается через `Environment` (`\.analyticsService`) для экранов.
- В `View` используется `@Environment(\.analyticsService)`.
- Для экранов используется `View.trackScreen(...)`.
- Для частей вне `Environment` применяется инъекция через `init(analytics:)`.
- Прямые вызовы Firebase SDK из экранов и ViewModel не используются.

## 4. Правила трекинга

- Открытие экранов логируется только через `.trackScreen(...)`.
- `userAction` логируется только для реальных пользовательских действий (например, `Button` action).
- Логирование `userAction` выполняется в точке нажатия:
  - до `guard`;
  - до сетевых вызовов;
  - до ранних `return`.
- Навигационные переходы через `NavigationLink` отдельно как `userAction` не логируются.
- Для `appError` отправляются: `operation`, `error_domain`, `error_code`.
- Для non-fatal ошибок дополнительно вызывается `Crashlytics.crashlytics().record(error:)`.

## 5. Данные и приватность

- События ориентированы на диагностику и не должны содержать PII.
- Запрещено передавать: `user_id`, `username`, email, телефон, текст сообщений/комментариев, координаты/адрес, URL аватаров, сырые поисковые запросы.
- Для `select_*` и фильтров допускаются только безопасные диагностические значения из контролируемых источников (enum, справочники, настройки).
- Для `source` используется типизированный `AnalyticsEvent.AppScreen`, без строковых литералов.

## 6. Текущее покрытие

- `screenView` внедрен на root/tab экранах и ключевых дочерних экранах.
- `userAction` внедрен для основных CTA-кнопок в auth/profile/parks/events/messages/journals/settings.
- `appError` внедрен в приоритетных `catch`-ветках:
  - auth/profile;
  - parks/events;
  - messages/journals.
- Для service/view-model слоя без `Environment` DI закрыт через `init(analytics:)` и единый `analyticsService` из `SwiftUI_WorkoutAppApp`.

## 7. Проверка перед релизом

- Базовая регрессия:
  - `make format`
  - `make test`
- Crashlytics run script должен выполняться только в `Release` (есть guard по `$CONFIGURATION` в build phase).
- Для финальной ручной валидации перед релизом используются Debug/Release проверки и выборочный просмотр событий в Firebase console.

## 8. Критерии поддержки

- Каждый новый экран обязан иметь `.trackScreen(...)`.
- Каждое новое критичное пользовательское действие обязано иметь `userAction`.
- Каждая новая критичная error-ветка обязана логировать `appError`.
- Имена событий остаются сценарными и диагностически полезными.

## 9. Ключевые файлы

- `SwiftUI-WorkoutApp/Services/Analytics/AnalyticsEvent.swift`
- `SwiftUI-WorkoutApp/Services/Analytics/AnalyticsService.swift`
- `SwiftUI-WorkoutApp/Services/Analytics/FirebaseAnalyticsProvider.swift`
- `SwiftUI-WorkoutApp/EnvironmentKeys/AnalyticsServiceEnvironmentKey.swift`
- `SwiftUI-WorkoutApp/Extensions/View+Analytics.swift`
- `SwiftUI-WorkoutApp/SwiftUI_WorkoutAppApp.swift`
