---
name: solo-figma-make-reviewer
description: Figma Make 산출물을 화면설계서 기준으로 검증하는 스킬. 사용자가 'Figma 확인해줘', '피그마 검증해줘', '디자인 산출물 점검해줘', 'Figma Make 결과 봐줘', '화면설계서랑 비교해줘' 등을 요청하거나, Figma Make URL을 공유하며 검증을 요청할 때 반드시 이 스킬을 사용하세요.
---

# Figma Make 검증 스킬

## 개요
Figma Make에서 생성된 UI 산출물을 화면설계서(specs) 기준으로 검증합니다. 화면 커버리지, 구조 일관성, 공통 컴포넌트 활용도를 점검하고 상세 보고서를 생성합니다.

## Figma Make URL 형식

```
https://www.figma.com/make/{fileKey}/{fileName}

예:
https://www.figma.com/make/abc123def456/MyApp-UI
https://www.figma.com/make/xyz789abc123/Dashboard-Screens
```

### URL 파싱

```
fileKey: "abc123def456"    (/ 뒤 첫 번째 경로 세그먼트)
fileName: "MyApp-UI"       (/ 뒤 두 번째 경로 세그먼트)
```

---

## 검증 도구 (MCP 사용)

### 사용 가능한 MCP 함수

| 함수 | 목적 | 반환값 |
|------|------|-------|
| `get_design_context` | 디자인 메타데이터 + 코드 + 스크린샷 | code, assets, screenshot |
| `get_screenshot` | 노드별 스크린샷 | PNG 이미지 |
| `get_metadata` | 페이지/노드 구조 (XML) | node IDs, layer names, positions |
| `get_variable_defs` | 디자인 토큰 (CSS variables, Tailwind) | variables 맵 |

### 사용 제약사항

**읽기 전용**: Figma Make 파일을 수정할 수 없습니다.
- 검증 후 PM에 수정 요청사항 보고
- Designer가 Figma 웹에서 직접 수정

---

## 검증 워크플로우

### Step 1: URL 파싱 및 기본 정보 수집

```
입력: Figma Make URL
→ fileKey 및 fileName 추출
→ get_metadata 호출 (전체 구조 확인)
→ 페이지 목록, 레이어 계층구조 파악
```

### Step 2: 화면 커버리지 검증

```
1. 기준 문서 확인: feature_spec_*.md + wireframe_v*.md
   → 정의된 화면 목록 (SCR-XXX-YYY) 추출

2. Figma 페이지 구조 스캔
   → Figma Make의 모든 페이지/프레임 목록화

3. 매핑 생성
   SC-AUTH-001 (스펙) ← → [Page: "Sign Up" / Frame: "Desktop"] (Figma)
   SC-AUTH-002 (스펙) ← → [Page: "Email Verification"] (Figma)
   ...

4. 커버리지 계산
   커버된 화면 / 전체 화면 = X%
```

### Step 3: 화면별 상세 검증

각 화면에 대해:

```
for each 화면 in Figma:
  1. get_screenshot 호출 → 시각 확인
  2. 관련 스펙 항목 확인
  3. 다음 항목 체크:
     ✓ 레이아웃 일관성
     ✓ 타이포그래피 (폰트, 크기, 무게)
     ✓ 컬러 사용 (디자인 토큰 준수)
     ✓ 간격/마진 (그리드 준수)
     ✓ 공통 컴포넌트 사용
     ✓ 상호작용 상태 (normal, hover, focus, disabled, error)
     ✓ 반응형 (필요 시)
     ✓ 접근성 (필요 시)
```

### Step 4: 공통 구조 분석

```
1. 화면 레이아웃 패턴 분석
   - 헤더 구조 (모든 화면에 일관성 있는가?)
   - 푸터 구조
   - 메인 콘텐츠 영역
   - 사이드바/네비게이션

2. 공통 컴포넌트 식별
   - 버튼 (Primary, Secondary, etc.)
   - 입력 필드 (기본, 오류, 포커스 상태)
   - 카드
   - 모달/다이얼로그
   - 알림/토스트
   - 텍스트 스타일 (Heading, Body, Caption)

3. 재사용성 확인
   - 컴포넌트가 Figma에서 컴포넌트화되었는가?
   - 또는 공통 스타일로 정의되었는가?
```

### Step 5: 이슈 식별

```
발견된 문제를 분류:

🔴 FAIL (블로커)
  - 필수 화면 누락
  - 스펙과 불일치하는 주요 레이아웃
  - 오류 상태 정의 누락
  - 중요 기능 화면 미포함

🟡 CONDITIONAL PASS (수정 필요)
  - 미세한 간격/정렬 불일치
  - 타이포그래피 미세 조정
  - 컴포넌트 변수 개수 부족
  - 반응형 스크린 누락 (필수가 아닌 경우)

✅ PASS (승인)
  - 모든 필수 화면 포함
  - 스펙과 일치
  - 공통 컴포넌트 체계적 정의
  - 상호작용 상태 완전 정의
```

---

## 검증 보고서 템플릿

### 파일명

```
figma_review_YYYY-MM-DD.md

예: figma_review_2026-03-23.md
```

### 보고서 구조

```markdown
# Figma Make 검증 보고서

**검증 일시**: 2026-03-23 14:00
**Figma Make URL**: https://www.figma.com/make/abc123/MyApp-UI
**File Key**: abc123
**Version**: {Figma Make 버전}
**관련 스펙**: feature_spec_auth_v1.0.md, wireframe_v1.0.md

---

## 1. 검증 개요

| 항목 | 결과 |
|------|------|
| **최종 판정** | PASS / CONDITIONAL PASS / FAIL |
| **검증자** | {PL명} |
| **승인자** | {PM명} (예정) |

---

## 2. 화면 커버리지

### 커버리지 요약

```
스펙 정의 화면: 8개
Figma Make 화면: 7개
→ 커버율: 87.5% (7/8)
```

### 화면별 매핑

| 스펙 화면 | Figma 페이지 | Figma 프레임 | 상태 | 비고 |
|----------|-------------|------------|------|------|
| SCR-AUTH-001 (가입) | Sign Up | Desktop | ✅ | - |
| SCR-AUTH-001 (가입) | Sign Up | Mobile | ✅ | 반응형 포함 |
| SCR-AUTH-002 (이메일 인증) | Email Verification | Desktop | ✅ | - |
| SCR-AUTH-003 (로그인) | Login | Desktop | ✅ | - |
| SCR-AUTH-004 (비밀번호 재설정) | Password Reset | Desktop | ❌ | **누락** |
| SCR-USER-001 (프로필) | User Profile | Desktop | ✅ | - |
| SCR-USER-002 (프로필 수정) | Edit Profile | Desktop | ✅ | - |
| SCR-USER-003 (설정) | Settings | Desktop | ✅ | - |

**분석**: Password Reset 화면(SCR-AUTH-004) 누락. 다음 반복에서 추가 필요.

---

## 3. 화면별 검증 상세

### SCR-AUTH-001: 가입 화면

#### 레이아웃 검증
- [x] 헤더 영역 포함 (로고, 메뉴)
- [x] 입력 폼 정렬 (수직 스택)
- [x] 하단 링크 ("로그인하기") 포함
- [x] 모바일 반응형 (모바일용 프레임)

#### 컴포넌트 검증

| 컴포넌트 | 사용 여부 | 상태 | 비고 |
|---------|---------|------|------|
| 입력 필드 (TextField) | O | ✅ | 정상 + 포커스 상태 |
| 버튼 (Primary) | O | ✅ | "가입" 버튼 |
| 버튼 (Link) | O | ✅ | "로그인하기" 링크 |
| 텍스트 (Heading) | O | ✅ | "계정 만들기" 제목 |
| 텍스트 (Body) | O | ✅ | 안내 문구 |
| 오류 메시지 (Error Text) | O | ⚠️ | 정의되었으나, 오류 상태 스크린 별도 없음 |

#### 타이포그래피 검증

| 요소 | 폰트 | 크기 | 무게 | 기대값 | 상태 |
|------|------|------|------|--------|------|
| 제목 | Inter | 32px | Bold | 32px Bold | ✅ |
| 본문 | Inter | 14px | Regular | 14px Regular | ✅ |
| 입력 레이블 | Inter | 12px | Medium | 12px Medium | ✅ |

#### 컬러/토큰 검증
- [x] Primary 색상 (버튼): #007AFF
- [x] Background: #F5F5F5
- [x] Text (Primary): #000000
- [x] Text (Secondary): #666666
- [x] Error: #FF3B30

**토큰 매핑**: 모든 색상이 정의된 디자인 토큰과 일치 ✅

#### 간격/그리드 검증
- [x] 기본 마진: 16px (그리드 기준)
- [x] 입력 필드 간격: 12px (일관성)
- [x] 버튼 높이: 48px (터치 타겟 최소값)

#### 상호작용 상태 검증

| 상태 | 스크린 | 스펙 | 구현 | 상태 |
|------|--------|------|------|------|
| Normal | 기본 입력 필드 | 스펙 참조 | O | ✅ |
| Focus | 입력 필드 포커스 | 파란 테두리 | O | ✅ |
| Disabled | 비활성화 버튼 | 회색 배경 | O | ✅ |
| Error | 오류 입력 필드 | 빨간 테두리 + 메시지 | △ | ⚠️ 오류 상태 스크린 필요 |

#### 접근성 검증 (필요 시)
- [ ] 명도 대비 (AA 기준 최소 4.5:1)
- [ ] 레이블 정의 (name, role 속성)
- [ ] 포커스 순서 (탭 순서)

#### 요약
**상태**: ✅ PASS
**미결**: 오류 상태 화면 별도 추가 (선택사항)

---

### SCR-AUTH-002: 이메일 인증 화면

#### 레이아웃 검증
- [x] 제목 및 설명 텍스트
- [x] 토큰 입력 필드 또는 "확인 링크 클릭" 버튼
- [x] 재발송 링크

#### 컴포넌트 검증

| 컴포넌트 | 사용 여부 | 상태 | 비고 |
|---------|---------|------|------|
| 입력 필드 (Code Input) | O | ✅ | 6자리 코드 입력 |
| 버튼 (Primary) | O | ✅ | "인증하기" 버튼 |
| 텍스트 (Link) | O | ✅ | "인증 코드 재발송" |
| 텍스트 (Timer) | O | ✅ | 타이머 표시 |

#### 요약
**상태**: ✅ PASS

---

### SCR-AUTH-004: 비밀번호 재설정 화면 (누락)

**상태**: ❌ FAIL - 화면 누락

**기대**: 비밀번호 재설정 기능의 화면 필요
- 이메일 입력 후 "코드 발송"
- 이메일 + 새 비밀번호 입력
- 완료 확인

**대응**: PM에 추가 요청. 다음 이터레이션(v2)에 포함.

---

## 4. 공통 구조 분석

### 레이아웃 패턴

**헤더**
- 구조: 로고 (좌) + 메뉴 (우)
- 높이: 56px
- 배경색: #FFFFFF
- 상태: ✅ 모든 화면에 일관됨

**푸터**
- 구조: 저작권 텍스트 (중앙)
- 높이: 48px
- 배경색: #F5F5F5
- 상태: ✅ 모든 화면에 일관됨

**메인 콘텐츠**
- 구조: 풀 너비 또는 최대 1200px 센터 정렬
- 패딩: 32px (양측)
- 상태: ✅ 일관되게 적용됨

### 공통 컴포넌트 시스템

#### 버튼 컴포넌트

| 타입 | 크기 | 배경색 | 텍스트색 | 사용 | 상태 |
|------|------|--------|---------|------|------|
| Primary | 48px | #007AFF | white | CTA 버튼 | ✅ 컴포넌트화 |
| Secondary | 48px | #F0F0F0 | #007AFF | 보조 버튼 | ✅ 컴포넌트화 |
| Tertiary | Auto | transparent | #007AFF | 텍스트 링크 | ✅ 컴포넌트화 |

**분석**: 모든 버튼이 일관되게 정의됨. 변수 활용도 우수. ✅

#### 입력 필드 컴포넌트

| 타입 | 높이 | 테두리 | 포커스 색상 | 상태 |
|------|------|--------|-----------|------|
| Text Field | 44px | 1px #CCCCCC | #007AFF | ✅ 정의됨 |
| Password Field | 44px | 1px #CCCCCC | #007AFF | ✅ 정의됨 |
| Error State | 44px | 2px #FF3B30 | #FF3B30 | ⚠️ 오류 상태만 정의, 오류 메시지 표시 방식 명확하지 않음 |

**분석**: 기본 상태는 좋음. 오류 상태 UX 개선 필요.

#### 텍스트 스타일 (Typography)

| 이름 | 폰트 | 크기 | 무게 | 라인하이트 | 사용처 | 상태 |
|------|------|------|------|-----------|--------|------|
| Display 1 | Inter | 40px | Bold | 48px | 페이지 제목 | ✅ |
| Display 2 | Inter | 32px | Bold | 40px | 섹션 제목 | ✅ |
| Heading | Inter | 24px | Bold | 32px | 소제목 | ✅ |
| Body | Inter | 14px | Regular | 20px | 본문 | ✅ |
| Caption | Inter | 12px | Regular | 16px | 보조 텍스트 | ✅ |

**분석**: 타이포그래피 시스템 완성도 높음. ✅

---

## 5. 디자인 토큰 추출

### Color Tokens

```css
:root {
  --color-primary: #007AFF;
  --color-primary-light: #E3F2FD;
  --color-secondary: #666666;
  --color-error: #FF3B30;
  --color-success: #34C759;
  --color-warning: #FF9500;
  --color-background: #F5F5F5;
  --color-background-white: #FFFFFF;
  --color-border: #CCCCCC;
  --color-text-primary: #000000;
  --color-text-secondary: #666666;
}
```

### Spacing Tokens

```css
:root {
  --space-xs: 8px;
  --space-sm: 12px;
  --space-md: 16px;
  --space-lg: 24px;
  --space-xl: 32px;
}
```

### Typography Tokens

```css
:root {
  --font-display-1: 40px/48px bold inter;
  --font-display-2: 32px/40px bold inter;
  --font-heading: 24px/32px bold inter;
  --font-body: 14px/20px regular inter;
  --font-caption: 12px/16px regular inter;
}
```

### Border Radius Tokens

```css
:root {
  --radius-none: 0px;
  --radius-sm: 4px;
  --radius-md: 8px;
  --radius-lg: 12px;
  --radius-full: 9999px;
}
```

---

## 6. 발견 이슈

### 🔴 FAIL (블로커)

#### ISSUE-001: SCR-AUTH-004 화면 누락
- **심각도**: High
- **설명**: 비밀번호 재설정 화면이 Figma에서 누락됨
- **스펙**: feature_spec_auth_v1.0.md, AC 3.1
- **영향**: 해당 기능 개발 불가
- **대응**: v2 이터레이션에서 추가

---

### 🟡 CONDITIONAL PASS (수정 권장)

#### ISSUE-002: 오류 상태 스크린 누락
- **심각도**: Medium
- **설명**: 입력 필드 오류 상태(validation error) 화면이 별도로 없음
- **현황**: 컴포넌트 수준에서는 정의되었으나, 실제 사용자 시나리오 화면 필요
- **예**: "이메일이 잘못되었습니다" 오류 메시지와 함께 입력 필드가 강조된 화면
- **대응**: Designer와 협의하여 오류 상태 화면 추가 (선택사항)

#### ISSUE-003: 로딩 상태 UI 미정의
- **심각도**: Medium
- **설명**: API 응답 대기 중 로딩 상태 UI(spinner, skeleton) 정의 없음
- **영향**: 개발 시 구현 방식 모호
- **대응**: 디자인 시스템에 로딩 컴포넌트 추가

#### ISSUE-004: 타이머 스타일 불명확
- **심각도**: Low
- **설명**: 이메일 인증 화면의 타이머 타이포그래피/색상 지정 미흡
- **영향**: 시각적 강조도 불명확
- **대응**: 타이머를 "Body + Primary 색상" 또는 별도 스타일로 정의

---

### ✅ PASS (이슈 없음)

#### ITEM-001: 버튼 시스템
- 모든 버튼이 일관되게 3가지 타입(Primary, Secondary, Tertiary)으로 정의됨
- 모든 상태(Normal, Hover, Focus, Disabled)가 명확히 구현됨

#### ITEM-002: 컬러 시스템
- 모든 색상이 정의된 토큰으로 관리됨
- 색상 대비가 WCAG AA 기준 준수

#### ITEM-003: 타이포그래피
- 5단계 계층 구조(Display 1~2, Heading, Body, Caption) 명확
- 모든 텍스트가 정의된 스타일 적용

---

## 7. 개선 권장사항

### 단기 (v1 최종 검증 전)
1. ✅ SCR-AUTH-004 (비밀번호 재설정) 화면 추가 필요
2. ⚠️ 오류 상태 화면 예시 추가 (선택)
3. ⚠️ 로딩 상태 UI 정의 추가 (선택)

### 중기 (v2 계획)
1. 반응형 웹(Tablet, 대형 데스크톱) 화면 추가
2. 다크 모드 테마 추가
3. 접근성(A11y) 검증 강화

### 장기 (v3+)
1. 애니메이션/인터랙션 프로토타입 추가
2. 다국어 지원(i18n) 고려
3. 컴포넌트 라이브러리 별도 문서화

---

## 8. 최종 판정

| 항목 | 결과 |
|------|------|
| **최종 판정** | 🟡 CONDITIONAL PASS |
| **실행 가능성** | 개발 진행 가능 (ISSUE-001 제외) |
| **승인 필요 사항** | 1. SCR-AUTH-004 추가 또는 범위 확정 (PM 의사결정) |
| | 2. 로딩/오류 상태 UI 정의 (PM 의사결정) |
| **검증자** | PL (준호) |
| **검증 완료일** | 2026-03-23 |

### 판정 근거

- ✅ 7/8 화면 커버 (87.5%)
- ✅ 공통 컴포넌트 시스템 완성도 높음
- ✅ 타이포그래피/컬러 토큰 명확
- ⚠️ 한 개 필수 화면 누락 (가역적, PM 확정 필요)
- ⚠️ 예외 상태 UI 미흡 (개발 진행 가능, 개선 권장)

### 다음 단계

1. **PM 검수** (예상: 2026-03-24)
   - ISSUE-001 (SCR-AUTH-004) 범위 확정
   - ISSUE-002, ISSUE-003, ISSUE-004 우선순위 결정

2. **Designer 수정** (예상: 2026-03-24 ~ 25)
   - 확정된 이슈 수정
   - 추가 화면 작성 (필요 시)

3. **재검증** (예상: 2026-03-26)
   - 수정 내용 확인
   - 최종 v1.0 승격

---

## 부록: 체크리스트

### 검증 전 확인사항
- [x] Figma Make URL 유효성 확인
- [x] 관련 스펙 문서 확인 (feature_spec_*.md)
- [x] 관련 화면설계 문서 확인 (wireframe_v*.md)
- [x] 이전 버전 보고서 확인 (있으면 변경사항 추적)

### 검증 수행 항목
- [x] 화면 커버리지 분석
- [x] 화면별 상세 검증
- [x] 공통 구조 분석
- [x] 컴포넌트 체계 검증
- [x] 디자인 토큰 추출
- [x] 이슈 식별 및 분류

### 보고서 완성
- [x] 보고서 작성
- [x] 스크린샷 삽입 (필요 시)
- [x] 판정 명확화
- [x] 다음 단계 지시

---

**담당**: PL (준호) - 검증
**검증자**: {PL명}
**승인자**: {PM명} (예정)
**출력 폴더**: docs/05_검증/ (또는 이슈 정리용 decision_log.md)
**MCP 도구**: get_design_context, get_screenshot, get_metadata, get_variable_defs
**제약사항**: Figma Make는 읽기 전용. 수정 사항은 Designer에게 요청.
**다음 단계**: PM 최종 검수 → Designer 수정 → 재검증
