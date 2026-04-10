# GitHub App 봇 설정 가이드

Claude의 작업(commit, PR, 이슈 코멘트)이 봇 계정으로 기록되도록 GitHub App을 설정하는 방법.

## 1. GitHub App 생성

1. GitHub → Settings → Developer settings → GitHub Apps → New GitHub App
2. 설정:
   - **App name**: `프로젝트명-claude-bot` (예: `ailot-claude-bot`)
   - **Homepage URL**: 레포 URL
   - **Webhook**: Active 해제
   - **Permissions**:
     - Repository: Contents (Read & Write), Pull requests (Read & Write), Issues (Read & Write), Metadata (Read)
   - **Where can this GitHub App be installed?**: Only on this account
3. 생성 후 App ID 기록

## 2. Private Key 생성

1. 생성된 App 페이지 → "Generate a private key"
2. 다운받은 `.pem` 파일을 안전한 곳에 저장:
   ```bash
   mkdir -p ~/.config/프로젝트명-claude-bot
   mv ~/Downloads/프로젝트명-claude-bot.*.pem ~/.config/프로젝트명-claude-bot/private-key.pem
   chmod 600 ~/.config/프로젝트명-claude-bot/private-key.pem
   ```

## 3. App을 레포에 설치

1. App 페이지 → "Install App" → 레포 선택
2. 설치 후 URL에서 Installation ID 확인:
   `https://github.com/settings/installations/INSTALLATION_ID`

## 4. project-config.sh 업데이트

```bash
export BOT_APP_ID="12345678"           # App ID
export BOT_INSTALLATION_ID="98765432"  # Installation ID
export BOT_PEM_PATH="$HOME/.config/프로젝트명-claude-bot/private-key.pem"
export BOT_NAME="프로젝트명-claude-bot[bot]"
export BOT_EMAIL="12345678+프로젝트명-claude-bot[bot]@users.noreply.github.com"
```

## 5. 의존성 확인

`setup-claude-session.sh`는 JWT 생성에 Python `PyJWT` 라이브러리를 사용합니다:

```bash
pip3 install PyJWT cryptography
```

## 토큰 만료

봇 토큰은 1시간 후 만료됩니다. 만료 시:

```bash
bash scripts/setup-claude-session.sh
```

또는 Claude Code 세션을 재시작하면 SessionStart 훅이 자동으로 재발급합니다.
