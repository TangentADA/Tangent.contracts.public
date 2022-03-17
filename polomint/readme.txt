This is a guide on how to use this repository to mint tokens. Of course, the same token that this project minted cannot be minted with the same PolicyID. However, this guide can be helpful for those wishing to mint their own tokens.

Ensure your cardano-cli is connected to cardano node.
	If using Daedalus, type in these commands
		export CARDANO_NODE_SOCKET_PATH=$(ps ax | grep -v grep | grep cardano-wallet | grep testnet | sed -E 's/(.*)node-socket //')
		echo $CARDANO_NODE_SOCKET_PATH
		cardano-cli get-tip --testnet-magic 1097911063
		OR
		cardano-cli get-tip --mainnet

Next, create the vkey and skey for address used to mint tokens. I like to follow this guide for generating these address from seed phrase derived from a wallet made in Daedalus. https://forum.cardano.org/t/create-a-signing-key-from-an-address-in-daedalus-wallet-resolved/66044/3


Next, get into the "main" directory, in this case polomint.

Next, we will edit the env.sh file to ensure it is connected to the node of interest and the correct file path.

Next, edit the 'query-key1.sh' file so that it contains the correct .addr/.address file for your desired address. invoke $./query-key.sh to ensure the address's utxo appears. (you will need the TxHash and TxIx in the next step)

Now, we need to get into a nix-shell and run ($ cabal build)

Next, run the command
	$ cabal exec token-policy -- policy.plutus your_txHash#your_TxIX desired_number_of_tokens desired_token_name
	$ cat policy.plutus  

Next, generate the policy.id for token. 
	$ cardano-cli transaction policyid --script-file policy.plutus > testnet/policy.id

Now we will create the metadata for the token. 
	$ touch token_meta.json
	$ vim token_meta.json
		copy and paste template and alter as needed
			{
      "721": {
        "<policy_id>": {
          "<asset_name>": {
            "name": <string>,
    
            "image": <uri | array>,
            "mediaType": "image/<mime_sub_type>",
    
            "description": <string | array>,
    
            "files": [{
              "name": <string>,
              "mediaType": <mime_type>,
              "src": <uri | array>,
              <other_properties>
            }],
    
            <other properties>
          }
        },
        "version": "1.0"
      }
    }


Finally, use the command $./mint-token-cli.sh your_txHash#your_TxIX desired_number_of_tokens desired_token_name testnet/your.addr testnet/your.skey 

Tokens should mint if everything was done correctly!
