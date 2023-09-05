{ pkgs ? import <nixpkgs> {}
, dappPkgs ? import (pkgs.fetchgit {
    url = "https://github.com/hujw77/dapptools";
    rev = "seth/0.9.6";
    sha256 = "0nvylcs7da6n3rbyvzlnrgajdw453k0a3f32ba37p0gc2wz8y9iy";
    fetchSubmodules = true;
  }) {}
}:

dappPkgs.callPackage ./fnc.nix {}
