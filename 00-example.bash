#!/bin/bash

source "multiprocess.bash"

concurrency_init

make_heavy() {
  sleep 10
  funcreturn '{"tag": "4.3.1"}'
}

too_much() {
  sleep 10
  funcreturn '{"CVE": "1343-HGt"}'
}

asynchronous() {
  background_execute -j "0" make_heavy
  background_execute -j "1" too_much

  background_read 0
  background_read 1
}

synchronous() {
  funcrun make_heavy
  funcrun too_much
}

main() {
  # time synchronous

  echo
  echo

  time asynchronous
}

main
