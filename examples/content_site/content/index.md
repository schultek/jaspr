---
title: "No macros in Dart, how to replace freezed?"
keywords: ["home"]
author: "Kilian Schulte"
date: "12 November"
readTime: "5 min"
authorImage: https://avatars.githubusercontent.com/u/13920539?s=96&v=4
tags: ["Dart", "Freezed", "Macros", "Freezed", "Macros", "Freezed", "Macros", "Freezed", "Macros", "Freezed", "Macros", "Freezed", "Macros", "Freezed", "Macros"]
---


This is a paragraph.

<PostBreak/>

This is another, longer paragraph. It contains more text and will be span the whole width of the screen.


<DropCap/>
The first letter of this paragraph (T) will be a drop cap. This looks best for longer paragraphs that have enough text to span multiple lines. The drop cap will be the first letter of the paragraph, and it will be larger than the rest of the text. This is a common design pattern in print media, and it can add a nice touch to your website.








> This is the about pages TEST HALLO
> Author: Albert Wolszon from LeanCode

Unfortunately, the Dart team has taken up the very difficult decision of abandoning their work on the macros language feature.


<DropCap/>
We were wholeheartedly cheering for this feature to come up eventually, but now that we know it won’t come, at least in the foreseeable future, we’re not caught off guard.

Macros would be the perfect solution for having proper data classes in Dart with little to no boilerplate.

![Test](https://images.unsplash.com/photo-1501504905252-473c47e087f8)

A long time ago we noticed how much freezed code generation contributes to the time it takes for the build_runner to generate all the code, even with optimizations. Because of that, we migrated away from it to packages and solutions that also fulfilled our needs without big overhead.

<PostBreak/>

Let’s take a look at the features that were most important to us in freezed:

<Image
  src="https://images.unsplash.com/photo-1501504905252-473c47e087f8"
  alt="Test"
  caption="Some nice image from Unsplash"
  zoom
/>



<Tabs>
  <TabItem label="Freezed" value="freezed">
    Freezed is a code generation library for Dart that helps you create immutable data classes.
  </TabItem>
  <TabItem label="Sealed Classes" value="sealed-classes">
    Sealed classes are a new feature in Dart that allows you to create a closed set of subclasses.
  </TabItem>
  <TabItem label="Value Equality" value="value-equality">
    Value equality is a way to compare objects based on their values rather than their references.
  </TabItem>
</Tabs>

Union classes — to have a closed set of data structures with different fields that we can map over.
Value equality — instead of reference equality.
`copyWith` — to conveniently create a new instance of the immutable data class with only some fields changed.
Union classes
One of the most valuable features in freezed was the union class “simulation”. We could create a class hierarchy that’s closed and strongly typed. It gave us the most value for state classes for our cubits and blocs. We most often had a hierarchy of a base `SomethingState` class with case classes `SomethingInitial`, `SomethingLoadInProgress`, `SomethingLoadSuccess`, and `SomethingLoadFailure`. Each had its own fields, sometimes all sharing a portion of them. In the base class, we had `map`, `maybeMap`, `when`, and `maybeWhen` that we used to return widgets appropriate to each state.

<img src="https://images.unsplash.com/photo-1501504905252-473c47e087f8" alt="Test" caption="HELLO THIS IS CAPTION" />

As Dart 3.0 was released, along with Flutter 3.10, sealed classes and pattern matching were introduced directly into the language. The class `SomethingState extends _$SomethingState` could be replaced with `sealed class SomethingState`. The freezed’s subclasses are now replaced with an ordinary subclass, marked final to close the hierarchy.

Before

```dart
@freezed
class SomethingState with _$SomethingState {
  const factory SomethingState.initial() = SomethingInitial;
  const factory SomethingState.loadInProgress() = SomethingLoadInProgress;
  const factory SomethingState.loadSuccess() = SomethingLoadSuccess;
  const factory SomethingState.loadFailure() = SomethingError;
}
```

After
```dart title="sealed class"
sealed class SomethingState {
  const SomethingState();
}

final class SomethingInitial extends SomethingState {
  const SomethingInitial();
}

final class SomethingLoadInProgress extends SomethingState {
  const SomethingLoadInProgress();
}

final class SomethingLoadSuccess extends SomethingState {
  const SomethingLoadSuccess();
}

final class SomethingError extends SomethingState {
  const SomethingError();
}
```

There are a few more lines to write (or to wait for Copilot to suggest), but in exchange, we don’t need to follow a specific pattern, otherwise making the code invalid for freezed generator, but rather we can write as many constructors, factories, subclasses, etc. as we need.

One of the things that freezed gave us, and we don’t have with sealed classes are automatic shared properties. Instead, we need to put the field in the base class.

Value equality
Immutability in the Flutter world is crucial. But we don’t want our data classes to be compared by reference. That would mean that two instances with the exact same values would be considered not equal and could result in a state emission in cubit/bloc, or `shouldRepaint`, `updateShouldNotify`, and similar returning true resulting in widget rebuilds, and possible performance degradation or increased battery consumption.