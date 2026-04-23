import unittest

from scripts.update_readme_versions import (
    BEGIN_MARKER,
    END_MARKER,
    build_badges,
    parse_ios_deployment_target,
    parse_ios_deployment_target_from_pbxproj,
    parse_xcode_version,
    replace_versions_block,
)


class UpdateReadmeVersionsTests(unittest.TestCase):
    def test_parse_xcode_version(self) -> None:
        output = "Xcode 26.4\nBuild version 17E192\n"
        self.assertEqual(parse_xcode_version(output), "26.4")

    def test_parse_ios_deployment_target(self) -> None:
        build_settings = "IPHONEOS_DEPLOYMENT_TARGET = 16.0\nSWIFT_VERSION = 6.0\n"
        self.assertEqual(parse_ios_deployment_target(build_settings), "16.0")

    def test_parse_ios_deployment_target_from_pbxproj_uses_highest(self) -> None:
        project = """
        IPHONEOS_DEPLOYMENT_TARGET = 15.0;
        IPHONEOS_DEPLOYMENT_TARGET = 16.0;
        IPHONEOS_DEPLOYMENT_TARGET = 13.4;
        """
        self.assertEqual(parse_ios_deployment_target_from_pbxproj(project), "16.0")

    def test_replace_versions_block(self) -> None:
        content = f"# Title\n\n{BEGIN_MARKER}\nold\n{END_MARKER}\nbody\n"
        badges = "new1\nnew2"
        updated = replace_versions_block(content, badges)
        expected = f"# Title\n\n{BEGIN_MARKER}\nnew1\nnew2\n{END_MARKER}\nbody\n"
        self.assertEqual(updated, expected)

    def test_replace_versions_block_without_markers_raises(self) -> None:
        with self.assertRaises(ValueError):
            replace_versions_block("# Title\n", "badges")

    def test_replace_versions_block_is_idempotent(self) -> None:
        badges = build_badges(xcode_version="26.4", swift_version="6.3.0", ios_version="16.0")
        content = f"{BEGIN_MARKER}\nold\n{END_MARKER}\n"

        first = replace_versions_block(content, badges)
        second = replace_versions_block(first, badges)

        self.assertEqual(first, second)


if __name__ == "__main__":
    unittest.main()
