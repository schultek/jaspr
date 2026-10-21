---
title: Place @client on the Uppermost Interactive Boundary
impact: HIGH
impactDescription: Avoids redundant hydration boundaries, duplicate markers, and runtime registration overhead
tags: server, client, hydration, architecture
---

## Place @client on the Uppermost Interactive Boundary

**Impact: HIGH (Avoids redundant hydration boundaries, duplicate markers, and runtime registration overhead)**

Annotating a component with `@client` marks it as a hydration boundary. During client hydration, `ClientApp()` locates every `@client` root and initializes hydration for that tree.

When you have a tree of interactive components (e.g. an interactive form containing interactive input fields and buttons), you only need to annotate the **uppermost** component with `@client`. Any child components inside an already hydrated client tree are automatically executed and reactive in the browser without needing `@client` annotations of their own.

**Incorrect (redundant @client annotations on nested children):**

```dart
// Redundant: FormInput and SubmitButton are already inside interactive MyForm
@client
class FormInput extends StatelessComponent { ... }

@client
class SubmitButton extends StatelessComponent { ... }

@client
class MyForm extends StatefulComponent {
  @override
  Component build(BuildContext context) {
    return form([
      FormInput(),
      SubmitButton(),
    ]);
  }
}
```

**Correct (only the root of the interactive island is annotated):**

```dart
// Plain components - executed on client because they are inside MyForm
class FormInput extends StatelessComponent { ... }

class SubmitButton extends StatelessComponent { ... }

// Only the root boundary gets @client
@client
class MyForm extends StatefulComponent {
  @override
  Component build(BuildContext context) {
    return form([
      FormInput(),
      SubmitButton(),
    ]);
  }
}
```
