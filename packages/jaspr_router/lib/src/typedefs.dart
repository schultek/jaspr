import 'dart:async' show FutureOr;

import 'package:jaspr/jaspr.dart';

import 'configuration.dart';

/// The component builder for [Route].
typedef RouterComponentBuilder = Component Function(BuildContext context, RouteState state);

/// The component builder for [ShellRoute].
typedef ShellRouteBuilder = Component Function(BuildContext context, RouteState state, Component child);

/// The signature of the redirect callback.
typedef RouterRedirect = FutureOr<String?> Function(BuildContext context, RouteState state);
