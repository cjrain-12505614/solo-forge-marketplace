---
name: solo-handoff-execute
description: 03_review.md 결정이 APPROVE인지 검증하고 EXECUTING 진입 가능 여부 + 가드레일 안내 출력
allowed_tools:
  - read
  - bash
---

# /solo-handoff-execute `<ID>` — APPROVED 게이트 검증

지정 핸드오프 폴더에서 `03_review.md`를 읽고, 결정이 `APPROVE`인지 정규식으로 검증한 뒤 EXECUTING 진입 가능 여부를 안내합니다. APPROVE가 아니면 진입을 차단합니다.

## 사용

```
/solo-handoff-execute <HO-ID>

예시:
/solo-handoff-execute PLG-001
```

## 절대 규칙 (immutable)

- 본 명령은 다음 파일을 **읽기만** 한다 — `INDEX.md`, `_README.md`, `_templates/*`, `01_directive.md`, `03_review.md`
- 위 파일에 대한 Write/Edit 액션을 절대 수행하지 않는다
- INDEX.md 상태 갱신은 Cowork 단독 책임 (운영 규칙 2)
- 본 명령은 작업 자체를 실행하지 않는다 — 게이트 검증 + 가드레일 안내만 수행

## 실행 단계

### 1. handoff 폴더 + 대상 HO 폴더 탐색 (NFD 안전 패턴)

```python
import os, sys, re, unicodedata

ID = sys.argv[1] if len(sys.argv) > 1 else None
if not ID:
    sys.exit("사용: /solo-handoff-execute <HO-ID>")

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

target = None
for entry in os.listdir(handoff):
    if unicodedata.normalize('NFC', entry).startswith(f"{ID}_"):
        cand = os.path.join(handoff, entry)
        if os.path.isdir(cand):
            target = cand
            break
if not target:
    sys.exit(f"{ID} 폴더 미발견")
```

### 2. 03_review.md 존재 + APPROVE 검증

```python
review = os.path.join(target, '03_review.md')
if not os.path.exists(review):
    sys.exit(
        f"{ID}/03_review.md 미존재 — 현재 상태에서 EXECUTING 진입 금지. "
        "Cowork이 먼저 검토 결과를 작성해야 합니다 (운영 규칙 3)."
    )

with open(review, 'r', encoding='utf-8') as f:
    body = f.read()

# 결정: APPROVE 패턴 (## 결정: APPROVE 또는 ## 결정: **APPROVE**)
APPROVE_RE = re.compile(r'^##\s*결정\s*:\s*\**APPROVE\b', re.MULTILINE)
REVISE_RE  = re.compile(r'^##\s*결정\s*:\s*\**REVISE\b',  re.MULTILINE)

if REVISE_RE.search(body):
    sys.exit(
        f"{ID}/03_review.md 결정 = REVISE — EXECUTING 진입 금지. "
        "03 본문의 수정 요청을 02_plan.md에 반영하고 Cowork 재검토를 받으세요."
    )
if not APPROVE_RE.search(body):
    sys.exit(
        f"{ID}/03_review.md 에서 '## 결정: APPROVE' 패턴 미발견 — "
        "EXECUTING 진입 금지 (운영 규칙 3)."
    )
```

### 3. 가드레일 항목 추출 + 안내 출력

```python
# 03_review.md 에서 ## 추가 가드레일 또는 ### G... 헤더 모음
GUARD_RE = re.compile(r'^###\s*(G\d+\.[^\n]*)', re.MULTILINE)
guards = GUARD_RE.findall(body)

print(f"{ID} 검토 결과 APPROVE 확인 완료.")
print("실행 진입 가능 — 03_review.md 의 추가 가드레일 항목을 우선 점검하세요.")
print()
print("⚠️ 다음은 사용자 또는 Cowork 측에서 수행:")
print(" - INDEX.md 상태 → EXECUTING 갱신 (운영 규칙 2)")
print(f" - 작업 완료 후 /solo-handoff-report {ID} 로 04 작성")
print()
if guards:
    print("가드레일 항목 (03_review.md):")
    for g in guards:
        print(f" - {g}")
else:
    print("가드레일 항목: 03_review.md 에 별도 가드레일 명시 없음")
```

### 4. 종료 코드

- APPROVE 검증 통과: 종료 코드 0
- 03 미존재 / REVISE / APPROVE 패턴 미발견: 종료 코드 1 (sys.exit 메시지)

## 결정 트리에서의 위치

- 02_plan.md 검토 후 03이 APPROVE → 본 명령으로 게이트 통과 확인 → 작업 실행 → `/solo-handoff-report <ID>`
