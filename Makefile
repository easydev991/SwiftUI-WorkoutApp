.PHONY: help setup setup_hook setup_snapshot setup_fastlane setup_ssh setup_markdownlint setup_periphery update update_fastlane update_swiftformat update_markdownlint update_readme_versions test_readme_versions update_oldparks test_update_oldparks format format_swift format_markdown screenshots upload_screenshots testflight fastlane increment_build build test scan_unused_code

# Цвета и шрифт
YELLOW=\033[1;33m
GREEN=\033[1;32m
RED=\033[1;31m
BOLD=\033[1m
RESET=\033[0m

# Версия Ruby в проекте
RUBY_VERSION=3.3.6

# Версия Swift в проекте
SWIFT_VERSION=6.3.0

# Глобальные настройки шелла
SHELL := /bin/bash
.ONESHELL:
BUNDLE_EXEC := RBENV_VERSION=$(RUBY_VERSION) bundle exec

## help: Показать это справочное сообщение
help:
	@echo "Доступные команды Makefile:"
	@echo ""
	@sed -n 's/^##//p' ${MAKEFILE_LIST} | \
	awk -F ':' '{printf "  $(BOLD)%s$(RESET):%s\n", $$1, $$2}' BOLD="$(BOLD)" RESET="$(RESET)" | column -t -s ':'
	@echo ""
	@printf "Рекомендуется сначала выполнить команду '$(BOLD)make setup$(RESET)'"
	@echo ""

## setup: Проверить и установить все необходимые инструменты и зависимости для проекта (Homebrew, rbenv, Ruby, Bundler, fastlane, swiftformat)
setup:
	@printf "$(YELLOW)Проверка наличия Homebrew...$(RESET)\n"
	@if ! command -v brew >/dev/null 2>&1; then \
		printf "$(YELLOW)Homebrew не установлен. Устанавливаю...$(RESET)\n"; \
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
	fi
	@printf "$(GREEN)Homebrew установлен$(RESET)\n"
	
	@printf "$(YELLOW)Проверка наличия rbenv...$(RESET)\n"
	@if ! command -v rbenv >/dev/null 2>&1; then \
		printf "$(YELLOW)rbenv не установлен. Устанавливаю...$(RESET)\n"; \
		brew install rbenv ruby-build; \
	fi
	@printf "$(GREEN)rbenv установлен$(RESET)\n"
	
	@printf "$(YELLOW)Проверка наличия Ruby версии $(RUBY_VERSION)...$(RESET)\n"
	@if ! rbenv versions | grep -q $(RUBY_VERSION); then \
		printf "$(YELLOW)Ruby $(RUBY_VERSION) не установлен. Устанавливаю...$(RESET)\n"; \
		rbenv install $(RUBY_VERSION); \
	fi
	@printf "$(GREEN)Ruby $(shell rbenv versions | grep $(RUBY_VERSION))$(RESET)\n"
	
	@printf "$(YELLOW)Проверка содержимого файла .ruby-version...$(RESET)\n"
	@if [ ! -f .ruby-version ] || [ "$(shell cat .ruby-version)" != "$(RUBY_VERSION)" ]; then \
		printf "$(YELLOW)Файл .ruby-version не найден или содержит неверную версию. Обновляю...$(RESET)\n"; \
		echo "$(RUBY_VERSION)" > .ruby-version; \
	else \
		printf "$(GREEN)Файл .ruby-version корректно настроен$(RESET)\n"; \
	fi
	
	@RBENV_VERSION=$(RUBY_VERSION) ruby -v >/dev/null 2>&1 || true
	@printf "$(GREEN)Ruby активирован локально для проекта$(RESET)\n"
	
	@printf "$(YELLOW)Проверка наличия Bundler нужной версии...$(RESET)\n"
	@if [ -f Gemfile.lock ]; then \
		BUNDLER_VERSION=$$(grep -A 1 "BUNDLED WITH" Gemfile.lock | tail -n 1 | xargs); \
		if [ -z "$$BUNDLER_VERSION" ]; then \
			printf "$(RED)Не удалось определить версию Bundler из Gemfile.lock$(RESET)\n"; \
			exit 1; \
		fi; \
		if ! RBENV_VERSION=$(RUBY_VERSION) gem list -i bundler -v "$$BUNDLER_VERSION" >/dev/null 2>&1; then \
			printf "$(YELLOW)Bundler версии $$BUNDLER_VERSION не установлен. Устанавливаю...$(RESET)\n"; \
			RBENV_VERSION=$(RUBY_VERSION) gem install bundler -v "$$BUNDLER_VERSION"; \
		else \
			printf "$(GREEN)Bundler версии $$BUNDLER_VERSION уже установлен$(RESET)\n"; \
		fi; \
	else \
		printf "$(YELLOW)Файл Gemfile.lock не найден, устанавливаю последнюю версию bundler...$(RESET)\n"; \
		RBENV_VERSION=$(RUBY_VERSION) gem install bundler; \
	fi
	
	@printf "$(YELLOW)Проверка наличия Gemfile...$(RESET)\n"
	@if [ ! -f Gemfile ]; then \
		printf "$(YELLOW)Gemfile не найден. Создаю новый Gemfile...$(RESET)\n"; \
		RBENV_VERSION=$(RUBY_VERSION) bundle init; \
		echo "gem 'fastlane'" >> Gemfile; \
		printf "$(GREEN)Gemfile создан и fastlane добавлен в зависимости$(RESET)\n"; \
	else \
		printf "$(GREEN)Gemfile уже существует$(RESET)\n"; \
	fi
	
	@printf "$(YELLOW)Проверка Ruby-зависимостей из Gemfile...$(RESET)\n"
	@if [ -f Gemfile ]; then \
		if ! RBENV_VERSION=$(RUBY_VERSION) bundle check >/dev/null 2>&1; then \
			printf "$(YELLOW)Зависимости не установлены. Выполняется bundle install...$(RESET)\n"; \
			RBENV_VERSION=$(RUBY_VERSION) bundle install; \
			printf "$(GREEN)Все Ruby-зависимости успешно установлены$(RESET)\n"; \
		else \
			printf "$(GREEN)Все Ruby-зависимости уже установлены$(RESET)\n"; \
		fi; \
	else \
		printf "$(YELLOW)Файл Gemfile не найден, пропуск установки Ruby-зависимостей$(RESET)\n"; \
	fi
	
	@printf "$(YELLOW)Проверка наличия swiftformat...$(RESET)\n"
	@if ! command -v swiftformat >/dev/null 2>&1; then \
		printf "$(YELLOW)swiftformat не установлен. Устанавливаю...$(RESET)\n"; \
		brew install swiftformat; \
		printf "$(GREEN)swiftformat успешно установлен$(RESET)\n"; \
	else \
		printf "$(GREEN)swiftformat уже установлен$(RESET)\n"; \
	fi
	
	@printf "$(YELLOW)Проверка наличия файла .swift-version...$(RESET)\n"
	@if [ ! -f .swift-version ]; then \
		printf "$(YELLOW)Файл .swift-version не найден. Создаю с версией $(SWIFT_VERSION)...$(RESET)\n"; \
		echo "$(SWIFT_VERSION)" > .swift-version; \
		printf "$(GREEN).swift-version создан$(RESET)\n"; \
	else \
		printf "$(GREEN)Файл .swift-version уже существует$(RESET)\n"; \
	fi
	
	@$(MAKE) setup_hook
	@$(MAKE) setup_fastlane
	@$(MAKE) setup_snapshot
	@$(MAKE) setup_ssh
	@$(MAKE) setup_markdownlint
	@$(MAKE) setup_periphery

## setup_markdownlint: Проверить и установить Node.js и markdownlint-cli для форматирования Markdown-файлов
setup_markdownlint:
	@printf "$(YELLOW)Проверка наличия Node.js/npm...$(RESET)\\n"
	@if ! command -v npm >/dev/null 2>&1; then \
		printf "$(YELLOW)Node.js/npm не установлен. Устанавливаю через Homebrew...$(RESET)\\n"; \
		brew install node; \
		printf "$(GREEN)Node.js/npm успешно установлен$(RESET)\\n"; \
	else \
		printf "$(GREEN)Node.js/npm уже установлен$(RESET)\\n"; \
	fi
	@printf "$(YELLOW)Проверка наличия markdownlint-cli...$(RESET)\\n"
	@if ! command -v markdownlint >/dev/null 2>&1; then \
		printf "$(YELLOW)markdownlint-cli не установлен. Устанавливаю...$(RESET)\\n"; \
		npm install -g markdownlint-cli; \
		printf "$(GREEN)markdownlint-cli успешно установлен$(RESET)\\n"; \
	else \
		printf "$(GREEN)markdownlint-cli уже установлен$(RESET)\\n"; \
	fi

## setup_periphery: Установить Periphery для поиска неиспользуемого кода
setup_periphery:
	@printf "$(YELLOW)Проверка наличия Periphery...$(RESET)\\n"
	@if ! command -v periphery >/dev/null 2>&1 && [ ! -x "$$HOME/.mint/bin/periphery" ]; then \
		printf "$(YELLOW)Periphery не установлен. Устанавливаю через Mint...$(RESET)\\n"; \
		if ! command -v mint >/dev/null 2>&1; then \
			printf "$(YELLOW)Mint не установлен. Устанавливаю через Homebrew...$(RESET)\\n"; \
			brew install mint; \
		fi; \
		mint install peripheryapp/periphery; \
		printf "$(GREEN)Periphery успешно установлен$(RESET)\\n"; \
	else \
		printf "$(GREEN)Periphery уже установлен$(RESET)\\n"; \
	fi

## setup_hook: Установить git-хуки (pre-commit для синхронизации версий README и pre-push для проверки SwiftFormat)
setup_hook:
	@mkdir -p .git/hooks
	@printf "$(YELLOW)Синхронизация скрипта pre-commit-readme-versions...$(RESET)\n"; \
	if cp .githooks/pre-commit-readme-versions .git/hooks/pre-commit-readme-versions && chmod +x .git/hooks/pre-commit-readme-versions; then \
		printf "$(GREEN)Скрипт pre-commit-readme-versions синхронизирован$(RESET)\n"; \
	else \
		printf "$(RED)Не удалось синхронизировать pre-commit-readme-versions$(RESET)\n"; \
		exit 1; \
	fi
	@printf "$(YELLOW)Синхронизация pre-commit git-хука...$(RESET)\n"; \
	if cp .githooks/pre-commit .git/hooks/pre-commit && chmod +x .git/hooks/pre-commit; then \
		printf "$(GREEN)pre-commit git-хук синхронизирован$(RESET)\n"; \
	else \
		printf "$(RED)Не удалось синхронизировать pre-commit git-хук$(RESET)\n"; \
		exit 1; \
	fi
	@printf "$(YELLOW)Синхронизация pre-push git-хука...$(RESET)\n"; \
	if cp .githooks/pre-push .git/hooks/pre-push && chmod +x .git/hooks/pre-push; then \
		printf "$(GREEN)pre-push git-хук синхронизирован$(RESET)\n"; \
	else \
		printf "$(RED)Не удалось синхронизировать pre-push git-хук$(RESET)\n"; \
		exit 1; \
	fi

## setup_snapshot: Проверить инициализацию fastlane/fastlane snapshot, при необходимости предложить варианты установки
setup_snapshot:
	@printf "$(YELLOW)Проверка инициализации fastlane snapshot...$(RESET)\n"
	@if [ ! -f fastlane/Snapfile ]; then \
		printf "$(YELLOW)fastlane snapshot не инициализирован.$(RESET)\n"; \
		printf "$(YELLOW)Для инициализации выполните: bundle exec fastlane snapshot init$(RESET)\n"; \
		printf "$(YELLOW)Или запустите: make setup_fastlane$(RESET)\n"; \
	else \
		printf "$(GREEN)fastlane snapshot уже инициализирован$(RESET)\n"; \
	fi

## setup_fastlane: Инициализировать fastlane в проекте (пошаговый процесс; при первом разворачивании может быть интерактивным)
setup_fastlane:
	@if [ ! -d fastlane ] || [ ! -f fastlane/Fastfile ]; then \
		printf "$(YELLOW)Инициализация fastlane в проекте...$(RESET)\n"; \
		printf "$(YELLOW)Это интерактивный процесс. Следуйте инструкциям на экране.$(RESET)\n"; \
		RBENV_VERSION=$(RUBY_VERSION) bundle exec fastlane init; \
		printf "$(GREEN)fastlane инициализирован!$(RESET)\n"; \
	else \
		printf "$(GREEN)fastlane уже инициализирован$(RESET)\n"; \
	fi

## setup_ssh: Настраивает SSH-доступ к GitHub (интерактивно: создаст ключ при необходимости, добавит в агент, опционально добавит ключ в аккаунт GitHub)
setup_ssh:
	@printf "$(YELLOW)Проверка SSH-доступа к GitHub...$(RESET)\n"
	@if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then \
		printf "$(GREEN)SSH-доступ к GitHub уже настроен$(RESET)\n"; \
		exit 0; \
	fi
	@# Проверка наличия jq
	@if ! command -v jq >/dev/null 2>&1; then \
		printf "$(YELLOW)Утилита jq не найдена. Устанавливаю через Homebrew...$(RESET)\n"; \
		if command -v brew >/dev/null 2>&1; then brew install jq; else printf "$(RED)Homebrew не найден. Установите jq вручную и повторите.$(RESET)\n"; exit 1; fi; \
	fi
	@# Создание каталога ~/.ssh при необходимости
	@if [ ! -d $$HOME/.ssh ]; then \
		mkdir -p $$HOME/.ssh; \
		printf "$(GREEN)Создана папка ~/.ssh$(RESET)\n"; \
	fi
	@# Создание ключа, если отсутствует (email запрашивается явно)
	@if [ ! -f $$HOME/.ssh/id_ed25519 ]; then \
		read -p "Введите email для комментария ключа: " KEY_EMAIL; \
		while [ -z "$$KEY_EMAIL" ]; do read -p "Email не может быть пустым. Введите email: " KEY_EMAIL; done; \
		printf "$(YELLOW)Создаю новый SSH-ключ id_ed25519...$(RESET)\n"; \
		ssh-keygen -t ed25519 -N "" -C "$$KEY_EMAIL" -f $$HOME/.ssh/id_ed25519; \
	else \
		printf "$(GREEN)SSH-ключ $$HOME/.ssh/id_ed25519 уже существует$(RESET)\n"; \
	fi
	@# Запуск ssh-agent и добавление ключа
	@eval "$$((ssh-agent -s) 2>/dev/null)" >/dev/null || true
	@ssh-add -K $$HOME/.ssh/id_ed25519 >/dev/null 2>&1 || ssh-add $$HOME/.ssh/id_ed25519 >/dev/null 2>&1 || true
	@# Настройка ~/.ssh/config для github.com
	@CONFIG_FILE="$$HOME/.ssh/config"; \
	HOST_ENTRY="Host github.com\n  HostName github.com\n  User git\n  AddKeysToAgent yes\n  UseKeychain yes\n  IdentityFile $$HOME/.ssh/id_ed25519\n"; \
	if [ -f "$$CONFIG_FILE" ]; then \
		if ! grep -q "Host github.com" "$$CONFIG_FILE"; then \
			echo "$$HOST_ENTRY" >> "$$CONFIG_FILE"; \
			printf "$(GREEN)Добавлена секция для github.com в ~/.ssh/config$(RESET)\n"; \
		else \
			printf "$(GREEN)Секция для github.com уже есть в ~/.ssh/config$(RESET)\n"; \
		fi; \
	else \
		echo "$$HOST_ENTRY" > "$$CONFIG_FILE"; \
		chmod 600 "$$CONFIG_FILE"; \
		printf "$(GREEN)Создан ~/.ssh/config с секцией для github.com$(RESET)\n"; \
	fi
	@# Предложение добавить публичный ключ в аккаунт GitHub через API
	@printf "$(YELLOW)Добавление публичного ключа в ваш аккаунт GitHub через API...$(RESET)\n"; \
	printf "Требуется персональный токен GitHub с правом 'admin:public_key'.\n"; \
	read -p "Добавить ключ в GitHub через API? [y/N]: " ADD_GH; \
	if [[ "$$ADD_GH" =~ ^[Yy]$$ ]]; then \
		read -p "Введите ваш GitHub Personal Access Token: " TOKEN; \
		read -p "Введите название для SSH-ключа (например, 'work-macbook'): " TITLE; \
		if [ -z "$$TITLE" ]; then TITLE="SwiftUI-WorkoutApp key"; fi; \
		PUB_KEY=$$(cat $$HOME/.ssh/id_ed25519.pub); \
		DATA=$$(jq -n --arg title "$$TITLE" --arg key "$$PUB_KEY" '{title:$$title, key:$$key}'); \
		RESPONSE=$$(curl -s -w "\n%{http_code}" -X POST "https://api.github.com/user/keys" -H "Accept: application/vnd.github+json" -H "Authorization: token $$TOKEN" -d "$$DATA"); \
		BODY=$$(echo "$$RESPONSE" | sed '$$d'); \
		STATUS=$$(echo "$$RESPONSE" | tail -n 1); \
		if [ "$$STATUS" = "201" ]; then \
			printf "$(GREEN)SSH-ключ успешно добавлен в GitHub$(RESET)\n"; \
		elif [ "$$STATUS" = "422" ]; then \
			printf "$(YELLOW)Ключ уже добавлен или недопустим. Сообщение GitHub:$(RESET)\n"; \
			echo "$$BODY"; \
		else \
			printf "$(RED)Ошибка при добавлении ключа в GitHub (HTTP $$STATUS)$(RESET)\n"; \
			echo "$$BODY"; \
		fi; \
	else \
		printf "$(YELLOW)Пропускаю авто-добавление ключа. Добавьте его вручную: $(RESET)https://github.com/settings/keys\n"; \
	fi
	@printf "$(YELLOW)Проверка соединения с github.com...$(RESET)\n"; \
	ssh -T git@github.com || true

## update: Обновить fastlane, swiftformat и версии Xcode/Swift/iOS в README
update:
	@printf "$(YELLOW)Обновление fastlane, swiftformat и README...$(RESET)\n"
	@$(MAKE) update_fastlane
	@$(MAKE) update_swiftformat
	@$(MAKE) update_readme_versions
	@printf "$(GREEN)Обновление завершено!$(RESET)\n"

## update_readme_versions: Обновить бейджи версий Xcode/Swift/iOS в README.md
update_readme_versions:
	@printf "$(YELLOW)Обновляю версии Xcode/Swift/iOS в README.md...$(RESET)\n"
	@python3 scripts/update_readme_versions.py --root .
	@printf "$(GREEN)Версии в README.md обновлены$(RESET)\n"

## test_readme_versions: Запустить unit-тесты утилиты обновления README
test_readme_versions:
	@python3 -m unittest scripts.tests.test_update_readme_versions

## update_oldparks: Обновить oldParks.json из API и дату lastParksUpdateDateString
update_oldparks:
	@printf "$(YELLOW)Обновляю oldParks.json из API...$(RESET)\n"
	@python3 scripts/update_oldparks.py --root .
	@printf "$(GREEN)oldParks.json и дата в ParksManager.swift обновлены$(RESET)\n"

## test_update_oldparks: Запустить unit-тесты утилиты обновления oldParks.json
test_update_oldparks:
	@python3 -m unittest scripts.tests.test_update_oldparks

## update_fastlane: Обновить только fastlane и его зависимости
update_fastlane:
	@printf "$(YELLOW)Проверка наличия обновлений fastlane и его зависимостей...$(RESET)\n"
	@RBENV_VERSION=$(RUBY_VERSION) bundle outdated fastlane --parseable | grep . && \
		printf "$(YELLOW)Есть обновления для fastlane или его зависимостей, выполняется обновление...$(RESET)\n"; \
		RBENV_VERSION=$(RUBY_VERSION) bundle update fastlane; \
		printf "$(GREEN)fastlane и его зависимости обновлены. Не забудьте закоммитить новый Gemfile.lock!$(RESET)\n"; \
	true || printf "$(GREEN)fastlane и его зависимости уже самые свежие$(RESET)\n"

## update_swiftformat: Обновить только swiftformat через Homebrew
update_swiftformat:
	@if ! command -v brew >/dev/null 2>&1; then \
		printf "$(RED)Homebrew не найден. Запустите $(BOLD)make setup$(RESET) для установки зависимостей.\n"; \
		exit 1; \
	fi
	@if brew list --versions swiftformat >/dev/null 2>&1; then \
		printf "$(YELLOW)Проверка обновлений swiftformat...$(RESET)\n"; \
		brew upgrade swiftformat || true; \
	else \
		printf "$(YELLOW)swiftformat не установлен. Устанавливаю...$(RESET)\n"; \
		brew install swiftformat; \
	fi
	@if command -v swiftformat >/dev/null 2>&1; then \
		VER=$$(swiftformat --version 2>/dev/null | awk "{print $$1}"); \
		printf "$(GREEN)swiftformat готов (версия: $$VER)$(RESET)\n"; \
	fi

## format: Запустить автоматическое форматирование Swift-кода с помощью swiftformat
format:
	@if ! command -v swiftformat >/dev/null 2>&1; then \
		if command -v brew >/dev/null 2>&1; then \
			printf "$(YELLOW)swiftformat не найден. Устанавливаю через Homebrew...$(RESET)\n"; \
			brew install swiftformat; \
		else \
			printf "$(RED)swiftformat не найден и Homebrew отсутствует. Запустите $(BOLD)make setup$(RESET) для установки зависимостей.\n"; \
			exit 1; \
		fi; \
	fi
	@printf "$(YELLOW)Форматирование Swift-кода...$(RESET)\n"
	@swiftformat .
	@printf "$(GREEN)Форматирование завершено!$(RESET)\n"
	@if command -v markdownlint >/dev/null 2>&1; then \
		printf "$(YELLOW)Форматирование Markdown-файлов...$(RESET)\\n"; \
		markdownlint --fix "**/*.md" ".cursor/rules/*.mdc" && printf "$(GREEN_NORMAL)Markdown-файлы успешно отформатированы$(RESET)\\n"; \
	else \
		echo "$(YELLOW)markdownlint-cli не установлен. Для установки: npm install -g markdownlint-cli$(RESET)"; \
	fi

## screenshots: Запустить fastlane snapshot для генерации скриншотов приложения
screenshots:
	@if [ ! -d fastlane ] || [ ! -f fastlane/Fastfile ]; then \
		printf "$(RED)fastlane не инициализирован в проекте$(RESET)\n"; \
		$(MAKE) setup_fastlane; \
		if [ ! -d fastlane ] || [ ! -f fastlane/Fastfile ]; then \
			printf "$(RED)Нужно инициализировать fastlane перед использованием$(RESET)\n"; \
			exit 1; \
		fi; \
	fi
	@printf "$(YELLOW)Запуск fastlane snapshot для генерации скриншотов...$(RESET)\n"
	@export LANG=en_US.UTF-8 && $(BUNDLE_EXEC) fastlane screenshots

## upload_screenshots: Загрузить существующие скриншоты в App Store Connect
upload_screenshots:
	@if [ ! -d fastlane ] || [ ! -f fastlane/Fastfile ]; then \
		printf "$(RED)fastlane не инициализирован в проекте$(RESET)\n"; \
		$(MAKE) setup_fastlane; \
		if [ ! -d fastlane ] || [ ! -f fastlane/Fastfile ]; then \
			printf "$(RED)Нужно инициализировать fastlane перед использованием$(RESET)\n"; \
			exit 1; \
		fi; \
	fi
	@printf "$(YELLOW)Загрузка скриншотов в App Store Connect...$(RESET)\n"
	@export LANG=en_US.UTF-8 && $(BUNDLE_EXEC) fastlane upload_screenshots

## build: Сборка проекта в терминале
build:
	xcodebuild -project SwiftUI-WorkoutApp.xcodeproj -scheme SwiftUI-WorkoutApp -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 17' build

## test: Запускает unit-тесты в терминале
test:
	xcodebuild -project SwiftUI-WorkoutApp.xcodeproj -scheme SwiftUI-WorkoutApp -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 17' test -testPlan SwiftUI-WorkoutApp

## scan_unused_code: Запустить поиск неиспользуемого кода через Periphery (предварительно собери проект: make build или xcodebuild-mcp build_sim)
scan_unused_code:
	@PERIPHERY=$$(command -v periphery 2>/dev/null || echo "$$HOME/.mint/bin/periphery"); \
	if [ ! -x "$$PERIPHERY" ]; then \
		printf "$(RED)periphery не найден. Установи: mint install peripheryapp/periphery$(RESET)\n"; \
		exit 1; \
	fi; \
	printf "$(YELLOW)Поиск неиспользуемого кода через Periphery...$(RESET)\n"; \
	BUILD_DIR=$$(xcodebuild -project SwiftUI-WorkoutApp.xcodeproj -scheme SwiftUI-WorkoutApp -showBuildSettings 2>/dev/null | grep -m1 "^    BUILD_DIR = " | sed 's/^    BUILD_DIR = //'); \
	if [ -z "$$BUILD_DIR" ]; then \
		printf "$(RED)Не удалось определить BUILD_DIR. Собери проект: make build$(RESET)\n"; \
		exit 1; \
	fi; \
	INDEX_STORE="$$(dirname "$$(dirname "$$BUILD_DIR")")/Index.noindex/DataStore"; \
	if [ ! -d "$$INDEX_STORE" ]; then \
		printf "$(YELLOW)IndexStore не найден: $$INDEX_STORE$(RESET)\n"; \
		printf "$(YELLOW)Собери проект: make build$(RESET)\n"; \
		exit 1; \
	fi; \
	"$$PERIPHERY" scan --config .periphery.yml --skip-build --index-store-path "$$INDEX_STORE"

## increment_build: Получить следующий номер сборки для TestFlight
increment_build:
	@printf "$(YELLOW)Информация о номерах сборки...$(RESET)\n"
	@export LANG=en_US.UTF-8 && $(BUNDLE_EXEC) fastlane get_next_build_number

## testflight: Собрать и отправить сборку в TestFlight через fastlane
testflight:
	@printf "$(YELLOW)Сборка и публикация в TestFlight...$(RESET)\n"
	@export LANG=en_US.UTF-8 && $(BUNDLE_EXEC) fastlane build_and_upload

## fastlane: Запустить меню команд fastlane
fastlane:
	@if [ ! -d fastlane ] || [ ! -f fastlane/Fastfile ]; then \
		printf "$(RED)fastlane не инициализирован в проекте$(RESET)\n"; \
		$(MAKE) setup_fastlane; \
		if [ ! -d fastlane ] || [ ! -f fastlane/Fastfile ]; then \
			printf "$(RED)Нужно инициализировать fastlane перед использованием$(RESET)\n"; \
			exit 1; \
		fi; \
	fi
	@printf "$(YELLOW)Запуск меню команд fastlane...$(RESET)\n"
	@export LANG=en_US.UTF-8 && $(BUNDLE_EXEC) fastlane

.DEFAULT:
	@printf "$(RED)Неизвестная команда: 'make $@'\n$(RESET)"
	@$(MAKE) help
