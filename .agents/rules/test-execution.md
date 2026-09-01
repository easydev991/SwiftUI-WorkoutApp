# Правила запуска тестов в SwiftUI-WorkoutApp

## Один прогон → один отчёт

Полный тест-план (`RunAllTests` / `make test`) — один раз в конце задачи или для широких изменений. Повторные полные прогоны ради перечитывания вывода ЗАПРЕЩЕНЫ. Перечитывай вывод уже выполненного прогона: xcode MCP (`GetConsoleOutput`, `GetBuildLog`) или для CLI-прогонов — вердикт последнего xcresult-бандла:

```sh
xcrun xcresulttool get test-results summary --path "$(ls -td ~/Library/Developer/Xcode/DerivedData/SwiftUI-WorkoutApp-*/Logs/Test/*.xcresult | head -1)"
```

## Сначала точечно

- Во время итераций запускай только затронутые тесты: xcode MCP `RunSomeTests` с 1–2 идентификаторами (список — `GetTestList`).
- Фоллбек без MCP: `xcodebuild test -only-testing:<Target/Class/method>` — примеры в AGENTS.md.

## Факты

- Схема: `SwiftUI-WorkoutApp`; тест-план: `SwiftUI-WorkoutApp` (состав таргетов — в AGENTS.md).
- Destination бери из Makefile-переменной `IOS_SIM_DEST` — НЕ хардкодь имена девайсов: они меняются с релизами Xcode.
- Локальные пакеты — `swift test --package-path SwiftUI-WorkoutApp/Libraries/<Package>` (SWModels, SWUtils, SWKeychain, SWNetwork) — быстро, без симулятора.
- Симулятор не загружен → тесты не стартуют. Это ожидаемо, не ретраить.

## Прочее

- После любых изменений кода — `make format` (pre-push хук проверяет `swiftformat --lint`).
- Вывод `make` конденсируется rtk: если вывод нечитаем — `rtk proxy <cmd>`, а не повторный запуск.
