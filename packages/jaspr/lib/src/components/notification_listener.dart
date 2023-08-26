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
  const NotificationListener({
    super.key,
    required this.child,
    this.onNotification,
  });

  final Component child;

  /// Called when a notification of the appropriate type arrives at this
  /// location in the tree.
  ///
  /// Return true to cancel the notification bubbling. Return false to
  /// allow the notification to continue to be dispatched to further ancestors.
  ///
  /// Notifications vary in terms of when they are dispatched. There are two
  /// main possibilities: dispatch between frames, and dispatch during layout.
  ///
  /// For notifications that dispatch during layout, such as those that inherit
  /// from [LayoutChangedNotification], it is too late to call [State.setState]
  /// in response to the notification (as layout is currently happening in a
  /// descendant, by definition, since notifications bubble up the tree). For
  /// components that depend on layout, consider a [LayoutBuilder] instead.
  final NotificationListenerCallback<T>? onNotification;

  @override
  Element createElement() {
    return _NotificationElement<T>(this);
  }
}

/// An element used to host [NotificationListener] elements.
class _NotificationElement<T extends Notification> extends SingleChildElement with NotifiableElementMixin {
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
  void notifyClients(covariant Component oldComponent) {
    // Notification tree does not need to notify clients.
  }
}
