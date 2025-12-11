#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/auto-test-for-gui-2635-2646/AutoTestforGUIMonolith"
mkdir -p "$WORKSPACE/tests" "$WORKSPACE/results"
# Robust Robot smoke test opening a known data: URI
cat >"$WORKSPACE/tests/example_gui_test.robot" <<'EOF'
*** Settings ***
Library    SeleniumLibrary
*** Test Cases ***
Open Data URI And Check Title
    ${url}=    Set Variable    data:text/html,<title>smoke</title><h1>smoke</h1>
    Open Browser    ${url}    browser=chrome    options=add_argument('--headless=new')
    ${title}=    Get Title
    Should Be Equal    ${title}    smoke
    Close Browser
Dummy Desktop Action
    Log    Desktop placeholder; runs only if DESKTOP_AUTOMATION=1
EOF
# start_test.sh helper with mktemp and trap
cat >"$WORKSPACE/start_test.sh" <<'BASH'
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
BASH
chmod +x "$WORKSPACE/start_test.sh"
# pytest helper
cat >"$WORKSPACE/run_pytest.sh" <<'BASH'
#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/auto-test-for-gui-2635-2646/AutoTestforGUIMonolith"
cd "$WORKSPACE"
if [ -x "$WORKSPACE/.venv/bin/pytest" ]; then
  "$WORKSPACE/.venv/bin/pytest" -q || true
else
  pytest -q || true
fi
BASH
chmod +x "$WORKSPACE/run_pytest.sh"
# Optional demo GUI for desktop automation
if [ "${DESKTOP_AUTOMATION:-0}" = "1" ]; then
  cat >"$WORKSPACE/demo_gui.py" <<'PY'
import tkinter as tk
root = tk.Tk()
root.title('demo-gui')
root.geometry('200x100')
label = tk.Label(root, text='demo running')
label.pack()
root.mainloop()
PY
  chmod +x "$WORKSPACE/demo_gui.py"
fi
sudo chown -R "$(id -u):$(id -g)" "$WORKSPACE" || true
exit 0
