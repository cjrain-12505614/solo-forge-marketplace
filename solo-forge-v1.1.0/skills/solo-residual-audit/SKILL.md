---
name: solo-residual-audit
description: 워크스페이스 전체 .md의 깨진 상대링크와 상대경로(../) 깊이 정합을 한 번에 점검하고 리포트로 남긴다. solo-link-integrity-check 훅(편집 직후 단일 파일)의 워크스페이스 광역 정기 점검 버전. "잔존 검증", "깨진 링크 전체 점검", "링크 정합 점검", "정기 점검", "문서 위생 점검" 요청에 사용한다.
---

# 잔존/정합 광역 점검 (solo-residual-audit)

문서가 쌓이면 링크가 조용히 깨지고 상대경로 깊이가 어긋난다. `solo-link-integrity-check` 훅이 편집 직후 그 파일 하나를 보는 즉시 탐지라면, 이 스킬은 **워크스페이스 전체를 한 번에 훑는 정기 점검**이다. 결과를 리포트로 남긴다.

## 점검 2축

1. **깨진 상대링크 검출** (전체 .md) — 마크다운 링크 `[..](경로)` 중 로컬 상대경로가 실제로 존재하지 않는 것. 외부 URL(`http`·`mailto:`·`#` 앵커)은 제외, 보관 영역(`_archive`·`archive`·`*.bak.*`)은 스킵.
2. **depth-up(`../`) 정합** — `_index.md` 같은 placeholder 파일에서 `../` 반복 깊이가 파일의 실제 루트까지 깊이와 맞는지. 일률적으로 `../../../../`를 박아둔 오류 패턴을 깊이별 정확한 개수와 대조.

## 실행 (Python 골격 — 경로 비종속)

```python
import os, re, datetime
from urllib.parse import unquote

ROOT = os.environ.get("CLAUDE_PROJECT_DIR") or os.getcwd()
LINK = re.compile(r'\[([^\]]*)\]\(([^)]+)\)')
def protected(p): return ('/_archive' in p) or ('/archive/' in p) or ('.bak.' in p)

broken = []          # (파일, 줄, 경로)
for root, dirs, files in os.walk(ROOT):
    if protected(root):
        continue
    for fn in files:
        if not fn.endswith('.md'):
            continue
        full = os.path.join(root, fn)
        try:
            for ln, line in enumerate(open(full, encoding='utf-8'), 1):
                for m in LINK.finditer(line):
                    p = m.group(2).split('#')[0].split('?')[0]
                    if not p or p.startswith(('http', 'mailto:', '#')):
                        continue
                    tgt = os.path.normpath(os.path.join(os.path.dirname(full), unquote(p)))
                    if not os.path.exists(tgt):
                        broken.append((os.path.relpath(full, ROOT), ln, p))
        except Exception:
            pass

# 리포트 저장 (docs/00_관리/ — 없으면 콘솔 요약만)
outdir = os.path.join(ROOT, 'docs', '00_관리')
report = os.path.join(outdir, f'residual-audit-{datetime.date.today():%Y%m%d}.md') if os.path.isdir(outdir) else None
print(f"깨진 링크: {len(broken)}건")
for f, ln, p in broken[:20]:
    print(f"  {f}:{ln}  →  {p}")
```

> depth-up 축은 `_index.md` 등 placeholder를 쓰는 프로젝트에서만 의미가 있다. 그런 파일이 없으면 링크 축만 돌린다.

## 운영 주기

- **정기 점검**(예: 월 1회 또는 릴리스 전) — 전체 스캔 → 리포트.
- **작업 진입 직전** — 큰 작업 전에 무결성 확인(깨진 링크 0 확인).
- **사용자 트리거** — 위 키워드.

## 원칙

- 근거는 파일:줄과 실제 존재 여부다. "정합해 보인다"가 아니라 실측 카운트로 보고한다.
- 이 스킬은 **검출·보고**만 한다. 링크 수정은 사용자 판단 후 별도 작업.
