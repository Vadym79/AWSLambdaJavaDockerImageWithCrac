#!/bin/bash

/prepare-jdk.cmd-zulu-spring-boot.sh

# Ensure small PID, for privileged-less criu to be able to restore PID by bumping.
# But not too small, to avoid clashes with other occasional processes on restore.
exec    $JAVA_HOME/bin/java \
		-Xshare:off \
		-cp /function:/function/lib/* \
		-Dcom.amazonaws.services.lambda.runtime.api.client.NativeClient.libsBase=/function/lib/ \
		--add-opens java.base/java.util=ALL-UNNAMED \
		com.amazonaws.services.lambda.runtime.api.client.AWSLambda "software.amazonaws.example.product.handler.StreamLambdaHandler::handleRequest"