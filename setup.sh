#!/usr/bin/env bash

log() {
  green='\033[0;32m'
  nc='\033[0m'
  echo -e "${green}LOG:${nc} $1"
}

error() {
  red='\033[0;31m'
  nc='\033[0m'
  echo -e "${red}ERROR: $1${nc}"
}

warning() {
  orange='\033[0;38;5;208m'
  nc='\033[0m'
  echo -e "${orange}WARNING:${nc} $1"
}

if [[ "$(uname -s)" != "Darwin" ]]; then
  error "This script only works on macOS."
  return 1
fi

if ! command -v brew >/dev/null 2>&1; then
  error "Brew needs to be installed for this script"
  return 1
fi

