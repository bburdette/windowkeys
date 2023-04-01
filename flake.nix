{
  description = "elm-dev";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pname = "elm-dev";
        pkgs = nixpkgs.legacyPackages."${system}";
      in
        rec {
          inherit pname;
          # `nix build`
          # packages.${pname} = pkgs.stdenv.mkDerivation {
          #   nativeBuildInputs = [ pkgs.makeWrapper ];
          #   name = pname;
          #   src = ./.;
          #   # building the 'out' folder
          #   installPhase = ''
          #     mkdir -p $out/share/zknotes/static
          #     mkdir $out/bin
          #     cp -r $src/server/static $out/share/zknotes
          #     cp ${elm-stuff}/main.js $out/share/zknotes/static
          #     cp -r ${rust-stuff}/bin $out
          #     mv $out/bin/zknotes-server $out/bin/.zknotes-server
          #     makeWrapper $out/bin/.zknotes-server $out/bin/zknotes-server --set ZKNOTES_STATIC_PATH $out/share/zknotes/static;
          #     '';
          # };
          # defaultPackage = packages.${pname};

          # `nix run`
          # apps.${pname} = flake-utils.lib.mkApp {
          #   drv = packages.${pname};
          # };
          # defaultApp = apps.${pname};

          # `nix develop`
          devShell = pkgs.mkShell {
            nativeBuildInputs = with pkgs; [
              # pkgconfig
              elm2nix
              elmPackages.elm
              elmPackages.elm-analyse
              elmPackages.elm-doc-preview
              elmPackages.elm-format
              elmPackages.elm-live
              elmPackages.elm-test
              elmPackages.elm-upgrade
              elmPackages.elm-xref
              elmPackages.elm-language-server
              elmPackages.elm-verify-examples
              elmPackages.elmi-to-json
              elmPackages.elm-optimize-level-2
            ];
          };
        }
    );
}

