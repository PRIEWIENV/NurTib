#!/bin/bash

sudo ./env.sh ./scripts/create_cita_config.py create \
--chain_name test2-chain \
--jsonrpc_port 2337 \
--ws_port 5337 \
--grpc_port 6000 \
--nodes "127.0.0.1:8000,127.0.0.1:8001,127.0.0.1:8002,127.0.0.1:8003" \
--contract_arguments "SysConfig.chainId=3" "SysConfig.economicalModel=1" \
"ChainManager.parentChainId=2" "ChainManager.parentChainAuthorities=0x17f3487df9f9331969602bf203165abf886a0ed1"

