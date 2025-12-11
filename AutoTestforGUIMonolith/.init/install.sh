#!/usr/bin/env bash
set -euo pipefail
# dependencies - python venv and test libs
WORKSPACE="/home/kavia/workspace/code-generation/auto-test-for-gui-2635-2646/AutoTestforGUIMonolith"
mkdir -p "$WORKSPACE"
# Ensure python3 venv support
if ! python3 -m venv --help >/dev/null 2>&1; then echo "python3-venv missing" >&2; exit 40; fi
# Create venv if missing
if [ ! -d "$WORKSPACE/.venv" ]; then python3 -m venv "$WORKSPACE/.venv"; fi
VENV_PIP="$WORKSPACE/.venv/bin/pip"
# Upgrade packaging tools quietly
"$VENV_PIP" install --upgrade pip setuptools wheel >/dev/null
# Prepare package list
PKGS=(robotframework robotframework-seleniumlibrary pytest)
if [ "${DESKTOP_AUTOMATION:-0}" = "1" ]; then PKGS+=(pyautogui); fi
# Install packages
"$VENV_PIP" install --upgrade --quiet "${PKGS[@]}" || { echo "pip install failed" >&2; exit 41; }
# Create robot-wrapper in workspace (atomic install will copy to /usr/local/bin)
cat >"$WORKSPACE/robot-wrapper" <<'BASH'
#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/auto-test-for-gui-2635-2646/AutoTestforGUIMonolith"
exec "$WORKSPACE/.venv/bin/robot" "$@"
BASH
chmod 0755 "$WORKSPACE/robot-wrapper"
# Install wrapper atomically to /usr/local/bin using sudo install
sudo install -m 0755 "$WORKSPACE/robot-wrapper" /usr/local/bin/robot-wrapper
# Write filtered requirements.txt from venv as workspace user
# Use pip freeze and filter relevant packages; ignore failure if grep finds nothing
"$WORKSPACE/.venv/bin/pip" freeze | grep -E '^(robotframework|robotframework-seleniumlibrary|pyautogui|pytest)' > "$WORKSPACE/requirements.txt" || true
# ensure workspace ownership for invoking user (non-root uid/gid)
sudo chown -R "$(id -u):$(id -g)" "$WORKSPACE" || true
# verify installation
if ! command -v robot-wrapper >/dev/null 2>&1; then echo "robot-wrapper not installed" >&2; exit 42; fi
exit 0
