---
title: Use Dart Primary Constructors for Concise Component Definitions
impact: LOW-MEDIUM
impactDescription: Eliminates boilerplate constructor and field declarations in component classes
tags: component, syntax, dart, clean-code
---

## Use Dart Primary Constructors for Concise Component Definitions

**Impact: LOW-MEDIUM (Eliminates boilerplate constructor and field declarations in component classes)**

Jaspr natively supports Dart primary constructors for components, including `@client` components and Server Components.

Instead of declaring separate constructor parameters, initializing formals, and field declarations, use primary constructors to keep components concise, legible, and easy to maintain.

**Incorrect (verbose traditional constructor ceremony):**

```dart
@client
class UserAvatar extends StatelessComponent {
  const UserAvatar({
    required this.name,
    required this.imageUrl,
    this.size = 40,
    super.key,
  });

  final String name;
  final String imageUrl;
  final int size;

  @override
  Component build(BuildContext context) {
    return img(src: imageUrl, alt: name, width: size, height: size);
  }
}
```

**Correct (concise component with primary constructor):**

```dart
@client
class UserAvatar({
  required this.name,
  required this.imageUrl,
  this.size = 40,
  super.key,
}) extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    return img(src: imageUrl, alt: name, width: size, height: size);
  }
}
```
