Readme for setting up PAB as per PPP 


first run $./start-testnet-wallet.sh

wait for 100% sync

then ./load-wallet.sh to connect wallet to previous thing ($./create-wallet.sh if never made before)
make sure walletID in env.sh is same from this ./load-walelt.sh

wait for 100% sync

then $./start-testnet-chain-index.sh

wait for 100% sync

edit start-testnet-pab.sh and change passphrase to whatever passphrase chosen in create-wallet.sh
(Optional: edit testnet/pab-config.yml at very end where it says "pabResumeFrom: ...". Get the tip of your blockchain, and change pointBlockId and pointSlot so PAB starts at most recent block)

then run $./migrate-pab.sh

then run $./start-testnet-pab.sh

wait for sybnc 100%

go to this website http://localhost:9080/swagger/swagger-ui/#/
	go to contact/activate tab
	hit try it out
	hit execute
	copt and pase the Curl command into a file you want to execute as cli command 

run $./get-addres.sh and put one of those addresses into file of env.sh or just copy and address from wallet (Daedalus) into env.sh
