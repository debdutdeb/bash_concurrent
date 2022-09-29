#!/bin/bash

source "./multiprocess.bash"

concurrency_init -p "functools_example"

foo() {
  DEBUG "executing foo"
  funcreturn '{"tag": "v12.87.3"}'
}

main() {
  local out="$(funcrun foo)"
  echo "out: $out"
}

main
