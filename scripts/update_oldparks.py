#!/usr/bin/env python3

from __future__ import annotations

import argparse
import json
import re
import sys
import tempfile
import time
from datetime import datetime
from pathlib import Path
from typing import Callable
from urllib import error, parse, request

DATE_FORMAT = "%Y-%m-%dT%H:%M:%S"
TARGET_FILE_NAME = "oldParks.json"
DATE_VARIABLE_NAME = "lastParksUpdateDateString"


class NetworkRequestError(RuntimeError):
    pass


def log(message: str) -> None:
    print(message)


def now_string() -> str:
    return f"{datetime.now().strftime('%Y-%m-%d')}T00:00:00"


def find_unique_file(root: Path, file_name: str) -> Path:
    matches = sorted(path for path in root.rglob(file_name) if path.is_file())
    if not matches:
        raise RuntimeError(f"Не удалось найти файл {file_name} в проекте {root}")
    if len(matches) > 1:
        file_list = "\n".join(f"- {path}" for path in matches)
        raise RuntimeError(
            f"Найдено несколько файлов {file_name}. Укажите путь через --output:\n{file_list}"
        )
    return matches[0]


def resolve_oldparks_path(root: Path, output: str | None) -> Path:
    if output:
        output_path = Path(output)
        return output_path if output_path.is_absolute() else (root / output_path).resolve()
    return find_unique_file(root, TARGET_FILE_NAME)


def resolve_parks_manager_path(root: Path, parks_manager_path: str | None) -> Path:
    if parks_manager_path:
        resolved = Path(parks_manager_path)
        return resolved if resolved.is_absolute() else (root / resolved).resolve()

    default_path = (root / "SwiftUI-WorkoutApp" / "Services" / "ParksManager.swift").resolve()
    if default_path.exists():
        return default_path

    candidates = [
        path for path in root.rglob("ParksManager.swift") if path.is_file() and DATE_VARIABLE_NAME in path.read_text(encoding="utf-8")
    ]
    if len(candidates) == 1:
        return candidates[0]
    if not candidates:
        raise RuntimeError("Не удалось найти файл ParksManager.swift с переменной lastParksUpdateDateString")
    listed = "\n".join(f"- {path}" for path in sorted(candidates))
    raise RuntimeError(f"Найдено несколько файлов ParksManager.swift с нужной переменной:\n{listed}")


def fetch_page(api_base: str, page: int, page_size: int, timeout_seconds: int) -> list[dict]:
    query = parse.urlencode(
        {
            "fields": "short",
            "page_size": str(page_size),
            "page": str(page),
        }
    )
    url = f"{api_base.rstrip('/')}/areas?{query}"

    try:
        with request.urlopen(url, timeout=timeout_seconds) as response:
            status_code = response.getcode()
            body = response.read().decode("utf-8")
    except error.HTTPError as exc:
        message = exc.read().decode("utf-8", errors="replace").strip()
        raise RuntimeError(f"Ошибка сервера на странице {page}: HTTP {exc.code}. {message}") from exc
    except error.URLError as exc:
        raise NetworkRequestError(f"Сетевая ошибка при запросе страницы {page}: {exc.reason}") from exc

    if status_code != 200:
        raise RuntimeError(f"Ошибка сервера на странице {page}: HTTP {status_code}")

    try:
        payload = json.loads(body)
    except json.JSONDecodeError as exc:
        raise RuntimeError(f"Сервер вернул невалидный JSON на странице {page}") from exc

    if not isinstance(payload, list):
        raise RuntimeError(f"Ожидался JSON-массив на странице {page}, получен {type(payload).__name__}")

    return payload


def load_all_parks(
    api_base: str,
    page_size: int,
    timeout_seconds: int,
    retries: int = 3,
    page_delay_seconds: int = 2,
    sleep_fn: Callable[[float], None] = time.sleep,
    fetch_fn: Callable[[str, int, int, int], list[dict]] = fetch_page,
) -> list[dict]:
    page = 1
    merged: list[dict] = []

    log("Начинаю загрузку списка площадок из API")
    while True:
        log(f"Запрашиваю страницу {page}")
        items = None
        for attempt in range(1, retries + 1):
            try:
                items = fetch_fn(api_base, page, page_size, timeout_seconds)
                break
            except NetworkRequestError as exc:
                if attempt >= retries:
                    raise
                log(f"{exc}. Повторяю попытку {attempt + 1} из {retries}...")
                sleep_fn(page_delay_seconds)

        if items is None:
            raise RuntimeError(f"Не удалось получить данные страницы {page}")
        log(f"Страница {page}: получено {len(items)} площадок")

        if not items:
            log(f"Получен пустой ответ на странице {page}, загрузка завершена")
            break

        merged.extend(items)
        sleep_fn(page_delay_seconds)
        page += 1

    log(f"Итог: загружено {len(merged)} площадок")
    return merged


def write_json_atomically(path: Path, data: list[dict]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.NamedTemporaryFile("w", encoding="utf-8", dir=path.parent, delete=False) as temp_file:
        json.dump(data, temp_file, ensure_ascii=False, indent=4)
        temp_file.write("\n")
        temp_path = Path(temp_file.name)
    temp_path.replace(path)


def replace_last_update_date(content: str, date_value: str) -> str:
    pattern = rf'({DATE_VARIABLE_NAME}\s*=\s*")([^"]*)(")'
    updated, count = re.subn(pattern, rf'\g<1>{date_value}\g<3>', content, count=1)
    if count != 1:
        raise RuntimeError("Не удалось обновить lastParksUpdateDateString в ParksManager.swift")
    return updated


def update_last_parks_date(parks_manager_path: Path, date_value: str) -> None:
    content = parks_manager_path.read_text(encoding="utf-8")
    updated_content = replace_last_update_date(content, date_value)
    parks_manager_path.write_text(updated_content, encoding="utf-8")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Обновляет oldParks.json из workout.su API")
    parser.add_argument("--root", default=".", help="Путь к корню проекта")
    parser.add_argument("--api-base", default="https://workout.su/api/v3", help="Базовый URL API")
    parser.add_argument("--page-size", type=int, default=1000, help="Размер страницы")
    parser.add_argument("--timeout", type=int, default=30, help="Таймаут запроса в секундах")
    parser.add_argument("--retries", type=int, default=3, help="Количество попыток при сетевой ошибке")
    parser.add_argument("--page-delay", type=int, default=2, help="Пауза между страницами в секундах")
    parser.add_argument("--output", default=None, help=f"Путь к {TARGET_FILE_NAME} (если не указан, файл ищется по проекту)")
    parser.add_argument(
        "--parks-manager",
        default=None,
        help="Путь к ParksManager.swift (если не указан, используется стандартный путь или автопоиск)",
    )
    return parser.parse_args()


def run(args: argparse.Namespace) -> int:
    root = Path(args.root).resolve()

    try:
        oldparks_path = resolve_oldparks_path(root=root, output=args.output)
        parks_manager_path = resolve_parks_manager_path(root=root, parks_manager_path=args.parks_manager)

        log(f"Файл с площадками: {oldparks_path}")
        log(f"Файл с датой обновления: {parks_manager_path}")

        parks = load_all_parks(
            api_base=args.api_base,
            page_size=args.page_size,
            timeout_seconds=args.timeout,
            retries=args.retries,
            page_delay_seconds=args.page_delay,
        )
        write_json_atomically(oldparks_path, parks)
        log(f"Файл {oldparks_path.name} успешно обновлен")

        date_value = now_string()
        update_last_parks_date(parks_manager_path, date_value)
        log(f"Переменная {DATE_VARIABLE_NAME} обновлена: {date_value}")
    except Exception as exc:
        print(f"Ошибка обновления списка площадок: {exc}", file=sys.stderr)
        return 1

    return 0


def main() -> int:
    return run(parse_args())


if __name__ == "__main__":
    raise SystemExit(main())
