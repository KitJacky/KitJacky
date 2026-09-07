#!/usr/bin/env python3
"""GitHub's image proxy drops SVG CSS animations, leaving opacity:0 text invisible."""

from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
PATTERN = re.compile(r"\.stagger\s*\{[^}]*\}")


def freeze(path: Path) -> None:
    path.write_text(PATTERN.sub(".stagger { opacity: 1; }", path.read_text().lstrip()))


def main() -> None:
    for name in ("profile/stats.svg", "profile/top-langs.svg"):
        freeze(ROOT / name)


if __name__ == "__main__":
    main()
