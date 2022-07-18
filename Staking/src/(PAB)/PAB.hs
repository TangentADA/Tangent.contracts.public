{-# LANGUAGE DeriveAnyClass    #-}
{-# LANGUAGE DeriveGeneric     #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeApplications  #-}



module PAB.PAB
    ( Address
    , StakingContracts (..)
    ) where


import           Data.Aeson                          (FromJSON, ToJSON)
--import           Data.OpenApi.Schema                 (ToSchema)
import           Schema                              (ToSchema)
import           GHC.Generics                        (Generic)
import           Ledger                              (Address, PubKeyHash)
import           Plutus.PAB.Effects.Contract.Builtin (Empty, HasDefinitions (..), SomeBuiltin (..), endpointsToSchemas)
import           Prettyprinter                       (Pretty (..), viaShow)
import           Wallet.Emulator.Wallet              (knownWallet, mockWalletAddress)
import           Ledger.Address                      (toPubKeyHash)


import qualified PAB.Monitor                      as Monitor
import qualified Staking.OffChain                 as Stake
import           MainToken                        as Token 
import           Staking.Types                    as Types
import           Staking.Business.Types           as Business

data StakingContracts = SS Types.StakingSettings | S Types.Staking | Monitor Address
    deriving (Eq, Show, Generic, FromJSON, ToJSON, ToSchema)

instance Pretty StakingContracts where
    pretty = viaShow

instance HasDefinitions StakingContracts where

    getDefinitions        = [S exampleStake ]

    --getContract (Monitor addr) =   SomeBuiltin $ Monitor.monitor addr
    getContract (S stk) = SomeBuiltin $ Stake.stakingEndpoints stk
    getContract (S stk) = SomeBuiltin $ Stake.userEndpoints stk    --i feel like this isnt right....

    getSchema = const $ endpointsToSchemas @Stake.StakingSchema


exampleStake :: Types.Staking 
exampleStake = Types.Staking
    { Types.nft = Token.mainTokenAC
    , Types.settings  =  stakeSettings
    }

stakeSettings :: Types.StakingSettings
stakeSettings = Types.StakingSettings
    { Types.refWallet  = getPKH $ removeMaybe $ toPubKeyHash exampleAddr1
    , Types.daoWallet  = getPKH $ removeMaybe $ toPubKeyHash exampleAddr2
    , Types.affWallet  = getPKH $ removeMaybe $ toPubKeyHash exampleAddr3
    , Types.opSettings = operationSettings
    }

exampleAddr1 :: Address
exampleAddr1 = mockWalletAddress $ knownWallet 1

{-- 
exampleAddr1 :: PubKeyHash 
exampleAddr1 = case toPubKeyHash of
    Just value -> mockWalletAddress $ knownWallet 1
    Nothing -> Empty 
--}

exampleAddr2 :: Address
exampleAddr2 = mockWalletAddress $ knownWallet 2

exampleAddr3 :: Address
exampleAddr3 = mockWalletAddress $ knownWallet 3


operationSettings:: Business.OperationSettings
operationSettings = Business.OperationSettings
    {
        Business.depositFee  = 0.01
      , Business.withdrawFee = 0.01
      , Business.daoShare    = 0.01
      , Business.affShare    = 0.01
      , Business.minDeposit  = 0.01
      , Business.minWithdraw = 0.01
      , Business.minClaim    = 0.01
    }

removeMaybe :: Maybe PubKeyHash -> [PubKeyHash]
removeMaybe Nothing = []
removeMaybe (Just i) = [i]

getPKH :: [PubKeyHash] -> PubKeyHash
getPkH [] = []
getPKH [x] = x
getPKH (x:xs) = x 