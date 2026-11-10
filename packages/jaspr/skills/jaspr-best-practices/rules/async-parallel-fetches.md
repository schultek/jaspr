---
title: Use Future.wait for Independent Asynchronous Operations
impact: HIGH
impactDescription: Cuts server response time from the sum of requests to the longest single request
tags: async, performance, concurrency, server
---

## Use Future.wait for Independent Asynchronous Operations

**Impact: HIGH (Cuts server response time from the sum of requests to the longest single request)**

Awaiting multiple independent asynchronous calls in sequence creates an unnecessary server-side waterfall. If operation A takes 100ms and operation B takes 120ms, running them sequentially takes 220ms.

Run independent operations in parallel using `Future.wait` or Dart records with futures so they execute concurrently.

**Incorrect (sequential awaits accumulating latency):**

```dart
class DashboardPage extends AsyncStatelessComponent {
  @override
  Future<Component> build(BuildContext context) async {
    // Sequential: 100ms + 150ms + 80ms = 330ms server delay!
    final user = await api.getUser();
    final notifications = await api.getNotifications();
    final analytics = await api.getAnalytics();

    return div([ ... ]);
  }
}
```

**Correct (concurrent execution with Future.wait):**

```dart
class DashboardPage extends AsyncStatelessComponent {
  @override
  Future<Component> build(BuildContext context) async {
    // Concurrent: runs all three simultaneously (max delay ~150ms):
    final (user, notifications, analytics) = await (
      api.getUser(),
      api.getNotifications(),
      api.getAnalytics(),
    ).wait;

    return div([ ... ]);
  }
}
```
