#!/usr/bin/env bash
export JAVA_HOME=/home/runner/jdk25
export PATH=$JAVA_HOME/bin:$PATH
cd pm-backend
exec mvn spring-boot:run \
  -Dspring-boot.run.profiles=dev \
  -Dspring-boot.run.jvmArguments="--enable-native-access=ALL-UNNAMED" \
  -q
