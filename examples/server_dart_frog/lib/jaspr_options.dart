// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/jaspr.dart';

import 'components/hello.dart' as c0;
import 'components/counter.dart' as c1;

const defaultJasprOptions = JasprOptions(
  clientComponents: {
    c0.Hello: ComponentEntry<c0.Hello>.client('components/hello', params: _params0Hello),
    c1.Counter: ComponentEntry<c1.Counter>.client('components/counter'),
  },
);

Map<String, dynamic> _params0Hello(c0.Hello c) => {'name': c.name};
