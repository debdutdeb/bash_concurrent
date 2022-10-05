#!/usr/bin/env bash

shopt -s expand_aliases

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

__do_create_temporary_file() {
  local \
    OPTARG \
    _opt \
    _cmd_args=(mktemp -p "${TMPDIR:-/tmp}")

  OPTIND=1
  while getopts "s:p:" _opt; do
    if [[ "$_opt" == "s" ]]; then
      _cmd_args+=("--suffix=$OPTARG")
      continue
    fi
    if [[ "$_opt" == "p" ]]; then
      _cmd_args+=("${OPTARG}XXXXX")
      continue
    fi
  done

  funcreturn "$("${_cmd_args[@]}")"
}

__create_temporary_file() {
  local _prefix_arg=(${1+-p $1})
  __do_create_temporary_file "${_prefix_arg[@]}"
}

__create_named_pipe() {
  local \
    _file_name \
    _prefix_arg=(${1+-p $1})
  _file_name="$(funcrun __do_create_temporary_file  "${_prefix_arg[@]}" -s ".fifo")"
  rm -f "$_file_name" >&2
  mkfifo "$_file_name"
  funcreturn "$_file_name"
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

__run_on_signal() {
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

__exit_at_failure() {
  # @descrition exit the whole program if this process fails
  local exit_code="$?"

  DEBUG "${__JOB_ID}::${BASHPID}::EXIT_CODE $exit_code"
  [[ "$exit_code" -eq 0 ]] && return

  DEBUG "non-zero exit code detected $exit_code"
  DEBUG "killing all child pids"

  while :; do ((__EXIT_HANDLER_PID_LOCK == 0)) && break; done
  true > "$__EXIT_HANDLER_TRIGGER_FIFO"
}

alias exit_at_failure='DEBUG "registering exit function action for jobid $id pid: $BASHPID"; trap "__exit_at_failure" RETURN EXIT'

__restart_exit_at_failure_handler() {
  __EXIT_HANDLER_PID_LOCK=1

  local pid

  [[ -f "$__EXIT_HANDLER_PID_FILE" ]] && read -r pid < "$__EXIT_HANDLER_PID_FILE"
  if [[ -n "$pid" ]]; then
    DEBUG "existing exit handler running on pid $pid"
    DEBUG "killing exit handler pid $pid"
    kill -SIGTERM "$pid"
  fi

  __do_restart_exit_at_failure_handler() {
    read -r < "$__EXIT_HANDLER_TRIGGER_FIFO" # block until something is written to the pipe
    kill -SIGTERM -- "-$$"
  }

  __do_restart_exit_at_failure_handler &
  pid="$!"

  DEBUG "new exit handler pid $pid"
  printf "%s" "$pid" > "$__EXIT_HANDLER_PID_FILE"

  __EXIT_HANDLER_PID_LOCK=0
}

__cleanup_file_after_exit() {
  local \
    __file \
    __cleanup_funcname
  __file="${1?file required}"
  __cleanup_funcname="__cleanup_$RANDOM"
  eval "${__cleanup_funcname}() { DEBUG 'cleaning up file ${__file}'; rm -f '${__file}'; }"
  __run_on_signal "${__cleanup_funcname}" EXIT SIGINT SIGTERM
}

__cleanup_pipe_after_exit() {
  local \
    id

  id="${1?job id required}"
  __cleanup_file_after_exit "${__pipes["$id"]}"
  __run_on_signal "unset __pipes[$id]" EXIT SIGINT SIGTERM
}

subprocess_popen() {
  local \
    OPTARG \
    OPTIND \
    _opt \
    id \
    _sync_file

  OPTIND=1
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

  __pipes["$id"]="$(funcrun __create_named_pipe "${__PIPE_PREFIX}_$RANDOM")"
  DEBUG "using named pipe for job id $id ${__pipes["$id"]}"

  __cleanup_pipe_after_exit "$id"

  __do() {
    # reset getopts
    OPTIND=1
    DEBUG "starting background task $id"
    printf "%s" "$(funcrun "$@")" > "${__pipes[$id]}"
    DEBUG "background task $id completed"
  }

  sync_file="$(funcrun __create_temporary_file "${__PREFIX}_func_returns")"
  __cleanup_file_after_exit "$sync_file"
  ( 
    __JOB_ID="$id"
    __initialize_synchronous_communication "$sync_file"
    __do "$@"
  ) &
  local subprocess_pid="$!"

  DEBUG "subprocess opened pid $subprocess_pid"

  __restart_exit_at_failure_handler

  funcreturn "$subprocess_pid"
}

subprocess_pread() {
  local \
    id \
    pid

  id="${1?job id required}"

  if ! is "$id" in __pipes; then
    ERROR "unknown background task id $id"
    return
  fi

  __do() {
    DEBUG "reading from pipe ${__pipes["$id"]}"
    funcreturn "$(cat "${__pipes[$id]}")"
  }

  funcrun __do

  DEBUG "flushing job id from memory"
  unset "__pipes[$id]"
}

__initialize_synchronous_communication() {
  # shellcheck disable=2155
  if ! declare -g __func_returns="${1:-$(mktemp "${__PREFIX}"__func_returnsXXXXX -p "${TMPDIR:-/tmp}")}"; then
    FATAL "failed to pipe function output"
    exit 100
  fi

  DEBUG "using file $__func_returns for synchronous communication in pid $BASHPID"

  # __cleanup_file_after_exit "$__func_returns"

  exec 3> "$__func_returns"
  exec 4>&1
}

concurrency_init() {

  local \
    OPTARG \
    OPTIND \
    _opt

  declare -g __PREFIX

  OPTIND=1
  while getopts "p:" _opt; do
    case "$_opt" in
      p)
        __PREFIX="$OPTARG"

        DEBUG "__PREFIX: $__PREFIX"
        ;;
      *) ERROR "unknown option" ;;
    esac
  done

  declare -g __PIPE_PREFIX=

  __PIPE_PREFIX="__${__PREFIX:=bash_$$}_pipe"
  DEBUG "__PIPE_PREFIX: $__PIPE_PREFIX"

  __initialize_synchronous_communication

  declare -xgA __pipes=()

  declare -xg __EXIT_HANDLER_PID=
  declare -xg __EXIT_HANDLER_PID_LOCK=0

  declare -xg __EXIT_HANDLER_SUBPROCESS_ID="__exit_handler_subprocess_id_$RANDOM"
  DEBUG "__EXIT_HANDLER_SUBPROCESS_ID: $__EXIT_HANDLER_SUBPROCESS_ID"
  declare -xg __EXIT_HANDLER_PID_FILE="$(funcrun __do_create_temporary_file -p "${__EXIT_HANDLER_SUBPROCESS_ID}" -s .pid)"
  DEBUG "__EXIT_HANDLER_PID_FILE: $__EXIT_HANDLER_PID_FILE"

  declare -xg __EXIT_HANDLER_TRIGGER_FIFO="$(funcrun __create_named_pipe "${__EXIT_HANDLER_SUBPROCESS_ID}")"
  DEBUG "__EXIT_HANDLER_TRIGGER_FIFO: $__EXIT_HANDLER_TRIGGER_FIFO"

  __cleanup_file_after_exit "$__EXIT_HANDLER_TRIGGER_FIFO"
  __cleanup_file_after_exit "$__EXIT_HANDLER_PID_FILE"
}
