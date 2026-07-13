---
name: solo-guide
description: 지금 뭐 해야 하지? — 현재 상태 기반 다음 단계 안내
allowed_tools:
  - read
  - glob
  - bash
---

# 가이드

현재 프로젝트 상태를 진단하고 다음 단계를 제시합니다.

## 상태 진단

### 1. 프로젝트 초기화 확인

CLAUDE.md 존재? → NO → **상태: 미초기화**

### 2. 현재 Phase 확인

team_plan.md에서 현재 Phase 읽기

### 3. 세션 상태 확인

최신 세션 로그에서 "다음 세션 TODO" 확인

### 4. 미결 의사결정 확인

decision_log.md에서 미결 항목 개수 파악

## 상태별 가이드

### 상태: 미초기화

```
아직 프로젝트가 설정되지 않았습니다.

🚀 시작하기:
  /init-project — 프로젝트 초기 설정
```

### 상태: Phase 초반 (1~2)

```
프로젝트 기획 및 설계 단계입니다.

📋 권장 명령어:
  /start-session — 세션 시작 및 목표 확인
  /feature-spec — 기능 명세 작성
  /decision add — 의사결정 기록
```

### 상태: Phase 중반 (2~4)

```
개발 및 구현 단계입니다.

💻 권장 명령어:
  /dispatch — 에이전트 투입 (개발/검토)
  /decision request — 미결 의사결정 요청
  /save-session — 중간 저장 (필요시)
```

### 상태: Phase 후반 (4~5)

```
검수 및 배포 단계입니다.

✅ 권장 명령어:
  /build-scenario — QA 테스트 시나리오
  /review-figma — 디자인 검증
  /end-session — 세션 종료 및 정리
```

### 상태: 미결 의사결정 多 (3+)

```
대기중인 의사결정이 많습니다.

🔔 권장 명령어:
  /decision list — 미결 의사결정 조회
  /decision request — PM 확인 요청
  /start-session — 세션 시작 후 의사결정 우선 처리
```

## 빠른 참조

| 상황 | 명령어 |
|------|--------|
| 지금부터 뭐 해? | `/start-session` |
| 현황 알고 싶어 | `/status` |
| 누군가에게 일 줄게 | `/dispatch [이름] [작업]` |
| 결정 기록해 | `/decision add` |
| 진행중 저장할게 | `/save-session` |
| 여기까지만 할게 | `/end-session` |
