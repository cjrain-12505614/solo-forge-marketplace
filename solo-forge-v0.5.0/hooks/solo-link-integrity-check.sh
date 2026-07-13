#!/usr/bin/env bash
# Hook: solo-link-integrity-check
# Trigger: PostToolUse (Write|Edit) on *.md
# Purpose: .md 편집 직후 그 파일의 상대경로 마크다운 링크 깨짐을 즉시 검출(단일 파일 점검 — 전수 X)
# SSoT: 없음(자기완결). solo 프로젝트는 세션로그·의사결정·로드맵 등 상대링크 집약형이라 고신호·저노이즈.
# 안전: 읽기 전용 · stderr 경고만 · 항상 exit 0(편집을 막지 않음).

FILE_PATH="${CLAUDE_FILE_PATH:-$1}"
[ -z "$FILE_PATH" ] && exit 0

# 비-마크다운 스킵
case "$FILE_PATH" in
  *.md|*.MD) ;;
  *) exit 0 ;;
esac

# 보관/백업 영역 스킵
case "$FILE_PATH" in
  */_archive/*|*/archive/*|*.bak.*) exit 0 ;;
esac

# 파일 미존재(삭제 직후 등) 스킵
[ -f "$FILE_PATH" ] || exit 0

# Python 깨진 링크 검출
python3 - "$FILE_PATH" <<'PYEOF'
import os, re, sys
from urllib.parse import unquote

LINK = re.compile(r'\[([^\]]*)\]\(([^)]+)\)')
broken = []
fp = sys.argv[1]
base = os.path.dirname(fp) or '.'

try:
    with open(fp, encoding='utf-8') as f:
        for ln, line in enumerate(f, 1):
            for m in LINK.finditer(line):
                p = m.group(2).split('#')[0].split('?')[0]
                if not p or p.startswith(('http://', 'https://', 'mailto:', '#')):
                    continue
                target = os.path.normpath(os.path.join(base, unquote(p)))
                if not os.path.exists(target):
                    broken.append((ln, p))
except Exception:
    sys.exit(0)

if broken:
    sys.stderr.write(f"⚠️  깨진 링크 검출: {fp}\n")
    for ln, p in broken[:5]:
        sys.stderr.write(f"    L{ln}: {p}\n")
    if len(broken) > 5:
        sys.stderr.write(f"    ... +{len(broken)-5}건\n")
PYEOF
exit 0
