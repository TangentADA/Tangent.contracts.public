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
import Ledger (PaymentPubKeyHash(..), Address, PubKeyHash, POSIXTime(..))
import Ledger.Address              (toPubKeyHash)
import Data.String (fromString) 
import Ledger.Tx.CardanoAPI (fromCardanoAddress, FromCardanoError)
import Data.ByteString.Lazy.UTF8 as BLU
import Staking.Types (StakingDatum, mkPoolDatum, mkUserDatum, mkStaking) 
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

{--

mkUserDatum ::
       PubKeyHash
    -> [Deposit]
    -> Maybe POSIXTime
    -> StakingDatum
mkUserDatum pkh dep lc = UserDatum $ mkUserState pkh dep lc

--}

main :: IO ()
main = do
  [addr', amt'] <- getArgs
  currPOSIX' <- Time.getPOSIXTime
  let addr = fromJust $ toPubKeyHash $ fromRight (error "not right") $ fromCardanoAddress $ fromJust $ deserialiseAddress (AsAddressInEra AsAlonzoEra) (Data.String.fromString addr') ---should add bettter error message for maybe failture here in future!!
      amt  = read amt'
      currPOSIX = POSIXTime ( round $ currPOSIX' * 1000)
      datum   = mkUserDatum addr [(currPOSIX, amt)] Nothing 
  print $ show addr
  writeData ("datum-user.json") datum 
  putStrLn "Done"
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

-- writeValidator :: FilePath -> Ledger.Validator -> IO (Either (FileError ()) ())
-- writeValidator file = writeFileTextEnvelope @(PlutusScript PlutusScriptV1) file Nothing . PlutusScriptSerialised . SBS.toShort . LBS.toStrict . serialise . Ledger.unValidatorScript

{-- some error handling code i could use later

data PlutusAddressDesrialisationError =
    DeserialiseAddressError
  | FromCardanoAddressError FromCardanoError

deserialisePlutusAddress :: Text -> Either PlutusAddressDesrialisationError Address
deserialisePlutusAddress addrText =
  case deserialiseAddress addrText of
    Nothing -> Left DeserialiseAddressError
    Just intermediate ->
      case fromCardanoAddress intermediate of
        Left err -> Left (FromCardanoAddressError err)
        Right addr -> Right addr
-}