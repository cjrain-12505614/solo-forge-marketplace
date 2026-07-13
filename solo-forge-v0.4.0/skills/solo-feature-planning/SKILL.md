---
name: solo-feature-planning
description: 기능 스펙 문서를 체계적으로 생성하는 스킬. 사용자가 '기능 기획해줘', '스펙 작성해줘', '요구사항 정리해줘', '사용자 스토리 만들어줘', '화면 목록 뽑아줘', '기능 분석해줘' 등을 요청하거나, 특정 기능에 대한 기획·설계 문서가 필요할 때 반드시 이 스킬을 사용하세요.
---

# 기능 기획 스킬

## 개요
비즈니스 요구사항을 기능 스펙으로 체계적으로 변환합니다. 사용자 스토리, 수용 기준, 화면 목록, 데이터 모델, API까지 포괄적으로 정의합니다.

## 출력 위치

모든 기능 스펙 문서는 **docs/02_기획/** 폴더에 저장됩니다.

```
docs/02_기획/
├── feature_spec_auth_v1.0.md
├── feature_spec_payment_v0.5.md
├── user_story_map_v1.0.md
└── ...
```

## 기능 스펙 템플릿

### 파일명
```
feature_spec_{기능명}_{버전}.md

예: feature_spec_auth_v1.0.md
   feature_spec_payment_v0.5.md
   feature_spec_user_profile_v1.0.md
```

### 문서 구조

```markdown
---
version: v1.0
status: Draft / Review / Approved
author: {작성자명}
date: YYYY-MM-DD
related_phase: P-X
related_requirements: REQ-XX, REQ-YY, ...
related_decisions: D-XX, D-YY, ...
---

# 기능 스펙: {기능 명칭}

## 1. 기능 개요

### 기능명
{한 줄 요약}

### 비즈니스 목표
- {목표 1}
- {목표 2}
- {목표 3}

### 범위
**포함 사항**:
- {기능 A}
- {기능 B}

**제외 사항**:
- {기능 C} (향후 버전에서 검토)
- {기능 D}

### 우선순위
P1 (Critical) / P2 (High) / P3 (Medium) / P4 (Low)

### 예상 복잡도
낮음 / 중간 / 높음

---

## 2. 사용자 스토리

### 서식
As a {사용자 역할}, I want {기능}, so that {기대 결과}

### 예시

#### Story 1: 사용자 가입
- **ID**: US-AUTH-001
- **Story**: As a new user, I want to create an account with email and password, so that I can access the service.
- **Priority**: P1
- **Est. Points**: 5

#### Story 2: 이메일 인증
- **ID**: US-AUTH-002
- **Story**: As a registered user, I want to verify my email via confirmation link, so that I can activate my account.
- **Priority**: P1
- **Est. Points**: 3

---

## 3. 수용 기준 (Acceptance Criteria)

각 사용자 스토리마다 최소 3개 이상의 AC 작성

### Story 1: 사용자 가입 (US-AUTH-001)

**AC 1.1**: 정상 가입
```gherkin
Given: 가입 페이지 접속
When: 유효한 이메일과 비밀번호 입력 후 "가입" 버튼 클릭
Then: 계정 생성 완료 메시지 표시 및 이메일 확인 페이지로 이동
```

**AC 1.2**: 이메일 중복 검증
```gherkin
Given: 이미 가입된 이메일로 가입 시도
When: "가입" 버튼 클릭
Then: "이미 등록된 이메일입니다" 오류 메시지 표시
      가입 폼은 유지
```

**AC 1.3**: 비밀번호 규칙 검증
```gherkin
Given: 비밀번호 입력창
When: 8자 미만의 비밀번호 입력
Then: "비밀번호는 8자 이상이어야 합니다" 경고 표시
      "가입" 버튼은 비활성화 상태
```

**AC 1.4**: 필수 필드 검증
```gherkin
Given: 가입 폼
When: 이메일이나 비밀번호 필드를 비운 상태로 제출 시도
Then: "필수 항목입니다" 오류 메시지 표시
      해당 필드 하이라이트
```

---

## 4. 화면 목록 (Screen Inventory)

### 화면 맵핑

| 화면 ID | 화면명 | 관련 기능 | 담당자 | 상태 |
|--------|--------|---------|---------|------|
| SCR-AUTH-001 | 가입 | US-AUTH-001, US-AUTH-002 | Designer | 🔄 진행중 |
| SCR-AUTH-002 | 이메일 확인 | US-AUTH-002 | Designer | ⬜ 미시작 |
| SCR-AUTH-003 | 로그인 | US-AUTH-003 | Designer | ⬜ 미시작 |

### 화면 설명

#### SCR-AUTH-001: 가입 화면
- **경로**: /signup
- **구성요소**:
  - 이메일 입력 필드 (+ 중복 체크)
  - 비밀번호 입력 필드 (+ 강도 표시)
  - 비밀번호 확인 필드
  - [가입] 버튼
  - [로그인하기] 링크
- **참고**: 04_화면설계/wireframe_v*.md 참조

---

## 5. 데이터 모델

### 엔티티 정의

#### User (사용자)
```
필드명          | 타입     | 제약사항          | 설명
user_id         | UUID     | PK, Auto         | 사용자 고유 ID
email           | String   | UK, Not Null     | 이메일 (로그인)
password_hash   | String   | Not Null         | 해시된 비밀번호
is_verified     | Boolean  | Default: false   | 이메일 인증 여부
created_at      | DateTime | Not Null         | 계정 생성일
updated_at      | DateTime | Not Null         | 마지막 수정일
```

#### EmailVerification (이메일 인증)
```
필드명          | 타입     | 제약사항          | 설명
token           | String   | PK, Unique       | 인증 토큰
user_id         | UUID     | FK → User        | 사용자 ID
expires_at      | DateTime | Not Null         | 토큰 만료 시간
verified_at     | DateTime | Nullable         | 인증 완료 시간
```

### ERD (관계도)
```
[User] ──────(1:N)────── [EmailVerification]
  │
  └─── (1:1) ──── [Profile]
```

---

## 6. API 엔드포인트 (REST)

### 가입 API

**Endpoint**: `POST /api/v1/auth/signup`

**Request**:
```json
{
  "email": "user@example.com",
  "password": "SecurePass123!",
  "password_confirm": "SecurePass123!"
}
```

**Response (201 Created)**:
```json
{
  "user_id": "550e8400-e29b-41d4-a716-446655440000",
  "email": "user@example.com",
  "message": "가입이 완료되었습니다. 이메일 확인 링크를 발송했습니다."
}
```

**Error (400 Bad Request)**:
```json
{
  "error_code": "INVALID_EMAIL",
  "message": "유효하지 않은 이메일 형식입니다."
}
```

**Error (409 Conflict)**:
```json
{
  "error_code": "EMAIL_ALREADY_EXISTS",
  "message": "이미 등록된 이메일입니다."
}
```

### 이메일 인증 API

**Endpoint**: `POST /api/v1/auth/verify-email`

**Request**:
```json
{
  "token": "{인증_토큰}"
}
```

**Response (200 OK)**:
```json
{
  "user_id": "550e8400-e29b-41d4-a716-446655440000",
  "message": "이메일 인증이 완료되었습니다."
}
```

---

## 7. 예외 케이스 (Edge Cases)

### Validation 오류
- 이메일 형식 검증 (RFC 5322)
- 비밀번호 규칙 (최소 8자, 특수문자 포함)
- 필수 필드 확인

### 타임아웃/네트워크 오류
- API 응답 타임아웃 (5초): 재시도 옵션 제공
- 네트워크 오류: 오프라인 메시지 표시
- 이메일 발송 실패: 재발송 링크 제공

### 보안 고려사항
- 비밀번호 평문 저장 금지 (bcrypt 또는 argon2 사용)
- SQL Injection 방지 (Prepared Statement)
- CSRF 토큰 사용
- Rate Limiting (가입: 분당 3회 제한)

### 중복 요청 (Idempotency)
- 이미 가입된 사용자가 다시 가입 시도 → "이미 등록된 이메일" 오류
- 중복된 가입 요청 → 첫 번째 결과 반환

---

## 8. 성능/확장성 고려사항

### 성능 목표
- 가입 완료 응답 시간: < 1초
- 이메일 발송 시간: < 5초 (비동기)
- 이메일 중복 검증: < 200ms

### 확장성
- 이메일 검증 토큰은 Redis에 캐싱 (TTL: 24시간)
- 사용자 정보는 DB에 저장 (자동 백업)
- 이메일 발송은 메시지 큐(SQS/RabbitMQ) 사용

---

## 9. 의사결정 참고 (Decision Log)

이 기능 기획과 관련된 의사결정:

| 결정 ID | 주제 | 결정사항 | 근거 |
|--------|------|--------|------|
| D-001 | 이메일 인증 방식 | 확인 링크 방식 | 사용자 편의성, 보안성 |
| D-002 | 비밀번호 최소 길이 | 8자 이상 | 보안 표준 준수 |
| D-003 | 토큰 유효 시간 | 24시간 | 일반적인 관례 |

→ decision_log.md에서 전체 기록 참조

---

## 10. 용어사전 (Glossary)

문서에서 사용되는 용어의 정의:

| 용어 | 정의 |
|------|------|
| 가입 (Sign Up) | 새로운 계정을 생성하는 절차 |
| 인증 (Verification) | 사용자가 이메일 소유자임을 확인하는 절차 |
| 토큰 (Token) | 이메일 확인용 일회용 문자열 |
| AC (Acceptance Criteria) | 기능이 완성되었음을 확인하는 조건 |

---

## 기능 기획 워크플로우

### 1단계: 요구사항 수집
```
team_plan.md → Phase 정의 → 해당 Phase의 요구사항 확인
docs/01_요구사항/ → requirements 문서 참조
```

### 2단계: 스펙 문서 생성
```
위 템플릿을 기반으로 feature_spec_{기능명}_v0.1.md 작성
처음엔 v0.1 (Draft) 상태로 시작
```

### 3단계: 반복 검토
```
v0.1 → v0.2 → ... → v0.9: 내부 피드백 반영
최종 PM 검수 후 v1.0 승격
(deliverable-management 스킬의 품질 게이트 실행)
```

### 4단계: 후속 산출물 연계
```
✅ 기능 스펙 v1.0 완료
  ↓
🔄 화면설계 시작 (04_화면설계/)
🔄 QA 시나리오 생성 (05_검증/)
🔄 DB 스키마 설계 (03_설계/)
🔄 API 설계 (03_설계/)
```

---

## 사용 예시

### 예시 1: 기본 요청
**PM**: "인증 기능 스펙 작성해줘"
→ 이 템플릿을 사용해 feature_spec_auth_v0.1.md 생성

### 예시 2: 특정 섹션 요청
**PM**: "결제 기능 사용자 스토리 만들어줘"
→ 템플릿의 "2. 사용자 스토리" 섹션 중심으로 작성

### 예시 3: 요구사항 → 스펙 변환
**PM**: "이 요구사항을 스펙으로 정리해줘" (요구사항 문서 제시)
→ 요구사항을 분석 → 스펙 문서로 구조화

### 예시 4: 버전 업데이트
**PM**: "요구사항이 바뀌었어, 스펙 수정해줘"
→ v0.x 문서 수정 → v0.(x+1)로 버전업
→ decision_log.md에 변경 사항 기록

---

## 품질 게이트 체크 (v1.0 승격 시)

이 스킬로 생성한 기능 스펙을 v1.0으로 승격할 때 확인할 항목:

**deliverable-management 스킬의 "기능 스펙 체크리스트"** 참조

---

**담당**: PM (기획) + PL (작성/검증)
**출력 폴더**: docs/02_기획/
**버전 규칙**: deliverable-management 스킬 참조
**연계 스킬**: feature-planning → qa-scenario-builder, figma-make-reviewer
