#!/bin/bash

error() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
}

info() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
}

print_usage() {
  info "$0 - execute JMeter-based testcases"
  info "usage $0 -t <testcase> -p <#parallel threads> -l <#loops>"
  info " "
  info "options:"
  info "-h show brief help"
  info "-t specify testcase w/o suffix .jmx (mandatory)"
  info "-p number of parallel threads (default 1)"
  info "-l number of loops per thread (default 1)"
  info "-r number of requests per minute (default 9999)"
  info "-e specify environment (default local)"
}

testcase=''
threads='1'
loops='1'
custom_parameter=''
environment='local'

if (! docker image inspect jmeter > /dev/null 2>&1); then
  error "Docker image jmeter does not exist"
  error "go to docker and execute ./build.sh first"
  exit 1
fi

while getopts 't:p:l:r:c:e:h' flag; do
  case "${flag}" in
    t) testcase="${OPTARG}" ;;
    p) threads="${OPTARG}" ;;
    l) loops="${OPTARG}" ;;
    r) req_min="${OPTARG}" ;;
    e) environment="${OPTARG}" ;;
    h) print_usage ;exit 9;;
    *) print_usage
       exit 2 ;;
  esac
done

[[ -z "$testcase" ]] && error "testcase not set" && print_usage && exit 3
[[ ! -f ${testcase}.jmx ]] && error "JMX file ${testcase}.jmx not found" && exit 4

[[ ! -f ${environment}.properties ]] && error "file ${environment}.properties not found" && exit 5

while IFS='=' read -r key value
do
  key=$(echo $key | tr '.' '_')
  eval ${key}=\${value} 2> /dev/null
done < "${environment}.properties"

now=$(date +"%Y-%m-%d_%H-%M-%S")
logdir="results/$now"
jmeter_log="$logdir/jmeter.log"
mkdir -p "${logdir}/report"
touch "$jmeter_log"

jmeter_parameter="-t /var/jmeter/${testcase}.jmx \
        -l /var/jmeter/$logdir/${testcase}.jtl \
        -e -o /var/jmeter/$logdir/report \
        -JTHREADS=${threads} \
        -JLOOPS=${loops} \
        -JREQUESTS_PER_MINUTE=${req_min} \
        -JHOST=${host} \
        -JPORT=${port}"

local_docker_mounts="-v $(PWD):/var/jmeter -v $(PWD)/${jmeter_log}:/opt/jmeter/jmeter.log"
docker_command="--rm ${local_docker_mounts} --name jmeter jmeter -n ${jmeter_parameter}"
docker run ${docker_command}

open "${logdir}"/report/index.html
