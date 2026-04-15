#!/usr/bin/env bash
# setup-wiki.sh — Bootstraps a wiki vault with the three-layer structure.
#
# Usage:
#   bash setup-wiki.sh "<base_dir>"                    # single wiki (backward compatible)
#   bash setup-wiki.sh "<base_dir>" "<wiki-name>"      # named wiki (multi-wiki support)
#
# Creates:
#   ~/.wiki/config.json (creates or merges into existing)
#   <base_dir>/raw/{articles,papers,assets}
#   <base_dir>/wiki/{entities,concepts,sources,synthesis}
#   <base_dir>/wiki/index.md
#   <base_dir>/wiki/log.md

set -euo pipefail

BASE_DIR="$1"
WIKI_NAME="${2:-}"

if [ -z "$BASE_DIR" ]; then
  echo "Usage: setup-wiki.sh <base_dir> [<wiki-name>]" >&2
  exit 1
fi

# Expand ~ if present
BASE_DIR="${BASE_DIR/#\~/$HOME}"

# Ensure base_dir is absolute
if [[ "$BASE_DIR" != /* ]]; then
  echo "Error: base_dir must be an absolute path (got: $BASE_DIR)" >&2
  exit 1
fi

# Strip trailing slash
BASE_DIR="${BASE_DIR%/}"

# Create config directory
CONFIG_DIR="$HOME/.wiki"
if [ -L "$CONFIG_DIR" ]; then
  CONFIG_DIR=$(readlink -f "$CONFIG_DIR")
elif [ ! -d "$CONFIG_DIR" ]; then
  mkdir -p "$CONFIG_DIR"
fi

# Create the three-layer structure
# Layer 1: Raw sources (immutable)
mkdir -p "$BASE_DIR/raw/articles"
mkdir -p "$BASE_DIR/raw/papers"
mkdir -p "$BASE_DIR/raw/assets"

# Layer 2: Wiki (LLM-compiled)
mkdir -p "$BASE_DIR/wiki/entities"
mkdir -p "$BASE_DIR/wiki/concepts"
mkdir -p "$BASE_DIR/wiki/sources"
mkdir -p "$BASE_DIR/wiki/synthesis"

# Create index.md if it doesn't exist
if [ ! -f "$BASE_DIR/wiki/index.md" ]; then
  cat > "$BASE_DIR/wiki/index.md" << 'INDEXEOF'
---
date: $(date +%Y-%m-%d)
tags:
  - wiki/index
  - MOC
---

# Wiki Index

## Entities

```dataview
TABLE created, updated
FROM "wiki/entities"
SORT updated DESC
```

## Concepts

```dataview
TABLE created, updated
FROM "wiki/concepts"
SORT updated DESC
```

## Sources

```dataview
TABLE created, updated
FROM "wiki/sources"
SORT created DESC
```

## Synthesis

```dataview
TABLE created, updated
FROM "wiki/synthesis"
SORT created DESC
```

## Recent Activity

See [[log]] for the full changelog.
INDEXEOF
  # Replace the date placeholder
  sed -i '' "s/\$(date +%Y-%m-%d)/$(date +%Y-%m-%d)/" "$BASE_DIR/wiki/index.md" 2>/dev/null || true
fi

# Create log.md if it doesn't exist
if [ ! -f "$BASE_DIR/wiki/log.md" ]; then
  cat > "$BASE_DIR/wiki/log.md" << 'LOGEOF'
---
tags:
  - wiki/log
---

# Wiki Log

Append-only record of all wiki operations.

LOGEOF
fi

# Write config.json
CONFIG_FILE="$HOME/.wiki/config.json"

if [ -n "$WIKI_NAME" ]; then
  # Named wiki — use multi-wiki format, merge into existing config
  if [ -f "$CONFIG_FILE" ]; then
    EXISTING=$(cat "$CONFIG_FILE")
    # Check if already in multi-wiki format
    HAS_WIKIS=$(echo "$EXISTING" | jq -r '.wikis // empty' 2>/dev/null || true)
    if [ -n "$HAS_WIKIS" ]; then
      # Add to existing wikis object
      echo "$EXISTING" | jq --arg name "$WIKI_NAME" --arg path "$BASE_DIR" '.wikis[$name] = $path' > "$CONFIG_FILE"
    else
      # Migrate from single-wiki to multi-wiki format
      OLD_DIR=$(echo "$EXISTING" | jq -r '.base_dir // empty' 2>/dev/null || true)
      if [ -n "$OLD_DIR" ]; then
        # Keep old wiki as "default", add new named wiki
        jq -n --arg old "$OLD_DIR" --arg name "$WIKI_NAME" --arg path "$BASE_DIR" \
          '{"wikis": {"default": $old, ($name): $path}, "default": "default"}' > "$CONFIG_FILE"
      else
        jq -n --arg name "$WIKI_NAME" --arg path "$BASE_DIR" \
          '{"wikis": {($name): $path}, "default": $name}' > "$CONFIG_FILE"
      fi
    fi
  else
    # Fresh config with named wiki
    jq -n --arg name "$WIKI_NAME" --arg path "$BASE_DIR" \
      '{"wikis": {($name): $path}, "default": $name}' > "$CONFIG_FILE"
  fi
else
  # Single wiki — backward compatible format
  printf '{\n  "base_dir": "%s"\n}\n' "$BASE_DIR" > "$CONFIG_FILE"
fi

# Validate JSON
if ! jq empty "$CONFIG_FILE" 2>/dev/null; then
  echo "Error: Failed to write valid JSON to $CONFIG_FILE" >&2
  exit 1
fi

echo "OK"
