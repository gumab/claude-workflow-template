#!/bin/bash
# Claude Code SessionStart 훅 — 세션 시작 시 자동 실행
# 1) Git commit identity → 봇 계정으로 설정
# 2) BOT_GH_TOKEN 발급 → PR/push용 (gh issue 등은 사용자 기본 인증 유지)
#
# CLAUDE_ENV_FILE에 쓰면 세션 내 모든 Bash 호출에서 env var 사용 가능

set -euo pipefail

# 프로젝트 설정 로드
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/project-config.sh"

# --- 봇 토큰 발급 ---
JWT=$(python3 -c "
import jwt, time
key = open('${BOT_PEM_PATH}').read()
payload = {'iss': '${BOT_APP_ID}', 'iat': int(time.time())-60, 'exp': int(time.time())+600}
print(jwt.encode(payload, key, algorithm='RS256'))
")

TOKEN=$(curl -s -X POST \
  -H "Authorization: Bearer ${JWT}" \
  -H "Accept: application/vnd.github+json" \
  "https://api.github.com/app/installations/${BOT_INSTALLATION_ID}/access_tokens" \
  | python3 -c "import sys,json; print(json.load(sys.stdin)['token'])")

if [ -z "$TOKEN" ] || [ "$TOKEN" = "None" ]; then
  echo "ERROR: 봇 토큰 발급 실패" >&2
  exit 1
fi

# --- CLAUDE_ENV_FILE에 환경변수 기록 ---
if [ -n "${CLAUDE_ENV_FILE:-}" ]; then
  cat >> "$CLAUDE_ENV_FILE" <<EOF
export GIT_AUTHOR_NAME="${BOT_NAME}"
export GIT_AUTHOR_EMAIL="${BOT_EMAIL}"
export GIT_COMMITTER_NAME="${BOT_NAME}"
export GIT_COMMITTER_EMAIL="${BOT_EMAIL}"
export BOT_GH_TOKEN="${TOKEN}"
EOF
  echo "Claude session setup complete: git identity=bot, BOT_GH_TOKEN ready"
else
  echo "WARN: CLAUDE_ENV_FILE not set — falling back to stdout" >&2
  echo "export GIT_AUTHOR_NAME=\"${BOT_NAME}\""
  echo "export GIT_AUTHOR_EMAIL=\"${BOT_EMAIL}\""
  echo "export GIT_COMMITTER_NAME=\"${BOT_NAME}\""
  echo "export GIT_COMMITTER_EMAIL=\"${BOT_EMAIL}\""
  echo "export BOT_GH_TOKEN=\"${TOKEN}\""
fi
