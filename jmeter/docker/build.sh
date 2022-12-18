#!/bin/bash

jmeter_version=5.5

docker build -t jmeter --build-arg JMETER_VERSION=${jmeter_version} .

docker tag jmeter jmeter:latest
docker tag jmeter jmeter:${jmeter_version}
