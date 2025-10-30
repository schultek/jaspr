{ pkgs, mode ? "static", routing ? "none", flutter ? false, plugins ? false, ... }: {
  packages = [
    pkgs.dart
    pkgs.flutter
  ];
  bootstrap = ''   
    mkdir -p "$out/.idx/"
    cp -rf ${./dev.nix} "$out/.idx/dev.nix"
    cp -rf ${./jaspr-create.sh} "$out/.idx/jaspr-create.sh"
    chmod +x "$out/.idx/jaspr-create.sh"
    echo "{\"mode\":\"${mode}\",\"routing\":\"${routing}\",\"flutter\":\"${if flutter then "embedded" else if plugins then "plugins-only" else "none"}\",\"backend\":\"none\"}" > "$out/.idx/.jaspr"
  '';
}