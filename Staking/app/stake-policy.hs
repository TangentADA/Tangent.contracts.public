{-# LANGUAGE OverloadedStrings  #-}

module Main
    ( main
    ) where
    
import Control.Exception           (throwIO)
import System.Environment          (getArgs)
import Staking.Validator           (validatorStaking, typedValidatorStaking, addressStaking)
import Plutus.V1.Ledger.Credential as Plutus
import Plutus.V1.Ledger.Crypto     as Plutus
import qualified Ledger            as Plutus
import Staking.Types               as Types
import Staking.Business.Types      as Business
import MainToken                   as Token 
import Ledger                      (Address, PubKeyHash)
import Ledger.Address              (toPubKeyHash)
import Wallet.Emulator.Wallet      (knownWallet, mockWalletAddress)
import SUtils                      (unsafeReadTxOutRef, writeMintingPolicy, writeValidator)

main :: IO ()
main = do
    [file] <- getArgs 
    let p = validatorStaking staking 
    e <- writeValidator file p 
    case e of 
        Left err -> throwIO $ userError $ show err
        Right () -> return ()



staking :: Types.Staking 
staking = Types.Staking
    { Types.nft = Token.mainTokenAC
    , Types.settings  =  stakeSettings
    }

stakeSettings :: Types.StakingSettings
stakeSettings = Types.StakingSettings
    { Types.refWallet  = "1c32757e39092fae02b2956c8336d681a1360a98bf565d605e1906e5"
    , Types.daoWallet  = "5e40b219353092ba3235281766f6f0dcb5fe95693b994ebb31c24a8f" 
    , Types.affWallet  = "e02d051ecedc735ff8273ad0406e7a7358e00ae21cec345b3ed27c94" 
    , Types.opSettings = operationSettings
    }

{-- 
reff :: Address
reff = addr_test1qzqsk4984l3lv8ehdz8mt3lak3afewflxmtrcd72urfwm4guxf6huwgf97hq9v54djpnd45p5ymq4x9l2ewkqhseqmjsrewhaj
      --1c32757e39092fae02b2956c8336d681a1360a98bf565d605e1906e5

dao :: Address
dao = addr_test1qrle0chx0hw70tckaxvu79rk52z25snmlh084re7nrx3le27gzepjdfsj2arydfgzan0duxukhlf26fmn98tkvwzf28sssrx0a
       --5e40b219353092ba3235281766f6f0dcb5fe95693b994ebb31c24a8f

aff :: Address
aff = addr_test1qzex0uf04xx2pnkhdcefmw55hp7asuz6kr4cpclpg6fx0mhq95z3ankuwd0lsfe66pqxu7nntrsq4csuas69k0kj0j2qjnwh9s
    --e02d051ecedc735ff8273ad0406e7a7358e00ae21cec345b3ed27c94
--}

exampleAddr1 :: Address
exampleAddr1 = mockWalletAddress $ knownWallet 1


exampleAddr2 :: Address
exampleAddr2 = mockWalletAddress $ knownWallet 2

exampleAddr3 :: Address
exampleAddr3 = mockWalletAddress $ knownWallet 3

-- | Settings for the staking operations:
--   depositFee : amount of fees paid in the deposit operation (per million)
--   withdrawFee : amount of fees paid in the deposit operation (per million)
--   daoShare : % of fees for DAO program (* 1 million)
--   affShare : % of fees for affiliate network (* 1 million)
--   minDeposit : Minimum valid deposit in micro token
--   minWithdraw : Minimum valid withdraw in micro token
operationSettings:: Business.OperationSettings
operationSettings = Business.OperationSettings
    {
        Business.depositFee  = 10 -- 10000 / 1000000 = 0.01
      , Business.withdrawFee = 10 -- 10000 / 1000000 = 0.01
      , Business.daoShare    = 10
      , Business.affShare    = 10
      , Business.minDeposit  = 10
      , Business.minWithdraw = 10
      , Business.minClaim    = 10
    }

removeMaybe :: Maybe PubKeyHash -> [PubKeyHash]
removeMaybe Nothing = []
removeMaybe (Just i) = [i]

getPKH :: [PubKeyHash] -> PubKeyHash
getPkH [] = []
getPKH [x] = x
getPKH (x:xs) = x 

