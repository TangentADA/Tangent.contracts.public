{-# LANGUAGE ImportQualifiedPost #-}
{-# LANGUAGE DataKinds           #-}
{-# LANGUAGE DeriveAnyClass      #-}
{-# LANGUAGE DeriveGeneric       #-}
{-# LANGUAGE FlexibleContexts    #-}
{-# LANGUAGE NoImplicitPrelude   #-}
{-# LANGUAGE OverloadedStrings   #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TemplateHaskell     #-}
{-# LANGUAGE TypeApplications    #-}
{-# LANGUAGE TypeFamilies        #-}
{-# LANGUAGE TypeOperators       #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# OPTIONS_GHC -fno-warn-unused-imports #-}

import Data.Aeson as Json ( encode )
import Data.ByteString.Lazy qualified as LB
import qualified Data.ByteString.Char8       as BS8
import System.Environment ( getArgs )
import Prelude
--import Relude
import Ledger (PaymentPubKeyHash(..), Address, PubKeyHash, POSIXTime(..))
import Ledger.Address              (toPubKeyHash)
import Data.String (fromString) 
import Ledger.Tx.CardanoAPI (fromCardanoAddress, FromCardanoError)
import Data.ByteString.Lazy.UTF8 as BLU
import Staking.Types (StakingDatum, mkPoolDatum, withdrawRedeemer)
import MainToken 
-- import Codec.Binary.Encoding (base16)
-- import Data.Text.Encoding (Base16(..))
import Data.Text (unpack, Text)
import Data.ByteArray.Encoding
import Cardano.Api( scriptDataToJson, ScriptDataJsonSchema(ScriptDataJsonDetailedSchema), deserialiseAddress, AsType(AsAlonzoEra,AsAddressInEra) )
import Cardano.Api.Shelley ( fromPlutusData )
import qualified PlutusTx
import Data.Maybe (fromJust)
import Data.Either (fromRight, fromLeft)
import Data.Time.Clock.POSIX as Time 
import Text.Read 
{--

withdrawRedeemer :: MainToken -> POSIXTime -> Redeemer
withdrawRedeemer mt = Redeemer . PlutusTx.toBuiltinData . Withdraw mt

--}


main :: IO ()
main = do
  currPOSIX' <- Time.getPOSIXTime
  allArgs    <- getArgs
  case allArgs of
    []         ->
      putStrLn "bad arguments."
    amt' : _ -> do 
      let mAmt = readMaybe amt'
          currPOSIX = POSIXTime (round $ currPOSIX' * 1000)
          mRedeem = 
            case mAmt of 
              Nothing -> Nothing 
              Just amt -> Just $ withdrawRedeemer amt currPOSIX
      case mRedeem of
        Nothing ->
          putStrLn "bad main token."
        Just redeem -> do 
          writeData "redeem-withdraw.json" redeem
          putStrLn "Done."
-- Datum also needs to be passed when sending the token to the script (aka putting for sale)
-- When doing this, the datum needs to be hashed.

writeData :: PlutusTx.ToData a => FilePath -> a -> IO ()
writeData file isData = do
  print file
  LB.writeFile file (toJsonString isData)

toJsonString :: PlutusTx.ToData a => a -> LB.ByteString
toJsonString =
  Json.encode
    . scriptDataToJson ScriptDataJsonDetailedSchema
    . fromPlutusData
    . PlutusTx.toData

