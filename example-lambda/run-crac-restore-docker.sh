#!/bin/bash
local_test() {
	docker run \
		--rm \
		--name crac-test-zulu \
		-v $PWD/aws-lambda-rie:/aws-lambda-rie \
		-p 8080:8080 \
		--device-read-bps /dev/loop0:1024 \
		--device-write-bps /dev/loop0:1024 \
		--cpus 1 \
		--entrypoint '' \
		--security-opt seccomp=$PWD/seccomp.json \
		"$@"
}

s05_local_restore() {
	local_test \
		crac-lambda-restore \
		/aws-lambda-rie /bin/bash /restore.cmd.sh
}

s05_local_restore