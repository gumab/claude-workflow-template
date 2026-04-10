#!/bin/bash
# 훅: PR 본문 검증
# closes #XX 또는 refs #XX 없으면 차단, --assignee REPO_OWNER 없으면 차단

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/project-config.sh"

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""')

# gh pr create 명령만 대상
if ! echo "$COMMAND" | grep -q 'gh pr create'; then
  exit 0
fi

if ! echo "$COMMAND" | grep -qE "\-\-assignee\s+${REPO_OWNER}"; then
  echo "PR에 --assignee ${REPO_OWNER} 이 빠져있습니다." >&2
  exit 2
fi

if ! echo "$COMMAND" | grep -qiE '(closes|refs)\s+#[0-9]+'; then
  echo "PR 본문에 'closes #XX' 또는 'refs #XX'가 없습니다. 이슈와 연결해주세요." >&2
  exit 2
fi

exit 0
