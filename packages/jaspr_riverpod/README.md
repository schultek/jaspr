# 🌊 jaspr_riverpod

A port of [`flutter_riverpod`](https://pub.dev/packages/flutter_riverpod) for [Jaspr](https://jaspr.site). It is based on Riverpod 3 and supports all providers and modifiers.

**TLDR: Differences to flutter_riverpod**

- No `Consumer` / `ConsumerComponent`, just use `context.read` / `context.watch`
- Additional `sync` option to sync providers between server and client.

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
  builder: (context) {
    var value = context.watch(...);
    return ...;
  },
);
```

## ♻️ Syncing Provider State

Jaspr allows data that is loaded during pre-rendering to be synced to the client for further use. `jaspr_riverpod` extends this for providers, allowing to sync provider state from server to client like this:

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

The `sync` property of `ProviderScope` receives a list of `provier.syncWith(String key, {Codec<T, Object?>? codec})`, where `provider` can be any Provider. It will:

- on the server: read the value of the provider and send it to the client
- on the client: receive the value from the server and override the provider with it.

Therefore, accessing a synced provider on the client will always return the synced value and skip it's computation.

Additionally during pre-rendering on the server, if provider is a `FutureProvider`, `StreamProvider` or `AsyncNotifier`, the `ProviderScope` will wait for the providers future to complete before building its child. Therefore reading the provider inside the subtree will already return the completed value.

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
