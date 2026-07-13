#!/usr/bin/env bash
# Hook: solo-code-quality-hook
# Trigger: PostToolUse (Write|Edit)
# Purpose: 코드 파일 저장 후 셀프체크 넛지 — 품질 체크리스트 · N회 수정마다 검증 권고 · 보안 민감 파일 알림
# Gate: solo-dev-gate.sh (SOLO_DEV_HOOKS env 또는 .solo-forge 마커) — 개발 중일 때만 발동, 아니면 무음 통과
#       (기본값은 꺼짐 — 프로젝트 루트에 `touch .solo-forge` 하거나 SOLO_DEV_HOOKS=1 로 켠다)
# 안전: 넛지(stdout)만 · 편집을 막지 않음 · 항상 exit 0

# --- 개발-중 게이트 (하네스 켠 프로젝트에서만 울림) ---
_GATE="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)/solo-dev-gate.sh"
[ -f "$_GATE" ] && . "$_GATE"
if command -v solo_dev_gate_on >/dev/null 2>&1; then
  solo_dev_gate_on "${CLAUDE_FILE_PATH:-}" || exit 0
fi

FILE="${CLAUDE_FILE_PATH:-}"
[ -z "$FILE" ] && exit 0

# 소스코드 확장자 판별 (언어무관)
case "$FILE" in
  *.java|*.kt|*.scala|*.ts|*.tsx|*.js|*.jsx|*.py|*.go|*.rs|*.rb|*.php|*.cs|*.swift|*.c|*.h|*.cpp|*.hpp|*.cc|*.ex|*.exs|*.clj|*.m|*.mm)
    echo "💡 코드 품질 셀프체크:"
    echo "  - [ ] 에러 핸들링: 예외/실패 경로를 처리했나?"
    echo "  - [ ] 입력 검증: null/빈값/경계값을 확인했나?"
    echo "  - [ ] 네이밍: 타입/함수/변수명이 의도를 드러내나?"
    echo "  - [ ] 관측성: 중요 분기에 로그/에러 메시지를 남겼나?"

    # N회 수정마다 검증 권고 (러너 하드코딩 대신 /solo-verify-step 로 위임)
    COUNTER_FILE="/tmp/.solo-forge-edit-counter"
    COUNT=$(cat "$COUNTER_FILE" 2>/dev/null || echo 0)
    COUNT=$((COUNT + 1))
    echo "$COUNT" > "$COUNTER_FILE"
    if [ $((COUNT % 5)) -eq 0 ]; then
      echo "🔨 코드 ${COUNT}회 수정 — 검증 시점입니다: /solo-verify-step (감지된 러너로 빌드·테스트 실행)"
    fi
    ;;
esac

# 보안 민감 파일 (파일명 기반, 언어무관)
LC_FILE="$(echo "$FILE" | tr '[:upper:]' '[:lower:]')"
case "$LC_FILE" in
  *auth*|*security*|*secret*|*password*|*passwd*|*credential*|*cred*|*token*|*jwt*|*oauth*|*.env|*.env.*|*apikey*|*api_key*|*privatekey*|*private_key*|*session*|*crypto*|*cipher*)
    echo "🔒 보안 민감 파일 감지: $FILE"
    echo "  - [ ] 하드코딩된 시크릿/비밀번호/키가 없나? (커밋 전 제거)"
    echo "  - [ ] 인증/인가 로직이 올바른가?"
    echo "  - [ ] .env·키파일이 .gitignore 에 있나?"
    ;;
esac

exit 0
