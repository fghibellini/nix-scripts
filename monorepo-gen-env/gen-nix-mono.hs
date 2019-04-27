
import Language.Nix (Expr(..), Attr(..), ScopedIdent(..), parseNixFile)
import Data.Traversable (traverse, sequenceA)
import Control.Monad (forM, foldM)
import System.Directory (listDirectory)
import Data.List (find, isSuffixOf, nub, intercalate)
import System.Posix.Files (setFileMode, ownerReadMode, ownerWriteMode, ownerExecuteMode, groupReadMode, groupExecuteMode, otherReadMode, otherExecuteMode)
import System.FilePath.Posix (takeBaseName)
import System.Posix.Types (CMode(..))
import Data.Bits ((.|.))
import System.IO (hPutStrLn, stderr)

extractDepList :: String -> Expr -> Maybe [String]
extractDepList depListName (Fun arg bdy) = case bdy of
    Apply mkder args -> case args of
      AttrSet False kvs -> case find (\attr -> case attr of
            (Assign (SIdent [idt]) _) ->  idt == depListName
            _ -> False) kvs of
          Just (Assign _ (List xs)) -> traverse (\x -> case x of
              Ident i -> Just i
              _ -> Nothing) xs
          Nothing -> Just []
    _ -> Nothing
extractDepList _ _ = Nothing

extractAllDeps :: Expr -> Maybe [String]
extractAllDeps ast = concat <$> sequenceA
                    [ extractDepList "libraryHaskellDepends" ast
                    , extractDepList "executableHaskellDepends" ast
                    , extractDepList "testHaskellDepends" ast
                    , extractDepList "benchmarkHaskellDepends" ast
                    ]

main :: IO ()
main = do
  files <- listDirectory "."
  deps <- (nub . concat) <$> (forM files $ \file -> do
              hPutStrLn stderr ("parsing: " ++ file)
              res <- parseNixFile file
              case res of
                Left err -> error (show err)
                Right ast -> case extractAllDeps ast of
                    Nothing -> error "Could not extract deps!"
                    Just deps -> pure deps)
  let projectNames = takeBaseName <$> files
  let allDeps = filter (isRelevantDep projectNames) deps
  let packageDef = intercalate "\n"
       [ "{ mkDerivation, stdEnv, " ++ (intercalate ", " allDeps) ++ " }:"
       , "  mkDerivation {"
       , "  pname = \"monorepo\";"
       , "  version = \"1.0.0\";"
       , "  src = \"./.\";"
       , "  libraryHaskellDepends = [ " ++ (intercalate " " allDeps) ++ " ];"
       , "  license = stdenv.lib.licenses.unfree;"
       , "}"
       ]
  let contents = "let\n  monorepo = " ++ packageDef ++ ";\nin (import ./release.nix).haskellPackages.callPackage monorepo {}"
  putStrLn contents

  where
    isRelevantDep :: [String] -> String -> Bool
    isRelevantDep projectNames = (not . (`elem` (projectNames ++ [ "mkDerivation", "stdEnv" ])))
