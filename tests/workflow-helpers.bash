#!/usr/bin/env bash
# Helper functions for workflow tests

# Run claude with timeout and capture output
# Uses gtimeout on macOS (coreutils), timeout on Linux
run_claude() {
  local prompt="$1"
  local timeout_sec="${2:-120}"

  # Find timeout command (gtimeout on macOS, timeout on Linux)
  local timeout_cmd=""
  if command -v gtimeout > /dev/null 2>&1; then
    timeout_cmd="gtimeout"
  elif command -v timeout > /dev/null 2>&1; then
    timeout_cmd="timeout"
  else
    # Fallback: run without timeout
    claude --print "${prompt}" 2>&1
    return
  fi

  "${timeout_cmd}" "${timeout_sec}" claude --print "${prompt}" 2>&1
}

# Assert output contains keyword
assert_contains() {
  local output="$1"
  local keyword="$2"
  if [[ "${output}" != *"${keyword}"* ]]; then
    echo "Expected output to contain: ${keyword}"
    echo "Actual output: ${output}"
    return 1
  fi
}

# Assert output does not contain keyword
assert_not_contains() {
  local output="$1"
  local keyword="$2"
  if [[ "${output}" == *"${keyword}"* ]]; then
    echo "Expected output NOT to contain: ${keyword}"
    echo "Actual output: ${output}"
    return 1
  fi
}

# Assert output contains at least one of the keywords
assert_contains_any() {
  local output="$1"
  shift
  for keyword in "$@"; do
    if [[ "${output}" == *"${keyword}"* ]]; then
      return 0
    fi
  done
  echo "Expected output to contain one of: $*"
  echo "Actual output: ${output}"
  return 1
}

# Setup test project directory
setup_test_project() {
  local name="$1"
  local dir="/tmp/workflow-test-${name}-$$"
  mkdir -p "${dir}"
  cd "${dir}" || return 1
  git init
  echo "# Test Project" > README.md
  git add README.md
  git commit -m "init"
  echo "${dir}"
}

# Cleanup test project
cleanup_test_project() {
  local dir="$1"
  if [[ -d "${dir}" && "${dir}" == /tmp/workflow-test-* ]]; then
    rm -rf "${dir}"
  fi
}

# Check if file exists
assert_file_exists() {
  local path="$1"
  if [[ ! -f "${path}" ]]; then
    echo "Expected file to exist: ${path}"
    return 1
  fi
}

# Check if directory exists
assert_dir_exists() {
  local path="$1"
  if [[ ! -d "${path}" ]]; then
    echo "Expected directory to exist: ${path}"
    return 1
  fi
}

# Check git branch exists
assert_branch_exists() {
  local branch="$1"
  if ! git branch --list "${branch}" | grep -q "${branch}"; then
    echo "Expected branch to exist: ${branch}"
    return 1
  fi
}

# Check worktree exists
assert_worktree_exists() {
  local path="$1"
  if ! git worktree list | grep -q "${path}"; then
    echo "Expected worktree to exist: ${path}"
    return 1
  fi
}
