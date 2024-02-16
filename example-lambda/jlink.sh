#!/bin/bash


dojlink() {
	local JDK=./zulu21.32.17-ca-crac-jdk21.0.2-linux_x64
	rm -rf jdk
	$JDK/bin/jlink --bind-services --output jdk --module-path $JDK/jmods --add-modules java.base,jdk.unsupported,java.sql
	# XXX
	cp $JDK/lib/criu jdk/lib/
}

dojlink 