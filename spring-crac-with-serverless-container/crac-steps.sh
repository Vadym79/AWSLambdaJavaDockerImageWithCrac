#!/bin/bash


dojlink() {
	local JDK=$1
	rm -rf jdk
	$JDK/bin/jlink --bind-services --output jdk --module-path $JDK/jmods --add-modules java.base,jdk.unsupported,java.sql
	# XXX
	cp $JDK/lib/criu jdk/lib/
}



s00_init() {

	#curl -LO https://d1ni2b6xgvw0s0.cloudfront.net/v2.x/dynamodb_local_latest.tar.gz
	#tar axf dynamodb_local_latest.tar.gz


	curl -L -o aws-lambda-rie https://github.com/aws/aws-lambda-runtime-interface-emulator/releases/download/v1.15/aws-lambda-rie-$(uname -m)
	chmod +x aws-lambda-rie

	
	curl -LO https://cdn.azul.com/zulu/bin/zulu21.32.17-ca-crac-jdk21.0.2-linux_x64.tar.gz
	tar axf zulu21.32.17-ca-crac-jdk21.0.2-linux_x64.tar.gz

 	dojlink zulu21.32.17-ca-crac-jdk21.0.2-linux_x64
}

s01_build() {
	mvn clean compile dependency:copy-dependencies -DincludeScope=runtime
	docker build -t crac-lambda-checkpoint-zulu-spring-boot -f Dockerfile-zulu-spring-boot.checkpoint .
}

s02_start_checkpoint() {
   docker run \
   --privileged  \
   --rm \
   --name crac-checkpoint-zulu-spring-boot \
   -e AWS_ENDPOINT_URL_DYNAMODB=http://172.17.0.1:8000 -e PRODUCT_TABLE_NAME=AWSLambdaSpringBoot32Java21DockerImageAndCRaCProductsTable -e AWS_REGION=fake  -e AWS_ACCESS_KEY_ID=fake -e AWS_SECRET_ACCESS_KEY=fake -e AWS_SESSION_TOKEN=fake \
   -v $PWD/aws-lambda-rie:/aws-lambda-rie -v $PWD/cr:/cr \
   -p 8080:8080  \
   crac-lambda-checkpoint-zulu-spring-boot
     
}

rawpost() {
        local c=0
        while [ $c -lt 20 ]; do
                curl -XPOST --no-progress-meter -d "$@" http://localhost:8080/2015-03-31/functions/function/invocations && break
                sleep 0.2
                c=$(($c + 1))
        done
}

post() {
  rawpost '{"resource": "/products/{id}", "path": "/products/0", "httpMethod": "GET", "pathParameters": {"id": "0"}, "requestContext": { "identity": {"apiKey": "blabla"}}}'
}

s03_checkpoint() {
        post checkpoint
        #sleep 2
        #post fini
     	#docker rm -f crac-checkpoint-zulu-spring-boot
}

s04_prepare_restore() {
	sudo rm -f cr/dump4.log # XXX
	docker build -t crac-lambda-restore-zulu-spring-boot -f Dockerfile-zulu-spring-boot.restore .
}


make_cold_local() {
        sync
        echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null
}


local_test() {
	docker run \
		--rm \
		--name crac-test-restre-zulu-spring-boot \
		-v $PWD/aws-lambda-rie:/aws-lambda-rie \
		-p 8080:8080 \
		--expose 8000  \
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

"$@"
