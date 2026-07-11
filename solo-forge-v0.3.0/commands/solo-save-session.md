---
name: solo-save-session
description: 세션 중간 체크포인트 저장
allowed_tools:
  - read
  - write
  - bash
---

# 세션 중간 저장

진행 중인 세션의 현재 진행 상황을 체크포인트로 저장합니다. 세션은 종료하지 않습니다.

## 실행 단계

### 1. 체크포인트 파일 생성

경로: `docs/00_관리/sessions/_checkpoint_YYYY-MM-DD_HH-mm.md`

형식:
```markdown
# 체크포인트 — YYYY-MM-DD HH:mm

## 현재 진행 상황
[현재 작업 내용과 진행률 1~2문단]

## 로드된 컨텍스트
- [읽은 파일/문서 1]
- [읽은 파일/문서 2]
- [파일 경로 3]

## 다음 작업
1. [다음 즉시 작업]
2. [그 다음 작업]

## 주의사항
- [있으면 기록, 없으면 "없음"]
```

### 2. 저장 확인

```
체크포인트 저장 완료 (YYYY-MM-DD HH:mm)

**저장 위치**: docs/00_관리/sessions/_checkpoint_YYYY-MM-DD_HH-mm.md
**다음 작업**: [다음 즉시 작업]

필요시 /resume-session으로 이 지점에서 복구할 수 있습니다.
```

## 용도

- 장시간 작업 중 진행상황 기록
- 여러 세션에 걸친 대규모 작업 중간 저장
- 예상치 못한 중단 시 복구 포인트
