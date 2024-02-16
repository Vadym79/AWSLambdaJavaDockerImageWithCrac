#!/bin/bash

if [ -z "${AWS_LAMBDA_RUNTIME_API}" ]; then
  echo  "variable is there"
else
    echo "variable is not there"
fi

export LD_LIBRARY_PATH="/function"

echo $PATH


# Ensure small PID, for privileged-less criu to be able to restore PID by bumping.
# But not too small, to avoid clashes with other occasional processes on restore.
exec /usr/local/bin/aws-lambda-rie /bin/bash -c '\
	while [ 128 -ge $(cat /proc/sys/kernel/ns_last_pid) ]; do :; done; \
	setsid  $JAVA_HOME/bin/java \
		-Xshare:off \
		-XX:-UsePerfData \
		-XX:CRaCCheckpointTo=/cr \
		-cp "./*" \
		-Dspring.context.checkpoint=onRefresh \
		-Dcom.amazonaws.services.lambda.runtime.api.client.NativeClient.libsBase=./ \
		-Djava.library.path="function/aws-lambda-runtime-interface-client.glibc.so" \
		--add-opens java.base/java.util=ALL-UNNAMED \
		com.amazonaws.services.lambda.runtime.api.client.AWSLambda $0' "$@"
