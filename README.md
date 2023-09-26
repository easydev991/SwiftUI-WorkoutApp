# SW Площадки
[Ссылка на приложение в AppStore](https://workout.su/ios)

## Установка и настройка проекта
1. Клонировать репозиторий
2. В терминале перейти в папку с проектом 
```shell
cd SwiftUI-WorkoutApp
```
3. Настроить адрес папки с хуками `SwiftUI-WorkoutApp/githooks`
```shell
git config core.hooksPath .githooks
```
4. Дать разрешение на запуск хука `pre-commit`
```shell
chmod +x SwiftUI-WorkoutApp/githooks/pre-commit
```
5. Открыть проект в `Xcode` и дождаться загрузки зависимостей
6. Проект готов к работе!

## Помощь проекту
1. Для доработок создаем **issue** с описанием задачи
2. Доработки делаем в отдельных ветках
3. Для каждого **PR** необходимо оставить описание на русском языке по аналогии со старыми **PR**
4. Вопросы по iOS-приложению решаем с Oleg991 в [почте](mailto:o.n.eremenko@gmail.com?subject=[GitHub]-SwiftUI-WorkoutApp) или в [телеграм](http://t.me/oleg991)
5. Вопросы по бэкенду/сайту - c Антоном в [почте](mailto:anton@workout.su?subject=[GitHub]-SwiftUI-WorkoutApp)

## Шпаргалка
### Настройка базовых параметров приложения  
`Xcode -> SwiftUI-WorkoutApp -> Target: SwiftUI-WorkoutApp -> General`
- `Display Name` - название приложения на экране смартфона 
- `Version` - версия приложения для магазина 
- `Build` - версия сборки для `TestFlight` 

### Публикация приложения
#### TestFlight
1. Скачать актуальную версию репозитория
   - Если ранее не скачивал, можно скачать по зеленой кнопке сверху с текстом `Code -> Open with Xcode`
   - Если ранее скачивал, то открываешь `Xcode`, в верхней панели нажать `Source Control -> Pull`
2. Открыть `Xcode` и дождаться загрузки зависимостей; при возникновении ошибок можно:
   -  почистить `Derived Data` и память билда (`command + shift + k`)
   -  обновить зависимости (`File -> Packages -> Reset/Resolve/Update`)
3. В верхней панели Xcode сменить девайс на `Any iOS Device`
4. В верхней панели нажать `Product -> Archive`
5. Дождаться архивации, в открывшемся окне со сборками выбрать нужную и нажать **Distribute App**
6. Пройти по всем шагам и снять галку с автоматического изменения версии сборки на одном из финальных шагов

#### AppStore
1. Открыть страницу с приложением в **AppstoreConnect**
2. В левом меню рядом с версией в статусе **Готово к продаже** нажать `+` и добавить новую версию
3. Заполнить поле **Что нового в этой версии**
4. Ниже в разделе **Сборка** выбрать нужную сборку из `TestFlight`
5. Ниже на странице проверить галки
   - *Выпустить эту версию автоматически*
   - *Выпустить обновление сразу для всех пользователей*
   - *Сохранить текущую оценку*
6. Нажать сверху справа кнопку **Сохранить**
7. Отправить приложение на проверку

### Скриншоты  
1. Генерируем скриншоты при помощи `Fastlane` ([документация](https://docs.fastlane.tools/getting-started/ios/setup/))
2. Настройки для генерации скриншотов находятся в файле [Snapfile](Snapfile) ([документация](https://docs.fastlane.tools/actions/snapshot/))
3. Генерация скриншотов выполняется командой в папке с проектом (команда может отличаться в зависимости от способа установки `fastlane`)
```shell
rbenv exec fastlane snapshot
```
4. Готовые скриншоты сохраняются в папке [screenshots/ru](./screenshots/ru)

| Список площадок | Площадка | Прошедшие мероприятия | Мероприятие | Профиль |
| --- | --- | --- | --- | --- |
| <img src="./screenshots/ru/iPhone 13 Pro Max-1-sportsGroundsList.png"> | <img src="./screenshots/ru/iPhone 13 Pro Max-2-sportsGroundDetails.png"> | <img src="./screenshots/ru/iPhone 13 Pro Max-3-pastEvents.png"> | <img src="./screenshots/ru/iPhone 13 Pro Max-4-eventDetails.png"> | <img src="./screenshots/ru/iPhone 13 Pro Max-5-profile.png"> |

#### Модели девайсов, используемые для скриншотов
- 6.5 дюйма: iPhone 13 Pro Max
- 5.8 дюйма: iPhone 13 Pro
- 5.5 дюйма: iPhone 8 Plus
- 4.7 дюйма: iPhone SE (3rd generation)

### Форматирование кода
- Используем [swiftformat (0.52.4)](https://github.com/nicklockwood/SwiftFormat) для форматирования кода
- Правила форматирования перечислены в файле [.swiftformat](.swiftformat)
- Все правила можно найти [тут](https://github.com/nicklockwood/SwiftFormat/blob/master/Rules.md)

#### Как это работает
1. Перед каждым коммитом должен выполняться хук, проверяющий необходимость форматирования кода
2. При нарушении правил форматирования кода, гит выдаст ошибку и напишет команду, которую нужно выполнить для запуска swiftformat

#### Как обновить `swiftformat`
1. Переходим на [страницу с релизами](https://github.com/nicklockwood/SwiftFormat/releases)
2. Скачиваем `swiftformat.zip`
3. Заменяем в папке с проектом старый файл `swiftformat` на новый
4. При необходимости даем системе разрешение на запуск нового файла в `системных настройках -> конфиденциальность и безопасность`
