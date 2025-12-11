#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/auto-test-for-gui-2635-2646/AutoTestforGUIMonolith"
cd "$WORKSPACE"
# Run project test runner; do not fail the wrapper if tests fail, but capture result
if [ -x "$WORKSPACE/start_test.sh" ]; then
  "$WORKSPACE/start_test.sh" || true
else
  echo "start_test.sh not executable or missing"
fi
# List results if present
if [ -d "$WORKSPACE/results" ]; then
  echo "RESULTS:"; ls -la "$WORKSPACE/results" || true
else
  echo "no results directory"
fi
