# claude-workflow-template

Claude Code와 GitHub를 활용한 AI 협업 개발 워크플로우 보일러플레이트.

## 포함된 것

- **CLAUDE.md** — Claude에게 전달하는 작업 프로세스 가이드 (이슈 기반 개발, 커밋 컨벤션, PR 워크플로우 등)
- **scripts/bot-gh.sh** — GitHub App 봇 계정으로 gh 명령 실행
- **scripts/setup-claude-session.sh** — Claude 세션 시작 시 봇 identity + 토큰 자동 설정
- **scripts/hooks/** — 커밋/PR/push 자동 검증 훅
- **.claude/settings.json** — Claude Code 권한 및 훅 설정

## 새 프로젝트에 적용하는 방법

### 1. 이 레포를 템플릿으로 사용

```bash
# GitHub에서 "Use this template" 버튼 클릭 또는:
gh repo create MY_PROJECT --template gumab/claude-workflow-template
```

### 2. 프로젝트 설정 수정

`scripts/project-config.sh`를 열어 값을 수정합니다:

```bash
REPO_OWNER="gumab"           # GitHub 계정명
BOT_APP_ID="YOUR_APP_ID"     # GitHub App ID
BOT_INSTALLATION_ID="..."    # Installation ID
BOT_PEM_PATH="..."           # Private key 경로
BOT_NAME="YOUR_BOT[bot]"     # 봇 이름
BOT_EMAIL="..."              # 봇 이메일
```

### 3. CLAUDE.md 커스터마이징

`CLAUDE.md` 하단의 "프로젝트 특화 설정" 섹션을 프로젝트에 맞게 채웁니다.

### 4. GitHub App 봇 설정

`docs/bot-setup.md` 참고.

## GitHub App 봇이 하는 일

- Claude의 git commit/push가 봇 계정 (`YOUR_BOT[bot]`)으로 기록됨
- PR 생성, 이슈 코멘트가 봇 계정으로 남겨짐
- 사용자(REPO_OWNER)의 이슈 생성/편집과 Claude의 작업 내역이 계정으로 명확히 구분됨

## 훅 동작

| 이벤트 | 훅 | 동작 |
|---|---|---|
| `git commit` | pre-commit-msg | 커밋 메시지 컨벤션 검증 (`type:#XX`) |
| `git push` | pre-push-branch | 브랜치명 컨벤션 검증 (`type/XX-설명`) |
| `gh pr create` | pre-pr-create | assignee + 이슈 링크 검증 |
| `git commit` | post-commit-reminder | 이슈 기록 리마인더 |
| `git push` | post-push-pr-check | PR 상태 확인 리마인더 |
| `gh pr create` | post-pr-reminder | 이슈 체크리스트 리마인더 |
