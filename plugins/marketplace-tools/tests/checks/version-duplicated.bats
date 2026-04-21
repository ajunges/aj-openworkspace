#!/usr/bin/env bats

SCRIPT="$BATS_TEST_DIRNAME/../../scripts/checks/version-duplicated.sh"
FIXTURES="$BATS_TEST_DIRNAME/../fixtures"

setup() {
  TMPDIR_TEST=$(mktemp -d)
  mkdir -p "$TMPDIR_TEST/clean-plugin/.claude-plugin"
  cp "$FIXTURES/plugin-without-version.json" "$TMPDIR_TEST/clean-plugin/.claude-plugin/plugin.json"
}

teardown() {
  rm -rf "$TMPDIR_TEST"
}

@test "happy path: plugin sem version em plugin.json passa" {
  mkdir -p "$TMPDIR_TEST/plugin-a/.claude-plugin"
  cp "$FIXTURES/plugin-without-version.json" "$TMPDIR_TEST/plugin-a/.claude-plugin/plugin.json"
  run bash "$SCRIPT" "plugin-a" "$TMPDIR_TEST/plugin-a" "$FIXTURES/marketplace-ok.json"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "sad path: version em ambos → finding MEDIUM + exit 1" {
  mkdir -p "$TMPDIR_TEST/duplicated/.claude-plugin"
  cp "$FIXTURES/plugin-with-version.json" "$TMPDIR_TEST/duplicated/.claude-plugin/plugin.json"
  run bash "$SCRIPT" "duplicated" "$TMPDIR_TEST/duplicated" "$FIXTURES/marketplace-l3-versioned.json"
  [ "$status" -eq 1 ]
  [[ "$output" == *"MEDIUM|3.7|duplicated|version-duplicated:"* ]]
  [[ "$output" == *"plugin.json=1.9.9"* ]]
  [[ "$output" == *"marketplace.json=2.0.0"* ]]
}

@test "edge: plugin.json ausente → exit 0 silencioso" {
  mkdir -p "$TMPDIR_TEST/missing"
  run bash "$SCRIPT" "duplicated" "$TMPDIR_TEST/missing" "$FIXTURES/marketplace-l3-versioned.json"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "edge: plugin não existe no marketplace.json → exit 0 silencioso" {
  run bash "$SCRIPT" "nao-existe" "$TMPDIR_TEST/clean-plugin" "$FIXTURES/marketplace-ok.json"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "edge: args faltando → exit 2" {
  run bash "$SCRIPT" "plugin-a"
  [ "$status" -eq 2 ]
}

@test "edge: marketplace.json inexistente → exit 2" {
  run bash "$SCRIPT" "plugin-a" "$TMPDIR_TEST/clean-plugin" "/nao/existe.json"
  [ "$status" -eq 2 ]
}
