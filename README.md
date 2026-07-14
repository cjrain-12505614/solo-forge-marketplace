# Solo Forge Marketplace

`solo-forge` 플러그인 배포용 Claude Code 마켓플레이스.

## 포함 플러그인

| 플러그인 | 최신 버전 | 설명 |
|---|---|---|
| `solo-forge` | v1.2.0 | 범용 1인 개발자 프로젝트 관리 플러그인 (세션·의사결정·핸드오프·진행 대시보드) |

## 설치 방법

### 1. 마켓플레이스 등록

`~/.claude/settings.json` 의 `extraKnownMarketplaces` 에 추가:

```json
"solo-forge-marketplace": {
  "source": {
    "source": "github",
    "repo": "cjrain-12505614/solo-forge-marketplace"
  }
}
```

또는 CLI:

```bash
claude plugin marketplace add solo-forge-marketplace --github cjrain-12505614/solo-forge-marketplace
```

### 2. 플러그인 설치

```bash
claude plugin install solo-forge@solo-forge-marketplace
```

CoWork 데스크탑 앱을 재시작하면 자동 반영됩니다.

## 업데이트 방법

```bash
claude plugin marketplace update solo-forge-marketplace
claude plugin install solo-forge@solo-forge-marketplace
```

## 소스 레포

- 플러그인 소스: [solo-forge](https://github.com/cjrain-12505614/solo-forge) _(비공개, 배포본만 본 레포에서 공유)_
