---
title: Defer Await Until Value is Needed in Conditional Branches
impact: MEDIUM
impactDescription: Avoids paying latency cost when early checks bypass the need for fetched data
tags: async, optimization, early-exit
---

## Defer Await Until Value is Needed in Conditional Branches

**Impact: MEDIUM (Avoids paying latency cost when early checks bypass the need for fetched data)**

Do not await asynchronous values upfront if a simple synchronous condition might render them unnecessary. Check cheap synchronous conditions or cache hits first before awaiting costly asynchronous operations.

**Incorrect (always paying async latency even when not needed):**

```dart
class ProfilePage extends AsyncStatelessComponent {
  const ProfilePage({required this.isLoggedIn, super.key});
  final bool isLoggedIn;

  @override
  Future<Component> build(BuildContext context) async {
    // Awaiting regardless of whether user is logged in!
    final extraDetails = await fetchExtraDetails();

    if (!isLoggedIn) {
      return div([.text('Please log in.')]);
    }

    return div([.text(extraDetails)]);
  }
}
```

**Correct (checking synchronous condition before awaiting):**

```dart
class ProfilePage extends AsyncStatelessComponent {
  const ProfilePage({required this.isLoggedIn, super.key});
  final bool isLoggedIn;

  @override
  Future<Component> build(BuildContext context) async {
    // Fast synchronous exit:
    if (!isLoggedIn) {
      return div([.text('Please log in.')]);
    }

    // Only await when needed:
    final extraDetails = await fetchExtraDetails();
    return div([.text(extraDetails)]);
  }
}
```
