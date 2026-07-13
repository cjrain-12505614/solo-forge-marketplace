---
name: solo-end-session
description: 세션 종료 — 로그 저장 및 상태 갱신
allowed_tools:
  - read
  - write
  - edit
  - bash
---

# 세션 종료

준호가 현재 세션을 정리하고 다음을 위해 상태를 저장합니다.

## 실행 단계

### 1. 세션 번호 결정

docs/00_관리/sessions 폴더의 파일명을 확인하여 다음 세션 번호 N을 결정합니다.
형식: `session_N_YYYY-MM-DD.md`

### 2. 세션 로그 작성

다음 템플릿으로 session_N_YYYY-MM-DD.md 작성:

```markdown
# 세션 N — YYYY-MM-DD

## 목표
- [시작시 제시된 목표 1]
- [목표 2]

## 완료 사항
- [완료 항목 1]
- [완료 항목 2]

## 미완료 사항
- [미완료 항목 1]

## 산출물
- [문서/코드 파일 경로]
- [산출물 2]

## 의사결정
- [D-XXX] [주제]: [결정 내용]

## 미해결 이슈
- [이슈 설명]

## 다음 세션 TODO
1. [다음 작업 1]
2. [다음 작업 2]
3. [다음 작업 3]
```

### 3. 문서 동기화

- **decision_log.md**: 이번 세션에서 확정한 의사결정 추가, 미결 의사결정 업데이트
- **team_plan.md**: 팀 상태 및 진행 단계 업데이트
- **CLAUDE.md Section 11**: Lessons Log에 오늘 날짜 헤더 추가 (필요시)

### 4. 완료 보고

```
세션 저장 완료.

**세션 로그**: docs/00_관리/sessions/session_N_YYYY-MM-DD.md
**다음 세션 TODO**:
  1. [다음 작업 1]
  2. [다음 작업 2]

다음 세션에서 위 작업부터 이어서 진행합니다.
```
