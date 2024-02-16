#!/bin/bash

rawpost() {
        local c=0
        while [ $c -lt 20 ]; do
                curl -XPOST --no-progress-meter -d "$@" http://localhost:8080/2015-03-31/functions/function/invocations && break
                sleep 0.2
                c=$(($c + 1))
        done
}

post() {
        rawpost "{ Records : [ { body : \"${1}\" } ] }"
}

s03_checkpoint() {
        post checkpoint
        sleep 2
        post fini
	docker rm -f crac-checkpoint
}

s03_checkpoint;