#!/bin/bash
# 훅: 브랜치 이름 검증
# Conventional Commits 표준 type + 이슈 번호 패턴 허용
# 예: feat/141-local-dev, fix/189-search, docs/126-roadmap, refactor/150-cleanup

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""')

if ! echo "$COMMAND" | grep -q 'git push'; then
  exit 0
fi

BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)

if echo "$BRANCH" | grep -qE '^(feat|fix|docs|style|refactor|perf|test|chore)/[0-9]+-'; then
  exit 0
fi

echo "현재 브랜치 '$BRANCH'는 push할 수 없습니다. type/XX-설명 형식이어야 합니다 (type: feat, fix, docs, style, refactor, perf, test, chore)." >&2
exit 2
