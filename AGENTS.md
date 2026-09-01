# AGENTS.md

## Project Overview

SwiftUI WorkoutApp — iOS street workout app, Swift 6.3, iOS 16+, MVVM architecture, modular structure. Xcode project (`.xcodeproj`) with local Swift Packages under `SwiftUI-WorkoutApp/Libraries/` and external SPM dependencies (e.g. Firebase).

## Build / Format / Test Commands

For app build and tests, use `xcodebuild-mcp` first. Use `make` commands below only as fallback if MCP is unavailable and cannot be fixed.

For app build and tests, use `xcodebuild-mcp` first. Use `make` commands below only as fallback if MCP is unavailable and cannot be fixed.

### Format

```sh
make format
```

A pre-push git hook (`.githooks/pre-push`) enforces `swiftformat --lint .` — unformatted code will be rejected on push.

### Build

```sh
make build
```

### Run all tests

```sh
make test
```

### Run a single test target/class/function

```sh
xcodebuild ... test -only-testing:WorkoutAppTests/DefaultsServiceTests/triggerLogoutManuallyTrueCallsAuthHelper
```

### Swift Package tests

```sh
swift test --package-path SwiftUI-WorkoutApp/Libraries/<Package>   # SWModels, SWUtils, SWKeychain, SWNetwork
```

## Agent Workflow Checklist

1. Study `docs/feature-map.md` for the affected area before changing functionality; update it when behavior changes.
2. Keep the changeset minimal — no speculative refactors.
3. Run `make format` after every code change.
4. Iterate with targeted tests only (`.agents/rules/test-execution.md`); run the full test plan once at the end of a wide change.
5. Changed a local package? Run its `swift test --package-path`.

## Project Structure

```
SwiftUI-WorkoutApp/
├── Screens/               # All screens (Root, Parks, Events, Profile, Messages, More, Common)
├── Services/              # Business logic (DefaultsService, ParksManager, GeocodingService, etc.)
├── Libraries/             # Local Swift Packages
│   ├── SWModels/          # Shared data models (Codable structs)
│   ├── SWNetwork/         # Network layer
│   ├── SWNetworkClient/   # API client (SWClient implementing protocol-based clients)
│   ├── SWUtils/           # Shared utilities
│   ├── SWKeychain/        # Keychain wrapper
│   ├── SWDesignSystem/    # Design system (colors, fonts, components)
│   ├── CachedAsyncImage/  # Async image caching
│   └── ClusteringMapView/ # Map clustering
├── Extensions/            # Swift extensions
├── EnvironmentKeys/       # Custom SwiftUI environment keys
├── PreviewContent/        # SwiftUI preview data
├── Resources/             # Assets and resources
├── WorkoutAppTests/       # Unit tests (repo root)
└── WorkoutAppUITests/     # UI tests (repo root)
```

ViewModels live as extensions in the same file or a `+ViewModel.swift` file next to their screen.

## Architecture & Patterns

- **MVVM**: Views → ViewModel (ObservableObject) → Service/Manager → Client
- **DI**: `@EnvironmentObject` for passing services/view models down the hierarchy
- **Single user**: Only one user at a time; logout clears all user data
- **Network layer**: Protocol-based client interfaces in `SWNetworkClient` package (`Sources/SWNetworkClient/Protocols/`). `SWClient` conforms to all client protocols
- **State management**: `@State` for local, `@Published` + `ObservableObject` for view models, `@AppStorage` for UserDefaults, `@KeychainWrapper` for Keychain, `SWFileManager` for JSON file storage

## Code Style Guidelines

### Imports

- Sort imports alphabetically (swiftformat `sortImports`)
- `@testable import` last in test files
- Framework imports first (`import Foundation`, `import SwiftUI`), then project modules (`import SWModels`)

### Formatting (.swiftformat)

- Max line width: 140 characters, trailing/semicolons: never
- `self`: only in `init` and closures
- `#if`/`#endif`: no indent; braces: same-line
- `@ViewBuilder` only for conditional logic (`if/else`) or multiple views — NOT for simple containers

### Naming & Type Conventions

- **ViewModels**: `SomeScreen.ViewModel` (nested type) or `SomeScreen+ViewModel.swift` (extension); `@MainActor final class ... : ObservableObject`
- **Services/Managers**: `SomethingService` / `SomethingManager`; with mutable state: `final class`, without: `struct`
- **Models**: `struct` with `Codable`, suffix `Response` for API response models
- **One file = one component/type**
- **View properties without params**: `var someView: some View`
- **View factory methods with params**: `func makeSomeView(for:) -> some View`
- **Test descriptions**: Use `@Test("description in Russian")`

### Error Handling & Logging

- **NEVER** force unwrap (`!`) — use `guard let`, `if let`, `??`, optional chaining
- In tests: `try #require(optionalValue)`
- Use `OSLog` (`Logger`), NOT `print()` or TODO comments
- Logger: `Logger(subsystem: Bundle.main.bundleIdentifier!, category: "ClassName")`

### Testing

- Swift Testing framework (`import Testing`, `@Test`, `#expect`, `#require`) — NOT XCTest
- Test structs (not classes): `struct SomeTests { ... }`
- Mocks go in `WorkoutAppTests/Mocks/` or alongside test files
- TDD: write failing test → implement minimum code → `make format && make test` → refactor

## Quirks

- Do not pin tool versions or device names anywhere (they change with Xcode releases): versions live in `README.md` badges (auto-updated by `make update_readme_versions`), simulator destination — in the Makefile variable `IOS_SIM_DEST`.

## Prohibited Actions

- Do NOT use UIKit when SwiftUI suffices (UIKit acceptable when SwiftUI cannot provide needed functionality)
- Do NOT use Core Data
- Do NOT leave unused code after refactoring
- Do NOT add unused methods/functions "just in case"
- Do NOT modify files outside this project without explicit approval
