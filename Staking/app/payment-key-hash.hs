module Main
    ( main
    ) where

import System.Environment (getArgs)
import PAB.Utils       (unsafeReadAddress, unsafePaymentPubKeyHash)

main :: IO ()
main = do
    [addr'] <- getArgs
    print $ unsafePaymentPubKeyHash $ unsafeReadAddress addr'
