#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/auto-test-for-gui-2635-2646/AutoTestforGUIMonolith"
cd "$WORKSPACE"
# Start demo GUI if present and requested
if [ "${DESKTOP_AUTOMATION:-0}" = "1" ] && [ -f "$WORKSPACE/demo_gui.py" ]; then
  nohup "$WORKSPACE/.venv/bin/python" "$WORKSPACE/demo_gui.py" >/dev/null 2>&1 &
  echo $! > "$WORKSPACE/.demo_gui_pid"
  sleep 1
  echo "demo gui started pid: $(cat "$WORKSPACE/.demo_gui_pid")"
else
  echo "demo gui not started"
fi
