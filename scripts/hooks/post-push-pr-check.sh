#!/bin/bash
# 훅: push 후 PR 상태 확인 리마인더

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""')

if ! echo "$COMMAND" | grep -q 'git push'; then
  exit 0
fi

jq -n '{
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": "리마인더: 현재 작업에 PR이 있어야 할 상황이라면, gh pr view로 PR 상태를 확인하세요. 이미 머지/닫혔으면 새 PR을 생성하세요."
  }
}'

exit 0
