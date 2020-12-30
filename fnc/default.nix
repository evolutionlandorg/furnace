{ pkgs ? import <nixpkgs> {}
, dappPkgs ? import (pkgs.fetchgit {
    url = "https://github.com/hujw77/dapptools";
    rev = "seth/0.9.4";
    sha256 = "0c4h1fv81cw3dvlzw1748rv374q6xi3bdn95gv9bzkraqyadvwif";
    fetchSubmodules = true;
  }) {}
}:

dappPkgs.callPackage ./fnc.nix {}
