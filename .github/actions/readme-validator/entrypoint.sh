#!/usr/bin/env bash
set -euo pipefail

# --- Inputs ---
REPO="${INPUT_REPO:-}"
THRESHOLD="${INPUT_THRESHOLD:-6}"

# --- Resolve repo ---
if [ -z "$REPO" ]; then
  REPO="${GITHUB_REPOSITORY}"
fi

if [ -z "$REPO" ]; then
  echo "::error ::No repository specified. Use INPUT_REPO or set GITHUB_REPOSITORY."
  exit 1
fi

# --- Clone repo (read-only) ---
WORKDIR=$(mktemp -d)
git clone "https://github.com/${REPO}.git" "$WORKDIR" 2>/dev/null || {
  echo "::error ::Failed to clone repository: ${REPO}"
  exit 1
}

# --- Read README ---
README="$WORKDIR/README.md"
if [ ! -f "$README" ]; then
  README="$WORKDIR/readme.md"
fi

if [ ! -f "$README" ]; then
  echo "::error ::No README.md found in ${REPO}"
  exit 1
fi

# --- Scoring ---
SCORE=0
MAX_SCORE=10

# 1. Title/description (first line or H1)
TITLE=$(head -1 "$README" | sed 's/^# //' | sed 's/^## //')
if [ -n "$TITLE" ]; then
  SCORE=$((SCORE + 1))
fi

# 2. Badges check (look for common badge patterns)
BADGE_COUNT=$(grep -rohE '!\[.*?\]\(.*?\.(svg|png|gif)(\?.*?)?\)' "$README" 2>/dev/null | wc -l || true)
if [ "$BADGE_COUNT" -ge 1 ]; then
  SCORE=$((SCORE + 1))
fi

# 3. License check
if grep -qiE 'license|mit|apache|gpl' "$README" 2>/dev/null; then
  SCORE=$((SCORE + 1))
fi

# 4. Code of conduct check
if grep -qiE 'code of conduct|conduct' "$README" 2>/dev/null; then
  SCORE=$((SCORE + 1))
fi

# 5. Links check (basic: no empty markdown links)
EMPTY_LINKS=$(grep -cP '\[ \]' "$README" 2>/dev/null || true)
if [ "$EMPTY_LINKS" -eq 0 ]; then
  SCORE=$((SCORE + 1))
fi

# 6. word about contribution or contributing
if grep -qiE 'contributing|contribute' "$README" 2>/dev/null; then
  SCORE=$((SCORE + 1))
fi

# 7. Basic front matter or overview
if head -5 "$README" | grep -qiE 'purpose|description|overview'; then
  SCORE=$((SCORE + 1))
fi

# --- Badge SVG generation ---
# Simple badge: e.g., "Score: 7/10"
BADGE_SVG="<svg xmlns='http://www.w3.org/2000/svg' width='80' height='20' role='img' aria-label='README Score: ${SCORE}/10'><rect width='80' height='20' rx='3' fill='#eeeeee'/><text x='4' y='15' fill='#333333' font-size='11' font-family='DejaVu Sans,Verdana,Geneva,sans-serif'>Score: ${SCORE}/10</text></svg>"

# --- Output ---
echo "score=${SCORE}" >> "$GITHUB_OUTPUT"
echo "badge_svg=${BADGE_SVG}" >> "$GITHUB_OUTPUT"

# --- Cleanup ---
rm -rf "$WORKDIR"

# --- Optional failure ---
if [ "$SCORE" -lt "$THRESHOLD" ]; then
  echo "::warning ::README score ${SCORE}/10 is below threshold ${THRESHOLD}. Consider improving your README."
fi