#!/usr/bin/env bats

SCRIPT="$BATS_TEST_DIRNAME/../iru/ggshield_audit.sh"
STUBS="$BATS_TEST_DIRNAME/stubs"

setup() {
	FIXTURE_DIR="$(mktemp -d)"
	GGSHIELD_PATH="$FIXTURE_DIR/ggshield"
	_TEST_PATH_OVERRIDE="$STUBS:/usr/bin:/bin:/usr/sbin:/sbin"
	export GGSHIELD_PATH _TEST_PATH_OVERRIDE
}

teardown() {
	rm -rf "$FIXTURE_DIR"
}

write_fixture_binary() {
	cat >"$GGSHIELD_PATH" <<EOF
#!/bin/bash
echo "$1"
EOF
	chmod +x "$GGSHIELD_PATH"
}

@test "fails when ggshield is not installed" {
	run "$SCRIPT"
	[ "$status" -eq 1 ]
	[[ "$output" == *"ggshield is not installed"* ]]
}

@test "fails on Team ID mismatch" {
	write_fixture_binary "ggshield, version 1.35.0"
	STUB_CODESIGN_TEAMID="EVILTEAMID" run "$SCRIPT"
	[ "$status" -eq 1 ]
	[[ "$output" == *"signature Team ID mismatch"* ]]
}

@test "fails when installed version cannot be determined" {
	write_fixture_binary "not a version string"
	run "$SCRIPT"
	[ "$status" -eq 1 ]
	[[ "$output" == *"Could not determine installed ggshield version"* ]]
}

@test "passes but warns when the latest version cannot be reached" {
	write_fixture_binary "ggshield, version 1.35.0"
	STUB_CURL_LATEST_FAIL=1 run "$SCRIPT"
	[ "$status" -eq 0 ]
	[[ "$output" == *"Skipping update check"* ]]
}

@test "fails when the installed version is outdated" {
	write_fixture_binary "ggshield, version 1.34.0"
	STUB_LATEST_VERSION="1.35.0" run "$SCRIPT"
	[ "$status" -eq 1 ]
	[[ "$output" == *"is outdated"* ]]
}

@test "passes when the installed version is up to date" {
	write_fixture_binary "ggshield, version 1.35.0"
	STUB_LATEST_VERSION="1.35.0" run "$SCRIPT"
	[ "$status" -eq 0 ]
	[[ "$output" == *"up to date and properly signed"* ]]
}
