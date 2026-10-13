
{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      forAll = f: nixpkgs.lib.genAttrs
        [ "x86_64-linux" "aarch64-linux" ]
        (system: f nixpkgs.legacyPackages.${system});
    in {
      packages = forAll (pkgs: {
        default = pkgs.gh.overrideAttrs (_: rec {
          version = "2.102.0";
          src = pkgs.fetchFromGitHub {
            owner = "cli";
            repo = "cli";
            rev = "v${version}";
            hash = "sha256-txjOmo46nwRxIutYR/lnFgYEWZpkbWC/ilrMAfTaFZc=";
          };
        });
      });
    };
}
