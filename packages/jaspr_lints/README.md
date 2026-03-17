# Jaspr Lints

This package provides lints and code assists for Jaspr projects.

## Setup:

Add `jaspr_lints` as a plugin to your `analysis_options.yaml` file:

```yaml
plugins:
  jaspr_lints:
    version: ^0.6.0
    diagnostics:
      sort_children_last: true
      prefer_html_components: true
      styles_ordering: true
```

After running `dart pub get` you now see additional Jaspr lints 
when invoking code assist on a component function like `div()` or `p()` files.

## Lints

- Prefer HTML components like `div(...)` over `Component.element(tag: 'div', ...)`. **(Fix available)**
- Sort children last in HTML components. **(Fix available)**
- Sort styles properties. **(Fix available)**
- Prefer styles getter over (final) variable. **(Fix available)**

## Code Assists:

- Create `StatelessComponent` / `StatefulComponent` / `InheritedComponent`
- Convert `StatelessComponent` to `StatefulComponent`
- Convert `StatelessComponent` to `AsyncStatelessComponent`
- Remove component from the tree
- Wrap component with `div()` / `section()` / `ul()` or any HTML component
- Wrap component with other component
- Wrap component with `Builder`
- Extract subtree into `StatelessComponent`
- Add styles to HTML component
- Convert import to web-only / server-only import

---

See the full documentation for each lint and code assist [here](https://docs.jaspr.site/api/linting).