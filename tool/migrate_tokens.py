#!/usr/bin/env python3
"""Bulk-migrate feature token files to AppWarmSurfaces / AppWarmText."""

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1] / "lib" / "features"

IMPORT = "import 'package:rydu_user/app/theme/app_colors.dart';\n"

SCAFFOLD_HEXES = {
    "0xFF050A12", "0xFF050A18", "0xFF060B14", "0xFF0A0E14", "0xFF0B0E14",
    "0xFF0B121E", "0xFF0A0E1A", "0xFF0A0E21", "0xFF0B0D17", "0xFF000000",
}

REPLACEMENTS = [
    (r"Color\(0xFF050A12\)", "AppWarmSurfaces.scaffold"),
    (r"Color\(0xFF050A18\)", "AppWarmSurfaces.scaffold"),
    (r"Color\(0xFF060B14\)", "AppWarmSurfaces.scaffold"),
    (r"Color\(0xFF0A0E14\)", "AppWarmSurfaces.scaffold"),
    (r"Color\(0xFF0B0E14\)", "AppWarmSurfaces.scaffold"),
    (r"Color\(0xFF0B121E\)", "AppWarmSurfaces.scaffold"),
    (r"Color\(0xFF0A0E1A\)", "AppWarmSurfaces.scaffold"),
    (r"Color\(0xFF0A0E21\)", "AppWarmSurfaces.scaffold"),
    (r"Color\(0xFF0B0D17\)", "AppWarmSurfaces.scaffold"),
    (r"Color\(0xFF111827\)", "AppWarmSurfaces.surface"),
    (r"Color\(0xFF1C1C1E\)", "AppWarmSurfaces.surface"),
    (r"Color\(0xFF12161F\)", "AppWarmSurfaces.surface"),
    (r"Color\(0xFF161B22\)", "AppWarmSurfaces.surface"),
    (r"Color\(0xFF161B2E\)", "AppWarmSurfaces.surfaceElevated"),
    (r"Color\(0xFF182235\)", "AppWarmSurfaces.inputSurface"),
    (r"Color\(0xFF0D1523\)", "AppWarmSurfaces.surfaceContainerLow"),
    (r"Color\(0xFF0D1117\)", "AppWarmSurfaces.surfaceContainerLow"),
    (r"Color\(0xFF1C1F2E\)", "AppWarmSurfaces.surfaceElevated"),
    (r"Color\(0xFF2A3548\)", "AppWarmSurfaces.border"),
    (r"Color\(0xFF2A3142\)", "AppWarmSurfaces.border"),
    (r"Color\(0xFF30363D\)", "AppWarmSurfaces.border"),
    (r"Color\(0xFF1F2937\)", "AppWarmSurfaces.borderSubtle"),
    (r"Color\(0xFFB8C0D4\)", "AppWarmText.secondary"),
    (r"Color\(0xFF9CA3AF\)", "AppWarmText.muted"),
    (r"AppDarkSurfaces\.", "AppWarmSurfaces."),
    (r"AppDarkText\.", "AppWarmText."),
]

WHITE_LINE = re.compile(
    r"static const (white|titleWhite|title) = Color\(0xFFFFFFFF\);"
)

SKIP_FILES = {
    "auth_light_tonal_tokens.dart",
    "offers_tokens.dart",  # marketing black hero — update manually
    "family_profile_tokens.dart",
    "rentals_tokens.dart",
}


def ensure_import(content: str) -> str:
    if "app/theme/app_colors.dart" in content:
        return content
    lines = content.splitlines(keepends=True)
    insert_at = 0
    for i, line in enumerate(lines):
        if line.startswith("import "):
            insert_at = i + 1
    lines.insert(insert_at, IMPORT)
    return "".join(lines)


def migrate_file(path: Path) -> bool:
    if path.name in SKIP_FILES:
        return False
    original = path.read_text(encoding="utf-8")
    content = original
    for pattern, repl in REPLACEMENTS:
        content = re.sub(pattern, repl, content)
    content = WHITE_LINE.sub(
        lambda m: f"static const {m.group(1)} = AppWarmText.primary;",
        content,
    )
    if "textOnScaffold" not in content and "AppWarmText" in content:
        # Add scaffold text role after first AppWarmText usage block
        content = content.replace(
            "abstract final class ",
            "abstract final class ",
            1,
        )
        if "static const textOnScaffold" not in content:
            marker = "abstract final class "
            idx = content.find(marker)
            if idx >= 0:
                brace = content.find("{", idx)
                if brace >= 0:
                    insert = (
                        "\n  static const textOnScaffold = AppWarmText.onScaffold;\n"
                        "  static const textPrimary = AppWarmText.primary;\n"
                    )
                    content = content[: brace + 1] + insert + content[brace + 1 :]
    content = ensure_import(content)
    if content != original:
        path.write_text(content, encoding="utf-8")
        return True
    return False


def main() -> None:
    changed = []
    for path in sorted(ROOT.rglob("*_tokens.dart")):
        if migrate_file(path):
            changed.append(str(path.relative_to(ROOT.parents[1])))
    print(f"Migrated {len(changed)} files:")
    for p in changed:
        print(f"  {p}")


if __name__ == "__main__":
    main()
