#!/usr/bin/env bash
set -euo pipefail

# Minimal Zoekt installer: relies on an existing Go toolchain and leaves
# the binaries in the Go bin directory (no sudo, no Homebrew copy step).

TOOLS=(
  zoekt
  zoekt-archive-index
  zoekt-dynamic-indexserver
  zoekt-git-clone
  zoekt-git-index
  zoekt-index
  zoekt-indexserver
  zoekt-merge-index
  zoekt-mirror-bitbucket-server
  zoekt-mirror-gerrit
  zoekt-mirror-gitea
  zoekt-mirror-github
  zoekt-mirror-gitiles
  zoekt-mirror-gitlab
  zoekt-repo-index
  zoekt-sourcegraph-indexserver
  zoekt-test
  zoekt-webserver
)

fail() {
  echo "error: $*" >&2
  exit 1
}

have() {
  command -v "$1" >/dev/null 2>&1
}

if ! have go; then
  fail "Go toolchain not found. Install Go (https://go.dev/dl/) and re-run."
fi

version() {
  local raw
  raw="$(go env GOVERSION 2>/dev/null || go version | awk '{print $3}')"
  printf '%s' "${raw#go}"
}

require_go="${REQUIRED_GO_VERSION:-1.23.4}"
current_go="$(version)"

# Simple numeric compare: split on '.' and compare each component.
version_ge() {
  local lhs rhs
  IFS='.' read -r -a lhs <<<"${1:-0}"
  IFS='.' read -r -a rhs <<<"${2:-0}"
  for i in 0 1 2; do
    local l="${lhs[$i]:-0}"
    local r="${rhs[$i]:-0}"
    if (( l > r )); then
      return 0
    elif (( l < r )); then
      return 1
    fi
  done
  return 0
}

if ! version_ge "$current_go" "$require_go"; then
  cat >&2 <<EOF2
error: Zoekt requires Go $require_go or newer.
       Detected Go $current_go. Upgrade Go and re-run this script.
EOF2
  exit 1
fi

version_spec="${ZOEK_VERSION:-latest}"
go_env=(GO111MODULE=on)
if go env GOTOOLCHAIN >/dev/null 2>&1; then
  go_env+=(GOTOOLCHAIN=auto)
fi

printf 'Installing Zoekt tools with go install (%s)...\n' "$version_spec"

for tool in "${TOOLS[@]}"; do
  printf '  -> %s\n' "$tool"
  env "${go_env[@]}" go install "github.com/sourcegraph/zoekt/cmd/${tool}@${version_spec}"
done

hash -r 2>/dev/null || true

gobin="$(GO111MODULE=on go env GOBIN)"
if [ -z "$gobin" ]; then
  gobin="$(GO111MODULE=on go env GOPATH)/bin"
fi

if [ -n "$gobin" ]; then
  printf '\nZoekt binaries installed to %s\n' "$gobin"
  if ! have zoekt; then
    printf 'Add %s to your PATH to start using them.\n' "$gobin"
  fi
fi

printf '\nDone.\n'
