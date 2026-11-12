---
title: Always Clean Up Subscriptions, Streams, and Notifiers in dispose()
impact: HIGH
impactDescription: Prevents memory leaks and zombie listeners executing callbacks on unmounted components
tags: state, lifecycle, memory, streams
---

## Always Clean Up Subscriptions, Streams, and Notifiers in dispose()

**Impact: HIGH (Prevents memory leaks and zombie listeners executing callbacks on unmounted components)**

In client components, `StreamSubscription`s, global window event listeners, or timers created in `initState()` will remain active in memory if not cancelled when the component unmounts. If a callback fires on an unmounted component and calls `setState()`, it can throw errors or leak memory.

Always override `dispose()` in `StatefulComponent` state classes to cancel subscriptions, detach listeners, and dispose owned notifiers.

**Incorrect (abandoning subscriptions when component unmounts):**

```dart
@client
class ResizeObserverView extends StatefulComponent {
  @override
  State<ResizeObserverView> createState() => _ResizeObserverViewState();
}

class _ResizeObserverViewState extends State<ResizeObserverView> {
  int windowWidth = 0;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      // Memory leak: subscription never cancelled on unmount!
      web.EventStreamProviders.resizeEvent.forTarget(web.window).listen((event) {
        setState(() => windowWidth = web.window.innerWidth);
      });
    }
  }

  @override
  Component build(BuildContext context) => div([.text('Width: $windowWidth')]);
}
```

**Correct (retaining and cancelling subscription in dispose):**

```dart
import 'dart:async';

@client
class ResizeObserverView extends StatefulComponent {
  @override
  State<ResizeObserverView> createState() => _ResizeObserverViewState();
}

class _ResizeObserverViewState extends State<ResizeObserverView> {
  int windowWidth = 0;
  StreamSubscription? _resizeSub;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _resizeSub = web.EventStreamProviders.resizeEvent.forTarget(web.window).listen((event) {
        if (mounted) {
          setState(() => windowWidth = web.window.innerWidth);
        }
      });
    }
  }

  @override
  void dispose() {
    _resizeSub?.cancel(); // Cleanly detached
    super.dispose();
  }

  @override
  Component build(BuildContext context) => div([.text('Width: $windowWidth')]);
}
```
