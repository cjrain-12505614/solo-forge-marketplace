---
name: solo-tdd
description: 테스트 주도 개발(TDD) RED→GREEN→REFACTOR 사이클을 안내한다. 실패하는 테스트부터 쓰고, 최소 코드로 통과시키고, 통과를 유지하며 리팩터한다. 언어/러너 무관(pytest·jest·go test·JUnit 등). "TDD", "테스트 먼저", "RED GREEN REFACTOR", "테스트 주도로 짜줘", "실패 테스트부터" 요청에 사용한다.
---

# TDD 워크플로우 (solo-tdd)

테스트 주도 개발 사이클을 안내한다. `solo-qa-scenario-builder`(사람이 손으로 실행하는 QA 시나리오 문서)와 달리, 이 스킬은 **실제 테스트 코드를 먼저 쓰고 러너로 돌리는** 개발 루프다. 검증 게이트는 `/solo-verify-step`과 짝을 이룬다.

## 사용법

```
/solo-tdd {기능 설명}
```
예: `/solo-tdd 벌크 상태 변경 API`

## 사이클

### Phase 1 — RED (실패하는 테스트 작성)
1. 구현할 기능의 기대 동작을 테스트로 먼저 쓴다.
2. 테스트 실행 → **반드시 실패를 확인**한다(아직 구현이 없으니 실패가 정상).
3. 실패 메시지가 "기대한 이유로" 실패하는지 확인한다(오타·컴파일 오류가 아니라 단언 실패인지).

### Phase 2 — GREEN (최소 코드로 통과)
1. 테스트를 통과시키는 **가장 단순한** 코드만 쓴다.
2. 리팩터 유혹을 참는다 — 지금은 통과만.
3. 테스트 실행 → **통과 확인**.

### Phase 3 — REFACTOR (통과 유지하며 개선)
1. 중복 제거·네이밍 개선·구조 정리.
2. 테스트 실행 → **여전히 통과** 확인.
3. 다음 기능으로 Phase 1 반복.

## 테스트 러너 (프로젝트에 맞게 감지 — 하드코딩 금지)

`/solo-verify-step`과 동일한 방식으로 프로젝트 마커로 러너를 판별한다.

| 마커 | 러너(테스트) |
|---|---|
| `pyproject.toml`/`setup.py` | `pytest` |
| `package.json` | `npm test` (jest/vitest 등) |
| `go.mod` | `go test ./...` |
| `Cargo.toml` | `cargo test` |
| `build.gradle`/`pom.xml` | `./gradlew test` / `mvn test` |
| `Makefile` | `make test` |

## 테스트 네이밍 (should_X_when_Y — 언어별 관용에 맞춰)

```python
# pytest (Python)
def test_changes_status_when_user_has_permission(): ...
def test_returns_403_when_commenter_bulk_edits(): ...
```
```js
// Jest / Vitest (JS·TS)
test('changes status when user has permission', () => { /* ... */ })
test('returns 403 when a commenter bulk-edits', () => { /* ... */ })
```
```go
// Go
func TestChangesStatus_WhenUserHasPermission(t *testing.T) { /* ... */ }
```

## 원칙

- 테스트 없이 프로덕션 코드를 먼저 쓰지 않는다.
- 한 번에 하나의 기능만 구현한다.
- REFACTOR 단계에서는 기능을 **추가하지 않는다**(구조만 개선).
- 각 Phase의 판정 근거는 **실제 러너 출력**이다(돌리지 않고 "통과했을 것"이라 말하지 않는다).
