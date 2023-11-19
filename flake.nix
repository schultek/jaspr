
{
  description = "Jaspr Flutter Dev Environment";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in
      {
        devShell =
          with pkgs; mkShell rec {
            buildInputs = [
              flutter-unwrapped
              nodejs_20
            ];

            shellHook = ''
              echo "Adding \$HOME/.pub-cache/bin to \$PATH"
              export PATH="$PATH":"$HOME/.pub-cache/bin"
              echo "Activating Jaspr CLI"
              dart pub global activate --source path packages/jaspr_cli/ > /dev/null
              echo "Activating melos ..."
              dart pub global activate melos > /dev/null
            '';
          };
      });
}
