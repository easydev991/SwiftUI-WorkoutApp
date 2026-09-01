# Справочник команд запуска тестов

Текущие правила (точечно → полный прогон один раз) — см. `.agents/rules/test-execution.md`. Здесь — справочник команд.

## Точечный прогон (основной путь во время итераций)

- xcode MCP: `GetTestList` → `RunSomeTests` (1–2 идентификатора)
- Фоллбек:

```sh
xcodebuild -project SwiftUI-WorkoutApp.xcodeproj -scheme SwiftUI-WorkoutApp \
  -sdk iphonesimulator -destination '<IOS_SIM_DEST из Makefile>' \
  test -testPlan SwiftUI-WorkoutApp -only-testing:WorkoutAppTests/DefaultsServiceTests
```

## Полный прогон (фоллбек, один раз в конце)

```sh
make test
```

Тест-план `SwiftUI-WorkoutApp`: WorkoutAppTests, SWNetworkTests, SWModelsTest, CachedAsyncImageTests, SWUtilsTests, SWKeychainTests, ClusteringMapViewTests.

## Локальные пакеты (без симулятора, быстро)

```sh
swift test --package-path SwiftUI-WorkoutApp/Libraries/SWModels
swift test --package-path SwiftUI-WorkoutApp/Libraries/SWUtils
swift test --package-path SwiftUI-WorkoutApp/Libraries/SWKeychain
swift test --package-path SwiftUI-WorkoutApp/Libraries/SWNetwork
```

## После изменений кода

`make format` — обязательно (pre-push хук проверяет `swiftformat --lint`).
