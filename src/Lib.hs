module Lib
  ( main
  )
where

import qualified Language.C.Inline             as C
import           Foreign.Ptr
import           Foreign.C.Types
import           Foreign.Storable
import qualified Data.Vector.Storable          as SV
import           Foreign.Marshal.Alloc

foreign import ccall unsafe "c_main" c_main :: IO ()

foreign import ccall unsafe "hello" cpp_hello :: IO ()

foreign import ccall unsafe "sum_ints" cpp_sumInts :: Ptr CInt -> CInt -> CInt

foreign import ccall unsafe "sum_vector" cpp_sumVector :: Ptr (CVector Double) -> CDouble

main :: IO ()
main = do
  putStrLn "Starts"
  -- c_main
  cpp_hello
  result <- SV.unsafeWith (SV.fromList [1 .. 100])
                          (\ptr -> pure $ cpp_sumInts ptr 100)
  putStrLn $ "sum = " ++ show result

  r2 <- sumVector (SV.fromList [1 .. 256])
  putStrLn $ "sum2 = " ++ show r2
  putStrLn "Ends"

data CVector a = CVector (Ptr a) CSize

ptrSize :: Int
ptrSize = sizeOf nullPtr

cSizeSize :: Int
cSizeSize = sizeOf (0 :: CSize)

instance Storable (CVector a) where
  sizeOf _ = sizeOf (undefined :: Ptr ()) + sizeOf (0 :: CSize)
  alignment _ = 8
  peek ptr = CVector
    <$> peekByteOff ptr 0
    <*> peekByteOff ptr ptrSize
  poke ptr (CVector ar size) = do
    pokeByteOff ptr 0 ar
    pokeByteOff ptr ptrSize size

sumVector :: SV.Vector Double -> IO Double
sumVector xs = unpackCDouble <$> withCVector xs (pure . cpp_sumVector)

unpackCDouble :: CDouble -> Double
unpackCDouble (CDouble x) = x

withCVector :: Storable a => SV.Vector a -> (Ptr (CVector a) -> IO b) -> IO b
withCVector vec op = SV.unsafeWith vec $ \pt -> do
  let cvec = CVector pt (fromIntegral (SV.length vec))
  withStorable cvec op

withStorable :: Storable a => a -> (Ptr a -> IO b) -> IO b
withStorable x f = alloca $ \mem -> do
  poke mem x
  f mem
