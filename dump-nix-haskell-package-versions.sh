#!/bin/bash
nix-instantiate --eval --strict --expr 'let pkgs = import <nixpkgs> {}; lib = pkgs.lib; in lib.attrsets.mapAttrsToList (k: v: let r = builtins.tryEval v; err = msg: { attr = k; error = msg; }; in (if r.success then (if builtins.isAttrs r.value then (if builtins.hasAttr "version" r.value then (if builtins.hasAttr "pname" r.value then ({ attr = k; inherit (r.value) pname version; isBroken = (builtins.hasAttr "broken" r.value.meta); })  else  err "<no_name>") else err "<no_version>") else err "<value_not_attrs>") else err "<could_not_eval>")) pkgs.haskell.packages.ghc844' --json | jq
