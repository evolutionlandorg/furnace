{ pkgs ? import <nixpkgs> {}
, dappPkgs ? import (pkgs.fetchgit {
    url = "https://github.com/hujw77/dapptools";
    rev = "seth/crab-rc";
    sha256 = "01cj6d6sddynhpyf0lyg2aic8xbksf2xcfcc97290i8kvlxhhcwc";
    fetchSubmodules = true;
  }) {}
}:

dappPkgs.callPackage ./fnc.nix {}
