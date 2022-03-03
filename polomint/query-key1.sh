#!/bin/bash

cardano-cli query utxo \
   $MAGIC \
   --address $(cat testnet/tn.payment-0.address)

