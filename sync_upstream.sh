#!/usr/bin/env bash
set -euo pipefail

branch="${1:-master}"
tag_suffix="${2:-domain-fix}"

if ! git remote get-url upstream >/dev/null 2>&1; then
  git remote add upstream https://github.com/IntQuant/noita_entangled_worlds.git
fi

git fetch upstream
git checkout "$branch"

if ! git merge --no-edit "upstream/$branch"; then
  echo "Upstream merge has conflicts. Resolve these files manually:"
  git diff --name-only --diff-filter=U
  exit 1
fi

if git diff --quiet HEAD@{1} HEAD; then
  echo "No upstream changes to push."
  exit 0
fi

git push origin "$branch"

version=$(grep -m1 '^version = ' noita_proxy/Cargo.toml | sed -E 's/version = "([^"]+)"/\1/')
timestamp=$(date -u +%Y%m%d%H%M%S)
tag="v${version}-${tag_suffix}-${timestamp}"

git tag "$tag"
git push origin "$tag"

echo "Pushed $branch and tag $tag. GitHub Actions should start automatically."
