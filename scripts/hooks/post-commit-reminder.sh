#!/bin/bash
# 훅: 커밋 후 이슈 기록 리마인더

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""')

if ! echo "$COMMAND" | grep -q 'git commit'; then
  exit 0
fi

jq -n '{
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": "리마인더: 이 커밋 내용을 GitHub 이슈에 기록했는지 확인하세요. 안 했다면 다음 작업 전에 이슈 코멘트 또는 본문을 업데이트하세요."
  }
}'

exit 0
