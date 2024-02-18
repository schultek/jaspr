part of 'framework.dart';

/// A notification that can bubble up the component tree.
///
/// You can determine the type of a notification using the `is` operator to
/// check the [runtimeType] of the notification.
///
/// To listen for notifications in a subtree, use a [NotificationListener].
///
/// To send a notification, call [dispatch] on the notification you wish to
/// send. The notification will be delivered to any [NotificationListener]
/// components with the appropriate type parameters that are ancestors of the given
/// [BuildContext].
abstract class Notification {
  /// Abstract const constructor. This constructor enables subclasses to provide
  /// const constructors so that they can be used in const expressions.
  const Notification();

  /// Start bubbling this notification at the given build context.
  ///
  /// The notification will be delivered to any [NotificationListener] components
  /// with the appropriate type parameters that are ancestors of the given
  /// [BuildContext]. If the [BuildContext] is null, the notification is not
  /// dispatched.
  void dispatch(BuildContext? target) {
    target?.dispatchNotification(this);
  }

  @override
  String toString() {
    final List<String> description = <String>[];
    debugFillDescription(description);
    return '${objectRuntimeType(this, 'Notification')}(${description.join(", ")})';
  }

  /// Add additional information to the given description for use by [toString].
  ///
  /// This method makes it easier for subclasses to coordinate to provide a
  /// high-quality [toString] implementation. The [toString] implementation on
  /// the [Notification] base class calls [debugFillDescription] to collect
  /// useful information from subclasses to incorporate into its return value.
  ///
  /// Implementations of this method should start with a call to the inherited
  /// method, as in `super.debugFillDescription(description)`.
  @protected
  @mustCallSuper
  void debugFillDescription(List<String> description) {}
}

/// Mixin this class to allow receiving [Notification] objects dispatched by
/// child elements.
///
/// See also:
///   * [NotificationListener], for a widget that allows consuming notifications.
mixin NotifiableElementMixin on Element {
  /// Called when a notification of the appropriate type arrives at this
  /// location in the tree.
  ///
  /// Return true to cancel the notification bubbling. Return false to
  /// allow the notification to continue to be dispatched to further ancestors.
  bool onNotification(Notification notification);

  @override
  void attachNotificationTree() {
    _notificationTree = _NotificationNode(_parent?._notificationTree, this);
  }
}

class _NotificationNode {
  _NotificationNode(this.parent, this.current);

  NotifiableElementMixin? current;
  _NotificationNode? parent;

  void dispatchNotification(Notification notification) {
    if (current?.onNotification(notification) ?? true) {
      return;
    }
    parent?.dispatchNotification(notification);
  }
}
