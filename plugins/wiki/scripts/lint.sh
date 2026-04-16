#!/usr/bin/env bash
# lint.sh — Structural health checks for a wiki vault.
#
# Usage: bash lint.sh <vault> [--stale-days N]
#
# Output: one finding per line in the format:
#   SEVERITY|check|path|detail
#
# Severity levels: CRITICAL, WARNING, SUGGESTION
#
# Example output:
#   CRITICAL|dead-link|wiki/concepts/foo.md|[[bar]] target not found
#   CRITICAL|missing-frontmatter|wiki/entities/foo.md|missing: type, updated
#   WARNING|orphan|wiki/entities/baz.md|no inbound links
#   WARNING|index-gap|wiki/concepts/qux.md|not listed in index.md
#   WARNING|no-outbound-links|wiki/concepts/qux.md|no wikilinks
#   SUGGESTION|stale|wiki/sources/old.md|last updated: 2025-01-01 (105 days ago)
#   SUGGESTION|empty-section|wiki/concepts/bar.md|## Related

set -euo pipefail

VAULT="${1:-}"
STALE_DAYS=90

shift 2>/dev/null || true
while [[ $# -gt 0 ]]; do
  case "$1" in
    --stale-days) STALE_DAYS="${2:-90}"; shift 2 ;;
    *) shift ;;
  esac
done

if [[ -z "$VAULT" ]]; then
  echo "Usage: lint.sh <vault> [--stale-days N]" >&2
  exit 1
fi

WIKI="$VAULT/wiki"
INDEX="$WIKI/index.md"

if [[ ! -d "$WIKI" ]]; then
  echo "ERROR: wiki directory not found at $WIKI" >&2
  exit 1
fi

# All wiki pages, excluding index and log
mapfile -t ALL_PAGES < <(find "$WIKI" -name "*.md" ! -name "index.md" ! -name "log.md" -type f | sort)

if [[ ${#ALL_PAGES[@]} -eq 0 ]]; then
  echo "INFO|empty|wiki/|no pages found"
  exit 0
fi

# ── 1. Dead links ─────────────────────────────────────────────────────────────
for page in "${ALL_PAGES[@]}"; do
  rel="${page#"$VAULT/"}"
  while IFS= read -r raw_link; do
    # Strip display text: [[target|display]] → target
    target="${raw_link%%|*}"
    target="${target#\[\[}"
    target="${target%%\]\]}"
    target="$(echo "$target" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
    [[ -z "$target" ]] && continue
    target_file="$WIKI/${target}.md"
    if [[ ! -f "$target_file" ]]; then
      echo "CRITICAL|dead-link|${rel}|[[${target}]] target not found"
    fi
  done < <(grep -o '\[\[[^]]*\]\]' "$page" 2>/dev/null || true)
done

# ── 2. Missing frontmatter ────────────────────────────────────────────────────
for page in "${ALL_PAGES[@]}"; do
  rel="${page#"$VAULT/"}"
  missing=()
  for field in type created updated; do
    if ! grep -q "^${field}:" "$page" 2>/dev/null; then
      missing+=("$field")
    fi
  done
  if [[ ${#missing[@]} -gt 0 ]]; then
    joined=$(IFS=', '; echo "${missing[*]}")
    echo "CRITICAL|missing-frontmatter|${rel}|missing: ${joined}"
  fi
done

# ── 3. Orphan pages (no inbound links from other pages) ───────────────────────
# Build inbound-link counts
declare -A INBOUND
for page in "${ALL_PAGES[@]}"; do
  INBOUND["$page"]="0"
done

for page in "${ALL_PAGES[@]}"; do
  while IFS= read -r raw_link; do
    target="${raw_link%%|*}"
    target="${target#\[\[}"
    target="${target%%\]\]}"
    target="$(echo "$target" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
    [[ -z "$target" ]] && continue
    target_file="$WIKI/${target}.md"
    if [[ -f "$target_file" ]]; then
      INBOUND["$target_file"]=$(( ${INBOUND["$target_file"]:-0} + 1 ))
    fi
  done < <(grep -o '\[\[[^]]*\]\]' "$page" 2>/dev/null || true)
done

for page in "${ALL_PAGES[@]}"; do
  if [[ "${INBOUND[$page]:-0}" -eq 0 ]]; then
    rel="${page#"$VAULT/"}"
    echo "WARNING|orphan|${rel}|no inbound links"
  fi
done

# ── 4. No outbound links ──────────────────────────────────────────────────────
for page in "${ALL_PAGES[@]}"; do
  rel="${page#"$VAULT/"}"
  if ! grep -q '\[\[' "$page" 2>/dev/null; then
    echo "WARNING|no-outbound-links|${rel}|no wikilinks to other pages"
  fi
done

# ── 5. Index gaps ─────────────────────────────────────────────────────────────
if [[ -f "$INDEX" ]]; then
  for page in "${ALL_PAGES[@]}"; do
    rel="${page#"$WIKI/"}"
    slug="${rel%.md}"
    # Check if slug appears anywhere in the index (as a wikilink target)
    if ! grep -qF "$slug" "$INDEX" 2>/dev/null; then
      echo "WARNING|index-gap|wiki/${rel}|not listed in index.md"
    fi
  done
fi

# ── 6. Stale pages ────────────────────────────────────────────────────────────
TODAY_EPOCH=$(date +%s)
for page in "${ALL_PAGES[@]}"; do
  rel="${page#"$VAULT/"}"
  updated=$(grep "^updated:" "$page" 2>/dev/null | head -1 | sed 's/updated:[[:space:]]*//')
  [[ -z "$updated" ]] && continue
  # macOS and Linux compatible date parsing
  updated_epoch=$(date -d "$updated" +%s 2>/dev/null \
    || date -j -f "%Y-%m-%d" "$updated" +%s 2>/dev/null \
    || echo "")
  [[ -z "$updated_epoch" ]] && continue
  age=$(( (TODAY_EPOCH - updated_epoch) / 86400 ))
  if [[ "$age" -gt "$STALE_DAYS" ]]; then
    echo "SUGGESTION|stale|${rel}|last updated: ${updated} (${age} days ago)"
  fi
done

# ── 7. Empty sections ─────────────────────────────────────────────────────────
for page in "${ALL_PAGES[@]}"; do
  rel="${page#"$VAULT/"}"
  prev_heading=""
  has_content=false
  while IFS= read -r line; do
    if [[ "$line" =~ ^#{1,6}[[:space:]] ]]; then
      if [[ -n "$prev_heading" && "$has_content" == false ]]; then
        echo "SUGGESTION|empty-section|${rel}|${prev_heading}"
      fi
      prev_heading="$line"
      has_content=false
    elif [[ -n "${line// /}" && ! "$line" =~ ^[[:space:]]*$ ]]; then
      has_content=true
    fi
  done < "$page"
  # Check last section
  if [[ -n "$prev_heading" && "$has_content" == false ]]; then
    echo "SUGGESTION|empty-section|${rel}|${prev_heading}"
  fi
done
