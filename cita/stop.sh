#!/bin/bash

for i in {0..3}
do
    sudo ./env.sh ./bin/cita stop test-chain/$i
    sudo ./env.sh ./bin/cita stop test2-chain/$i
done

