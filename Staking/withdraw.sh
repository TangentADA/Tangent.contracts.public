#!/bin/bash

pooladdr=$(cat script.addr)
token=c5594df2e9ce28c3e6416d536f2769399b387292192c2eedb5cc9deb.7a504f4c4f
reff=addr_test1qzqsk4984l3lv8ehdz8mt3lak3afewflxmtrcd72urfwm4guxf6huwgf97hq9v54djpnd45p5ymq4x9l2ewkqhseqmjsrewhaj
dao=addr_test1qrle0chx0hw70tckaxvu79rk52z25snmlh084re7nrx3le27gzepjdfsj2arydfgzan0duxukhlf26fmn98tkvwzf28sssrx0a
aff=addr_test1qzex0uf04xx2pnkhdcefmw55hp7asuz6kr4cpclpg6fx0mhq95z3ankuwd0lsfe66pqxu7nntrsq4csuas69k0kj0j2qjnwh9s

orefpool=$1
amt=$2
addrFile=$3
skeyFile=$4


echo "orefpool : $orefpool" 
echo "amt : $amt" 
echo "address file: $addrFile"
echo "signing key file: $skeyFile"
echo "token: $token"

useraddr=$(cat $addrFile)
ppFile=testnet/protocol-parameters.json
policyFile=stake.policy
userDatumFile=datum-user.json 
unsignedFile=testnet/tx.unsigned
signedFile=testnet/tx.signed

orefuser=$(cardano-cli-balance-fixer collateral -a $useraddr $MAGIC)
echo "orefuser: $orefuser" 

amt2=$(expr $amt - 30)
echo "amt2=$amt2"

v="$amt2 $token"
vreff="10 $token"
vdao="10 $token"
vaff="10 $token"


cabal exec redeemer-withdraw $amt
redeemer=redeemer-withdraw.json


#echo --tx-out $useraddr+2000000+$v

cardano-cli transaction build \
    --babbage-era \
    $MAGIC \
    --tx-in $orefpool \
    --tx-in-script-file  $policyFile \
    --tx-in-datum-file datum-user.json \
    --tx-in-redeemer-file redeem-withdraw.json \
    --required-signer $skeyFile \
    --tx-in-collateral $orefuser \
    --change-address $useraddr \
    --tx-out "$useraddr + 2000000 lovelace +$v" \
    --tx-out "$reff + 2000000 lovelace" \
    --tx-out "$dao + 2000000 lovelace " \
    --tx-out "$aff + 2000000 lovelace" \
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
