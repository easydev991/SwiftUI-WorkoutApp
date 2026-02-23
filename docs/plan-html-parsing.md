# План: Доработка парсинга HTML в iOS-приложении

## Цель

Заменить текущую реализацию `withoutHTML` на новый метод `withoutHtml(compact: Bool)` с логикой, аналогичной Android-реализации.

## Текущее состояние

### Реализация (String+.swift:5-10)

```swift
@available(*, deprecated, message: "Доработать парсинг HTML")
var withoutHTML: String {
    replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
        .trimmingCharacters(in: .whitespacesAndNewlines)
}
```

### Использование (6 мест)

| Файл | Свойство | Нужен compact |
|------|----------|---------------|
| `DialogResponse.swift:52` | `lastMessageFormatted` | **Да** (превью сообщения в списке) |
| `JournalResponse.swift:66` | `formattedLastMessage` | **Да** (превью сообщения в списке) |
| `EventResponse.swift:133` | `formattedDescription` | Нет (полное описание) |
| `MessageResponse.swift:18` | `formattedMessage` | Нет (полное сообщение) |
| `Park.swift:179` | `CommentResponse.formattedBody` | Нет (полный комментарий) |
| `JournalEntryResponse.swift:50` | `formattedMessage` | Нет (полное сообщение) |

---

## Этап 1: Реализация нового метода

- [ ] Добавить новый метод `withoutHtml(compact: Bool) -> String` в `String+.swift`
  - Обработать структурные теги (`<br>`, `</p>`, `</div>`) с учётом `compact`
  - Удалить все оставшиеся HTML-теги
  - Декодировать HTML-сущности (`&amp;`, `&lt;`, `&gt;`, `&nbsp;`, `&quot;`, `&#39;`)
  - Финальная зачистка whitespace в зависимости от режима

- [ ] Добавить optional-версию `withoutHtmlOrNull(compact:) -> String?` для nullable строк (аналог Android)

- [ ] Удалить старый deprecated-метод `withoutHTML`

---

## Этап 2: Обновление тестов

- [ ] Обновить тест `stringWithoutHTML()` на `testWithoutHtmlCompactMode()`
  - Проверить обработку `<br>`, `</p>`, `</div>` в compact-режиме
  - Проверить декодирование HTML-сущностей
  - Проверить схлопывание whitespace

- [ ] Добавить тест `testWithoutHtmlFullMode()`
  - Проверить сохранение переносов строк
  - Проверить корректную обработку множественных переносов

- [ ] Добавить тесты для граничных случаев
  - Пустая строка
  - Строка без HTML
  - Только теги без текста

---

## Этап 3: Обновление использования

### 3.1 Превью-режим (compact: true)

- [ ] `DialogResponse.swift` — `lastMessageFormatted`
- [ ] `JournalResponse.swift` — `formattedLastMessage`

### 3.2 Полный режим (compact: false)

- [ ] `EventResponse.swift` — `formattedDescription`
- [ ] `MessageResponse.swift` — `formattedMessage`
- [ ] `Park.swift` — `CommentResponse.formattedBody`
- [ ] `JournalEntryResponse.swift` — `formattedMessage`

---

## Этап 4: Верификация

- [x] Запустить unit-тесты: `make test` или `swift test`
- [x] Проверить сборку проекта: `make build`
- [x] Убедиться, что deprecated-метод продолжает работать

---

## Этап 5: Замена withoutHtmlOrNull на withoutHtmlOrEmpty

> **Причина:** `withoutHtmlOrNull` не используется в production-коде (только в тестах).
> Заменяем на `withoutHtmlOrEmpty`, который возвращает пустую строку вместо nil.

- [x] Заменить метод `withoutHtmlOrNull` на `withoutHtmlOrEmpty` в `String+.swift`
  - Возвращать `""` для nil вместо `nil`
- [x] Обновить тест `withoutHtmlOrNull()` на `withoutHtmlOrEmpty()`
  - Проверить что nil возвращает пустую строку
- [x] Запустить тесты для верификации

---

## Ожидаемый результат

```swift
// String+.swift
public extension String {
    /// Очищает строку от HTML-тегов.
    /// - Parameter compact: Если true — заменяет переносы на пробелы и схлопывает whitespace (для превью).
    ///                      Если false — сохраняет структуру текста.
    func withoutHtml(compact: Bool = false) -> String {
        var text = self

        // 1. Предварительная обработка структурных тегов
        if compact {
            text = text
                .replacingOccurrences(of: "<br\\s*/?>", with: " ", options: .regularExpression)
                .replacingOccurrences(of: "</p>", with: " ", options: .caseInsensitive)
                .replacingOccurrences(of: "</div>", with: " ", options: .caseInsensitive)
        } else {
            text = text
                .replacingOccurrences(of: "<br\\s*/?>", with: "\n", options: .regularExpression)
                .replacingOccurrences(of: "</p>", with: "\n\n", options: .caseInsensitive)
                .replacingOccurrences(of: "</div>", with: "\n", options: .caseInsensitive)
        }

        // 2. Удаляем все оставшиеся теги
        text = text.replacingOccurrences(of: "<[^>]*>", with: "", options: .regularExpression)

        // 3. Декодируем HTML-сущности
        text = text
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&nbsp;", with: " ")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&#39;", with: "'")

        // 4. Финальная зачистка
        if compact {
            return text.trimmingCharacters(in: .whitespacesAndNewlines)
                .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        } else {
            return text.trimmingCharacters(in: .whitespacesAndNewlines)
                .replacingOccurrences(of: "\n{3,}", with: "\n\n", options: .regularExpression)
        }
    }
}

public extension String? {
    func withoutHtmlOrEmpty(compact: Bool = false) -> String {
        self?.withoutHtml(compact: compact) ?? ""
    }
}
```
