---
name: solo-decision
description: 의사결정 기록 또는 컨펌 요청
allowed_tools:
  - read
  - edit
  - bash
---

# 의사결정 관리

의사결정을 기록하거나 PM의 확인을 요청합니다.

## 사용법

```
/decision add [주제] [선택지] [선정 사유]
/decision request [주제] [선택지] [검토 필요 이유]
/decision list
```

## 서브커맨드

### 1. add — 의사결정 기록

이미 확정된 의사결정을 decision_log.md에 기록합니다.

```
/decision add 인증방식 JWT vs OAuth 선택 JWT 선택 — 간단하고 모바일 친화적
```

실행 단계:
1. decision_log.md 열기
2. 다음 D-ID 결정 (기존 최대 ID + 1)
3. "확정 의사결정" 섹션에 추가:
```
- [D-001] 인증방식: JWT (이유: 간단하고 모바일 친화적)
  - 선택지: JWT vs OAuth
  - 확정일: YYYY-MM-DD
  - 제안자: [역할]
```
4. CLAUDE.md Section 9에도 동기화
5. 완료 보고

### 2. request — PM 확인 요청

아직 확정되지 않은 의사결정을 PM의 검토 요청합니다.

```
/decision request 캐싱전략 Redis vs Memcached 성능과 비용 고려 필요
```

실행 단계:
1. decision_log.md 열기
2. "미결 의사결정" 섹션에 추가:
```
- [D-002] 캐싱전략: 검토중 (제안자: [역할])
  - 선택지: Redis vs Memcached
  - 비고: 성능과 비용 고려 필요
  - 상태: PM 검토 대기
```
2. CLAUDE.md Section 10에 추가
3. PM에게 알림:
```
의사결정 검토 요청

**항목**: [D-002] 캐싱전략
**선택지**: Redis vs Memcached
**배경**: [상세 설명]
**영향도**: [high/medium/low]

검토 후 /decision add로 확정 바랍니다.
```

### 3. list — 의사결정 조회

현재 확정/미결 의사결정 목록을 표시합니다.

```
현재 의사결정 현황

## 확정 의사결정 (X건)
- [D-001] 인증방식: JWT
- [D-002] DB: PostgreSQL
- ...

## 미결 의사결정 (Y건)
- [D-XXX] 캐싱전략: Redis vs Memcached (PM 검토 대기)
- [D-YYY] 배포방식: Kubernetes vs Docker Compose (설계 진행중)
- ...
```

## 동기화 규칙

- **add 시**: decision_log.md + CLAUDE.md Section 9
- **request 시**: decision_log.md + CLAUDE.md Section 10
- **list 시**: decision_log.md 읽기만 (수정 없음)

## ID 포맷

D-001, D-002, ... (의사결정 로그 파일에서 자동 부여)
