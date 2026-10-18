# План: устранение таймаутов -1001 при работе с workout.su API

Статус: реализован полностью. Вся реализация — в одном коммите «Реализация доработки» от 18.10.2026; промежуточные коммиты по шагам, на которые ссылались ранние редакции плана, в текущей истории отсутствуют, их функциональное содержание отражено в сообщении этого коммита. Тесты пакета SWNetwork — 49/49 (после шага 5г; до шага 5 в плане фигурировало «40/40»), `MainUserProfileScreenViewModelTests` — 6 тестов, `DialogsListScreenViewModelTests` — 3 теста (после правок по ревью: тест очереди refresh и тест снятия флага загрузки в обоих сьютах, у диалогов ещё тест сохранения списка при офлайн-refresh; офлайн-тесты шага 5в удалены вместе с параметром). Полный тест-план 690/690 (18.10.2026, до правок ревью — 689/689). Обновлён 18.10.2026. Исходный опыт Android — в Jetpack-WorkoutApp от 17.10.2026 (классификация инфра-404).

## 1. Симптомы

При открытом приложении запросы к `https://workout.su/api/v3/...` (`/dialogs`, `/friends/requests`, `/users/{id}`, `/users/{id}/friends`, `/blacklist`) висят и падают с `URLError -1001` («Превышен лимит времени на запрос»). На экране профиля авторизованного пользователя — серия ошибок, затем «Устанавливаем состояние .ready (есть кэшированные данные)» и снова ошибка от фонового обновления. В Android-версии тех же функций ошибок нет.

## 2. Диагноз

### 2.1 iOS (SwiftUI-WorkoutApp)

Сетевой слой: plain `URLSession`, без Alamofire.

| Параметр | Значение | Где |
|---|---|---|
| Таймаут запроса (idle) | 30 с | `Libraries/SWNetwork/Sources/SWNetwork/Public/SWNetwork.swift:18-22` |
| Таймаут ресурса (общий) | 60 с | там же `:19-23` |
| Сессия | **новая на каждую операцию** — `SWClient.init` создаёт `SWNetworkService()` → новый `URLSession`, новый пул соединений, новый TCP+TLS handshake | `Libraries/SWNetworkClient/Sources/SWNetworkClient/SWClient.swift:15`; комментарий «Создаем новый клиент для каждого запроса» — `Screens/Profile/MainUserProfileScreen+ViewModel.swift:42-50` |
| Ретраи/backoff | отсутствуют | — |
| Маппинг `.timedOut` | отсутствует — сырой `URLError` уходит в алерт | `SWNetwork.swift:154-178` (ветка `default`) |

Поток запросов при старте/открытии профиля авторизованного пользователя:

1. Открытие вкладки при отсутствии данных или после фона (`needUpdateUser = true`): `.task` → `getSocialUpdates` — **4 параллельных** запроса (`users/{id}`, `users/{id}/friends`, `friends/requests`, `blacklist`) — `Screens/Profile/MainUserProfileScreen+ViewModel.swift`, `Libraries/SWNetworkClient/Sources/SWNetworkClient/Protocols/ProfileClient.swift:41-52`. Повторное открытие вкладки в `.ready` без `needUpdateUser` сеть не тревожит (`shouldLoad`, `MainUserProfileScreen+ViewModel.swift:94-100`).
2. Плюс `/dialogs` из двух независимых путей: `.task(id: isAuthorized)` — при старте приложения и при смене `isAuthorized` (`SwiftUI_WorkoutAppApp.swift:97`) — и `updateDialogsIfNeeded` при переходе приложения в `.active` (там же `:144-152`). Проверка сети (`isNetworkConnected` env + `SWAlert.presentNoConnection`) стоит только в точках, инициируемых пользователем: профиль — включая путь вкладки `.task` (`MainUserProfileScreen.swift:31, 133`), диалоги — только refresh-кнопка и pull-to-refresh (`Screens/Messages/DialogsListScreen.swift`); оба пути — первичная загрузка из `.task(id:)` и фоновый `updateDialogsIfNeeded` — идут в сеть без проверки (guard `shouldUpdateDialogsAndProfile` — только фаза, `SwiftUI_WorkoutAppApp.swift:32-34`).
3. Плюс **дубль всей четвёрки** при переходе приложения в `.active` (`updateProfileIfNeeded`, `refresh: true`) — `SwiftUI_WorkoutAppApp.swift:154-166`. `refresh: true` **обходит** защиту `shouldLoad` от повторной загрузки (`MainUserProfileScreen+ViewModel.swift:33-36, 94-100`), то есть две пачки по 4 запроса могут идти параллельно на двух разных сессиях. У диалогов дедупа нет вовсе: `dialogsUpdateTask?.cancel()` (`:148`) отменяет только собственную предыдущую задачу App, но не путь `.task(id:)`; отмена кооперативная, а catch в `DialogsListScreen.ViewModel.getDialogs` (`Screens/Messages/DialogsListScreen+ViewModel.swift`, без `Task.isCancelled`-защиты — в отличие от профиля, `MainUserProfileScreen+ViewModel.swift:60`) переведёт `.ready(dialogs)` в `.error` — список диалогов у пользователя исчезнет.
4. Итого: до 9–10 свежих TCP/TLS-соединений к медленному серверу за один сценарий.

При ошибке обновления при наличии кэша UI остаётся рабочим (`.ready`), но ошибка **пробрасывается дальше** (`MainUserProfileScreen+ViewModel.swift:73` → `throw`) и показывается алертом (`MainUserProfileScreen.swift:136-138`). Отсюда и «.ready», и алерт «Превышен лимит времени» одновременно — ровно то, что в логах.

### 2.2 Android (Jetpack-WorkoutApp) — за образец

- Один общий `OkHttpClient` на приложение: connect 15 с, read/write 30 с, callTimeout 60 с (`app/src/main/java/com/swparks/data/AppContainer.kt:112-117, 307-310`). Значения по сути совпадают с iOS (30/60) — **таймауты не являются различием**.
- `RetryInterceptor`: 3 повтора с паузой 500 мс, только на HTTP 502/503/504 (`data/interceptor/RetryInterceptor.kt`).
- **Инфра-404 отличается от API-404** (Android, изменения от 17.10.2026): настоящий API-404 — только JSON-тело, где `errors` непустой ИЛИ `name != nil` (`BaseRepository.isApiNotFoundBody`); HTML-страница 404 от nginx-прокси при больном сервере → `ServerException(503)` «Сервер недоступен»: без удаления данных из кэша, без NavigateBack, без краш-репортов (только breadcrumb). Классификация — по содержимому тела, не по статус-коду; точная формулировка правила — в шаге 5г.
- Удаление данных из кэша (журналы, площадки) — только при настоящем API-404 (правило классификации) и централизовано в одном методе репозитория (дедуп + перенос удаления строки площадки из общего кэша в `removeParkLocally`).
- **Экран профиля не ходит в сеть при открытии**: Room — источник истины; сеть только после логина/регистрации и по pull-to-refresh (`RootScreen.kt:1683-1690, 1701-1707` — колбэки логина/регистрации, `ProfileViewModel.kt:123` — `loadProfileFromServer`, `ProfileViewModel.kt:148` + `ProfileRootScreen.kt:133` — pull-to-refresh).
- Четыре социальных запроса — параллельно в `supervisorScope` (`UserProfileRepository.kt:120-179`): общее время = самому медленному запросу.
- Главное: при `IOException` (в т.ч. таймаут) при непустом кэше — **тихий фолбэк на кэш Room и `Result.success`** (`UserProfileRepository.kt:156-175`) — пользователь не видит ни таймаута, ни алерта; при пустом кэше — `Result.failure` (ошибка доходит до UI; iOS-аналог этого ветвления — шаг 2).

То есть Android «выживает» не за счёт таймаутов и не за счёт HTTP-кэша (OkHttp Cache и ETag там не настроены), а за счёт **offline-first модели, тихого фолбэка и аккуратной классификации инфра-ошибок**, скрывающих медленный сервер.

### 2.3 Сервер (StreetWorkoutSU) — для сведения, вне скоупа приложения

- Режим `readOnlySite` (`common/config/params.php:30`, `common/components/ReadOnlySite.php`) блокирует только изменяющие экшены — пять GET-эндпоинтов из симптомов **не заблокированы** и выполняют живые запросы к БД.
- Вероятные причины медленных GET: переполнение диска («stop disk-full log floods», ENOSPC-гарды), тяжёлые запросы — N+1 в `ApiUser::fillByModel` (профили в списках друзей/диалогов), несаргабельный запрос диалогов с `count()` (`Dialog::findForUser`). Проверка на сервере: `df -h`, `SHOW FULL PROCESSLIST`, slow log.
- Косвенное подтверждение проблем инфры: nginx на больном сервере отдаёт HTML-страницы 404 — зафиксировано Android-приложением (§2.2).

## 3. Ключевой вывод

Чинить нужно **модель загрузки**, а не цифры таймаутов: iOS уже имеет те же 30/60 с, что и Android. Четыре реальных различия: (1) iOS ходит в сеть при открытии профиля без данных и после возврата из фона (`needUpdateUser`), плюс при каждом `.active` (обновление с обходом `shouldLoad`), Android — только по явному рефрешу; (2) iOS создаёт новую сессию на каждую операцию, Android держит один пул соединений; (3) при ошибке iOS кричит алертом даже при показанном кэше, Android тихо отдаёт кэш; (4) Android отличает инфра-404 от nginx от настоящего API-404 по телу ответа (см. §2.2), iOS маппит любой HTTP 404 в «Ресурс не найден», не читая тело (см. шаг 5г).

## 4. Изменения (по приоритету)

> Все шаги — в коммите «Реализация доработки» от 18.10.2026. Тестовые моки клиентов в `WorkoutAppTests/Mocks/`. Инъекция фабрики в `ViewModel`: шаг 1 — `makeProfileClient`, шаг 5б — `makeDialogsClient`.

### Шаг 1 — P0. Профиль offline-first [x]

`MainUserProfileScreen.ViewModel.getUserProfile`: после guard `mainUserInfo` запрос идёт фоном, `.loading` не выставляется. Мёртвый код `.loading` — в §7.

### Шаг 2 — P0. Тихий фолбэк при наличии кэша [x]

В catch `getUserProfile`: при непустом `mainUserInfo` — `analytics.log` + `logger.error` + `.ready` без `throw`; при пустом (логаут во время запроса) — `.initial` + `throw`. Трейд-офф (фолбэк по любым ошибкам без разбора, гашение настоящего API-404 при непустом кэше) — в §7.

### Шаг 3 — P0. Дедуп профиля [x]

`isInFlight` в `MainUserProfileScreen.ViewModel` (guard до запроса, сброс в `defer`). В App удалены `profileUpdateTask` и его cancel; Task-обёртка с `do/catch`-логированием осталась как sync→async мост. Гейт мока и `.timeLimit` — в §7.

### Шаг 4 — P1. Общий URLSession [x]

`SWNetworkService.sharedSession` — единая сессия на приложение, таймауты 30/60 с сохранены. Структурное изменение, новых тестов нет. Связанная чистка мёртвого кода `.loading` — в §7.

### Шаг 5 — P2. UX и гигиена [x]

- **5а.** `URLError.timedOut` → `APIError.timedOut` («Сервер долго не отвечает…»). `handleUrlSession` перенесён из private-экстеншена в internal для тестируемости (`@testable` открывает только `internal`, а точка инъекции `URLSession` отсутствует — реальный таймаут для теста нестабилен). Тесты: `URLSessionErrorMappingTests`.
- **5б.** Дедуп диалогов: `isInFlight` в `DialogsListScreen.ViewModel.getDialogs` (покрывает оба пути — `.task(id:)` и `updateDialogsIfNeeded`); `dialogsUpdateTask` удалён из App. Refresh, пришедший во время загрузки, не дропается, а ставится в очередь и повторяется после неё (правка после ревью: тихий дроп прятал только что отправленное сообщение — `UserDetailsScreen` зовёт `getDialogs(refresh: true)` тем же ViewModel). Тест: `DialogsListScreenViewModelTests.duplicateRefreshDuringInFlightLoadIsQueuedAndRunsAfter`.
- **5в.** Параметр `isNetworkOnline: Bool = true` в `getDialogs`/`getUserProfile`; при `refresh && !isNetworkOnline` — тихий выход с логом. App передаёт `network.isOnline`. Защищает только фоновый путь: первичная загрузка диалогов идёт без проверки сознательно — кэша диалогов нет, при офлайн-старте в сеть всё равно придётся. Тесты: офлайн-refresh для профиля и диалогов.
  - Отменено после ревью (как в Android): параметр удалён из обеих сигнатур и из App. Android (`Jetpack-WorkoutApp`) фоновых проверок сети не делает вовсе — его единственная проверка коннективности стоит перед отправкой сообщения (`TextEntryViewModel.isNetworkAvailable`, `NET_CAPABILITY_VALIDATED`), а refresh-пути (pull-to-refresh, диалоги) уходят в сеть без предпроверки: офлайн-запрос падает сам, catch сохраняет состояние (у диалогов — снекбар при непустом списке, `DialogsViewModel.loadDialogsInternal`). У нас то же: офлайн-refresh обрабатывают catch (профиль — тихий `.ready` при кэше, диалоги — сохранение списка). Вместе с параметром ушли оба офлайн-теста 5в.
- **5г.** Классификация инфра-404 (перенос Android-опыта). `isApiNotFoundBody(Data)` рядом с `ErrorResponse`: настоящий API-404 при `errors` непустом или `name != nil` (включая `name: ""`); иначе новый кейс `APIError.serverUnavailable` («Сервер недоступен», ru/en в `Localizable.xcstrings`). `make` бросает классифицированную ошибку до декода `ErrorResponse`. `SWClient.mapErrors` не меняется: `.serverUnavailable` проходит как обычная ошибка. Деструктивная ветка `ParkDetailScreen.process` (`onDelete + закрытие`) срабатывает только на настоящий API-404 — на инфра-404 идёт существующий else-путь с алертом без удаления и без закрытия. Логаут по 404 нет — только по 401. Тесты: `ApiNotFoundClassifierTests` (6 + 1 для `errorDescription`).

## 5. Что сознательно не делаем

- **HTTP-кэш/ETag (URLCache-политики)** — у Android их нет, преимуществом они не являются; нужный эффект уже дают `@AppStorage`-кэши.
- **Изменение таймаутов** — уже эквивалентны Android (30/60 с); увеличение лишь дольше держит пользователя в ожидании.
- **Правки сервера** — отдельная задача (гипотеза «диск полон» + тяжёлые запросы диалогов/друзей); приложение обязано жить и при медленном сервере.
- **Ретраи для 502–504** — не добавляем: живая проверка 16.10.2026 (логин + 3 последовательных раунда и параллельный залп пяти GET из симптомов, аккаунт `testuserapple`) — 20/20 `HTTP 200` за <0.5 с, 5xx нет. При этом инфра-сбои в дикой природе существуют — Android зафиксировал инфра-404 от nginx (§2.2); ответ на них в этом плане — тихий фолбэк (шаг 2) и классификация (5г), а не ретраи. Если понадобятся — отдельная задача (аналог Android `RetryInterceptor`).
- **Единый источник HTTP-кодов (Android `HttpCodes.kt`)** — в iOS уже есть: `StatusCodeGroup` + `APIError.init(with:)` — переносить нечего.
- **Централизованное удаление из кэша при 404 (Android)** — в iOS деструктивный сценарий по 404 один: `ParkDetailScreen.process` удаляет площадку и закрывает экран — его решает шаг 5г, оставляя удаление только для настоящего API-404; отдельная централизация очистки, как в Android, не нужна (кэш профиля/диалогов по 404 не удаляется, логаут только по 401).

## 6. Проверка

- **Unit-тесты (Swift Testing):** профиль — `WorkoutAppTests/MainUserProfileScreenViewModelTests.swift` (7), диалоги — `DialogsListScreenViewModelTests.swift` (4), `SWClient` — `SWClientMapErrorsTests.swift` (5 кейсов), пакет SWNetwork — `URLSessionErrorMappingTests` (2) + `ApiNotFoundClassifierTests` (8). Прогон: `swift test --package-path SwiftUI-WorkoutApp/Libraries/SWNetwork` — 50/50.
- **Полный тест-план:** 693/693 (18.10.2026). Обновлён `docs/feature-map.md` (Profile — модель загрузки, Parks — поведение при инфра-404, Messages — дедуп и офлайн-refresh диалогов).
- **Ручной сценарий:** профиль под Charles/Proxyman throttle открывается из кэша без алертов; инфра-404 при пустом кэше — «Сервер недоступен», при непустом — тихо; HTML-404 на экране площадки — без удаления, алерт «Сервер недоступен»; настоящий API-404 на площадке — прежнее поведение (удаление, закрытие).

## 7. Технический долг (закрыт)

- **Мёртвый код после шага 1:** кейс `.loading`, `isLoading`, `loadingOverlay`/`.disabled` на экране профиля, ложный комментарий про «новый клиент на каждый запрос» — удалены. Тест переформулирован в живой инвариант «состояние остаётся .initial».
- **Взаимодействие шагов 5г и 2:** catch профиля ловит всё одинаково → и настоящий API-404, и инфра-404 гасятся при непустом кэше. Сознательно; отдельная задача на будущее — разделить ветки для `APIError.notFound`/`.serverUnavailable`/прочие.
- **Гейт мока (находка шага 3):** `MockSocialUpdatesClient.onPaused` — одноразовый; пауза через счётчик `pauseFirstCalls`. Конвенция для гейт-тестов — сьют с `@Suite(.timeLimit(.minutes(1)))`: зависание из-за ошибки координации превращается в отказ теста, а не висящий прогон.
