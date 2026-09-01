# Симулятор и MCP — маршрутизация

- **Сборка, тесты, запуск, дебаг** — xcode MCP (`BuildProject`, `RunSomeTests`, `RunProject`, `GetConsoleOutput`); make-фоллбеки описаны в AGENTS.md.
- **UI-проверки на экране** (элементы, тапы, скриншоты) — mobile-mcp: `list_elements_on_screen` → тап по `@ref`; скриншоты — только чтобы оценить внешний вид. Перед UI-автоматизацией симулятор должен быть загружен (`xcrun simctl boot`, если ещё не запущен).
- **Если mobile-mcp недоступен** — фоллбек на `simctl` через bash: `xcrun simctl list devices`, `xcrun simctl io booted screenshot`, `xcrun simctl launch <bundle-id>`.
- Установка/удаление приложения — mobile-mcp (`install_app`/`uninstall_app`) или `xcrun simctl install/uninstall`.
