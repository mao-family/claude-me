#!/bin/bash
# Check that all lint disables have justification comments
# Exit 1 if any unjustified disables are found

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

cd "${REPO_ROOT}"

errors=0

# Check ShellCheck disables without reason
# Valid: # shellcheck disable=SC1234  # reason here
# Invalid: # shellcheck disable=SC1234
while IFS= read -r line; do
  file=$(echo "${line}" | cut -d: -f1)
  lineno=$(echo "${line}" | cut -d: -f2)
  content=$(echo "${line}" | cut -d: -f3-)

  # Check if there's a comment after the disable
  if ! echo "${content}" | grep -qE 'shellcheck disable=[A-Z0-9,]+\s+#'; then
    echo "❌ ${file}:${lineno}: ShellCheck disable without reason"
    echo "   ${content}"
    echo "   Fix: Add reason comment, e.g., # shellcheck disable=SC1234  # reason"
    errors=$((errors + 1))
  fi
done < <(grep -rn --include="*.sh" --include="*.bats" 'shellcheck disable=' . 2> /dev/null | grep -v 'check-lint-disables.sh' || true)

# Check markdownlint disables without reason
# Valid: <!-- markdownlint-disable MD040 -- reason here -->
# Invalid: <!-- markdownlint-disable MD040 -->
while IFS= read -r line; do
  file=$(echo "${line}" | cut -d: -f1)
  lineno=$(echo "${line}" | cut -d: -f2)
  content=$(echo "${line}" | cut -d: -f3-)

  # Check if there's a reason after --
  if ! echo "${content}" | grep -qE 'markdownlint-disable[^>]+--'; then
    echo "❌ ${file}:${lineno}: markdownlint disable without reason"
    echo "   ${content}"
    echo "   Fix: Add reason, e.g., <!-- markdownlint-disable MD040 -- reason -->"
    errors=$((errors + 1))
  fi
done < <(grep -rn --include="*.md" 'markdownlint-disable' . 2> /dev/null | grep -v 'check-lint-disables.sh' | grep -v 'rules/lint.md' || true)

if [[ ${errors} -gt 0 ]]; then
  echo ""
  echo "Found ${errors} lint disable(s) without justification."
  echo "See rules/lint.md for guidelines."
  exit 1
fi

exit 0
