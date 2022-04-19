#!/bin/bash

cardano-cli query utxo \
   $MAGIC \
   --address $(cat testnet/t03.addr)

