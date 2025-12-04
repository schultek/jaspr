# Jaspr Lints

This package provides lints and code assists for Jaspr projects.

## Code Assists:

- Create `StatelessComponent` / `StatefulComponent` / `InheritedComponent`
- Convert `StatelessComponent` to `StatefulComponent`
- Convert `StatelessComponent` to `AsyncStatelessComponent`
- Remove component from the tree
- Wrap component with `div()` / `section()` / `ul()` or any html component
- Wrap component with other component
- Wrap component with `Builder`
- Extract subtree into `StatelessComponent`
- Add styles to html component
- Convert import to web-only / server-only import

## Lints

- Prefer html methods like `div(...)` over `DomComponent(tag: 'div', ...)`. **(Fix available)**
- Sort children properties last in html component methods. **(Fix available)**
- Sort styles properties. **(Fix available)**
- Prefer styles getter over (final) variable. **(Fix available)**

## Setup:

* Add `jaspr_lints` as a plugin to your `analysis_options.yaml` file:
```yaml
plugins:
  jaspr_lints:
    diagnostics:
      sort_children_last: true
      prefer_html_components: true
      styles_ordering: true
```

After running `dart pub get` you now see additional Jaspr lints 
when invoking code assist on a component function like `div()` or `p()` files.

## Usage

Unfortunately, running `dart analyze` does not pick up the custom lints. 
Instead, you need to run a separate command for this: `jaspr analyze`

Also enabling / disabling specific lint rules works slightly different.
In `analysis_options.yaml` add the following section:

```yaml
custom_lint:
  rules:
    prefer_html_methods: true
    sort_children_properties_last: true
    styles_ordering: true
    prefer_styles_getter: true
```
