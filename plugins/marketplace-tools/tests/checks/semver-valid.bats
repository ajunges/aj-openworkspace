#!/usr/bin/env bats

SCRIPT="$BATS_TEST_DIRNAME/../../scripts/checks/semver-valid.sh"

@test "happy: 1.0.0 válido" {
  run bash "$SCRIPT" "1.0.0" "plugin-x"
  [ "$status" -eq 0 ]
}

@test "happy: 0.4.0 válido" {
  run bash "$SCRIPT" "0.4.0" "plugin-x"
  [ "$status" -eq 0 ]
}

@test "happy: 1.2.3-alpha.1 válido (pre-release)" {
  run bash "$SCRIPT" "1.2.3-alpha.1" "plugin-x"
  [ "$status" -eq 0 ]
}

@test "happy: 1.2.3+build.1 válido (build metadata)" {
  run bash "$SCRIPT" "1.2.3+build.1" "plugin-x"
  [ "$status" -eq 0 ]
}

@test "sad: 1.0 inválido (só dois segmentos) → finding + exit 1" {
  run bash "$SCRIPT" "1.0" "plugin-x"
  [ "$status" -eq 1 ]
  [[ "$output" == *"LOW|semver-invalid|plugin-x|semver-invalid:"* ]]
  [[ "$output" == *"'1.0'"* ]]
}

@test "sad: v1.0.0 inválido (prefixo v) → exit 1" {
  run bash "$SCRIPT" "v1.0.0" "plugin-x"
  [ "$status" -eq 1 ]
}

@test "sad: string vazia → exit 2" {
  run bash "$SCRIPT" "" "plugin-x"
  [ "$status" -eq 2 ]
}

@test "sad: plugin_name faltando → exit 2" {
  run bash "$SCRIPT" "1.0.0"
  [ "$status" -eq 2 ]
}
