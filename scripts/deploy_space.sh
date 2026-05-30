#!/usr/bin/env bash
set -euo pipefail

# Deploy backend code from this repository into a dedicated Hugging Face Space clone.
#
# Default assumptions:
# - This script is executed from anywhere.
# - Main repo: .../quran-ai-transcriping
# - Space clone: .../hf-space-ayat_finder (sibling folder)
#
# Usage:
#   scripts/deploy_space.sh
#   scripts/deploy_space.sh --space-dir /abs/path/to/space-clone
#   scripts/deploy_space.sh --message "deploy: backend update"
#   scripts/deploy_space.sh --no-push

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SPACE_DIR="${SPACE_DIR:-"$ROOT_DIR/../hf-space-ayat_finder"}"
COMMIT_MESSAGE="deploy: sync backend from main repo"
PUSH_CHANGES=1

while [[ $# -gt 0 ]]; do
  case "$1" in
    --space-dir)
      SPACE_DIR="$2"
      shift 2
      ;;
    --message)
      COMMIT_MESSAGE="$2"
      shift 2
      ;;
    --no-push)
      PUSH_CHANGES=0
      shift
      ;;
    -h|--help)
      sed -n '1,35p' "$0"
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

if [[ ! -d "$SPACE_DIR/.git" ]]; then
  echo "Space repo not found at: $SPACE_DIR" >&2
  echo "Clone it first:" >&2
  echo "  git clone https://huggingface.co/spaces/<user>/<space> $SPACE_DIR" >&2
  exit 1
fi

if [[ ! -f "$SPACE_DIR/Dockerfile" ]]; then
  echo "Dockerfile missing in Space repo: $SPACE_DIR/Dockerfile" >&2
  echo "The Space deployment bootstrap may be incomplete." >&2
  exit 1
fi

echo "==> Syncing backend files to Space clone"
rsync -av --delete "$ROOT_DIR/app/" "$SPACE_DIR/app/"
rsync -av --delete "$ROOT_DIR/config/" "$SPACE_DIR/config/"
cp "$ROOT_DIR/requirements.txt" "$SPACE_DIR/requirements.txt"

# Ensure runtime directories tracked in git.
mkdir -p "$SPACE_DIR/data/uploads" "$SPACE_DIR/data/results" "$SPACE_DIR/logs"
touch "$SPACE_DIR/data/.gitkeep" \
      "$SPACE_DIR/data/uploads/.gitkeep" \
      "$SPACE_DIR/data/results/.gitkeep" \
      "$SPACE_DIR/logs/.gitkeep"

echo "==> Preparing git commit in Space repo"
git -C "$SPACE_DIR" add app config requirements.txt data logs

if git -C "$SPACE_DIR" diff --cached --quiet; then
  echo "No changes to deploy."
  exit 0
fi

git -C "$SPACE_DIR" commit -m "$COMMIT_MESSAGE"

if [[ "$PUSH_CHANGES" -eq 1 ]]; then
  echo "==> Pushing to Hugging Face Space remote"
  git -C "$SPACE_DIR" push
  echo "Deployment pushed successfully."
else
  echo "Commit created locally (push skipped with --no-push)."
fi

