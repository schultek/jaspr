---
title: Only Annotate the Root Component of an Interactive Client Island
impact: LOW-MEDIUM
impactDescription: Avoids unnecessary client component registrations and clarifies island boundaries
tags: server, client, hydration, architecture
---

## Only Annotate the Root Component of an Interactive Client Island

**Impact: LOW-MEDIUM (Avoids unnecessary client component registrations and clarifies island boundaries)**

Annotating a component with `@client` registers it as an entrypoint for client-side hydration. When building an interactive feature composed of multiple components, you only need to annotate the root of the interactive island.

While Jaspr automatically suppresses nested `@client` boundaries during hydration when there is no intervening server component, adding `@client` to internal child components that are only ever used inside an existing client island creates unnecessary registration boilerplate.

- For **internal child components** that are only used within a specific client island (e.g. `FormInput` and `SubmitButton` inside `MyForm`), omit `@client`. They are compiled and executed in the browser automatically as part of the parent island.
- For **reusable components** that are also instantiated directly in server components (e.g. a shared `Button` or `Modal`), keep `@client` so they can hydrate independently when used directly from server scope.

**Unnecessary (annotating internal child components used only inside a client island):**

```dart
// Redundant: FormInput and SubmitButton are only used inside MyForm:
@client
class FormInput extends StatelessComponent { ... }

@client
class SubmitButton extends StatelessComponent { ... }

@client
class MyForm extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    return form([
      FormInput(),
      SubmitButton(),
    ]);
  }
}
```

**Correct (only the island root is annotated):**

```dart
// Plain components - executed on client because they are inside MyForm:
class FormInput extends StatelessComponent { ... }

class SubmitButton extends StatelessComponent { ... }

// Only the root boundary gets @client:
@client
class MyForm extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    return form([
      FormInput(),
      SubmitButton(),
    ]);
  }
}
```
