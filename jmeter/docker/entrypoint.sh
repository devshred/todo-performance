#!/bin/bash
# based on https://github.com/justb4/docker-jmeter

info() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
}

set -e
freeMem=`awk '/MemFree/ { print int($2/1024) }' /proc/meminfo`
s=$(($freeMem/10*8))
x=$(($freeMem/10*8))
n=$(($freeMem/10*2))
export JVM_ARGS="-Xmn${n}m -Xms${s}m -Xmx${x}m"

info "external ip-address: $(curl ifconfig.me 2> /dev/null)"
info
info "START Running Jmeter"
info "JVM_ARGS=${JVM_ARGS}"
info "jmeter args=$@"

jmeter $@

info "END Running Jmeter"%
