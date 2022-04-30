import 'package:meta/meta.dart';

/// Base class for mixins that provide singleton services (also known as
/// "bindings").
///
/// To use this class in an `on` clause of a mixin, inherit from it and implement
/// [initInstances()]. The mixin is guaranteed to only be constructed once in
/// the lifetime of the app (more precisely, it will assert if constructed twice
/// in debug mode).
///
/// The top-most layer used to write the application will have a concrete class
/// that inherits from [BindingBase] and uses all the various [BindingBase]
/// mixins (such as [ComponentsBinding]). The relevant library defines how to
/// create the binding. It could be implied (for example,
/// [ComponentsBinding] is automatically started from [runApp]), or the
/// application might be required to explicitly call the constructor.
abstract class BindingBase {
  /// Default abstract constructor for bindings.
  ///
  /// First calls [initInstances] to have bindings initialize their
  /// instance pointers and other state.
  BindingBase() {
    assert(!_debugInitialized);
    initInstances();
    assert(_debugInitialized);
  }

  static bool _debugInitialized = false;

  /// The initialization method. Subclasses override this method to hook into
  /// the platform and otherwise configure their services. Subclasses must call
  /// "super.initInstances()".
  ///
  /// By convention, if the service is to be provided as a singleton, it should
  /// be exposed as `MixinClassName.instance`, a static getter that returns
  /// `MixinClassName._instance`, a static field that is set by
  /// `initInstances()`.
  @protected
  @mustCallSuper
  void initInstances() {
    assert(!_debugInitialized);
    assert(() {
      _debugInitialized = true;
      return true;
    }());
  }
}
