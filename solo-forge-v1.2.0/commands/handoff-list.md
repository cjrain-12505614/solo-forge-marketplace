---
name: solo-handoff-list
description: handoff/INDEX.md를 파싱하여 Code 차례인 핸드오프(ISSUED·APPROVED·REVISE)만 목록 출력
allowed_tools:
  - read
  - glob
  - bash
---

# /solo-handoff-list — 핸드오프 차례 확인

`{프로젝트_루트}/handoff/INDEX.md`를 읽어 Code 측에서 처리해야 할 핸드오프(상태 = `ISSUED`, `APPROVED`, `REVISE`)만 추려서 출력합니다.

## 사용

```
/solo-handoff-list
```

인자 없음. 현재 워킹 디렉토리 또는 가까운 상위 디렉토리에서 `handoff/INDEX.md`를 자동 탐색합니다.

## 절대 규칙 (immutable)

- 본 명령은 다음 파일을 **읽기만** 한다 — `INDEX.md`, `_README.md`, `_templates/*`, `01_directive.md`, `03_review.md`
- 위 파일에 대한 Write/Edit 액션을 절대 수행하지 않는다
- INDEX.md 상태 갱신은 Cowork 단독 책임 (운영 규칙 2)

## 실행 단계

### 1. handoff 폴더 위치 탐색 (NFD 안전 패턴)

```python
import os, sys, unicodedata

def find_handoff_dir(start=None):
    """현재 디렉토리부터 상위로 올라가며 handoff/ 폴더를 탐색.
    iCloud Drive 한글 폴더 NFD/NFC 차이를 흡수."""
    cur = os.path.abspath(start or os.getcwd())
    while True:
        for entry in os.listdir(cur):
            nfc = unicodedata.normalize('NFC', entry)
            if nfc == 'handoff':
                full = os.path.join(cur, entry)
                if os.path.isdir(full) and os.path.exists(os.path.join(full, 'INDEX.md')):
                    return full
        parent = os.path.dirname(cur)
        if parent == cur:
            return None
        cur = parent

handoff = find_handoff_dir()
if not handoff:
    sys.exit("handoff/INDEX.md 미발견 — Cowork이 먼저 핸드오프를 발행해야 합니다")
```

### 2. INDEX.md 파싱 — 진행 중 표에서 Code 차례만 필터링

- `진행 중` 또는 동등 표 행을 정규식으로 추출 (`| HO-NNN | ... | 상태 | ...`)
- 상태가 `ISSUED`, `APPROVED`, `REVISE`인 행만 유지
- 상태가 `IN_REVIEW`, `EXECUTING`, `REPORTING`, `CLOSED-MERGE`, `CLOSED-REJECT`인 행은 제외

### 3. 출력 포맷

```
[Code 차례 핸드오프]

PLG-001 [APPROVED] solo-forge 핸드오프 명령·스킬 추가 (단계 03, 갱신 2026-05-05)
  → 다음 액션: 02_plan.md 검토 결과 APPROVE 확인 후 작업 실행 → /solo-handoff-execute PLG-001

HO-005 [ISSUED] CatBoost cat_features 직접 활용 (단계 01, 갱신 2026-05-06)
  → 다음 액션: /solo-handoff-pickup HO-005 로 02_plan.md 작성

HO-007 [REVISE] groupby 통계 피처 (단계 03, 갱신 2026-05-08)
  → 다음 액션: 03_review.md의 수정 요청 반영 후 02_plan.md 갱신
```

### 4. 빈 결과 처리

- 필터링 결과 0건이면: `Code 차례 핸드오프 없음 — Cowork 또는 사용자 응답 대기`
- INDEX.md 자체가 없거나 표 파싱 실패면: `INDEX.md 미존재 — Cowork이 먼저 핸드오프를 발행해야 합니다`

## 결정 트리에서의 위치

- "지금 뭐 해야 해?" → 본 명령
- 결과 → `/solo-handoff-pickup <ID>` 또는 `/solo-handoff-execute <ID>`
