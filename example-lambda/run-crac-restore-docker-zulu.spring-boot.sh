#!/bin/bash
local_test() {
	docker run \
		--rm \
		--name crac-test-restre-zulu-spring-boot \
		-v $PWD/aws-lambda-rie:/aws-lambda-rie \
		-p 8080:8080 \
		--device-read-bps /dev/loop0:1024 \
		--device-write-bps /dev/loop0:1024 \
		--cpus 1 \
		--entrypoint '' \
		"$@"
}

s05_local_restore() {
	local_test \
		crac-lambda-restore-zulu-spring-boot \
		/aws-lambda-rie /bin/bash /restore.cmd-zulu-spring-boot.sh
}

s05_local_restore