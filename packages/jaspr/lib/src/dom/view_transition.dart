import '/jaspr.dart';
import 'view_transition/view_transition_io.dart'
    if (dart.library.js_interop) 'view_transition/view_transition_web.dart';

mixin ViewTransitionMixin<T extends StatefulComponent> on State<T> {
  void setStateWithViewTransition(
    void Function() callback, {
    void Function()? preTransition,
    void Function()? postTransition,
  }) {
    if (preTransition != null) {
      setState(preTransition);
      context.binding.addPostFrameCallback(() {
        setStateWithViewTransition(callback, postTransition: postTransition);
      });
      return;
    }

    final transition = startViewTransition(() {
      setState(callback);
    });

    if (postTransition != null) {
      if (transition is Future) {
        transition.whenComplete(() {
          setState(postTransition);
        });
      } else {
        setState(postTransition);
      }
    }
  }
}
