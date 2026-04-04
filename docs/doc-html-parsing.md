# Парсинг HTML-тегов

## API

**Расположение:** `SWUtils/Extensions/String+.swift`

```swift
func withoutHtml(compact: Bool = false) -> String
func withoutHtmlOrEmpty(compact: Bool = false) -> String  // для String?
```

## Параметры

| Параметр | По умолчанию | Описание |
|----------|--------------|----------|
| `compact` | `false` | Режим превью: схлопывает whitespace, заменяет переносы на пробелы |

## Обрабатываемые конструкции

**Структурные теги:**

- `<br>`, `</p>`, `</div>` → `\n` (или пробел в compact-режиме)

**HTML-сущности:**

- `&amp;` `&lt;` `&gt;` `&nbsp;` `&quot;` `&#39;`

**Финальная зачистка:**

- Compact: схлопывание `\s+` в один пробел
- Full: ограничение переносов до `\n\n`

## Использование

| Файл | compact | Контекст |
|------|---------|----------|
| `DialogResponse.swift` | `true` | Превью сообщения в списке |
| `JournalResponse.swift` | `true` | Превью сообщения в списке |
| `EventResponse.swift` | `false` | Полное описание |
| `MessageResponse.swift` | `false` | Полное сообщение |
| `Park.swift` | `false` | Полный комментарий |
| `JournalEntryResponse.swift` | `false` | Полное сообщение |

## Тесты

**Расположение:** `SWUtils/Tests/SWUtilsTests/SWUtilsTests.swift`

- `withoutHtmlBasicTags()` — базовое удаление тегов
- `withoutHtmlCompactMode()` — compact-режим
- `withoutHtmlFullMode()` — полный режим с переносами
- `withoutHtmlBrTag()` — обработка `<br>`
- `withoutHtmlEntities()` — декодирование сущностей
- `withoutHtmlOrEmpty()` — null-safety
- `withoutHtmlEmptyString()` — пустая строка
