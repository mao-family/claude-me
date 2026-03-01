#!/bin/bash
# Load child project CLAUDE.md when working in workspace/repos/{project}/
# This hook runs on SessionStart and injects project context into Claude's context

set -euo pipefail

CLAUDE_ME_ROOT="${HOME}/Repos/claude-me"
WORKSPACE_REPOS="${CLAUDE_ME_ROOT}/workspace/repos"
MEMORY_BANK="${CLAUDE_ME_ROOT}/workspace/memory-bank"

# JSON escape function
escape_for_json() {
    local input="$1"
    local output=""
    local i char
    for (( i=0; i<${#input}; i++ )); do
        char="${input:$i:1}"
        case "$char" in
            $'\\') output+='\\\' ;;
            '"') output+='\"' ;;
            $'\n') output+='\n' ;;
            $'\r') output+='\r' ;;
            $'\t') output+='\t' ;;
            *) output+="$char" ;;
        esac
    done
    printf '%s' "$output"
}

# Get current working directory
CWD="${PWD}"
CONTEXT=""

# Check if we're inside workspace/repos/{project}/
if [[ "${CWD}" == "${WORKSPACE_REPOS}/"* ]]; then
    # Extract project name (first directory after workspace/repos/)
    RELATIVE_PATH="${CWD#${WORKSPACE_REPOS}/}"
    PROJECT_NAME="${RELATIVE_PATH%%/*}"

    if [[ -n "${PROJECT_NAME}" ]]; then
        PROJECT_CLAUDE_MD="${MEMORY_BANK}/${PROJECT_NAME}/CLAUDE.md"

        if [[ -f "${PROJECT_CLAUDE_MD}" ]]; then
            CONTEXT+="# Project Context: ${PROJECT_NAME}"$'\n\n'
            CONTEXT+="$(cat "${PROJECT_CLAUDE_MD}")"$'\n'
        fi

        # Check for feature branch context
        if command -v git &> /dev/null && git rev-parse --git-dir &> /dev/null 2>&1; then
            BRANCH=$(git branch --show-current 2>/dev/null || echo "")

            if [[ "${BRANCH}" == feature/* ]]; then
                FEATURE_NAME="${BRANCH#feature/}"
                FEATURE_DIR="${MEMORY_BANK}/${PROJECT_NAME}/features/${FEATURE_NAME}"

                if [[ -d "${FEATURE_DIR}" ]]; then
                    CONTEXT+=$'\n'"# Feature Context: ${FEATURE_NAME}"$'\n\n'
                    for md_file in "${FEATURE_DIR}"/*.md; do
                        if [[ -f "${md_file}" ]]; then
                            CONTEXT+="## $(basename "${md_file}")"$'\n\n'
                            CONTEXT+="$(cat "${md_file}")"$'\n\n'
                        fi
                    done
                fi
            fi
        fi
    fi
fi

# Output JSON format required by Claude Code hooks
if [[ -n "${CONTEXT}" ]]; then
    ESCAPED_CONTEXT=$(escape_for_json "${CONTEXT}")
    cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "${ESCAPED_CONTEXT}"
  }
}
EOF
fi

exit 0
