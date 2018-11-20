module MatDemo where

main :: IO ()
main = c_matdemo

foreign import ccall unsafe "matdemo" c_matdemo :: IO ()
