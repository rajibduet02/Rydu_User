#!/usr/bin/env python3
"""Replace coral #EF8561 migration colors with Figma blue reference tokens."""

from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1] / "lib"

# Order matters: longer / alpha patterns first.
REPLACEMENTS: list[tuple[str, str]] = [
    ("0x80EF8561", "0x802F6BFF"),
    ("0x8CEF8561", "0x8C2F6BFF"),
    ("0x66EF8561", "0x662F6BFF"),
    ("0x4DEF8561", "0x4D2F6BFF"),
    ("0x33EF8561", "0x332F6BFF"),
    ("0x1AEF8561", "0x1A2F6BFF"),
    ("0x99EF8561", "0x992F6BFF"),
    ("0xFFEF8561", "0xFF2F6BFF"),
    ("0xFFF5A882", "0xFF4D7DFF"),
    ("0xFFD66B45", "0xFF2962FF"),
    ("0xFF2A211C", "0xFF1A2F55"),
    ("#EF8561", "#2F6BFF"),
    ("#F5A882", "#4D7DFF"),
    ("#D66B45", "#2962FF"),
    ("#2A211C", "#1A2F55"),
    ("EF8561", "2F6BFF"),
    ("F5A882", "4D7DFF"),
    ("D66B45", "2962FF"),
]

TOKEN_SUBS: list[tuple[str, str]] = [
    ("static const borderFocused = Color(0xFF2F6BFF);", "static const borderFocused = AppBrand.primary;"),
    ("static const buttonBlue = Color(0xFF2F6BFF);", "static const buttonBlue = AppBrand.primary;"),
    ("static const buttonBlueEnd = Color(0xFF4D7DFF);", "static const buttonBlueEnd = AppBrand.primaryLight;"),
    ("static const accent = Color(0xFF2F6BFF);", "static const accent = AppBrand.primary;"),
    ("static const accentAlt = Color(0xFF2F6BFF);", "static const accentAlt = AppBrand.primary;"),
    ("static const accentBlue = Color(0xFF2F6BFF);", "static const accentBlue = AppBrand.primary;"),
    ("static const accentSolid = Color(0xFF2F6BFF);", "static const accentSolid = AppBrand.primary;"),
    ("static const accentDeep = Color(0xFF2F6BFF);", "static const accentDeep = AppBrand.primary;"),
    ("static const link = Color(0xFF2F6BFF);", "static const link = AppBrand.primary;"),
    ("static const liveChat = Color(0xFF2F6BFF);", "static const liveChat = AppBrand.primary;"),
    ("static const selectedBorder = Color(0xFF2F6BFF);", "static const selectedBorder = AppBrand.primary;"),
    ("static const sliderActive = Color(0xFF2F6BFF);", "static const sliderActive = AppBrand.primary;"),
    ("static const borderSelected = Color(0xFF2F6BFF);", "static const borderSelected = AppBrand.primary;"),
    ("static const protectionCircle = Color(0xFF2F6BFF);", "static const protectionCircle = AppBrand.primary;"),
    ("static const userBubble = Color(0xFF2F6BFF);", "static const userBubble = AppBrand.primary;"),
    ("static const dotBlue = Color(0xFF2F6BFF);", "static const dotBlue = AppBrand.primary;"),
    ("static const topBorder = Color(0x662F6BFF);", "static const topBorder = AppBrand.primaryBorder;"),
    ("static const borderUnread = Color(0x802F6BFF);", "static const borderUnread = Color(0x802F6BFF);"),
    ("static const secureFill = Color(0x1A2F6BFF);", "static const secureFill = Color(0x1A2F6BFF);"),
    ("static const secureBorder = Color(0x4D2F6BFF);", "static const secureBorder = AppBrand.primaryBorder;"),
    ("static const reminderFill = Color(0x1A2F6BFF);", "static const reminderFill = Color(0x1A2F6BFF);"),
    ("static const reminderBorder = Color(0x4D2F6BFF);", "static const reminderBorder = AppBrand.primaryBorder;"),
]


def ensure_app_colors_import(text: str) -> str:
    if "AppBrand." not in text:
        return text
    if "app_colors.dart" in text:
        return text
    return "import 'package:rydu_user/app/theme/app_colors.dart';\n" + text


def process_file(path: Path) -> bool:
    original = path.read_text(encoding="utf-8")
    text = original
    for old, new in REPLACEMENTS:
        text = text.replace(old, new)
    for old, new in TOKEN_SUBS:
        if old.split("=")[0].strip() in text:
            text = text.replace(old, new)
    if text != original and "AppBrand." in text:
        text = ensure_app_colors_import(text)
    if text != original:
        path.write_text(text, encoding="utf-8")
        return True
    return False


def main() -> None:
    changed = 0
    for path in sorted(ROOT.rglob("*.dart")):
        if process_file(path):
            changed += 1
            print(path.relative_to(ROOT.parent))
    print(f"Updated {changed} files")


if __name__ == "__main__":
    main()
