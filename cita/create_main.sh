#!/bin/bash

sudo ./env.sh ./scripts/create_cita_config.py create \
--chain_name test-chain \
--jsonrpc_port 1337 \
--ws_port 4337 \
--grpc_port 5000 \
--nodes "127.0.0.1:4000,127.0.0.1:4001,127.0.0.1:4002,127.0.0.1:4003" \
--contract_arguments "SysConfig.chainId=2" "SysConfig.economicalModel=1"

