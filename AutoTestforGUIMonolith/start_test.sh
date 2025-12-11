#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/auto-test-for-gui-2635-2646/AutoTestforGUIMonolith"
export DISPLAY="${DISPLAY:-:99}"
export PATH="/usr/local/bin:$PATH"
cd "$WORKSPACE"
BEFORE=$(mktemp)
AFTER=$(mktemp)
trap 'rm -f "$BEFORE" "$AFTER"' EXIT
pgrep -x chromedriver >"$BEFORE" || true
robot-wrapper --outputdir "$WORKSPACE/results" "$WORKSPACE/tests" || true
pgrep -x chromedriver >"$AFTER" || true
comm -13 <(sort "$BEFORE" 2>/dev/null || true) <(sort "$AFTER" 2>/dev/null || true) | tr '\n' ' ' > "$WORKSPACE/.chromedriver_pids" || true
