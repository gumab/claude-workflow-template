#!/bin/bash
# 훅: 커밋 메시지 포맷 검증
# Conventional Commits 표준 type + 이슈번호 필수

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""')

if ! echo "$COMMAND" | grep -q 'git commit'; then
  exit 0
fi

if echo "$COMMAND" | grep -qE '(feat|fix|docs|style|refactor|perf|test|chore):#[0-9]+'; then
  exit 0
fi

echo "커밋 메시지가 컨벤션에 맞지 않습니다. 형식: type:#XX (type: feat, fix, docs, style, refactor, perf, test, chore)" >&2
exit 2
