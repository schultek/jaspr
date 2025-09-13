// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../framework/framework.dart';

/// Signature for [Notification] listeners.
///
/// Return true to cancel the notification bubbling. Return false to allow the
/// notification to continue to be dispatched to further ancestors.
///
/// Used by [NotificationListener.onNotification].
typedef NotificationListenerCallback<T extends Notification> = bool Function(T notification);

/// A component that listens for [Notification]s bubbling up the tree.
///
/// Notifications will trigger the [onNotification] callback only if their
/// [runtimeType] is a subtype of `T`.
///
/// To dispatch notifications, use the [Notification.dispatch] method.
class NotificationListener<T extends Notification> extends Component {
  /// Creates a component that listens for notifications.
  const NotificationListener({this.onNotification, required this.child, super.key});

  /// Called when a notification of the appropriate type arrives at this
  /// location in the tree.
  ///
  /// Return true to cancel the notification bubbling. Return false to
  /// allow the notification to continue to be dispatched to further ancestors.
  final NotificationListenerCallback<T>? onNotification;

  final Component child;

  @override
  Element createElement() {
    return _NotificationElement<T>(this);
  }
}

/// An element used to host [NotificationListener] elements.
class _NotificationElement<T extends Notification> extends BuildableElement with NotifiableElementMixin {
  _NotificationElement(NotificationListener<T> super.component);

  @override
  bool onNotification(Notification notification) {
    final NotificationListener<T> listener = component as NotificationListener<T>;
    if (listener.onNotification != null && notification is T) {
      return listener.onNotification!(notification);
    }
    return false;
  }

  @override
  Component build() => (component as NotificationListener<T>).child;
}
