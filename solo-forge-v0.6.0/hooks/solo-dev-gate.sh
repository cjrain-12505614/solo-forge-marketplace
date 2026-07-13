#!/usr/bin/env bash
# solo-dev-gate.sh — 개발 중일 때만 넛지 훅을 울리는 비강제 게이트 (source 로 호출하는 라이브러리)
# 함수 solo_dev_gate_on: 0(켜짐) / 1(꺼짐) 을 반환한다.
#
# 켜짐 판정:
#   1) 환경변수 override 우선:
#        SOLO_DEV_HOOKS=1|on|true|yes  → 강제 켜짐
#        SOLO_DEV_HOOKS=0|off|false|no → 강제 꺼짐
#   2) env 미설정이면 편집 파일 경로($1 또는 $CLAUDE_FILE_PATH)의 디렉토리부터 상위로
#      올라가며 '.solo-forge' 마커(파일/폴더)가 있으면 켜짐.
#   3) 아무 신호도 없으면 꺼짐 → 호출 훅이 무음 통과.
#
# 프로젝트에서 코드 넛지를 켜려면: 프로젝트 루트에 `touch .solo-forge` (또는 SOLO_DEV_HOOKS=1).
# 안전 게이트(solo-db-guard)는 이 게이트로 묶지 않는다(항상 켜짐).

solo_dev_gate_on() {
  local f="${1:-${CLAUDE_FILE_PATH:-}}"

  # 1) 환경변수 override
  case "${SOLO_DEV_HOOKS:-}" in
    1|on|ON|true|TRUE|yes|YES)    return 0 ;;
    0|off|OFF|false|FALSE|no|NO)  return 1 ;;
  esac

  # 2) .solo-forge 마커 상향 탐색
  [ -n "$f" ] || return 1
  local dir
  dir="$(cd "$(dirname "$f")" 2>/dev/null && pwd)" || return 1
  while [ -n "$dir" ] && [ "$dir" != "/" ]; do
    [ -e "$dir/.solo-forge" ] && return 0
    dir="$(dirname "$dir")"
  done

  # 3) 신호 없음 → 꺼짐
  return 1
}
