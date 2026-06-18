#!/usr/bin/env bash

set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

apply_tests_file="${tmp_dir}/terraform-apply-tests.txt"

if grep -R --include='*.tftest.hcl' -nE 'command[[:space:]]*=[[:space:]]*apply' modules >"$apply_tests_file"; then
  if [[ "${ALLOW_TERRAFORM_APPLY_TESTS:-}" != "1" ]]; then
    echo "Refusing to run Terraform apply tests. These can create real resources:" >&2
    cat "$apply_tests_file" >&2
    echo "Remove those tests or set ALLOW_TERRAFORM_APPLY_TESTS=1 to override." >&2
    exit 1
  fi

  echo "WARNING: running Terraform apply tests because ALLOW_TERRAFORM_APPLY_TESTS=1:" >&2
  cat "$apply_tests_file" >&2
fi

declare -A seen_modules=()
module_dirs=()

while IFS= read -r -d '' test_file; do
  test_dir="$(dirname "$test_file")"
  module_dir="$(dirname "$test_dir")"

  if [[ -z "${seen_modules[$module_dir]+x}" ]]; then
    seen_modules["$module_dir"]=1
    module_dirs+=("$module_dir")
  fi
done < <(find modules -path '*/tests/*.tftest.hcl' -print0 | sort -z)

if [[ "${#module_dirs[@]}" -eq 0 ]]; then
  echo "No Terraform tests found under modules/**/tests/*.tftest.hcl"
  exit 0
fi

cpu_count="$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 4)"
default_jobs="$cpu_count"
if (( default_jobs > 4 )); then
  default_jobs=4
fi

max_jobs="${TERRAFORM_TEST_JOBS:-$default_jobs}"
if ! [[ "$max_jobs" =~ ^[0-9]+$ ]] || (( max_jobs < 1 )); then
  echo "TERRAFORM_TEST_JOBS must be a positive integer." >&2
  exit 1
fi

run_module_test() {
  local module_dir="$1"
  local init_status

  echo "==> terraform test ${module_dir}"

  if [[ "${TERRAFORM_TEST_INIT:-0}" == "1" ]]; then
    echo "--> terraform init ${module_dir}"
    terraform -chdir="$module_dir" init -backend=false
    init_status=$?

    if (( init_status != 0 )); then
      return "$init_status"
    fi
  fi

  terraform -chdir="$module_dir" test
}

all_modules=()
all_logs=()
all_status_files=()
all_reported=()
completed_count=0
total_count="${#module_dirs[@]}"

report_completed() {
  local index
  local module_dir
  local status_file
  local status

  for index in "${!all_modules[@]}"; do
    if [[ "${all_reported[$index]}" == "1" ]]; then
      continue
    fi

    module_dir="${all_modules[$index]}"
    status_file="${all_status_files[$index]}"

    if [[ -f "$status_file" ]]; then
      status="$(<"$status_file")"
      completed_count=$((completed_count + 1))

      if [[ "$status" == "0" ]]; then
        printf '[%d/%d] Passed %s ✅\n' "$completed_count" "$total_count" "$module_dir"
      else
        printf '[%d/%d] Failed %s ❌\n' "$completed_count" "$total_count" "$module_dir"
      fi

      all_reported[$index]=1
    fi
  done
}

echo "Queued ${total_count} Terraform module test suite(s) with concurrency ${max_jobs}."

for module_dir in "${module_dirs[@]}"; do
  while (( $(jobs -rp | wc -l) >= max_jobs )); do
    wait -n || true
    report_completed
  done

  log_name="${module_dir//\//__}.log"
  log_file="${tmp_dir}/${log_name}"
  status_file="${tmp_dir}/${log_name}.status"

  all_modules+=("$module_dir")
  all_logs+=("$log_file")
  all_status_files+=("$status_file")
  all_reported+=("0")

  (
    set +e
    run_module_test "$module_dir"
    status=$?
    printf '%s\n' "$status" >"$status_file"
    exit "$status"
  ) >"$log_file" 2>&1 &
done

while (( $(jobs -rp | wc -l) > 0 )); do
  wait -n || true
  report_completed
done

report_completed

failure_count=0
for index in "${!all_modules[@]}"; do
  status_file="${all_status_files[$index]}"

  if [[ -f "$status_file" ]]; then
    status="$(<"$status_file")"
  else
    status=1
  fi

  if [[ "$status" != "0" ]]; then
    failure_count=$((failure_count + 1))
  fi
done

if [[ "${TERRAFORM_TEST_VERBOSE:-0}" == "1" ]]; then
  for index in "${!all_modules[@]}"; do
    echo
    echo "===== ${all_modules[$index]} ====="
    cat "${all_logs[$index]}"
  done
fi

if (( failure_count > 0 )); then
  for index in "${!all_modules[@]}"; do
    status_file="${all_status_files[$index]}"

    if [[ -f "$status_file" ]]; then
      status="$(<"$status_file")"
    else
      status=1
    fi

    if [[ "$status" != "0" ]]; then
      echo
      echo "===== FAILED: ${all_modules[$index]} ====="
      cat "${all_logs[$index]}"
    fi
  done

  exit 1
fi
