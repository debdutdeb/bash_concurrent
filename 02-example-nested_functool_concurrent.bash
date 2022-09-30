#!/bin/bash

source "./multiprocess.bash"

concurrency_init -p "nested_functool_with_multitasking"

function foo() {
  DEBUG "inside foo"
  funcreturn "foo $$"
}

function bar() {
  DEBUG "inside bar"
  local out=
  out="$(funcrun foo)"
  funcreturn "$out ${FUNCNAME[0]} $$"
}

function baz() {
  sleep 10
  DEBUG "in baz"
  local out=
  out="$(funcrun bar)"
  funcreturn "$out ${FUNCNAME[0]} $$"
}

function main() {
  background_execute -j 0 baz
  background_execute -j 1 baz
  background_execute -j 2 baz
  background_execute -j 3 baz

  background_read 0
  background_read 1
  background_read 2
  background_read 3
}

main
