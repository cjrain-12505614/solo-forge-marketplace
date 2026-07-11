#!/usr/bin/env bash
# Trigger: UserPromptSubmit
# Tools: — (프롬프트 이벤트 — 도구 매처 없음)
# Purpose: 매 입력마다 진행 대시보드(solo-progress-dashboard) 발동 판단 환기 1줄 주입 — 3중 상시 인지(CLAUDE.md·스킬·매 입력 환기)의 셋째 다리
# SSoT: skills/solo-progress-dashboard/SKILL.md §13
#
# 배경(v0.3.0 신설 — douzone-forge dz-progress-dashboard에서 이식):
#   원 스킬에서 환기 층이 워크스페이스 로컬 파일로만 구현돼 gitignore 영역에서
#   조용히 소실 → 대시보드 상시 미발동 사고가 있었다. 본 훅은 플러그인에 내장하고
#   **기본 문구를 스크립트에 내장**해 외부 파일 부재 시에도 절대 침묵하지 않는다.
#
# 내용 우선순위:
#   1순위: {프로젝트}/docs/00_관리/진행대시보드-환기.md (존재 시 문구 교체를 재배포 없이 전파)
#   2순위(기본): 아래 내장 1줄
#
# 안전: 읽기 전용 · 항상 exit 0 (프롬프트를 막지 않음).
set -euo pipefail

DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
SYNCED="$DIR/docs/00_관리/진행대시보드-환기.md"
DEFAULT='[진행 대시보드 환기] 이번 작업이 신호 3개 이상(단계 3개+ · 다영역/다파일 · 장시간·다세션 · 산출물 다수 · "복잡" 언급)이면 solo-progress-dashboard 자동 발동을 검토할 것 — 상위 대시보드가 있으면 신규 생성 없이 그 항목만 갱신, 켤 때 "대시보드로 추적하겠습니다" 1줄 고지.'

if [ -r "$SYNCED" ]; then
  cat "$SYNCED" 2>/dev/null || echo "$DEFAULT"
else
  echo "$DEFAULT"
fi

exit 0
