#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
cd "$root"

fail() {
  printf 'ai governance violation: %s\n' "$1" >&2
  exit 1
}

require_file() {
  [[ -f "$1" ]] || fail "missing required file: $1"
}

require_file AGENTS.md
require_file CLAUDE.md
require_file CODEX.md
require_file .claude/rules/yadra-repo.md
require_file .cursor/rules/yadra-repo.mdc
require_file .grok/README.md
require_file .windsurfrules
require_file .clinerules
require_file .roo/rules/yadra-repo.md
require_file .github/workflows/ai-governance.yml
require_file README.md
require_file LICENSE
require_file CONTRIBUTING.md
require_file CODE_OF_CONDUCT.md
require_file SECURITY.md
require_file CHANGELOG.md
require_file ROADMAP.md
require_file CODEOWNERS

grep -q 'yadra-nest' AGENTS.md || fail 'AGENTS.md must name yadra-nest'
grep -q '@AGENTS.md' CLAUDE.md || fail 'CLAUDE.md must import AGENTS.md'

for file in CLAUDE.local.md Agents.md Agents.local.md AGENTS.local.md; do
  [[ ! -e "$file" ]] || fail "personal AI file found: $file"
done

if grep -RIn --exclude-dir=.git --exclude=verify-ai-governance.sh 'status\.yarda\.app' AGENTS.md CLAUDE.md CODEX.md .claude .cursor .grok .roo .windsurfrules .clinerules README.md docs 2>/dev/null; then
  fail 'typo domain status.yarda.app found'
fi

if grep -RIn --exclude-dir=.git --exclude=verify-ai-governance.sh 'old desktop code is active\|archive/desktop-legacy/.*active implementation' AGENTS.md README.md docs 2>/dev/null; then
  fail 'legacy desktop described as active implementation'
fi

printf 'ai governance ok\n'
