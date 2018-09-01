#!/bin/bash

for i in {0..3} 
do 
    sudo ./env.sh ./bin/cita setup test2-chain/$i 
done 

for i in {0..3}
do
    sudo ./daemon.sh ./bin/cita start test2-chain/$i
done

