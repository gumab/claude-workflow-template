# Claude AI 워크플로우 가이드

> 이 파일은 `claude-workflow-template` 보일러플레이트 기반의 AI 협업 가이드입니다.
> 새 프로젝트 시작 시 `scripts/project-config.sh`의 값을 수정하고, 이 파일의 프로젝트 특화 섹션을 채우세요.

## 매 태스크 필수 체크리스트
> 모든 태스크(#XX) 시작/진행/완료 시 반드시 따를 것. 이 체크리스트를 건너뛰지 마라.

1. **시작 전**: `gh issue view XX`로 이슈 확인 (없으면 먼저 생성) → 사용자에게 작업 방향 브리핑 → 확인 받은 뒤 이슈 브랜치 생성(`feat/XX-설명`) → 작업 시작
2. **작업 중**: 발견한 중요 사항, 결정 사유, 예상 밖 변경 → **즉시** 이슈에 기록 (체크리스트 상태, 새로 발견한 사실, 제외/변경 사항, 관련 이슈 링크 등)
3. **커밋 전**: 빌드 테스트 통과 확인, `.claude/settings.json` 변경 있으면 함께 포함
4. **PR 생성 시**: `closes #XX` 또는 `refs #XX` 연결, `--assignee REPO_OWNER`
5. **완료 시**: 이슈 체크리스트 갱신, 작업 결과 코멘트

## 역할 정의
- **REPO_OWNER**: 이슈 생성자 · PR reviewer · 최종 머지 담당
- **Claude (봇 계정)**: 이슈 해결 작업자 · 코드 작성 · PR 생성
- **GitHub 계정 사용 기준**:
  - **REPO_OWNER 계정** (기본 인증): 이슈 생성(`gh issue create`), 이슈 편집(`gh issue edit`) — 사용자의 요구사항/의사결정
  - **봇 계정** (`scripts/bot-gh.sh`): git commit, git push, `gh pr create`, 이슈 코멘트(`scripts/bot-gh.sh issue comment`) — Claude의 작업 내역/답변

## 맥락 데이터 저장 원칙
> 여러 컴퓨터에서 작업하므로, 맥락은 반드시 **git 저장소**(CLAUDE.md) 또는 **GitHub Issues**에 저장해야 함.

- **프로젝트 규칙/가이드** → CLAUDE.md 파일들 (소스코드에 커밋, 모든 머신에서 접근 가능)
- **태스크별 맥락/조사 결과** → GitHub Issues (본문 + 코멘트)
- **로컬 memory 시스템** (`~/.claude/`) → 해당 머신에서만 유효한 보조 캐시. 중요 정보는 여기에만 두지 마라
- CLAUDE.md에 넣기 애매한 프로젝트 맥락 → GitHub Issue에 기록 후 CLAUDE.md에서 이슈 번호로 참조
- **규칙 추가/변경 시**: 이 CLAUDE.md 구조(루트=프로세스, 하위=도메인)에서 가장 적절한 위치에 배치. 루트에 도메인 기술 내용을 넣거나, 하위에 프로세스 규칙을 넣지 마라
- **규칙 변경 시 settings.json 연동 점검**: 역할/계정/권한 관련 규칙이 바뀌면 `.claude/settings.json`의 허용 목록·훅 설정도 함께 맞춰야 하는지 확인

## 이슈 맥락 보존
> 세션은 유한하고, 다음 세션의 Claude는 이슈만 보고 작업한다. **이슈가 곧 작업 명세서다.**

- **조사/분석 결과는 원본 이슈에 상세하게 기록** — 요약만 남기지 마라. SQL 쿼리, 발견한 데이터, 판단 근거를 그대로 남겨라
- **새 이슈 생성 시**: 조사 이슈 링크 + 해당 이슈에서 발견한 핵심 내용 인용. "다음 세션에서 이 이슈만 보고도 작업 가능한가?" 자문
- **여러 이슈에 걸치는 조사**: 원본 조사 이슈에 방대하게 기록 → 새 이슈들에서 `관련: #XX` 링크
- **이슈 본문 수정** (`gh issue edit XX --body`): 체크리스트 갱신, 작업 범위 변경, 스펙 변경 등 이슈의 정의 자체가 바뀌는 경우
- **이슈 코멘트** (`scripts/bot-gh.sh issue comment XX --body`): 작업 진행 경과, 발견한 문제, 결정 사유, PR 링크 등 시간순 기록 (봇 계정)

## GitHub 봇 계정 (자동 설정)
- Claude의 git commit/push/PR은 **봇 계정**으로 실행
- **SessionStart 훅이 자동으로 설정** — 수동 토큰 활성화 불필요
  - `GIT_AUTHOR_NAME/EMAIL`, `GIT_COMMITTER_NAME/EMAIL` → 봇 identity
  - `BOT_GH_TOKEN` → PR/push용 봇 토큰
- **사용법**:
  - `git commit`, `git push` → 자동 (env var로 봇 identity)
  - `gh pr create` → `scripts/bot-gh.sh pr create ...`
  - `gh issue create/edit/comment` → GH_TOKEN 미설정 → **REPO_OWNER 계정으로 실행**
- 토큰 1시간 만료 시 → `bash scripts/setup-claude-session.sh` 재실행
- 훅 스크립트: `scripts/setup-claude-session.sh`
- GitHub App 설정: `docs/bot-setup.md`

## 작업 트래커 (GitHub Issues)
- **Repo**: `REPO_OWNER/REPO_NAME`
- **Project**: GitHub Projects 칸반 보드
- 이슈 확인: `gh issue view XX` 또는 `gh issue list`
- **라벨 정의**:
  - 유형: `bug`(버그), `epic`(에픽 — 하위 서브태스크 묶음), `on-hold`(작업 보류 — 기술적 난이도/블로커로 일시 중지), `reopened`(완료 후 다시 열림)
  - 워크플로우: `quick-win`(XS/S + High/Medium — 빠르게 처리 가능), `blocked`(다른 이슈 완료 대기 중 — 의존성 블로커)
- **라벨 적용 기준**:
  - `quick-win`: Size XS~S이면서 Priority High~Medium인 이슈에 부여
  - `blocked`: 선행 이슈가 있어야 착수 가능한 경우 부여. 선행 이슈 완료 시 제거
  - `on-hold` vs `blocked`: on-hold는 기술적 난이도/외부 요인으로 보류, blocked는 내부 이슈 의존성
- **이슈 통합 원칙**: 관련된 기능은 하나의 이슈로 관리. 통합 시 기존 이슈를 `not_planned`로 close하고 통합 이슈 번호를 코멘트에 기록

## GitHub Projects 상태 워크플로우
- **Backlog**: 등록만 된 상태. `on-hold` 이슈도 여기에 위치
- **Todo**: 다음에 할 작업. 이슈 프로젝트 추가 시 자동 설정. `reopened` 이슈도 여기로 자동 이동
- **In Progress**: 브랜치를 따서 실제 작업 시작
- **In Review**: PR 생성됨 (자동 — PR이 이슈에 연결 시)
- **Done**: 완료 (자동 — 이슈 close, PR 머지 시)
- **Cancelled**: 영구 드랍 — 보드에서 이동 후 이슈를 `not_planned`로 close
- 보류/재오픈 상태는 Status가 아닌 **라벨**(`on-hold`, `reopened`)로 관리
- **자동화 워크플로우** (GitHub Projects Workflows):
  - Auto-add to project: 이슈 생성 → 프로젝트 자동 추가
  - Item closed → Done / Item reopened → Todo
  - Pull request linked to issue → In Review / Pull request merged → Done

## 커밋 컨벤션
- **형식**: `type:#XX 작업 내용 요약`
- **type**: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `chore` (Conventional Commits 표준)
- 예시: `feat:#1 초기 프로젝트 셋업`, `fix:#3 연결 재시도 버그 수정`
- 하나의 커밋이 여러 이슈에 걸칠 경우: `feat:#XX #YY 내용`
- Co-Authored-By 트레일러 불필요 (봇 계정으로 커밋되므로 자동 구분)

## 작업 진행 규칙
- 각 태스크(#XX) 작업 시작 전:
  1. `gh issue view XX`로 해당 이슈 본문 + 댓글을 읽어옴
  2. 새로운 지시사항이 있으면 작업 방향에 반영
  3. 사용자에게 작업 방향을 간단히 브리핑하고 확인을 받은 뒤 시작
- 확인 전에는 브랜치 생성이나 상태 변경을 하지 않음
- 확인 후: 브랜치 생성 → 작업 시작
- 사용자가 브리핑과 다른 방향으로 지시하면, 변경된 내용을 이슈 코멘트에 기록한 뒤 진행
- **사용자 메시지에 #XX가 언급되면**: 해당 세션에서 아직 안 읽은 이슈라면 `gh issue view XX`로 먼저 확인
- **응답을 마치기 전 자문**: "이 작업의 맥락이 이슈에 충분히 남았나?" — 세션이 끝나도 다음 세션에서 이어갈 수 있는 수준인지 점검
- **커밋 전 빌드 확인**: 해당 세션에서 변경한 앱의 빌드를 아직 안 돌렸으면 커밋 전에 반드시 실행

## 이슈 관리 규칙
- **에픽 생성**: 태스크가 쌓여서 병합이 필요해 보이면 사용자에게 물어본 뒤, 에픽 이슈를 생성하고 GitHub 네이티브 Sub-issues로 서브태스크 연결
- **하위이슈(Sub-issues) 원칙**: 하위이슈 목록은 GitHub 네이티브 Sub-issues 기능으로만 관리. 이슈 본문에 하위이슈 목록을 중복 나열하지 않음
- **장기 이슈 진행률**: 완료/남은 항목을 체크리스트 코멘트로 기록하여 진행률 추적
- **Cancelled 처리**: 보드에서 Cancelled로 이동 + `gh issue close XX --reason "not planned"` 실행
- **레거시 삭제 전 백업 필수**: 레거시 코드 삭제 시 별도 파일에 상세 백업 + git 커밋 해시 기록
- **GitHub Projects API 주의**: Status 필드 옵션을 API로 수정하면 전체 덮어쓰기되어 기존 매핑 소실. 반드시 UI에서 수동 요청

## 워크트리 구조
| 워크트리 | 경로 | 용도 |
|---|---|---|
| `main` | `프로젝트명/` | 코드 리뷰, 이슈 관리 등 비개발 작업 |
| `feature` | `프로젝트명-worktrees/feature/` | 주요 기능 개발 |
| `misc` | `프로젝트명-worktrees/misc/` | 인프라, 문서 등 기타 작업 |

> 워크트리 구조는 프로젝트 규모에 맞게 조정하세요.

## 브랜치 & PR 워크플로우
- 브랜치명: `type/XX-설명` — type은 커밋 컨벤션과 동일 (`feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `chore`)
- **기본 흐름**:
  1. 해당 도메인 워크트리로 이동
  2. main 기반 태스크 브랜치 생성 (`git checkout -b feat/XX-설명 main`)
  3. 작업 → 커밋 → PR to `main`
  4. 다음 태스크 시작 시 다시 main 기반으로 새 브랜치 생성
- **서브이슈가 있는 경우**:
  1. 부모이슈 브랜치를 main 기반으로 생성 (`feat/XX-설명`)
  2. 서브이슈 브랜치는 부모이슈 브랜치에서 생성 (`feat/YY-설명`)
  3. 서브이슈 PR → 부모이슈 브랜치로 머지
  4. 모든 서브이슈 완료 후 부모이슈 브랜치 → `main`으로 최종 PR
- PR 본문에 `closes #XX` → 이슈 자동 close + Projects 자동 Done
- 중간 PR은 `refs #XX`로 연결 (close 안 됨, 참조만)
- **PR 생성 시 `--assignee REPO_OWNER` 포함** — 모든 PR에 REPO_OWNER를 assignee로 지정
- **push 후 PR 상태 확인 필수**: push 후 `gh pr view` 실행. PR이 없거나 이미 머지/닫혔으면 새 PR 생성

## 커밋 습관
- **브리핑 → 컨펌 → 자율 커밋** 흐름이 기본:
  1. 사용자가 작업을 지시하면, 작업량에 따라 브리핑 (이슈 태스크는 무조건 브리핑)
  2. 사용자가 브리핑을 컨펌하면, 그 작업 범위 내에서 덩어리별 자율 커밋/push OK
  3. 브리핑 없이 시작한 작업은 자율 커밋 불가 — 커밋 전 변경 내용 보고 후 승인 받기
- **핵심 판단**: "사용자가 내 작업 방향을 확인한 상태인가?" — 아니면 커밋하지 마라
- **조사/추적 요청과 작업 지시를 구분할 것** — "추적해봐", "찾아봐", "확인해봐"는 조사만 하라는 것이지 코드 변경/커밋하라는 지시가 아님
- **승인 요청은 한번에**: "커밋/push/PR 할까요?" 처럼 맥락에 맞는 범위를 한번에 물어라
- **자율 커밋 모드**(브리핑 컨펌 후)에서는 커밋만 자율. push/PR은 묶어서 확인
- **커밋할 때마다 자문**: "이 작업 내용을 이슈에 기록했나?" — 안 했으면 커밋 전에 이슈 코멘트/본문 업데이트 먼저
- **커밋 시 `.claude/settings.json` 변경사항이 있으면 항상 함께 포함**
- **커밋 전 빌드 테스트** — 앱 코드 변경 시 필수. 문서만 변경하는 커밋은 빌드 불필요

---

## 프로젝트 특화 설정
> 이 섹션은 각 프로젝트에서 채워야 합니다

### 도메인별 기술 가이드
<!-- 예시:
- `src/CLAUDE.md` — 주요 모듈 구조, 빌드 방법
-->

### 빌드 명령
<!-- 예시:
- 변경 시: `cd src && make build`
-->
