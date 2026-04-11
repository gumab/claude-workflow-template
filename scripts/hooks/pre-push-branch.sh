#!/bin/bash
# 훅: 브랜치 이름 검증
# Conventional Commits 표준 type + 이슈 번호 패턴 허용
# 예: feat/141-local-dev, fix/189-search, docs/126-roadmap, refactor/150-cleanup
#
# 이 훅은 자신이 속한 프로젝트에서 push할 때만 동작합니다.
# 다른 레포에서 push하는 경우 자동으로 스킵됩니다.

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""')

if ! echo "$COMMAND" | grep -q 'git push'; then
  exit 0
fi

# 이 훅 스크립트가 속한 프로젝트 루트
HOOK_PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# 명령어에서 cd로 이동한 디렉토리가 있으면 해당 위치의 git root를 사용
TARGET_CD=$(echo "$COMMAND" | grep -oE 'cd [^&;]+' | head -1 | sed 's/cd //' | xargs 2>/dev/null)
if [ -n "$TARGET_CD" ] && [ -d "$TARGET_CD" ]; then
  PUSH_GIT_ROOT=$(cd "$TARGET_CD" && git rev-parse --show-toplevel 2>/dev/null)
else
  PUSH_GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
fi

# 이 훅이 속한 프로젝트가 아니면 스킵
if [ "$PUSH_GIT_ROOT" != "$HOOK_PROJECT_ROOT" ]; then
  exit 0
fi

BRANCH=$(git -C "$PUSH_GIT_ROOT" rev-parse --abbrev-ref HEAD 2>/dev/null)

if echo "$BRANCH" | grep -qE '^(feat|fix|docs|style|refactor|perf|test|chore)/[0-9]+-'; then
  exit 0
fi

echo "현재 브랜치 '$BRANCH'는 push할 수 없습니다. type/XX-설명 형식이어야 합니다 (type: feat, fix, docs, style, refactor, perf, test, chore)." >&2
exit 2
