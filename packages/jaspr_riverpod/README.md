# 🌊 Riverpod for Jaspr

Jaspr comes with a Riverpod package that ports over flutter_riverpod to Jaspr. It is based
on Riverpod 2 and supports all providers and modifiers.

**TLDR: Differences to flutter_riverpod**

- No `Consumer` / `ConsumerComponent`, just use `context.read` / `context.watch`
- Additional `SyncProvider` to sync values between server and client.

> Also check out [this example](https://github.com/schultek/jaspr/tree/main/examples/riverpod_app).

## 🪄 Accessing Providers

While it has feature-parity for defining `Provider`s, it comes with some quality-of-life improvements
on the `Consumer` side. Mainly:

**It does not have `Consumer`, `ConsumerWidget` or `StatefulConsumerWidget`.** This is because it
does not rely on `WidgetRef` to access providers but instead comes with **context extensions** on the
`BuildContext` of **any** component.

As an example, this (in Flutter):

```dart
// (Flutter)
// need to extend custom ConsumerWidget
class MyWidget extends ConsumerWidget {
  // need to accept custom WidgetRef
  Widget build(BuildContext context, WidgetRef ref) {
    // uses ref to access providers
    var value = ref.watch(myProvider);
    return Text(value);
  }
}
```

is equivalent to this (in Jaspr)

```dart 
// (Jaspr)
// just extends the normal component
class MyComponent extends StatelessComponent {
  // no extra parameter
  Iterable<Component> build(BuildContext context) sync* {
    // uses context to access providers
    var value = context.watch(myProvider);
    yield Text(value);
  }
}
```

The extension on `BuildContext` supports all the normal methods from `WidgetRef``

- `context.read()`,
- `context.watch()`,
- `context.refresh()`,
- `context.invalidate()`,
- `context.listen()`

#### Replacement for Consumer

Same as with `ConsumerComponent`, we don't need the `Consumer` anymore. If you want only parts of your
component tree to rebuild when watching a provider, simply use the `Builder` component. This will
give you a new context which you can call `context.watch` on:

```dart
Builder(
  builder: (context) sync* {
    var value = context.watch(...);
    yield ...;
  },
);
```

## ♻️ Preloading and Syncing Provider State

Jaspr allows `StatefulComponent`s to preload state as well as sync state between server and client
(when using server-side rendering).

Since providers often are used to replace `StatefulComponent`s, `jaspr_riverpod` offers the same
mechanisms inside a special provider, called `SyncProvider`:

```dart
final mySyncProvider = SyncProvider<int>((ref) async {
  // do some async work on the server, like fetching data from a database
  await Future.delayed(Duration(seconds: 1));
  return 100;
}, id: 'initial_count');
```

This provider needs an additional id to be synced with the client.
The create function of a `SyncProvider` is only executed on the server, and
never on the client. Instead the synced value is returned.

It then can be used like any other provider. It functions like a `FutureProvider` and exposes a
value of type `AsyncValue<T>`.

## 📜 Backstory: Why context extensions instead of Consumer?

Put simply: Because they are easier and more flexible to use and require less boilerplate.

The actual question would be why they are not part of flutter_riverpod in the first place.
This is because mainly `context.watch` is [not feasible in `flutter_riverpod`](https://github.com/rrousselGit/riverpod/issues/134).

This is a limitation by Flutter itself, not Riverpod. There are [long standing bugs](https://github.com/flutter/flutter/issues/62861)
(or [missing features](https://github.com/flutter/flutter/issues/12992) depending on how you view it)
in flutter with `InheritedWidget` that make it impossible for `context.watch` to work properly.
Recently there have been [efforts](https://github.com/flutter/flutter/issues/106549) by the creator
of riverpod to [fix](https://github.com/flutter/flutter/issues/106546) these bugs,
but [without success](https://github.com/flutter/flutter/pull/107112).

As `jaspr` is basically a complete rewrite of flutters core framework, I went ahead and fixed
these bugs and thereby making `context.watch` feasible.
