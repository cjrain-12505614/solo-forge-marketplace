---
name: solo-handoff-report
description: _templates/04_report.md 사본을 04_report.md로 생성하고 산출물 경로 인자가 있으면 wc/md5 인벤토리 자동 채움
allowed_tools:
  - read
  - write
  - bash
---

# /solo-handoff-report `<ID>` `[산출물경로 ...]` — 04_report.md 골격 + 산출물 인벤토리

지정 핸드오프 폴더에 `_templates/04_report.md` 사본을 `04_report.md`로 생성합니다. 인자로 산출물 경로 리스트를 받으면 각 파일에 대해 `wc -c`와 `md5`를 실행하여 산출물 표를 자동 채웁니다.

## 사용

```
/solo-handoff-report <HO-ID> [산출물경로 ...]

예시 1 (산출물 경로 지정):
  /solo-handoff-report PLG-001 \
    "/Users/cjrain/Workspace/_plugin/solo-forge/commands/solo-handoff-list.md" \
    "/Users/cjrain/Workspace/_plugin/solo-forge/skills/solo-handoff-protocol/SKILL.md"

예시 2 (인자 없이 빈 골격만):
  /solo-handoff-report HO-005
```

⚠️ 경로에 공백·대괄호·한글 등이 포함되면 반드시 큰따옴표로 감쌀 것 (bash 위치 인자 공백 split).

## 절대 규칙 (immutable)

- 본 명령은 다음 파일을 **읽기만** 한다 — `INDEX.md`, `_README.md`, `_templates/*`, `01_directive.md`, `03_review.md`
- 위 파일에 대한 Write/Edit 액션을 절대 수행하지 않는다
- INDEX.md 상태 갱신은 Cowork 단독 책임 (운영 규칙 2)
- `04_report.md` 가 이미 존재하면 **덮어쓰기 금지**

## 실행 단계

### 1. handoff 폴더 + 대상 HO 폴더 탐색 (NFD 안전 패턴)

```python
import os, sys, subprocess, unicodedata, hashlib
from datetime import date

if len(sys.argv) < 2:
    sys.exit("사용: /solo-handoff-report <HO-ID> [산출물경로 ...]")
ID = sys.argv[1]
artifacts = sys.argv[2:]

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

### 2. 04_report.md 덮어쓰기 방지

```python
report_path = os.path.join(target, '04_report.md')
if os.path.exists(report_path):
    sys.exit(
        f"{ID}/04_report.md 이미 존재. 본 명령은 새 파일을 만들지 않습니다. "
        "직접 갱신하거나 백업 후 삭제하세요."
    )
```

### 3. 템플릿 복사 + 토큰 치환

```python
template = os.path.join(handoff, '_templates', '04_report.md')
with open(template, 'r', encoding='utf-8') as f:
    body = f.read()

today = date.today().isoformat()
body = body.replace('{ID}', ID).replace('YYYY-MM-DD', today)
```

### 4. 산출물 인벤토리 자동 채움 (선택)

```python
def file_md5(path):
    h = hashlib.md5()
    with open(path, 'rb') as f:
        for chunk in iter(lambda: f.read(8192), b''):
            h.update(chunk)
    return h.hexdigest()

if artifacts:
    rows = ["| 경로 | 크기 (bytes) | md5 |", "|------|-------------|-----|"]
    for path in artifacts:
        if not os.path.exists(path):
            rows.append(f"| {path} | (미발견) | - |")
            continue
        size = os.path.getsize(path)
        digest = file_md5(path)
        rows.append(f"| {path} | {size} | {digest} |")
    inventory = "\n".join(rows)
    # 템플릿의 산출물 표 자리에 삽입 (## 6. 산출물 인벤토리 등의 헤더 아래)
    # 헤더 형식은 _templates/04_report.md 의 실제 구조에 맞춰 단순 append
    body += "\n\n## 산출물 인벤토리 (자동 채움)\n\n" + inventory + "\n"
```

### 5. 파일 쓰기 + 안내 출력

```python
with open(report_path, 'w', encoding='utf-8') as f:
    f.write(body)

print(f"{ID}/04_report.md 골격 생성 완료 ({report_path})")
if artifacts:
    print(f"산출물 인벤토리 {len(artifacts)} 행 자동 채움")
print()
print("다음 액션:")
print(" 1. 04_report.md 의 지표 결과 / 자체 검증 응답 / 발견 이슈 절을 직접 채우기")
print(" 2. 작성 완료 후 사용자에게 보고")
print(" 3. INDEX.md 상태 → REPORTING 갱신은 Cowork 책임 (운영 규칙 2)")
```

## 결정 트리에서의 위치

- 작업 끝 → 본 명령으로 04 골격 생성 → 검증 응답·발견 이슈 채우기 → Cowork이 05_decision.md 작성
