#!/bin/bash

pooladdr=$(cat script.addr)
token=c5594df2e9ce28c3e6416d536f2769399b387292192c2eedb5cc9deb.7a504f4c4f

oref=$1
amt=$2
addrFile=$3
skeyFile=$4


echo "oref : $oref" 
echo "pooladdr : $pooladdr" 
echo "amt : $amt" 
echo "address file: $addrFile"
echo "signing key file: $skeyFile"
echo "token: $token"

utxo=$(cardano-cli-balance-fixer utxo-assets -u $oref  $MAGIC )

useraddr=$(cat $addrFile)

ppFile=testnet/protocol-parameters.json
cardano-cli query protocol-parameters $MAGIC --out-file $ppFile

policyFile=testnet/stake.policy
cabal exec stake-policy $policyFile

userDatumFile=datum-user.json 
cabal exec parse-data-user $useraddr $amt 


unsignedFile=testnet/tx.unsigned
signedFile=testnet/tx.signed
v="$amt $token"
starttoken=$(echo $utxo |  sed "s/.*+ //g" | sed s/$token//) 
remainingtoken=$(expr $starttoken - $amt)
rv="$remainingtoken $token"
backuputxo=$(cardano-cli-balance-fixer collateral -a $useraddr $MAGIC)


echo "v :$v"
echo "starttoken : $starttoken" 
echo "remainingtoken : $remainingtoken"


cardano-cli transaction build \
    --babbage-era \
    $MAGIC \
    --tx-in $oref \
    --tx-in $backuputxo \
    --tx-in-collateral $oref \
    --tx-out "$pooladdr + 10000000 lovelace + $v" \
    --tx-out-datum-hash-file  $userDatumFile\
    --tx-out "$useraddr + 2000000 lovelace + $rv" \
    --change-address $useraddr \
    --protocol-params-file $ppFile \
    --out-file $unsignedFile \

cardano-cli transaction sign \
    --tx-body-file $unsignedFile \
    --signing-key-file $skeyFile \
    $MAGIC \
    --out-file $signedFile

cardano-cli transaction submit \
    $MAGIC \
    --tx-file $signedFile
