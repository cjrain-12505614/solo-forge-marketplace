---
name: solo-excel-reviewer
description: 엑셀 워크북(.xlsx/.xlsm)의 구조를 정밀 점검한다 — 보이는 데이터뿐 아니라 숨김 시트·병합셀·데이터 검증(드롭다운)·시트 상태까지. 라이브러리 파싱이 깨지면 zip/xml fallback으로 최소 구조라도 복원한다. "엑셀 분석", "숨김 시트 확인", "워크북 구조 파악", "병합셀 확인", "xlsx 읽어줘" 요청에 사용한다.
---

# 엑셀 리뷰어 (solo-excel-reviewer)

엑셀 파일을 넘겨받았을 때, 보이는 셀만 보는 게 아니라 **숨김 시트·병합 구조·데이터 검증(드롭다운)·시트 상태**까지 포함한 전체 구조를 파악한다. 검수 시나리오·WBS·백로그가 엑셀로 오는 경우, 숨김 탭이나 병합에 중요한 정보가 들어 있을 때 특히 유용하다.

## 기본 원칙

1. 먼저 워크북 **메타 구조**를 본다(시트 목록·상태·병합·검증 개수).
2. 시트별 상태(visible / hidden)를 분리한다 — **숨김 시트도 맥락 후보**로 본다.
3. 라이브러리 파싱이 깨지면 **zip/xml fallback**으로 최소 구조라도 복원한다.

## 작업 순서

### 1. 메타 구조 점검 (openpyxl)

```bash
python3 -m pip install openpyxl -q --break-system-packages 2>/dev/null || pip install openpyxl -q
```
```python
import openpyxl, sys
wb = openpyxl.load_workbook(sys.argv[1], data_only=False, keep_vba=True)
for ws in wb.worksheets:
    print(f"[{ws.title}] state={ws.sheet_state} dims={ws.dimensions} "
          f"merged={len(ws.merged_cells.ranges)} "
          f"validations={len(ws.data_validations.dataValidation)}")
    hidden_cols = [c for c,d in ws.column_dimensions.items() if d.hidden]
    hidden_rows = [r for r,d in ws.row_dimensions.items() if d.hidden]
    if hidden_cols or hidden_rows:
        print(f"  숨김 열={hidden_cols} 숨김 행={hidden_rows}")
```
확인: 시트명·숨김 여부, 행/열 크기, 병합셀 수, 데이터 검증 수, 숨김 행/열.

### 2. 파싱 경로 선택
- `openpyxl`이 정상 → 셀 값을 읽는다.
- `openpyxl` 실패 → **zip/xml fallback**: `.xlsx`는 zip이므로 `unzip -l`로 `xl/worksheets/*.xml`·`xl/workbook.xml`(시트 목록·상태)을 직접 확인해 최소 구조(시트 목록·숨김 여부·병합/검증 존재)라도 복원한다.

### 3. 시트 유형 판별 (내용이 정형이면)
- **검수 시나리오형**: PASS/FAIL 드롭다운·테스트 케이스 구조
- **WBS형**: 상위 묶음 + 하위 세부행, 날짜/진행률
- **backlog형**: 카테고리 × 항목, 우선순위/일정

### 4. 정리 보고
- 읽은 파일 경로 / 전체 시트 목록 + **숨김 시트 목록(별도 섹션 필수)**
- 병합·데이터 검증이 중요한 시트 표시
- 어느 파싱 경로(openpyxl / zip·xml fallback)를 썼는지
- 값 해석이 불완전하면 CSV 재내보내기나 해당 시트 캡처 요청

## 출력 규칙

- **숨김 시트는 반드시 별도 섹션**으로 적는다(놓치기 쉬운 맥락).
- 병합셀·데이터 검증이 중요한 시트는 그 사실을 남긴다.
- 파싱 실패가 있으면 어느 경로를 썼는지 명시한다.
- 이 스킬은 구조 **파악·보고**가 목적이다. 그 내용을 기획/컨텍스트 문서로 옮기는 것은 후속 작업.
