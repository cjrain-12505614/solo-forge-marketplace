# solo-forge

범용 1인 개발자 프로젝트 관리 플러그인 (v0.1.0)

## 개요

solo-forge는 체계적인 프로젝트 관리를 위한 Cowork 플러그인입니다. CLAUDE.md 계약 기반으로 세션 관리, 에이전트 팀 디스패치, 의사결정 추적, 산출물 버전 관리, QA 시나리오 빌더, Figma Make 검증 등을 지원합니다.

## 빠른 시작

1. `/init-project` — 프로젝트 초기 설정
2. `/start-session` — 세션 시작
3. `/guide` — 다음에 뭐 해야 하지?
4. `/end-session` — 세션 종료

## 스킬 (10개)

| 스킬 | 설명 |
|------|------|
| project-bootstrap | CLAUDE.md 생성 및 프로젝트 초기 설정 |
| session-protocol | 세션 시작/종료/체크포인트 프로토콜 |
| agent-dispatch | 에이전트 팀 디스패치 (유동적 팀 구성) |
| decision-tracker | 3단계 의사결정 추적 |
| lessons-learned | 교훈 기록 및 활용 |
| status-reporter | 프로젝트 현황 보고 |
| deliverable-management | 산출물 버전 관리 및 품질 게이트 |
| feature-planning | 기능 스펙 문서 생성 |
| qa-scenario-builder | QA 테스트 시나리오 생성 |
| figma-make-reviewer | Figma Make 산출물 검증 |

## 커맨드 (14개)

| 커맨드 | 설명 |
|--------|------|
| /init-project | 새 프로젝트 초기 설정 |
| /start-session | 세션 시작 프로토콜 |
| /end-session | 세션 종료 및 저장 |
| /save-session | 중간 체크포인트 |
| /resume-session | 이전 세션에서 재개 |
| /status | 프로젝트 현황 |
| /guide | 다음 단계 안내 |
| /dispatch {이름} {업무} | 에이전트 투입 |
| /decision [add\|request\|list] | 의사결정 관리 |
| /lesson {내용} | 교훈 기록 |
| /feature-spec {기능명} | 기능 스펙 생성 |
| /build-scenario {대상} | QA 시나리오 생성 |
| /review-figma {URL} | Figma 검증 |
| /extract-design-tokens | 디자인 토큰 추출 |

## 팀 구성

PL(준호)은 항상 고정. 에이전트 팀은 프로젝트 규모에 따라 유동적으로 구성합니다.

- 소규모 (5-15 features): PL + 2~3명
- 중규모 (15-50 features): PL + 4~5명
- 대규모 (50+ features): PL + 5명 이상

## CLAUDE.md 계약

Sections 1-11은 모든 스킬의 의존 기반입니다. 섹션 번호와 제목은 변경 불가(immutable contract).
