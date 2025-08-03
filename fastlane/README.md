fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios screenshots

```sh
[bundle exec] fastlane ios screenshots
```

Сгенерировать новые локализованные скриншоты

### ios upload_screenshots

```sh
[bundle exec] fastlane ios upload_screenshots
```

Загрузить существующие скриншоты в App Store Connect

### ios make_and_upload_screenshots

```sh
[bundle exec] fastlane ios make_and_upload_screenshots
```

Выполнить первые 2 команды вместе

### ios release

```sh
[bundle exec] fastlane ios release
```

Собрать и отправить сборку в TestFlight

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
