let
    nixpkgs = import <nixpkgs> {};

    language-nix = { mkDerivation, base, containers, doctest, fetchgit, hspec, HUnit
        , mtl, parsec, QuickCheck, stdenv, transformers
        , transformers-compat, filepath
        }:
        mkDerivation {
          pname = "language-nix";
          version = "1.0.1";
          src = ../../language-nix;
          isLibrary = true;
          isExecutable = true;
          libraryHaskellDepends = [
            base containers mtl parsec QuickCheck transformers
            transformers-compat filepath
          ];
          executableHaskellDepends = [
            base containers mtl parsec QuickCheck transformers
            transformers-compat
          ];
          testHaskellDepends = [
            base containers doctest hspec HUnit mtl parsec QuickCheck
            transformers transformers-compat
          ];
          homepage = "https://github.com/peti/language-nix";
          description = "Data types and useful functions to represent and manipulate the Nix language";
          license = stdenv.lib.licenses.bsd3;
      };

in
    nixpkgs.haskellPackages.ghcWithPackages (pkgs: [(pkgs.callPackage language-nix {}) pkgs.text])
