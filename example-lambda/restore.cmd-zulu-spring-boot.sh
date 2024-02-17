#!/bin/bash

/prepare-restore-jdk.cmd-zulu-spring-boot.sh



lz4 -q -d /cr.tar.lz4  - | tar x -C /tmp/

echo "restore part 5"
$JAVA_HOME/bin/java -XX:CRaCRestoreFrom=/tmp/cr
echo "restore part 7"