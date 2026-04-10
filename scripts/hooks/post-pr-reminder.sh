#!/bin/bash
# 훅: PR 생성 후 이슈 상태 리마인더

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""')

if ! echo "$COMMAND" | grep -q 'gh pr create'; then
  exit 0
fi

jq -n '{
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": "리마인더: PR을 생성했습니다. 연결된 GitHub 이슈의 상태와 체크리스트가 최신인지 확인하세요."
  }
}'

exit 0
