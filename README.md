# Street Workout Площадки

<!-- BEGIN_VERSIONS -->
[<img alt="Xcode Version" src="https://img.shields.io/badge/Xcode_Version-26.6-blue">](https://developer.apple.com/xcode/)
[<img alt="Swift Version" src="https://img.shields.io/badge/Swift_Version-6.3.0-orange">](https://swift.org)
[<img alt="iOS Version" src="https://img.shields.io/badge/iOS_Version-16.0-4F9153">](https://www.apple.com/ios/)
<!-- END_VERSIONS -->
[![GitMCP](https://img.shields.io/endpoint?url=https://gitmcp.io/badge/easydev991/SwiftUI-WorkoutApp)](https://gitmcp.io/easydev991/SwiftUI-WorkoutApp)

## Реализованный функционал

Описание всех экранов и функций приложения доступно в [карте экранов и функционала](docs/feature-map.md).

## Помощь в разработке

Прежде чем что-то делать, ознакомься с [правилами](.github/CONTRIBUTING.md), пожалуйста.

## Скриншоты  

1. Генерируем скриншоты при помощи `Fastlane` ([документация](https://docs.fastlane.tools/getting-started/ios/setup/))
2. Настройки для генерации скриншотов находятся в [Snapfile](./fastlane/Snapfile) ([документация](https://docs.fastlane.tools/actions/snapshot/))
3. Для генерации скриншотов нужно предварительно [настроить проект](docs/setup-guide.md)
4. Генерация скриншотов выполняется командой:

```shell
make screenshots
```

5. Для генерации скриншотов **необходимо наличие в Xcode симуляторов с нужной версией iOS** в соответствие с настройками в [Snapfile](./fastlane/Snapfile)
6. Если тесты падают с ошибкой при запуске через `fastlane`, нужно убедиться, что при ручном запуске тестов из `Xcode` они успешно проходят во всех локализациях, используемых для создания скриншотов
7. Готовые скриншоты сохраняются в папке [screenshots](./fastlane/screenshots)
8. Отправить скриншоты в appstoreconnect можно командой:

```shell
make upload_screenshots
```

### iPhone

| Карта с площадками | Список площадок | Площадка | Прошедшие мероприятия | Мероприятие | Профиль |
| --- | --- | --- | --- | --- | --- |
| <img src="./fastlane/screenshots/ru/iPhone 15 Pro Max-0-parksMap.png"> | <img src="./fastlane/screenshots/ru/iPhone 15 Pro Max-1-parksList.png"> | <img src="./fastlane/screenshots/ru/iPhone 15 Pro Max-2-parkDetails.png"> | <img src="./fastlane/screenshots/ru/iPhone 15 Pro Max-3-pastEvents.png"> | <img src="./fastlane/screenshots/ru/iPhone 15 Pro Max-4-eventDetails.png"> | <img src="./fastlane/screenshots/ru/iPhone 15 Pro Max-5-profile.png"> |

### iPad

| Карта с площадками | Список площадок | Площадка | Прошедшие мероприятия | Мероприятие | Профиль |
| --- | --- | --- | --- | --- | --- |
| <img src="./fastlane/screenshots/ru/iPad Pro (12.9-inch) (6th generation)-0-parksMap.png"> | <img src="./fastlane/screenshots/ru/iPad Pro (12.9-inch) (6th generation)-1-parksList.png"> | <img src="./fastlane/screenshots/ru/iPad Pro (12.9-inch) (6th generation)-2-parkDetails.png"> | <img src="./fastlane/screenshots/ru/iPad Pro (12.9-inch) (6th generation)-3-pastEvents.png"> | <img src="./fastlane/screenshots/ru/iPad Pro (12.9-inch) (6th generation)-4-eventDetails.png"> | <img src="./fastlane/screenshots/ru/iPad Pro (12.9-inch) (6th generation)-5-profile.png"> |

### Модели девайсов, используемые для скриншотов

По состоянию на 2025 год Apple берет за основу скриншоты для диагонали 6.9 (или 6.7) дюймов для айфона (13 дюймов для айпада) и масштабирует их под все остальные размеры экранов, то есть можно использовать для скриншотов по одному девайсу на платформу:

- iPhone 15 Pro Max
- iPad Pro (12.9-inch) (6th generation)

Список всех существующих девайсов есть [тут](https://iosref.com/res).

## Документация

- [Установка и настройка](docs/setup-guide.md) - подробная инструкция по настройке проекта
- [Публикация приложения](docs/deployment.md) - инструкции по сборке и публикации в AppStore
- Остальная документация есть в папке [docs](docs)
