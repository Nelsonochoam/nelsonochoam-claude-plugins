#!/usr/bin/env bash
# log-append.sh — Append a timestamped entry to wiki/log.md.
#
# Usage:
#   bash log-append.sh <vault> <operation> <title> [source-path]
#
# Arguments:
#   vault        — absolute path to the wiki vault
#   operation    — ingest | query | lint
#   title        — human-readable title (article name, query text, etc.)
#   source-path  — (optional) path to the raw source file ingested
#
# Examples:
#   bash log-append.sh ~/vault ingest "My Article" "raw/articles/my-article.md"
#   bash log-append.sh ~/vault query "What is RAG?"
#   bash log-append.sh ~/vault lint ""

set -euo pipefail

VAULT="${1:-}"
OPERATION="${2:-}"
TITLE="${3:-}"
SOURCE_PATH="${4:-}"

if [[ -z "$VAULT" || -z "$OPERATION" || -z "$TITLE" ]]; then
  echo "Usage: log-append.sh <vault> <operation> <title> [source-path]" >&2
  exit 1
fi

LOG_FILE="$VAULT/wiki/log.md"
DATE=$(date +%Y-%m-%d)

{
  printf "\n## [%s] %s | %s\n" "$DATE" "$OPERATION" "$TITLE"
  if [[ -n "$SOURCE_PATH" ]]; then
    printf "\nSource: %s\n" "$SOURCE_PATH"
  fi
} >> "$LOG_FILE"
