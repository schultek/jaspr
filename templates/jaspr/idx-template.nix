{ pkgs, mode ? "static", routing ? "none", flutter ? "false", plugins ? "false", ... }: {
  packages = [
    pkgs.dart
    pkgs.flutter
  ];
  bootstrap = ''    
    dart pub global activate jaspr_cli
    jaspr create --mode=${mode} --routing=${routing} \
      --flutter=${if flutter then "embedded" else if plugins then "plugins-only" else none} \
      --backend=none "$WS_NAME"
    chmod -R +w "$WS_NAME"
    mv "$WS_NAME" "$out"
    mkdir -p "$out/.idx/"
    cp -rf ${./dev.nix} "$out/.idx/dev.nix"
  '';
}