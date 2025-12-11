#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/auto-test-for-gui-2635-2646/AutoTestforGUIMonolith"
cd "$WORKSPACE"
if [ -x "$WORKSPACE/.venv/bin/pytest" ]; then
  "$WORKSPACE/.venv/bin/pytest" -q || true
else
  pytest -q || true
fi
