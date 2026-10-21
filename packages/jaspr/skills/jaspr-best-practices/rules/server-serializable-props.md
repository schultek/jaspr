---
title: Ensure Non-Component Props Across @client Boundaries Are Serializable
impact: CRITICAL
impactDescription: Prevents serialization crashes during SSR and hydration decode errors in the browser
tags: server, client, serialization, codec
---

## Ensure Non-Component Props Across @client Boundaries Are Serializable

**Impact: CRITICAL (Prevents serialization crashes during SSR and hydration decode errors in the browser)**

Data passed from server-rendered components to `@client` components must be serialized into the HTML output on the server and deserialized by the client during hydration.

- Allowed parameter types:
  - Component types: `Component`, `List<Component>` (handled as Server Components).
  - Primitive types: `int`, `double`, `String`, `bool`, `List`, `Map`.
  - Custom classes or Enums: MUST define `@encoder` and `@decoder` methods.
- Parameters MUST NOT be functions, callbacks, or complex unsupported objects.

**Incorrect (passing non-serializable objects or functions to @client components):**

```dart
enum UserRole { admin, user }

class Config {
  final String api;
  Config(this.api);
}

@client
class UserDashboard extends StatelessComponent {
  // CRASH: Config and UserRole have no @encoder/@decoder, and onSelect is a function!
  const UserDashboard({
    required this.config,
    required this.role,
    required this.onSelect,
    super.key,
  });

  final Config config;
  final UserRole role;
  final void Function(int) onSelect;

  @override
  Component build(BuildContext context) => ...;
}
```

**Correct (providing codecs for enums/classes, using primitive callbacks or state):**

```dart
enum UserRole {
  admin,
  user;

  @encoder
  String encode() => name;

  @decoder
  static UserRole decode(String value) => values.byName(value);
}

class Config {
  final String api;
  const Config(this.api);

  @encoder
  Map<String, dynamic> encode() => {'api': api};

  @decoder
  static Config decode(Map<String, dynamic> map) => Config(map['api'] as String);
}

@client
class UserDashboard extends StatelessComponent {
  const UserDashboard({
    required this.config,
    required this.role,
    super.key,
  });

  final Config config;
  final UserRole role;

  @override
  Component build(BuildContext context) => ...;
}
```
