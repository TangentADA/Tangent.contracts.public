{-# LANGUAGE DeriveAnyClass        #-}
{-# LANGUAGE DerivingStrategies    #-}
{-# LANGUAGE DeriveGeneric         #-}
{-# LANGUAGE NoImplicitPrelude     #-}
{-# LANGUAGE OverloadedStrings     #-}
{-# LANGUAGE RecordWildCards       #-}
{-# LANGUAGE TemplateHaskell       #-}
{-# LANGUAGE DerivingVia           #-}

{-|
Module      : MainToken
Description : Description of the token used by the staking pool.
Copyright   : P2P Solutions Ltd.
License     : GPL-3
Maintainer  : laurynas@adafinance.io
Stability   : develop
-}

module MainToken where

-- GHC libraries.
import           Data.Aeson       (FromJSON, ToJSON)
import           GHC.Generics     (Generic)
import qualified Prelude          as HP (Show (..), Eq (..), Read (..))

-- Third-party libraries.
import           Data.OpenApi.Schema    (ToSchema)
import           Ledger
import           Ledger.Value
import qualified PlutusTx
import           PlutusTx.Prelude

newtype MainToken = MicroToken { getMicroToken :: Integer }
  deriving (HP.Eq, HP.Show, Generic, ToSchema)
  deriving HP.Read via Integer
  deriving anyclass (FromJSON, ToJSON)


-- Boilerplate.
instance Eq MainToken where
    {-# INLINABLE (==) #-}
    am1 == am2 = getMicroToken am1 == getMicroToken am2

mainTokenSymbol :: CurrencySymbol
mainTokenSymbol = "c5594df2e9ce28c3e6416d536f2769399b387292192c2eedb5cc9deb"

mainToken :: TokenName
mainToken = "zPOLO"

mainTokenAC :: AssetClass
mainTokenAC = AssetClass (mainTokenSymbol, mainToken)

{-# INLINABLE mainTokenValue #-}
mainTokenValue :: Integer -> Value
mainTokenValue = assetClassValue mainTokenAC

PlutusTx.unstableMakeIsData ''MainToken
