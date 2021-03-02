{ pkgs ? import <nixpkgs> {}
, dappPkgs ? import (pkgs.fetchgit {
    url = "https://github.com/hujw77/dapptools";
    rev = "seth/0.9.5";
    sha256 = "0wabwawdcjs1jxsh1d6zidgp33gypxh2yc611gb6r3q20v42arw0";
    fetchSubmodules = true;
  }) {}
}:

dappPkgs.callPackage ./fnc.nix {}
