#!/usr/bin/env bash

set_defaults() {
  VERBOSE=false
  INDENT_LEVEL=0
  INDENT_CHAR="│ "
  LAST_INDENT_CHAR="└─"
  BRANCH_INDENT_CHAR="├─"

  GREEN='\033[0;32m'
  RED='\033[0;31m'
  ORANGE='\033[0;38;5;208m'
  BLUE='\033[0;34m'
  GRAY='\033[0;90m'
  CYAN='\033[0;36m'
  YELLOW='\033[0;33m'
  NC='\033[0m'
}

get_indent() {
  local level=${1:-$INDENT_LEVEL}
  local is_last=${2:-false}
  local is_branch=${3:-false}
  local indent=""

  for ((i=0; i<level; i++)); do
    if [[ $i -eq $((level-1)) ]]; then
      if [[ "$is_last" == "true" ]]; then
        indent+="${YELLOW}${LAST_INDENT_CHAR}${NC} "
      elif [[ "$is_branch" == "true" ]]; then
        indent+="${YELLOW}${BRANCH_INDENT_CHAR}${NC} "
      else
        indent+="${CYAN}${INDENT_CHAR}${NC}"
      fi
    else
      indent+="${CYAN}${INDENT_CHAR}${NC}"
    fi
  done

  echo -n "$indent"
}

log() {
  local msg="$1"
  local is_last=${2:-false}
  local is_branch=${3:-false}
  local indent=$(get_indent $INDENT_LEVEL "$is_last" "$is_branch")
  echo -e "${indent}${GREEN}LOG:${NC} $msg"
}

error() {
  local msg="$1"
  local verbose_msg="${2:-$msg}"
  local indent=$(get_indent $INDENT_LEVEL "false" "false")

  if [[ "$VERBOSE" == true && "$verbose_msg" != "$msg" ]]; then
    echo -e "${indent}${RED}ERROR:${NC} $msg\n${indent}${GRAY}       $verbose_msg${NC}"
  else
    echo -e "${indent}${RED}ERROR:${NC} $msg"
  fi
}

warning() {
  local msg="$1"
  local is_last=${2:-false}
  local is_branch=${3:-false}
  local indent=$(get_indent $INDENT_LEVEL "$is_last" "$is_branch")
  echo -e "${indent}${ORANGE}WARNING:${NC} $msg"
}

verbose() {
  if [[ "$VERBOSE" == true ]]; then
    local msg="$1"
    local is_last=${2:-false}
    local is_branch=${3:-false}
    local indent=$(get_indent $INDENT_LEVEL "$is_last" "$is_branch")
    echo -e "${indent}${BLUE}INFO:${NC} $msg"
  fi
}

start_subtask() {
  local task_name="$1"
  local add_log=${2:-true}
  INDENT_LEVEL=$((INDENT_LEVEL + 1))
  if [[ "$add_log" == "true" ]]; then
    log "Starting: $task_name" false true
  fi
  if [[ "$VERBOSE" == "true" ]]; then
    verbose "Task details for: $task_name" true
  fi
  return 0
}

end_subtask() {
  local task_name="$1"
  local add_log=${2:-false}
  if [[ "$add_log" == "true" ]]; then
    log "Completed: $task_name" true
  fi
  if [[ "$VERBOSE" == "true" && "$add_log" == "false" ]]; then
    verbose "Completed: $task_name" true
  fi
  INDENT_LEVEL=$((INDENT_LEVEL - 1))
  return 0
}

set_defaults

for arg in "$@"; do
  case $arg in
    -v|--verbose)
      VERBOSE=true
      shift
      ;;
    *)
      error "Unknown option: $arg" "The option '$arg' is not recognized. Use -v or --verbose for verbose output."
      exit 1
      ;;
  esac
done

if [[ "$(uname -s)" != "Darwin" ]]; then
  error "This script only works on macOS."
  exit 1
fi

if ! command -v brew >/dev/null 2>&1; then
  error "Brew needs to be installed for this script"
  exit 1
fi

start_subtask "Install tmux"
brew install tmux >/dev/null 2>&1
end_subtask "Install tmux" true

