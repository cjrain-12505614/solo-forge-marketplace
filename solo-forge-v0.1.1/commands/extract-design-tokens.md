---
name: solo-extract-design-tokens
description: Figma Make에서 디자인 토큰 추출
allowed_tools:
  - read
  - write
  - bash
---

# 디자인 토큰 추출

Figma Make에서 디자인 토큰을 추출하여 CSS 변수 및 Tailwind 설정으로 변환합니다.

## 사전 요구사항

- Figma Make 파일 존재
- 디자인 토큰 정의 완료 (색상, 타이포그래피, 스페이싱 등)

## 사용법

```
/extract-design-tokens [Figma_URL]
```

### 예시

```
/extract-design-tokens https://figma.com/design/abc123/MyDesignFile?node-id=1-2
```

## 실행 단계

### 1. Figma 토큰 조회

get_variable_defs MCP 도구로 Figma 변수 정의 조회

변수 형식:
```
{카테고리}/{부카테고리}/{토큰명}: {값}

예시:
color/primary/default: #007AFF
color/semantic/success: #34C759
typography/heading/h1: 32px / bold
spacing/padding/sm: 8px
```

### 2. 토큰 매핑 테이블 생성

저장 경로: `docs/03_설계/design_tokens.md`

템플릿:
```markdown
# 디자인 토큰

**추출일**: YYYY-MM-DD
**출처**: [Figma 파일명]

## 색상 (Color Tokens)

| 토큰명 | 값 | 사용처 | CSS 변수명 |
|--------|-----|--------|-----------|
| primary/default | #007AFF | 주요 버튼, CTA | --color-primary |
| primary/dark | #0051D5 | Hover 상태 | --color-primary-dark |
| semantic/success | #34C759 | 성공 메시지 | --color-success |
| semantic/error | #FF3B30 | 오류 메시지 | --color-error |
| semantic/warning | #FF9500 | 경고 메시지 | --color-warning |
| neutral/50 | #F9FAFB | 배경 | --color-neutral-50 |
| neutral/100 | #F3F4F6 | 구분선 | --color-neutral-100 |
| neutral/900 | #111827 | 본문 텍스트 | --color-neutral-900 |

## 타이포그래피 (Typography Tokens)

| 토큰명 | 폰트 | 크기 | 굵기 | 행높이 | CSS 클래스명 |
|--------|------|------|------|--------|------------|
| heading/h1 | -system- | 32px | bold | 1.2 | .text-h1 |
| heading/h2 | -system- | 24px | bold | 1.3 | .text-h2 |
| heading/h3 | -system- | 20px | semibold | 1.4 | .text-h3 |
| body/large | -system- | 16px | regular | 1.5 | .text-body-lg |
| body/base | -system- | 14px | regular | 1.5 | .text-body |
| body/small | -system- | 12px | regular | 1.4 | .text-body-sm |
| caption | -system- | 10px | regular | 1.4 | .text-caption |

## 스페이싱 (Spacing Tokens)

| 토큰명 | 값 | 사용처 | CSS 변수명 |
|--------|-----|--------|-----------|
| xs | 4px | 아이콘 간격 | --spacing-xs |
| sm | 8px | 컴포넌트 내부 | --spacing-sm |
| md | 16px | 섹션 간격 | --spacing-md |
| lg | 24px | 구간 구분 | --spacing-lg |
| xl | 32px | 페이지 마진 | --spacing-xl |
| 2xl | 48px | 큰 구간 | --spacing-2xl |

## 그림자 및 효과 (Shadow/Effect Tokens)

| 토큰명 | CSS 값 | 사용처 |
|--------|--------|--------|
| shadow/sm | 0 1px 2px rgba(...) | 카드 기본 |
| shadow/md | 0 4px 6px rgba(...) | 카드 호버 |
| shadow/lg | 0 10px 15px rgba(...) | 모달 |

## 경계값 (Radius Tokens)

| 토큰명 | 값 | 사용처 | CSS 변수명 |
|--------|-----|--------|-----------|
| radius/none | 0 | 직사각형 | --radius-none |
| radius/sm | 4px | 버튼 | --radius-sm |
| radius/md | 8px | 카드 | --radius-md |
| radius/lg | 12px | 컨테이너 | --radius-lg |
| radius/full | 9999px | 아바타 | --radius-full |
```

### 3. CSS 변수 파일 생성

저장 경로: `docs/04_개발/variables.css` (또는 SCSS)

예시:
```css
/* Design Tokens - Auto Generated */

:root {
  /* Colors */
  --color-primary: #007AFF;
  --color-primary-dark: #0051D5;
  --color-success: #34C759;
  --color-error: #FF3B30;
  --color-warning: #FF9500;
  --color-neutral-50: #F9FAFB;
  --color-neutral-100: #F3F4F6;
  --color-neutral-900: #111827;

  /* Spacing */
  --spacing-xs: 4px;
  --spacing-sm: 8px;
  --spacing-md: 16px;
  --spacing-lg: 24px;
  --spacing-xl: 32px;
  --spacing-2xl: 48px;

  /* Radius */
  --radius-none: 0;
  --radius-sm: 4px;
  --radius-md: 8px;
  --radius-lg: 12px;
  --radius-full: 9999px;
}
```

### 4. Tailwind 설정 생성 (선택)

저장 경로: `tailwind.config.js` (또는 추가 섹션)

예시:
```javascript
module.exports = {
  theme: {
    extend: {
      colors: {
        primary: '#007AFF',
        'primary-dark': '#0051D5',
        success: '#34C759',
        error: '#FF3B30',
        warning: '#FF9500',
        neutral: {
          50: '#F9FAFB',
          100: '#F3F4F6',
          900: '#111827',
        },
      },
      spacing: {
        xs: '4px',
        sm: '8px',
        md: '16px',
        lg: '24px',
        xl: '32px',
        '2xl': '48px',
      },
      borderRadius: {
        none: '0',
        sm: '4px',
        md: '8px',
        lg: '12px',
        full: '9999px',
      },
    },
  },
};
```

### 5. 비교 및 동기화

기존 프로젝트 설정과 비교:
- 추가된 토큰
- 변경된 토큰
- 제거할 토큰

생성 문서에 기록

## 완료 보고

```
디자인 토큰 추출 완료.

**추출 대상**: {Figma 파일명}
**생성 문서**:
  - docs/03_설계/design_tokens.md (매핑 테이블)
  - docs/04_개발/variables.css (CSS 변수)
  - tailwind.config.js (Tailwind 설정)

**토큰 통계**:
  - 색상: N개
  - 타이포그래피: N개
  - 스페이싱: N개
  - 기타: N개

개발 시 위 파일들을 프로젝트에 통합하시기 바랍니다.
```

## 동기화 규칙

- Figma 토큰 변경 시 → 이 명령어 재실행
- CSS 변수와 Tailwind 설정은 자동 동기화
- 프로젝트 설정 변경 시 → Figma에 역반영 검토
