# What is this

This will take a folder containing `.nix` files describing haskell projects from a monorepo
and it will generate a dummy package that has as dependencies the union of all their dependencies.

# How to run

1. start shell with `nix-shell -p 'import ./default.nix'`
2. `cd` into directory with monorepo's `.nix` files.
3. `runHaskell <path-to-this-dir>/gen-nix-mono.hs > ../monorepo.nix`

