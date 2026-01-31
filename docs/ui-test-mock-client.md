# Мок-клиент для UI-тестов

## Цель

Мок-клиент для UI-тестов, который:

- Отвечает на все запросы мгновенно (без задержек)
- Возвращает только успешные ответы
- Полностью заменяет сетевые запросы (никакой зависимости от сервера)
- Используется только при аргументе запуска "UITest"
- Отключает анимации для стабильности скриншотов

## Архитектура

### Структура файлов

- `PreviewContent/Client+.swift` - моки с поддержкой `instantResponse`
- `PreviewContent/MockSWClient.swift` - единый мок-клиент
- `PreviewContent/MockAuthHelper.swift` - мок-хелпер авторизации (наследуется от `AuthHelperImp`)

### Протоколы клиентов

Созданы 10 протоколов для групп функциональности SWClient в папке `Libraries/SWNetworkClient/Sources/SWNetworkClient/Protocols/`:

- `AuthClient` - авторизация и регистрация
- `ProfileClient` - профиль пользователя
- `FriendsClient` - друзья и черный список
- `CountriesClient` - справочник стран
- `ParksClient` - площадки (включает `ParksUpdaterClient`)
- `CommentsClient` - комментарии
- `EventsClient` - мероприятия
- `MessagesClient` - сообщения и диалоги
- `JournalsClient` - дневники
- `PhotosClient` - фотографии

### Моки для каждого протокола

Все моки в `PreviewContent/Client+.swift` поддерживают параметр `instantResponse`:

- `MockAuthClient`
- `MockProfileClient`
- `MockFriendsClient`
- `MockCountriesClient`
- `MockParksClient`
- `MockCommentsClient`
- `MockEventsClient`
- `MockMessagesClient`
- `MockJournalsClient`
- `MockPhotosClient`

Параметр `instantResponse: Bool = false` добавлен в инициализатор каждого мока. `Task.sleep` применяется только если `instantResponse == false`. По умолчанию `instantResponse = false` (сохраняется текущее поведение для превью).

### Единый MockSWClient

`MockSWClient` в `PreviewContent/MockSWClient.swift` реализует все протоколы через делегирование вызовов соответствующим мок-клиентам. Инициализатор принимает `instantResponse: Bool = true` (по умолчанию мгновенные ответы для UI-тестов).

### MockAuthHelper

`MockAuthHelper` в `PreviewContent/MockAuthHelper.swift` наследуется от `AuthHelperImp` и переопределяет методы для мок-поведения (без использования Keychain). Хранит данные авторизации в памяти.

## Инициализация приложения для UI-тестов

В `init()` приложения (`SwiftUI_WorkoutAppApp.swift`) используется условная инициализация:

- При аргументе "UITest" (проверяется через `Constants.isUITest`): создаются `MockAuthHelper` и передается флаг `isUITest: true` в ViewModels
- Отключаются анимации (`UIView.setAnimationsEnabled(false)`)
- Очищаются UserDefaults для чистого состояния (`UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!))`)

## Использование в экранах

ViewModels создают клиент локально в методах, используя флаг `isUITest` и `authHelper`:

```swift
#if DEBUG
let client: SomeClient = isUITest
    ? MockSWClient(instantResponse: true)
    : SWClient(with: authHelper)
#else
let client: SomeClient = SWClient(with: authHelper)
#endif
```

Флаг `isUITest` передается в ViewModels через конструкторы при инициализации приложения.

## Поведение при запуске UI-тестов

При запуске UI-тестов с аргументом "UITest":

- Приложение использует мок-клиент для всех операций
- Все запросы обрабатываются мгновенно (`instantResponse: true`)
- Авторизация работает через `MockAuthHelper` (без Keychain)
- Анимации отключены для скорости выполнения тестов
- UserDefaults очищены для чистого состояния
- Приложение полностью независимо от сервера для UI-тестов

## Экраны для скриншотов

1. **ParksMapScreen** - карта площадок
2. **ParksListScreen** - список площадок
3. **ParkDetailScreen** - детальный экран площадки
4. **EventsListScreen** - список мероприятий (прошедшие)
5. **EventDetailsScreen** - детальный экран мероприятия
6. **UserDetailsScreen** - профиль пользователя (после авторизации и поиска)
