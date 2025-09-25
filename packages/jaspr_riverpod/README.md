# 🌊 jaspr_riverpod

A port of [`flutter_riverpod`](https://pub.dev/packages/flutter_riverpod) for [Jaspr](https://jaspr.site). It is based on Riverpod 3 and supports all providers and modifiers.

**TLDR: Differences to flutter_riverpod**

- No `Consumer` / `ConsumerComponent`, just use `context.read` / `context.watch`
- Additional `sync` option to sync providers between server and client.

## 🪄 Accessing Providers

While it has feature-parity for defining `Provider`s, it comes with some quality-of-life improvements on the `Consumer` side. Mainly:

**It does not have `Consumer`, `ConsumerWidget` or `StatefulConsumerWidget`.** This is because it does not rely on `WidgetRef` to access providers but instead comes with **context extensions** on the `BuildContext` of **any** component.

As an example, this (in Flutter):

```dart
// (Flutter)
// need to extend custom ConsumerWidget
class MyWidget extends ConsumerWidget {

  @override    // need to accept custom WidgetRef
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
 
  @override       // no extra ref parameter
  Component build(BuildContext context) {
    // uses context to access providers
    var value = context.watch(myProvider);
    return Text(value);
  }
}
```

The extension on `BuildContext` supports all the normal methods from `WidgetRef`

- `context.read()`
- `context.watch()`
- `context.listen()`
- `context.listenManual()`
- `context.invalidate()`
- `context.refresh()`
- `context.exists()`

#### Replacement for Consumer

Same as with `ConsumerComponent`, we don't need the `Consumer` anymore. If you want only parts of your component tree to rebuild when watching a provider, simply use the `Builder` component. This will
give you a new context which you can call `context.watch` on:

```dart
Builder(
  builder: (context) {
    var value = context.watch(...);
    return ...;
  },
);
```

## ♻️ Syncing Provider State

Jaspr allows data that is loaded during pre-rendering (in **server** or **static** mode) to be synced to the client for further use. `jaspr_riverpod` extends this for providers, allowing to sync provider state from server to client like this:

```dart
@override
Component build() {
  return ProviderScope(
    sync: [
      myProvider.syncWith('some-unique-key'),
    ],
    child: ...
  );
}
```

This will cause the value of `myProvider` to be evaulated and serialized on the server, and deserialized on the client. Then when accessing `myProvider` on the client, it will return the original value from the server.

The `syncWith()` method takes a unique `String key` to identify the provider, and an optional `Codec<T, Object?>? codec` parameter for converting the provider value of type `T` to/from a serializable value. The `codec` parameter is not needed for serializable values, like primitives (`String`, numbers, `bool`, etc.) or `Map`s and `List`s of these.

The following provider types support syncing: `NotifierProvider`, `AsyncNotifierProvider`, `Provider`, `FutureProvider`, `StreamProvider` and `StateProvider`.

### Awaiting Async Providers

If a synced provider is a `FutureProvider`, `StreamProvider` or `AsyncNotifier`, the `ProviderScope` will wait for the providers future to complete before building its child (on the server). Therefore reading the provider inside the subtree will already return the completed value.

### Sync Overrides and Scoping

In detail, the process of syncing a provider between server and client works like this:

- During pre-rendering on the server, the value of a synced provider is read, serialized and embedded into the rendered html.
- Together with the html it is then sent to the client.
- When the client first builds your component containing the `ProviderScope`, the embedded provider value is read and deserialized.
- The provider is then **overridden** with the received value, using the normal `.overrideWith()` feature of Riverpod.
- Accessing a synced provider on the client will always return the overridden value and skip it's initial computation.

It is important to note that overrides in Riverpod only propagate the provider chain when they are defined on the root `ProviderScope`, and the same applies to synced providers. Therefore, either make sure to define synced providers only on the root client-side `ProviderScope`, or set the `dependencies` option required for scoping providers.

Read more about scoping providers [here](https://riverpod.dev/de/docs/concepts2/scoping).

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
