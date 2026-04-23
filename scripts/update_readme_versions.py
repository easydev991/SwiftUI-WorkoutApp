#!/usr/bin/env python3

from __future__ import annotations

import argparse
import re
import subprocess
import sys
from pathlib import Path

BEGIN_MARKER = "<!-- BEGIN_VERSIONS -->"
END_MARKER = "<!-- END_VERSIONS -->"


def run_command(args: list[str]) -> str:
    completed = subprocess.run(args, capture_output=True, text=True, check=False)
    if completed.returncode != 0:
        message = completed.stderr.strip() or completed.stdout.strip() or "неизвестная ошибка"
        raise RuntimeError(f"Команда завершилась с ошибкой: {' '.join(args)}. {message}")
    return completed.stdout


def parse_xcode_version(text: str) -> str:
    match = re.search(r"^Xcode\s+([0-9]+(?:\.[0-9]+)*)\s*$", text, flags=re.MULTILINE)
    if match is None:
        raise ValueError("Не удалось определить версию Xcode из вывода xcodebuild")
    return match.group(1)


def parse_ios_deployment_target(text: str) -> str:
    match = re.search(r"IPHONEOS_DEPLOYMENT_TARGET\s*=\s*([0-9]+(?:\.[0-9]+)?)", text)
    if match is None:
        raise ValueError("Не удалось определить IPHONEOS_DEPLOYMENT_TARGET из build settings")
    return match.group(1)


def parse_ios_deployment_target_from_pbxproj(text: str) -> str:
    matches = re.findall(r"IPHONEOS_DEPLOYMENT_TARGET = ([0-9]+(?:\.[0-9]+)?);", text)
    if not matches:
        raise ValueError("Не удалось определить IPHONEOS_DEPLOYMENT_TARGET из project.pbxproj")

    def to_tuple(value: str) -> tuple[int, ...]:
        return tuple(int(part) for part in value.split("."))

    return max(matches, key=to_tuple)


def read_swift_version(swift_version_path: Path) -> str:
    if not swift_version_path.exists():
        raise FileNotFoundError(f"Файл не найден: {swift_version_path}")

    for line in swift_version_path.read_text(encoding="utf-8").splitlines():
        version = line.strip()
        if version:
            return version
    raise ValueError(f"Не удалось найти версию Swift в файле {swift_version_path}")


def build_badges(xcode_version: str, swift_version: str, ios_version: str) -> str:
    return "\n".join(
        [
            f'[<img alt="Xcode Version" src="https://img.shields.io/badge/Xcode_Version-{xcode_version}-blue">](https://developer.apple.com/xcode/)',
            f'[<img alt="Swift Version" src="https://img.shields.io/badge/Swift_Version-{swift_version}-orange">](https://swift.org)',
            f'[<img alt="iOS Version" src="https://img.shields.io/badge/iOS_Version-{ios_version}-4F9153">](https://www.apple.com/ios/)',
        ]
    )


def replace_versions_block(readme_content: str, badges_block: str) -> str:
    begin_index = readme_content.find(BEGIN_MARKER)
    end_index = readme_content.find(END_MARKER)
    if begin_index == -1 or end_index == -1 or begin_index > end_index:
        raise ValueError("В README не найдены маркеры блока версий")

    head = readme_content[: begin_index + len(BEGIN_MARKER)]
    tail = readme_content[end_index:]
    return f"{head}\n{badges_block}\n{tail}"


def get_ios_version(root_dir: Path, project: str, scheme: str) -> str:
    try:
        build_settings = run_command(
            [
                "xcodebuild",
                "-project",
                project,
                "-scheme",
                scheme,
                "-showBuildSettings",
            ]
        )
        return parse_ios_deployment_target(build_settings)
    except Exception:
        pbxproj_path = root_dir / f"{project}/project.pbxproj"
        return parse_ios_deployment_target_from_pbxproj(pbxproj_path.read_text(encoding="utf-8"))


def update_readme_versions(root_dir: Path, readme_path: Path, project: str, scheme: str) -> bool:
    swift_version = read_swift_version(root_dir / ".swift-version")
    xcode_version = parse_xcode_version(run_command(["xcodebuild", "-version"]))
    ios_version = get_ios_version(root_dir, project=project, scheme=scheme)

    badges_block = build_badges(
        xcode_version=xcode_version,
        swift_version=swift_version,
        ios_version=ios_version,
    )

    original_content = readme_path.read_text(encoding="utf-8")
    updated_content = replace_versions_block(original_content, badges_block)

    if updated_content == original_content:
        return False

    readme_path.write_text(updated_content, encoding="utf-8")
    return True


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Обновляет бейджи Xcode/Swift/iOS в README.md")
    parser.add_argument("--root", default=".", help="Путь к корню проекта")
    parser.add_argument("--readme", default="README.md", help="Путь к README относительно корня")
    parser.add_argument("--project", default="SwiftUI-WorkoutApp.xcodeproj", help="Файл Xcode-проекта")
    parser.add_argument("--scheme", default="SwiftUI-WorkoutApp", help="Название схемы Xcode")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    root_dir = Path(args.root).resolve()
    readme_path = (root_dir / args.readme).resolve()

    try:
        changed = update_readme_versions(
            root_dir=root_dir,
            readme_path=readme_path,
            project=args.project,
            scheme=args.scheme,
        )
    except Exception as error:
        print(f"Не удалось обновить версии в README: {error}", file=sys.stderr)
        return 1

    if changed:
        print("Версии в README обновлены")
    else:
        print("Версии в README уже актуальны")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
