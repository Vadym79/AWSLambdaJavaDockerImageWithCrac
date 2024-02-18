#!/bin/bash

[ -d /tmp/sub/jdk ] && exit 0



# ensure umask is consistent between environments
umask 0002

mkdir -p /tmp/sub/jdk/lib/server/
cp $JAVA_HOME/lib/server/libjvm.so /tmp/sub/jdk/lib/server
ln -s -t /tmp/sub/jdk/lib  $JAVA_HOME/lib/* 2>/dev/null
