# Примеры unit-тестов

## Синтаксис тестов

```swift
@Test("Описание теста на русском языке")
func testSomeFunctionality() throws {
    let optionalValue = try #require(someOptional)
    #expect(optionalValue == expectedValue)
}
```

## Проверка конкретных ошибок

```swift
@Test("Должен выбрасывать ошибку для несуществующего пользователя")
func testUserNotFound() {
    #expect(throws: MyServiceError.userNotFound) { 
        try service.someMethod() 
    }
}
```

## Параметризированные тесты

```swift
@Test("Должен обрабатывать разные значения", arguments: ["value1", "value2", "value3", "value4"])
func testValues(input: String) {
    let expected = "expectedResult"
    let result = service.processValue(input)
    #expect(result == expected)
}
```

## Пример неправильно (избыточные комментарии)

```swift
@Test
func testUserValidation() {
    let result = service.validateUser(email: "test@example.com", age: 17)
    // Ожидаем false из-за возраста
    #expect(!result)
}
```

## Пример правильно (самодокументирующийся код)

```swift
@Test("Должен отклонять пользователей младше 18 лет")
func testUserValidation() {
    let result = service.validateUser(email: "test@example.com", age: 17)
    #expect(!result)
}
```
