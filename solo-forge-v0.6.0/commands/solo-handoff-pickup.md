---
name: solo-handoff-pickup
description: 핸드오프 ID로 01_directive.md 검증 후 _templates/02_plan.md 사본을 02_plan.md로 생성 (ID·날짜 치환)
allowed_tools:
  - read
  - write
  - bash
---

# /solo-handoff-pickup `<ID>` — 02_plan.md 골격 생성

지정 핸드오프 폴더에서 `01_directive.md` 존재를 검증하고, `_templates/02_plan.md` 사본을 같은 폴더에 `02_plan.md`로 생성합니다. `{ID}`와 발행일을 자동 치환합니다.

## 사용

```
/solo-handoff-pickup <HO-ID>

예시:
/solo-handoff-pickup PLG-002
/solo-handoff-pickup HO-005
```

## 절대 규칙 (immutable)

- 본 명령은 다음 파일을 **읽기만** 한다 — `INDEX.md`, `_README.md`, `_templates/*`, `01_directive.md`, `03_review.md`
- 위 파일에 대한 Write/Edit 액션을 절대 수행하지 않는다
- INDEX.md 상태 갱신은 Cowork 단독 책임 (운영 규칙 2)
- `02_plan.md`가 이미 존재하면 **덮어쓰기 금지** (REVISE 상황은 기존 파일 갱신으로 안내)

## 실행 단계

### 1. handoff 폴더 + 대상 HO 폴더 탐색 (NFD 안전 패턴)

```python
import os, sys, unicodedata, shutil
from datetime import date

ID = sys.argv[1] if len(sys.argv) > 1 else None
if not ID:
    sys.exit("사용: /solo-handoff-pickup <HO-ID>")

def find_handoff_dir(start=None):
    cur = os.path.abspath(start or os.getcwd())
    while True:
        for entry in os.listdir(cur):
            if unicodedata.normalize('NFC', entry) == 'handoff':
                full = os.path.join(cur, entry)
                if os.path.isdir(full) and os.path.exists(os.path.join(full, 'INDEX.md')):
                    return full
        parent = os.path.dirname(cur)
        if parent == cur:
            return None
        cur = parent

handoff = find_handoff_dir()
if not handoff:
    sys.exit("handoff/INDEX.md 미발견")

# HO 폴더 매칭 (예: PLG-001_20260505-solo-forge-handoff-support)
target = None
for entry in os.listdir(handoff):
    nfc = unicodedata.normalize('NFC', entry)
    if nfc.startswith(f"{ID}_") and os.path.isdir(os.path.join(handoff, entry)):
        target = os.path.join(handoff, entry)
        break
if not target:
    sys.exit(f"{ID} 폴더 미발견 — Cowork이 먼저 01_directive.md를 발행해야 합니다")
```

### 2. 01_directive.md 존재 검증

```python
directive = os.path.join(target, '01_directive.md')
if not os.path.exists(directive):
    sys.exit(f"{ID}/01_directive.md 미존재 — pickup 진행 불가")
```

### 3. 02_plan.md 덮어쓰기 방지

```python
plan_path = os.path.join(target, '02_plan.md')
if os.path.exists(plan_path):
    sys.exit(
        f"{ID}/02_plan.md 이미 존재. REVISE 상황이면 기존 파일을 직접 갱신하세요. "
        "본 명령은 새 파일을 만들지 않습니다."
    )
```

### 4. 템플릿 복사 + 토큰 치환

```python
template = os.path.join(handoff, '_templates', '02_plan.md')
with open(template, 'r', encoding='utf-8') as f:
    body = f.read()

today = date.today().isoformat()  # YYYY-MM-DD
body = body.replace('{ID}', ID).replace('YYYY-MM-DD', today)

with open(plan_path, 'w', encoding='utf-8') as f:
    f.write(body)
```

### 5. 사용자 안내 출력

```
{ID}/02_plan.md 골격 생성 완료 ({plan_path})

다음 액션:
1. 01_directive.md 를 정독
2. 02_plan.md 의 7절 (접근 방식 / 단계별 액션 / 예상 시간 / 위험 / 가정 / Cowork 질문 / 산출물 매핑)을 직접 채우기
3. 작성 완료 후 사용자에게 "{ID} 02_plan.md 작성 완료, 검토 부탁드립니다" 보고
4. INDEX.md 상태 → IN_REVIEW 갱신은 Cowork 책임 (운영 규칙 2)
```

## 결정 트리에서의 위치

- INDEX에서 ISSUED 발견 → 본 명령으로 골격 생성 → 직접 본문 채우기 → Cowork 검토 (03_review.md)
