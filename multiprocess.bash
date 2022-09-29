#!/usr/bin/env bash

{
  if ! command &> /dev/null -v DEBUG; then
    DEBUG() {
      [[ -n $DEBUG ]] && printf "[DEBUG] %s\n" "$*" >&2
    }
  fi

  if ! command &> /dev/null -v ERROR; then
    ERROR() {
      printf "[ERROR] %s\n" "$*" >&2
    }
  fi
}

funcreturn() {
  echo "$@" >&3
}

funcrun() {
  eval "$*" >&4
  # wish I knew of a better way :/
  tail -1 "$__func_returns"
}

is() {
  [[ $2 == "in" ]] || ERROR "noooo"

  # shellcheck disable=SC2155
  local check="$(printf '%s[%s]' "$3" "$1")"

  [[ -v $check ]]
}

atexit() {
  local command="${1?trap command required}"

  shift

  if (($# == 0)); then
    ERROR "signal required"
    return
  fi

  __trap_command() {
    local __signal="${1?signal required}"
    __extract() {
      local __command="${3}"
      [[ -z "$__command" ]] && return
      printf "%s;" "$__command"
    }
    eval "__extract $(trap -p "$__signal")"
    printf "%s" "$command"
  }

  for sig in "$@"; do
    # shellcheck disable=2064
    trap "$(__trap_command "$sig")" "$sig"
  done
}

background_execute() {
  local \
    OPTARG \
    OPTIND \
    _opt \
    id

  while getopts "j:" _opt; do
    case "$_opt" in
      j)
        id="$OPTARG"

        DEBUG "creating background job with id $id"
        ;;
      *) ERROR "unknown option" ;;
    esac
  done
  shift $((OPTIND - 1))

  if is "$id" in __pipes; then
    ERROR "a background job with id $id already exists"
    return
  fi

  __pipes["$id"]="/tmp/${__PIPE_PREFIX}_$RANDOM"
  mkfifo "${__pipes[$id]}"

  local __cleanup_funcname="__cleanup_$RANDOM"
  eval "${__cleanup_funcname}() { rm -f ${__pipes["$id"]}; }"
  atexit "${__cleanup_funcname}" EXIT SIGINT

  __do() {
    DEBUG "starting background task $id"
    printf "%s" "$(funcrun "$@")" > "${__pipes[$id]}"
    DEBUG "background task $id completed"

    DEBUG "flushing pipe id from memory"
    unset "__pipes[$id]"
  }

  (
    __initialize_synchronous_communication
    __do "$@"
  ) &
}

background_read() {
  local id="${1?job id required}"
  if ! is "$id" in __pipes; then
    ERROR "unknown background task id $id"
    return
  fi

  __do() {
    DEBUG "reading from pipe ${__pipes["$id"]}"
    funcreturn "$(cat "${__pipes[$id]}")"
  }

  funcrun __do
}

__initialize_synchronous_communication() {
  # shellcheck disable=2155
  if ! declare -g __func_returns="$(mktemp -t "${__PREFIX}"__func_returnsXXXXXXXXXX)"; then
    FATAL "failed to pipe function output"
    exit 100
  fi

  DEBUG "using file $__func_returns for synchronous communication in pid $$"

  exec 3> "$__func_returns"
  exec 4>&1
}

concurrency_init() {
  local \
    OPTARG \
    OPTIND \
    _opt

  declare -g __PREFIX

  while getopts "p:" _opt; do
    case "$_opt" in
      p)
        __PREFIX="$OPTARG"

        DEBUG "__PREFIX: $__PREFIX"
        ;;
      *) ERROR "unknown option" ;;
    esac
  done

  declare -gA __pipes=()
  declare -g __PIPE_PREFIX=

  __PIPE_PREFIX="__${__PREFIX:=bash_$$}_pipe"
  DEBUG "__PIPE_PREFIX: $__PIPE_PREFIX"

  __initialize_synchronous_communication
}
