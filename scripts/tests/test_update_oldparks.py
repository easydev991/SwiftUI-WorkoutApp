import json
import tempfile
import unittest
from argparse import Namespace
from pathlib import Path
from unittest import mock

from scripts import update_oldparks


class UpdateOldParksTests(unittest.TestCase):
    def test_replace_last_update_date_updates_value(self) -> None:
        source = 'private(set) var lastParksUpdateDateString = "2025-10-25T00:00:00"\n'
        updated = update_oldparks.replace_last_update_date(source, "2026-04-25T18:00:00")
        self.assertIn('lastParksUpdateDateString = "2026-04-25T18:00:00"', updated)

    def test_replace_last_update_date_raises_when_variable_missing(self) -> None:
        with self.assertRaises(RuntimeError):
            update_oldparks.replace_last_update_date("var unknown = \"x\"\n", "2026-01-01T00:00:00")

    def test_find_unique_file_returns_single_match(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            target = root / "A" / "oldParks.json"
            target.parent.mkdir(parents=True)
            target.write_text("[]", encoding="utf-8")

            found = update_oldparks.find_unique_file(root, "oldParks.json")
            self.assertEqual(found, target)

    def test_find_unique_file_raises_when_not_found(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            with self.assertRaises(RuntimeError):
                update_oldparks.find_unique_file(Path(temp_dir), "oldParks.json")

    def test_find_unique_file_raises_when_multiple_found(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            for index in range(2):
                target = root / f"P{index}" / "oldParks.json"
                target.parent.mkdir(parents=True)
                target.write_text("[]", encoding="utf-8")

            with self.assertRaises(RuntimeError):
                update_oldparks.find_unique_file(root, "oldParks.json")

    def test_load_all_parks_stops_on_empty_page(self) -> None:
        responses = {
            1: [{"id": 1}],
            2: [{"id": 2}, {"id": 3}],
            3: [],
        }
        calls: list[int] = []

        def fake_fetch(_api_base: str, page: int, _page_size: int, _timeout: int) -> list[dict]:
            calls.append(page)
            return responses[page]

        result = update_oldparks.load_all_parks(
            api_base="https://example.com/api/v3",
            page_size=1000,
            timeout_seconds=5,
            retries=3,
            page_delay_seconds=2,
            sleep_fn=lambda _seconds: None,
            fetch_fn=fake_fetch,
        )

        self.assertEqual(calls, [1, 2, 3])
        self.assertEqual(result, [{"id": 1}, {"id": 2}, {"id": 3}])

    def test_load_all_parks_sleeps_between_non_empty_pages(self) -> None:
        responses = {
            1: [{"id": 1}],
            2: [],
        }
        sleeps: list[float] = []

        def fake_fetch(_api_base: str, page: int, _page_size: int, _timeout: int) -> list[dict]:
            return responses[page]

        update_oldparks.load_all_parks(
            api_base="https://example.com/api/v3",
            page_size=1000,
            timeout_seconds=5,
            retries=3,
            page_delay_seconds=2,
            sleep_fn=lambda seconds: sleeps.append(seconds),
            fetch_fn=fake_fetch,
        )

        self.assertEqual(sleeps, [2])

    def test_load_all_parks_retries_network_errors(self) -> None:
        attempts = {"count": 0}
        sleeps: list[float] = []

        def fake_fetch(_api_base: str, page: int, _page_size: int, _timeout: int) -> list[dict]:
            if page == 1:
                attempts["count"] += 1
                if attempts["count"] < 3:
                    raise update_oldparks.NetworkRequestError("Сетевая ошибка")
                return [{"id": 1}]
            return []

        result = update_oldparks.load_all_parks(
            api_base="https://example.com/api/v3",
            page_size=1000,
            timeout_seconds=5,
            retries=3,
            page_delay_seconds=2,
            sleep_fn=lambda seconds: sleeps.append(seconds),
            fetch_fn=fake_fetch,
        )

        self.assertEqual(result, [{"id": 1}])
        self.assertEqual(attempts["count"], 3)
        self.assertEqual(sleeps, [2, 2, 2])

    def test_load_all_parks_fails_after_max_retries(self) -> None:
        attempts = {"count": 0}

        def fake_fetch(_api_base: str, _page: int, _page_size: int, _timeout: int) -> list[dict]:
            attempts["count"] += 1
            raise update_oldparks.NetworkRequestError("Сетевая ошибка")

        with self.assertRaises(update_oldparks.NetworkRequestError):
            update_oldparks.load_all_parks(
                api_base="https://example.com/api/v3",
                page_size=1000,
                timeout_seconds=5,
                retries=3,
                page_delay_seconds=2,
                sleep_fn=lambda _seconds: None,
                fetch_fn=fake_fetch,
            )

        self.assertEqual(attempts["count"], 3)

    def test_fetch_page_builds_short_query_without_equipment(self) -> None:
        class FakeResponse:
            def __init__(self, body: str) -> None:
                self._body = body

            def getcode(self) -> int:
                return 200

            def read(self) -> bytes:
                return self._body.encode("utf-8")

            def __enter__(self) -> "FakeResponse":
                return self

            def __exit__(self, exc_type, exc, tb) -> bool:
                return False

        with mock.patch("scripts.update_oldparks.request.urlopen", return_value=FakeResponse("[]")) as mocked:
            update_oldparks.fetch_page("https://example.com/api/v3", page=4, page_size=1000, timeout_seconds=5)
            called_url = mocked.call_args.args[0]

        self.assertIn("fields=short", called_url)
        self.assertIn("page_size=1000", called_url)
        self.assertIn("page=4", called_url)
        self.assertNotIn("equipment", called_url)

    def test_write_json_atomically_writes_file(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            target = Path(temp_dir) / "oldParks.json"
            data = [{"id": 7}]
            update_oldparks.write_json_atomically(target, data)
            self.assertEqual(json.loads(target.read_text(encoding="utf-8")), data)

    def test_run_updates_json_and_date_on_success(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            oldparks = root / "Any" / "oldParks.json"
            oldparks.parent.mkdir(parents=True)
            oldparks.write_text("[]", encoding="utf-8")

            parks_manager = root / "SwiftUI-WorkoutApp" / "Services" / "ParksManager.swift"
            parks_manager.parent.mkdir(parents=True)
            parks_manager.write_text(
                'private(set) var lastParksUpdateDateString = "2025-10-25T00:00:00"\n',
                encoding="utf-8",
            )

            args = Namespace(
                root=str(root),
                api_base="https://example.com/api/v3",
                page_size=1000,
                timeout=5,
                retries=3,
                page_delay=2,
                output=None,
                parks_manager=None,
            )

            with mock.patch(
                "scripts.update_oldparks.load_all_parks",
                return_value=[{"id": 1}, {"id": 2}],
            ), mock.patch("scripts.update_oldparks.now_string", return_value="2026-04-25T18:11:12"):
                code = update_oldparks.run(args)

            self.assertEqual(code, 0)
            self.assertEqual(json.loads(oldparks.read_text(encoding="utf-8")), [{"id": 1}, {"id": 2}])
            manager_content = parks_manager.read_text(encoding="utf-8")
            self.assertIn('lastParksUpdateDateString = "2026-04-25T18:11:12"', manager_content)

    def test_run_does_not_update_date_when_download_fails(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            oldparks = root / "Any" / "oldParks.json"
            oldparks.parent.mkdir(parents=True)
            oldparks.write_text('[{"id": 9}]', encoding="utf-8")

            parks_manager = root / "SwiftUI-WorkoutApp" / "Services" / "ParksManager.swift"
            parks_manager.parent.mkdir(parents=True)
            initial_date = "2025-10-25T00:00:00"
            parks_manager.write_text(
                f'private(set) var lastParksUpdateDateString = "{initial_date}"\n',
                encoding="utf-8",
            )

            args = Namespace(
                root=str(root),
                api_base="https://example.com/api/v3",
                page_size=1000,
                timeout=5,
                retries=3,
                page_delay=2,
                output=None,
                parks_manager=None,
            )

            with mock.patch("scripts.update_oldparks.load_all_parks", side_effect=RuntimeError("HTTP 500")):
                code = update_oldparks.run(args)

            self.assertEqual(code, 1)
            self.assertEqual(json.loads(oldparks.read_text(encoding="utf-8")), [{"id": 9}])
            manager_content = parks_manager.read_text(encoding="utf-8")
            self.assertIn(f'lastParksUpdateDateString = "{initial_date}"', manager_content)

    def test_now_string_uses_expected_format(self) -> None:
        value = update_oldparks.now_string()
        self.assertRegex(value, r"^\d{4}-\d{2}-\d{2}T00:00:00$")


if __name__ == "__main__":
    unittest.main()
