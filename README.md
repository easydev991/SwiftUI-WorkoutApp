# SW Площадки
[Ссылка на приложение в AppStore](https://itunes.apple.com/us/app/jobsy/id1035159361)

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
2. Открыть `Xcode` и дождаться загрузки зависимостей; при возникновении ошибок можно:
   -  почистить `Derived Data` и память билда (`command + shift + k`)
   -  обновить зависимости (`File -> Packages -> Reset/Resolve/Update`)
3. В верхней панели Xcode сменить девайс на `Any iOS Device `
4. `Product` -> `Archive`
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
3. Готовые скриншоты сохраняются в папке [screenshots/ru](./screenshots/ru)

| Список площадок | Площадка | Прошедшие мероприятия | Мероприятие | Профиль |
| --- | --- | --- | --- | --- |
| <img src="./screenshots/ru/iPhone 13 Pro Max-1-sportsGroundsList.png"> | <img src="./screenshots/ru/iPhone 13 Pro Max-2-sportsGroundDetails.png"> | <img src="./screenshots/ru/iPhone 13 Pro Max-3-pastEvents.png"> | <img src="./screenshots/ru/iPhone 13 Pro Max-4-eventDetails.png"> | <img src="./screenshots/ru/iPhone 13 Pro Max-5-profile.png"> |

#### Модели девайсов, используемые для скриншотов
- 6.5 дюйма: iPhone 13 Pro Max
- 5.8 дюйма: iPhone 13 Pro
- 5.5 дюйма: iPhone 8 Plus
- 4.7 дюйма: iPhone SE (3rd generation)
