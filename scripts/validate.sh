#!/usr/bin/env bash
# Format-check the repo, then validate every module and config and run offline tests.
# No Azure credentials are needed. Usage: scripts/validate.sh [dir ...]
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"

# Only the landing zone is format-checked. PCET-SRE, PCET-SRE-Tests and AppGateway are imported
# snapshots kept as they were written (older Terraform, not fmt-clean) and are not validated here.
terraform fmt -check -recursive -diff modules configs

if [ "$#" -gt 0 ]; then
  dirs=("$@")
else
  dirs=(modules/*/ configs/*/)
fi

# Offline tests (mocked provider). A test file with its own top-level `variables {}` block is
# self-contained and runs once. Any other test file is run once per environments/**/*.tfvars
# file, so every environment file is planned against the config.
run_tests() {
  [ -d tests ] || return 0
  for test_file in tests/*.tftest.hcl; do
    [ -e "$test_file" ] || continue
    if grep -q '^variables {' "$test_file" || [ ! -d environments ]; then
      echo "    test: $test_file"
      terraform test -no-color -filter="$test_file" >"$log" 2>&1 || { cat "$log"; return 1; }
    else
      while read -r var_file; do
        echo "    test: $test_file with $var_file"
        terraform test -no-color -filter="$test_file" -var-file="$var_file" >"$log" 2>&1 || { cat "$log"; return 1; }
      done < <(find environments -name '*.tfvars' | sort)
    fi
  done
}

log="$(mktemp)"
trap 'rm -f "$log"' EXIT

failed=0
for dir in "${dirs[@]}"; do
  dir="${dir%/}"
  ls "$dir"/*.tf >/dev/null 2>&1 || continue
  echo "==> $dir"
  if ! (cd "$dir" &&
    terraform init -backend=false -input=false -no-color >/dev/null &&
    terraform validate -no-color &&
    run_tests); then
    failed=1
  fi
done
exit "$failed"
