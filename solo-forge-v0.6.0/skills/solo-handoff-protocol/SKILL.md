---
name: solo-handoff-protocol
description: "이 스킬은 사용자가 '핸드오프', '지시서', 'HO-', 'PLG-', 'directive', 'plan', 'review', 'report', '계획서', '검토', '완료보고서' 등을 요청하거나, handoff/ 폴더의 5단계 프로토콜 (01 directive → 02 plan → 03 review → 04 report → 05 decision)을 따라 작업해야 할 때 반드시 사용하세요. Cowork ↔ Claude Code 역할 분담 하에 핸드오프 파일을 안전하게 작성·실행·보고하도록 안내합니다."
---

# 핸드오프 프로토콜 스킬 (Cowork ↔ Claude Code)

본 스킬은 `{프로젝트_루트}/handoff/` 폴더의 5단계 파일 기반 핸드오프 프로토콜을 안내합니다. 모든 세부 운영 규칙·템플릿·INDEX 형식의 SSoT는 `handoff/_README.md` 입니다 — 본 문서는 요약·결정 트리만 제공합니다.

## SSoT 위치

- 운영 규칙 SSoT: `{프로젝트_루트}/handoff/_README.md`
- 추적표: `{프로젝트_루트}/handoff/INDEX.md`
- 템플릿 5종: `{프로젝트_루트}/handoff/_templates/01_directive.md ~ 05_decision.md`
- 핸드오프 폴더: `HO-NNN_YYYYMMDD-주제/`, `PLG-NNN_*/`, `DOC-NNN_*/`

본 스킬에서 규정·운영이 모호하면 항상 `_README.md` 본문을 우선합니다.

## 역할 분담

| 측 | 강점 | 책임 |
|----|------|------|
| **Cowork** (Claude Desktop) | 전 폴더 맥락, Chrome MCP, SSoT 갱신 권한 | 전략·검증 — 지시·승인·결과 평가·INDEX 갱신 |
| **Code** (Claude Code CLI) | Kaggle CLI, Python 실행, NFD 경로 안전 | 실행 — 계획·구현·실험·보고 |

## 5단계 파일

| 파일 | 작성자 | 다음 |
|------|--------|------|
| `01_directive.md` | Cowork | → 02 (Code) |
| `02_plan.md` | Code | → 03 (Cowork) |
| `03_review.md` | Cowork | → 04 (APPROVE) 또는 02 갱신 (REVISE) |
| `04_report.md` | Code | → 05 (Cowork) |
| `05_decision.md` | Cowork | (종료) |

## 상태 머신 (INDEX.md `상태` 컬럼)

```
DRAFT          — Cowork가 01 작성 중
ISSUED         — 01 발행, Code가 02 작성할 차례
PLANNING       — Code가 02 작성 중
IN_REVIEW      — 02 발행, Cowork가 03 작성할 차례
REVISE         — 03 = 수정 요청, Code가 02 갱신할 차례
APPROVED       — 03 = 승인, Code가 작업 시작 가능
EXECUTING      — Code 작업 진행 중
REPORTING      — Code가 04 작성 중
CLOSED-MERGE   — 채택, SSoT 갱신 완료
CLOSED-REJECT  — 반려, 교훈만 기록
```

## Immutable 운영 규칙 (요약 — 풀버전은 _README.md)

1. **단방향 쓰기** — 각 파일은 한쪽만 작성. 상대편은 같은 파일을 수정하지 않고 다음 파일에서 응답
2. **상태 갱신 독점** — `INDEX.md` 수정은 Cowork만. Code는 읽기 전용
3. **APPROVED 게이트** — `03_review.md` 결정이 `APPROVE` 인지 확인 후에만 EXECUTING 진입 (Code는 `/solo-handoff-execute <ID>` 로 검증)
4. **04 없이는 CLOSED 안 됨** — `04_report.md` 작성 전 다음 핸드오프 시작 금지
5. **LB 점수 양측 검증** — Code가 04에 LB 기록 → Cowork가 Chrome MCP로 리더보드 재확인 → 05에서 확정
6. **PLAN.md / history/ 갱신은 Cowork 단독** — 단일 SSoT
7. **핸드오프 외 통신 금지** — Code↔Cowork 직접 통신 없음. 모든 결정은 사용자 채팅을 통해 다음 파일을 통해
8. **NFD 경로** — iCloud Drive 한글 폴더는 NFD(조합형). 하드코딩 NFC 경로 금지. `os.listdir() + unicodedata.normalize('NFC', s)` 패턴 사용
9. **Kaggle CLI 사용** — Code는 사용자 Mac 인증 토큰으로 직접 호출. Cowork은 토큰 없음 (Chrome MCP로 검증)
10. **노트북 산출 csv만 제출** — `kaggle competitions submit`은 `kaggle kernels output`에서 다운된 csv만
11. **kaggle kernels push 전 보존** — 푸시 직전 현재 `baseline.ipynb`를 `kaggle_notebook/versions/vN_<설명>.ipynb`로 사본 보존
12. **Commit 전 사용자 승인** — 모든 git commit은 변경 후보 보여주고 사용자 승인 후에만
13. **Leakage 의심 즉시 정지** — train만 fit / test transform만 / TE는 cv-aware k-fold smoothing / Optuna는 cv 내부

## 명령 4종 결정 트리 (Code 측)

```
"지금 뭐 해야 해?"
    └→ /solo-handoff-list
        └→ INDEX 에서 ISSUED · APPROVED · REVISE 핸드오프만 출력

ISSUED 핸드오프 발견
    └→ /solo-handoff-pickup <ID>
        └→ _templates/02_plan.md 사본 생성 → 직접 본문 채우기 → Cowork 검토 요청

APPROVED 상태로 진입한 핸드오프
    └→ /solo-handoff-execute <ID>
        └→ 03 의 결정이 APPROVE 인지 정규식 검증 (REVISE/미작성이면 진입 차단)
        └→ 가드레일 항목 안내 + INDEX 상태 갱신은 Cowork 책임 안내

작업 완료
    └→ /solo-handoff-report <ID> [산출물경로 ...]
        └→ _templates/04_report.md 사본 생성
        └→ 산출물 경로 인자 있으면 wc/md5 인벤토리 자동 채움
        └→ 직접 본문 채우기 (지표 결과 / 자체 검증 / 발견 이슈)
```

⚠️ 4개 명령은 모두 **read-only** 입니다 — `INDEX.md`, `_README.md`, `_templates/*`, `01_directive.md`, `03_review.md` 절대 수정 안 합니다. 자기 자신이 새로 만드는 파일(02_plan.md, 04_report.md)만 Write 합니다.

## 새 세션 진입 흐름

### Cowork 측

1. `_README.md` 읽기
2. `INDEX.md` 읽고 자기 차례 핸드오프 식별 (상태 = `IN_REVIEW` 또는 `REPORTING`)
3. `PLAN.md` + `history/` 최신 md 읽고 컨텍스트 보강
4. 해당 HO 폴더의 `02_plan.md` 또는 `04_report.md` 검토
5. `03_review.md` 또는 `05_decision.md` 작성
6. `INDEX.md` 상태 갱신 + (CLOSED-MERGE 시) PLAN.md/history/notebooks/INDEX.md 갱신

### Code 측

1. `_README.md` 읽기
2. `INDEX.md` 읽고 자기 차례 핸드오프 식별 (상태 = `ISSUED` 또는 `APPROVED` 또는 `REVISE`)
3. `PLAN.md` + `history/` 최신 md 읽고 컨텍스트 보강
4. 해당 HO 폴더의 `01_directive.md` 또는 `03_review.md` 읽기
5. `02_plan.md` 작성 또는 작업 실행 후 `04_report.md` 작성
6. 사용자에게 단계 완료 보고 (Cowork이 INDEX 갱신할 수 있도록)

## 자주 발생하는 함정

- **02_plan.md를 자기 호출 명령으로 만들기 시도** — `/solo-handoff-pickup <자기-자신-ID>` 는 PLG-001 같이 본 프로토콜 자체를 만드는 핸드오프에서 무한 회귀 위험. 그런 경우는 사용자가 직접 Write 도구로 작성
- **NFC 한글 경로 하드코딩** — iCloud Drive에서 파일을 못 찾거나 NFC 고스트 폴더 생성. 반드시 NFD 안전 패턴 (`os.listdir + normalize('NFC')`) 사용
- **APPROVED 없이 EXECUTING 진입** — 03이 미작성·REVISE 상태에서 작업 시작하면 운영 규칙 3 위반. `/solo-handoff-execute` 게이트 통과 필수
- **04_report.md 작성 전 다음 핸드오프 시작** — 운영 규칙 4 위반. 한 번에 한 핸드오프만 실행
- **Code가 INDEX.md 직접 수정** — 운영 규칙 2 위반. INDEX 갱신은 항상 Cowork 통해

## 참고

- 운영 규칙 SSoT: `{프로젝트_루트}/handoff/_README.md`
- 명령 소스: `{plugin}/commands/solo-handoff-{list,pickup,execute,report}.md`
- 본 스킬: `{plugin}/skills/solo-handoff-protocol/SKILL.md`
