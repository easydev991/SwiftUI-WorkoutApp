# Примеры локализации

## Использование в SwiftUI View

```swift
// Строки передаются напрямую в Text
Text("Settings")
Text("About the app")

// Для нескольких ключей экрана используем подход с точкой
Text("Home.Theme")

// Для ошибок используем префикс Error
Text("Error.Authorize")
```

## Получение локализованной строки

```swift
// Использование String(localized:) для получения локализованной строки
let title = String(localized: "Home.Activity")
let errorMessage = String(localized: "pushUps970")
```

## Локализованные ошибки

```swift
enum NotificationError: Error, LocalizedError {
    case denied
    var errorDescription: String? {
        String(localized: "Error.NotificationPermission")
    }
}
```
