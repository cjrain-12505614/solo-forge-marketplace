# solo-forge

범용 1인 개발자 프로젝트 관리 플러그인 (v0.4.0)

## 개요

solo-forge는 체계적인 프로젝트 관리를 위한 Cowork 플러그인입니다. CLAUDE.md 계약 기반으로 세션 관리, 에이전트 팀 디스패치, 의사결정 추적, 산출물 버전 관리, QA 시나리오 빌더, Figma Make 검증, 핸드오프 프로토콜 등을 지원합니다.

## 빠른 시작

1. `/init-project` — 프로젝트 초기 설정
2. `/start-session` — 세션 시작
3. `/guide` — 다음에 뭐 해야 하지?
4. `/end-session` — 세션 종료

## 스킬 (12개)

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
| handoff-protocol | Cowork ↔ Code 5단계 파일 기반 핸드오프 프로토콜 안내 (v0.2.0) |
| progress-dashboard | 복잡·다단계 작업 진행을 HTML 대시보드로 자동 생성·갱신·표시 (v0.3.0) |

## 커맨드 (20개)

| 커맨드 | 설명 |
|--------|------|
| /init-project | 새 프로젝트 초기 설정 |
| /verify-step | (v0.4.0) 구현 완료 전 빌드/테스트/린트 자동감지 실행 + 결과 보고 게이트 |
| /update-context | (v0.4.0) 작업 완료 후 CLAUDE.md 동적 섹션(§9/§10/§11)·컨텍스트 동기화 |
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
| /solo-handoff-list | (v0.2.0) handoff/INDEX.md 에서 Code 차례 핸드오프 목록 출력 |
| /solo-handoff-pickup {ID} | (v0.2.0) `_templates/02_plan.md` 사본을 02_plan.md로 생성 |
| /solo-handoff-execute {ID} | (v0.2.0) 03_review.md APPROVE 검증 후 EXECUTING 게이트 통과 안내 |
| /solo-handoff-report {ID} [경로 ...] | (v0.2.0) `_templates/04_report.md` 사본 + 산출물 wc/md5 인벤토리 |

모든 명령은 `solo-` 접두사 + 무접두사 별칭 두 변형이 모두 제공됩니다 (예: `/solo-verify-step` ≡ `/verify-step`).

## 코드 실행 루프 훅 (v0.4.0 신설)

`hooks/hooks.json`에 3종 훅이 추가되어, 코드 작업 중 안전·위생을 자동으로 지킵니다.

- **solo-db-guard** (PreToolUse) — 마이그레이션/Bash에서 파괴적 SQL(`DROP TABLE`·`TRUNCATE`·무조건 `DELETE`)을 감지하면 **차단**(exit 2). 기본 켜짐, `SOLO_DB_GUARD=off`로 우회.
- **solo-force-rules-inject** (UserPromptSubmit) — 매 입력마다 프로젝트 `docs/00_관리/강제규칙.md`를 맥락에 주입(파일 없으면 침묵). 세션당 1회 규칙 인지를 턴당 1회로 강화.
- **solo-link-integrity-check** (PostToolUse) — `.md` 편집 직후 깨진 상대경로 링크를 즉시 검출(경고만, 편집 막지 않음).

## 핸드오프 프로토콜 (v0.2.0)

`{프로젝트_루트}/handoff/` 폴더 5단계 파일 기반 (01 directive → 02 plan → 03 review → 04 report → 05 decision) 으로 Cowork(전략·검증) ↔ Claude Code(실행) 간 작업 위임을 관리합니다. 운영 규칙·상태 머신·결정 트리는 SSoT (`{프로젝트_루트}/handoff/_README.md`) 에 정의됩니다.

- 명령 4종 (위 표 참조)으로 Code 측 자동화
- 스킬 `solo-handoff-protocol` 로 결정 트리·진입 흐름 안내
- 모든 명령은 `INDEX.md`/`_README.md`/`_templates/*` 를 read-only 로만 다룸 (INDEX 갱신은 Cowork 단독 책임)

## 진행 대시보드 (v0.3.0)

다단계 작업(신호 3개+: 단계 3개 이상·다영역/다파일·장시간·산출물 다수·"복잡" 언급)을 감지하면 HTML 대시보드를 자동 생성하고 단계 전환마다 갱신합니다. 진행률은 순수 칸 비율, 갱신은 마커(`<!-- SF:키 -->`) 부분 치환, 보관은 `docs/00_관리/dashboards/`. douzone-forge `dz-progress-dashboard` 에서 이식·범용화했습니다.

**훅 (v0.3.0 신설)**: `hooks/hooks.json` 의 UserPromptSubmit 훅이 매 입력마다 대시보드 발동 판단을 1줄로 환기합니다. 문구는 스크립트에 내장되어 있으며, 프로젝트에 `docs/00_관리/진행대시보드-환기.md` 를 두면 그 내용이 우선합니다.

## 팀 구성

PL(준호)은 항상 고정. 에이전트 팀은 프로젝트 규모에 따라 유동적으로 구성합니다.

- 소규모 (5-15 features): PL + 2~3명
- 중규모 (15-50 features): PL + 4~5명
- 대규모 (50+ features): PL + 5명 이상

## CLAUDE.md 계약

Sections 1-11은 모든 스킬의 의존 기반입니다. 섹션 번호와 제목은 변경 불가(immutable contract).
