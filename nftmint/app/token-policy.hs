module Main
    ( main
    ) where

import Control.Exception    (throwIO)
import Data.String          (IsString (..))
import System.Environment   (getArgs)
import NFT                  (tokenPolicy)
import Utils                (writeMintingPolicy)


main :: IO ()
main = do
    [file, dl', amt', tn'] <- getArgs
    let amt  = read amt'
        dl   = fromInteger (read dl') 
        tn   = fromString tn'
        p    = tokenPolicy dl tn amt
    e <- writeMintingPolicy file p
    case e of
        Left err -> throwIO $ userError $ show err
        Right () -> return ()
