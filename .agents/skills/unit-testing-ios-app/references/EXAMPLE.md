# Примеры unit-тестов

## Синтаксис тестов

```swift
@Test("Описание теста на русском языке")
func someFunctionality() throws {
    let optionalValue = try #require(someOptional)
    #expect(optionalValue == expectedValue)
}
```

## Проверка конкретных ошибок

```swift
@Test("Должен выбрасывать ошибку для несуществующего пользователя")
func userNotFound() {
    #expect(throws: MyServiceError.userNotFound) { 
        try service.someMethod() 
    }
}
```

## Параметризованные тесты

Простой вход без пары «ожидание» (утверждение зависит от входа, а не фиксировано):

```swift
@Test("Должен возвращать непустой результат для каждого входа", arguments: ["value1", "value2", "value3", "value4"])
func values(input: String) {
    let result = service.processValue(input)
    #expect(!result.isEmpty)
}
```

Пары «вход → ожидание» — через отдельную структуру-кейс:

```swift
@Suite("Тесты форматирования дней недели")
struct DayFormatterTests {
    struct DayLabelCase {
        let day: Day
        let expected: String
    }

    @Test(
        "Должен форматировать день недели",
        arguments: [
            DayLabelCase(day: .monday, expected: "Понедельник"),
            DayLabelCase(day: .friday, expected: "Пятница")
        ]
    )
    func dayLabel(testCase: DayLabelCase) {
        #expect(format(testCase.day) == testCase.expected)
    }
}
```

## Пример неправильный (избыточные комментарии)

```swift
@Test
func userValidation() {
    let result = service.validateUser(email: "test@example.com", age: 17)
    // Ожидаем false из-за возраста
    #expect(!result)
}
```

## Пример правильный (самодокументирующийся код)

```swift
@Test("Должен отклонять пользователей младше 18 лет")
func userValidation() {
    let result = service.validateUser(email: "test@example.com", age: 17)
    #expect(!result)
}
```
