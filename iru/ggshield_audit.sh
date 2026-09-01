#!/bin/bash
# ggshield Audit Script for Iru (formerly Kandji)
#
# Checks if ggshield is installed, up to date, and properly signed.
# Exit 0 = pass (installed, up to date, valid signature)
# Exit 1 = fail (not installed, outdated, or invalid signature) -> triggers remediation
#
# Inspired by Installomator (https://github.com/Installomator/Installomator)

# _TEST_PATH_OVERRIDE is read only by the test suite; production runs always
# get the hardcoded value below.
export PATH="${_TEST_PATH_OVERRIDE:-/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin}"

# --- Configuration ---
GGSHIELD_PATH="${GGSHIELD_PATH:-/usr/local/bin/ggshield}"
EXPECTED_TEAM_ID="N67C7J5WQ9" # GitGuardian Inc.

# --- Check if ggshield is installed ---
if [[ ! -x "$GGSHIELD_PATH" ]]; then
	echo "FAIL: ggshield is not installed."
	exit 1
fi

# --- Verify code signature and Team ID ---
teamID=$(codesign -dv "$GGSHIELD_PATH" 2>&1 | awk -F= '/TeamIdentifier/ {print $2}')
if [[ "$teamID" != "$EXPECTED_TEAM_ID" ]]; then
	echo "FAIL: ggshield signature Team ID mismatch. Got '$teamID', expected '$EXPECTED_TEAM_ID'."
	exit 1
fi

# --- Get installed version ---
installedVersion=$("$GGSHIELD_PATH" --version 2>/dev/null | sed 's/[^0-9.]//g')
if [[ -z "$installedVersion" ]]; then
	echo "FAIL: Could not determine installed ggshield version."
	exit 1
fi

# --- Get latest version from GitHub releases ---
latestVersion=$(curl -sLI "https://github.com/GitGuardian/ggshield/releases/latest" |
	grep -i "^location" | tr "/" "\n" | tail -1 | sed 's/[^0-9.]//g')

if [[ -z "$latestVersion" ]]; then
	echo "WARN: Could not determine latest ggshield version. Skipping update check."
	# Pass the audit if we can't reach GitHub - don't break things if offline
	exit 0
fi

echo "Installed: $installedVersion | Latest: $latestVersion | Team ID: $teamID"

if [[ "$installedVersion" == "$latestVersion" ]]; then
	echo "PASS: ggshield is up to date and properly signed."
	exit 0
else
	echo "FAIL: ggshield is outdated ($installedVersion -> $latestVersion)."
	exit 1
fi
