# Google Sheets 연동 설정 가이드

> solo-forge에서 Google Sheets를 활용하는 방법을 안내합니다.

## 개요

solo-forge는 Google Sheets MCP를 통해 다음 데이터를 시트로 관리할 수 있습니다:

- **QA 시나리오**: 테스트 케이스 작성 및 실행 결과 기록
- **WBS (Work Breakdown Structure)**: 작업 분해 및 일정 관리
- **이슈 트래커**: 버그/개선 사항 추적

## 사전 조건

1. Google Sheets MCP가 Cowork에 연결되어 있어야 합니다
2. 대상 스프레드시트의 편집 권한이 있어야 합니다

## 시트 설정

### sheets-config.json

프로젝트 루트에 `sheets-config.json`을 생성하여 시트 URL을 관리합니다:

```json
{
  "project": "{프로젝트명}",
  "sheets": {
    "qa": {
      "spreadsheet_id": "{스프레드시트 ID}",
      "description": "QA 테스트 시나리오"
    },
    "wbs": {
      "spreadsheet_id": "{스프레드시트 ID}",
      "description": "WBS 일정 관리"
    },
    "issues": {
      "spreadsheet_id": "{스프레드시트 ID}",
      "description": "이슈 트래커"
    }
  }
}
```

> 스프레드시트 ID는 URL에서 추출합니다:
> `https://docs.google.com/spreadsheets/d/{스프레드시트_ID}/edit`

## 사용 가능한 MCP 도구

| 도구 | 용도 |
|------|------|
| `spreadsheet_get` | 스프레드시트 메타데이터 조회 |
| `values_get` | 셀 범위 데이터 읽기 |
| `values_update` | 셀 범위 데이터 쓰기 |
| `values_append` | 행 추가 |
| `sheets_list` | 탭 목록 조회 |
| `sheet_add` | 새 탭 추가 |

## 폴백 정책

Google Sheets MCP가 연결되지 않은 경우:

1. **QA 시나리오** → `docs/05_검증/qa_{기능코드}.md` 마크다운 파일
2. **WBS** → `docs/00_관리/wbs.md` 마크다운 테이블
3. **이슈** → `docs/00_관리/issues.md` 마크다운 테이블

마크다운 폴백 파일은 나중에 시트 연동 시 자동 마이그레이션할 수 있습니다.
