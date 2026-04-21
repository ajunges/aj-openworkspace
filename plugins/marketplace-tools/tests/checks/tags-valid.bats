#!/usr/bin/env bats

SCRIPT="$BATS_TEST_DIRNAME/../../scripts/checks/tags-valid.sh"
FIXTURES="$BATS_TEST_DIRNAME/../fixtures"

@test "happy path: tags[0]=recomendado → exit 0" {
  run bash "$SCRIPT" "plugin-a" "$FIXTURES/marketplace-ok.json"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "happy path: tags[0]=em-testes → exit 0" {
  run bash "$SCRIPT" "plugin-b" "$FIXTURES/marketplace-ok.json"
  [ "$status" -eq 0 ]
}

@test "sad path: tags[0] inválida → finding + exit 1" {
  run bash "$SCRIPT" "plugin-bad" "$FIXTURES/marketplace-bad-tags.json"
  [ "$status" -eq 1 ]
  [[ "$output" == *"MEDIUM|tag-convention|plugin-bad|tags-valid:"* ]]
  [[ "$output" == *"tag-invalida"* ]]
}

@test "edge: args faltando → exit 2" {
  run bash "$SCRIPT"
  [ "$status" -eq 2 ]
}

@test "edge: plugin não existe no marketplace → exit 1 (tags[0] ausente)" {
  run bash "$SCRIPT" "nao-existe" "$FIXTURES/marketplace-ok.json"
  [ "$status" -eq 1 ]
  [[ "$output" == *"tags[0] ausente"* ]]
}
