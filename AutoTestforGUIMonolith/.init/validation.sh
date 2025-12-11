#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/auto-test-for-gui-2635-2646/AutoTestforGUIMonolith"
cd "$WORKSPACE"
[ -f /etc/profile.d/robot_env.sh ] && . /etc/profile.d/robot_env.sh || true
export PATH="/usr/local/bin:$PATH"
export DISPLAY="${DISPLAY:-:99}"
# Print versions and environment
echo "user: $(id -un)"
python3 --version 2>/dev/null || true
if command -v chromium >/dev/null 2>&1; then chromium --version || true
elif command -v chromium-browser >/dev/null 2>&1; then chromium-browser --version || true
else echo "chromium not found"; fi
command -v chromedriver >/dev/null 2>&1 && chromedriver --version || echo "chromedriver not found"
if command -v robot-wrapper >/dev/null 2>&1; then robot-wrapper --version >/dev/null 2>&1 || true; else echo "robot-wrapper not available"; fi
# Optionally start demo GUI
DEMO_PID=""
if [ "${DESKTOP_AUTOMATION:-0}" = "1" ] && [ -f "$WORKSPACE/demo_gui.py" ]; then
  nohup "$WORKSPACE/.venv/bin/python" "$WORKSPACE/demo_gui.py" >/dev/null 2>&1 &
  DEMO_PID=$!
  echo "demo gui pid: $DEMO_PID"
  sleep 1
fi
# Run tests (do not abort validation on test failures)
if [ -x "$WORKSPACE/start_test.sh" ]; then
  "$WORKSPACE/start_test.sh" || true
else
  echo "start_test.sh missing or not executable"
fi
# Evidence
if [ -d "$WORKSPACE/results" ]; then
  echo "RESULTS:"; ls -la "$WORKSPACE/results" || true
else
  echo "no results"
fi
# Cleanup chromedriver pids recorded
if [ -f "$WORKSPACE/.chromedriver_pids" ]; then
  for pid in $(tr -s ' ' '\n' < "$WORKSPACE/.chromedriver_pids" || true); do
    if [ -n "$pid" ] && ps -p "$pid" -o comm= 2>/dev/null | grep -qx "chromedriver"; then
      kill "$pid" 2>/dev/null || kill -9 "$pid" 2>/dev/null || true
      echo "killed chromedriver pid: $pid"
    fi
  done
  rm -f "$WORKSPACE/.chromedriver_pids" || true
fi
# Stop demo GUI if started
if [ -n "${DEMO_PID:-}" ]; then
  kill "$DEMO_PID" 2>/dev/null || true
  echo "stopped demo gui pid: $DEMO_PID"
fi
# final ownership ensure
sudo chown -R "$(id -u):$(id -g)" "$WORKSPACE" || true
exit 0
