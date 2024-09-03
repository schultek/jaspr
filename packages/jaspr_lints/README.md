# Jaspr Lints

This package provides lints and code assists for jaspr projects.

### Features:
* Create a new StatelessComponent / StatefulComponent / InheritedComponent
* Remove components from the component tree
* Add components tp the component tree
* More to come

### Setup:

* Add `jaspr_lints` as dev dependency:
```shell
dart pub add jaspr_lints --dev
```

* Add the following to your `analysis_options.yaml` file:
```yaml
analyzer:
  plugins:
    - jaspr_lints
```

After running `pub get` you now see additional Jaspr lints when invoking code assist on a component function like `div()` or `p()` files:

![Example screenshot of what Jaspr code assists look like](screenshots/1.png "Jaspr Code Assists")
