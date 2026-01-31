# Примеры использования логов

## Ошибки

```swift
logger.error("Ошибка загрузки данных: \(error)")
logger.error("Не удалось сохранить тренировку: \(error)")
```

## Информация

```swift
logger.info("Тренировка сохранена успешно")
logger.info("Синхронизировано \(count) элементов")
```

## Отладка

```swift
logger.debug("Начинаем синхронизацию данных")
logger.debug("Время выполнения: \(duration)ms")
```

## Обращение к self в логах (создаем локальную копию)

```swift
let workoutId = self.workout.id
logger.info("Тренировка \(workoutId) сохранена")
```
