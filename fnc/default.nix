{ pkgs ? import <nixpkgs> {}
, dappPkgs ? import (pkgs.fetchgit {
    url = "https://github.com/hujw77/dapptools";
    rev = "seth/0.10.3";
    sha256 = "1zr4mjypzx9p1xrj22bprlp6lna3jjg990dqn3g1mh293brj4mig";
    fetchSubmodules = true;
  }) {}
}:

dappPkgs.callPackage ./fnc.nix {}
