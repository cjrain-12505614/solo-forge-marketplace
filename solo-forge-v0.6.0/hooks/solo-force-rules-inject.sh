#!/usr/bin/env bash
# Hook: solo-force-rules-inject
# Trigger: UserPromptSubmit (도구 매처 없음 — 프롬프트 이벤트)
# Purpose: 매 입력마다 프로젝트 핵심규칙을 맥락에 주입해, 세션당 1회(CLAUDE.md)를 넘어 턴당 1회로 강화 적용받게 한다.
# SSoT: 각 프로젝트의 docs/00_관리/강제규칙.md (없으면 침묵)
#
# 설계(왜 플러그인 훅인가): 메커니즘(매 턴 주입) = 플러그인이 제공 → 설치만으로 자동 배선.
#   내용(주입할 규칙) = 프로젝트 파일에서 읽음 → 파일만 고치면 재배포 없이 갱신 전파.
#   progress-dashboard-remind.sh 와 완전히 동일한 배선 패턴.
# 안전: 읽기 전용 · 파일이 없으면 조용히 통과(프롬프트를 막지 않음) · 항상 exit 0.
set -uo pipefail

DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
RULES="$DIR/docs/00_관리/강제규칙.md"

if [ -r "$RULES" ]; then
  cat "$RULES" 2>/dev/null || true
fi

exit 0
