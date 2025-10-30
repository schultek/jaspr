{ pkgs, ... }: {
  # Which nixpkgs channel to use.
  channel = "unstable";
  # Use https://search.nixos.org/packages to find packages
  packages = [
    pkgs.dart
    pkgs.flutter
  ];
  # Sets environment variables in the workspace
  env = {};
  idx = {
    # Search for the extensions you want on https://open-vsx.org/ and use "publisher.id"
    extensions = [
      "dart-code.dart-code"
      "schultek.jaspr-code"
    ];
    workspace = {
      # Runs when a workspace is first created with this `dev.nix` file
      onCreate = {
        jaspr-create = "./.idx/jaspr-create.sh";

        default.openFiles = [
          "pubspec.yaml"
          "lib/main.dart"
          "web/main.dart"
        ];
      };
      # To run something each time the workspace is (re)started, use the `onStart` hook
    };
    # Enable previews and customize configuration
    previews = {
      enable = true;
      previews = {
        web = {
          command = [
            "jaspr"
            "serve"
            "--port=$PORT"
          ];
          manager = "web";
        };
      };
    };
  };
}