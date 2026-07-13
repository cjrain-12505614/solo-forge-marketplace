---
name: solo-verify-step
description: 구현 Step 완료 전 빌드/테스트/린트를 자동 감지·실행하고 결과 보고서를 만든다. "검증 없이 완료라고 말하지 않는다"는 Fresh Evidence 원칙을 강제한다. "verify-step", "검증 실행", "빌드 테스트 돌려", "완료 전 검증" 요청에 사용.
allowed_tools:
  - read
  - bash
  - glob
---

# /solo-verify-step — Step 완료 검증

구현 Step을 "완료"라고 보고하기 전에, 아래 검증을 자동 수행한다. CLAUDE.md 검증 규칙("검증 없이 완료라고 말하지 않는다 · Fresh Evidence 필수 · 빌드 통과 ≠ 런타임 정상")을 실물로 강제하는 게이트다.

## 0. 프로젝트 타입 자동 감지 (고정 경로 가정 금지)

레포 루트와 하위에서 아래 마커 파일의 존재로 러너를 판별한다. `cd backend/frontend` 같은 고정 구조를 가정하지 말고 실제 파일로 결정한다.

| 마커 파일 | 생태계 | 빌드 | 테스트 | 린트(있으면) |
|---|---|---|---|---|
| `package.json` | Node/TS | `npm run build`(스크립트 있으면) | `npm test` | `npm run lint` |
| `pyproject.toml` / `setup.py` | Python | `python -m build`(선택) | `pytest` | `ruff`/`flake8` |
| `go.mod` | Go | `go build ./...` | `go test ./...` | `go vet ./...` |
| `Cargo.toml` | Rust | `cargo build` | `cargo test` | `cargo clippy` |
| `build.gradle`/`pom.xml` | JVM | `./gradlew build` / `mvn package` | 빌드에 포함 | — |
| `Makefile` | 공용 | `make build`(타깃 있으면) | `make test` | `make lint` |

> 마커가 여러 개면 모두 검증한다(예: 풀스택 = package.json + pyproject.toml). `package.json`은 `scripts` 키에 실제 존재하는 스크립트만 실행한다(없는 스크립트 호출 금지).

## 실행 순서

1. **빌드** — 감지된 러너로 실행. FAIL이면 오류 그대로 출력하고 중단(수정 후 재실행 유도). 빌드 개념이 없는 프로젝트(순수 스크립트 등)는 생략하고 그 사실을 보고.
2. **테스트** — 감지된 러너로 실행. 전체/통과/실패/스킵 수를 집계. 이번 Step에서 추가된 신규 테스트 수도 표기.
3. **린트/정적분석** — 설정돼 있으면 실행(없으면 생략, "미설정"으로 표기).
4. **커버리지** — 커버리지 도구가 설정된 경우만 %를 표기(미설정이면 생략 — 없는 값을 지어내지 않는다).
5. **결과 보고** — 아래 형식으로 콘솔 요약. 프로젝트에 구현 보고 폴더 규약이 있으면 그곳에도 남긴다.

## 결과 형식

```
✅ solo-verify-step 완료  (또는 ❌ 실패 — 사유)
- 감지: Node(package.json) + Python(pyproject.toml)
- 빌드: PASS (npm run build 2.1s)
- 테스트: PASS (128건, 실패 0, 스킵 2, 신규 +6)
- 린트: PASS (ruff, 0 warning)
- 커버리지: 도구 미설정 — 생략
- 판정: 완료 보고 가능 / 재작업 필요
```

## 원칙

- **실행 로그가 근거다.** 빌드/테스트를 실제로 돌린 출력 없이 "완료"라고 말하지 않는다.
- **빌드 통과는 런타임 정상을 보장하지 않는다.** 런타임 동작이 핵심인 변경은 실제 실행(또는 `/verify` 스킬)까지 확인한다.
- 없는 수치(커버리지·테스트 수)를 추정으로 채우지 않는다. 없으면 "미설정/생략"으로 정직하게 표기한다.
