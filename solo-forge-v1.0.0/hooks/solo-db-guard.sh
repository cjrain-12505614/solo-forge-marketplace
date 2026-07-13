#!/usr/bin/env bash
# Hook: solo-db-guard
# Trigger: PreToolUse (Write|Edit|Bash)
# Purpose: 마이그레이션 SQL / Bash 커맨드에서 파괴적 명령(DROP TABLE·TRUNCATE·무조건 DELETE) 감지 시 차단
# SSoT: skills/solo-project-bootstrap 검증 규칙 ("실수로 운영 데이터 손실 방지")
#
# 입력: stdin JSON (Claude Code hook 표준) { "tool_name": ..., "tool_input": {...} }
# 차단: stdout에 {continue:false, decision:"block", reason:...} + exit 2
#
# 설계: 안전 가드라 기본 켜짐(다른 넛지 훅의 개발-중-게이트를 적용하지 않음).
#   명시적 opt-out(SOLO_DB_GUARD=off)일 때만 우회하며, 우회 사실을 가시 경고로 남긴다(우회=본인 책임).
# 안전: opt-out 외에는 파괴 패턴에서만 차단. 그 외 항상 exit 0.
set -euo pipefail

case "${SOLO_DB_GUARD:-}" in
  off|OFF|0|false|FALSE|no|NO)
    echo "⚠️ [solo-db-guard] SOLO_DB_GUARD=off — 파괴적 SQL 차단을 우회합니다(opt-out). 데이터 손실 위험은 본인 책임." >&2
    exit 0 ;;
esac

INPUT_JSON="$(cat || true)"

extract_field() {
  local key="$1"
  if command -v jq >/dev/null 2>&1; then
    echo "$INPUT_JSON" | jq -r "$key // empty" 2>/dev/null || echo ""
  else
    echo "$INPUT_JSON" | grep -oE "\"${key##*.}\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" \
      | head -1 | sed -E 's/.*:[[:space:]]*"([^"]*)".*/\1/'
  fi
}

TOOL_NAME="$(extract_field '.tool_name')"
FILE_PATH="$(extract_field '.tool_input.file_path')"
CONTENT="$(extract_field '.tool_input.content')"
COMMAND="$(extract_field '.tool_input.command')"

# 여러 생태계의 마이그레이션 위치를 포괄 (Rails·Django/alembic·Prisma·Flyway·golang-migrate·knex 등)
MIG_PATH_PAT='migrations?/|db/migrate|db/migration|prisma/migrations|alembic|flyway|sql/'
DANGER_PAT='(DROP[[:space:]]+TABLE|TRUNCATE[[:space:]]+TABLE|TRUNCATE[[:space:]]+[A-Za-z_]|DELETE[[:space:]]+FROM[[:space:]]+[A-Za-z_]+[[:space:]]*;)'

block() {
  local reason="$1"
  if command -v jq >/dev/null 2>&1; then
    jq -n --arg r "$reason" '{continue:false, decision:"block", reason:$r}'
  else
    printf '{"continue":false,"decision":"block","reason":"%s"}\n' "$reason"
  fi
  exit 2
}

case "$TOOL_NAME" in
  Write|Edit)
    if echo "$FILE_PATH" | grep -qiE "$MIG_PATH_PAT" && \
       echo "$FILE_PATH" | grep -qiE '\.sql$' && \
       echo "$CONTENT" | grep -qiE "$DANGER_PAT"; then
      block "마이그레이션 SQL에 파괴적 명령 감지 (DROP TABLE/TRUNCATE/무조건 DELETE). 데이터 손실 위험 → 주석으로 사유 명시 후 의도한 경우에만 진행(SOLO_DB_GUARD=off 로 우회). file=$FILE_PATH"
    fi
    ;;
  Bash)
    if echo "$COMMAND" | grep -qiE "$DANGER_PAT"; then
      block "Bash 커맨드에 파괴적 SQL 감지 (DROP TABLE/TRUNCATE/무조건 DELETE). command=$COMMAND"
    fi
    ;;
esac

exit 0
