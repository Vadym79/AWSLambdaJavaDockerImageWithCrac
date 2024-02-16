#!/bin/bash

/prepare-jdk.cmd.sh

lz4 -q -d /cr.tar.lz4  - | tar x -C /tmp/

$JAVA_HOME/bin/java -XX:CRaCRestoreFrom=/tmp/cr
