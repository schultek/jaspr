// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/browser.dart';
import 'components/hello.client.dart' deferred as i0;
import 'components/counter.client.dart' deferred as i1;

void main() {
  registerClients({
    'components/hello': loadClient(
      i0.loadLibrary,
      (p) => i0.getComponentForParams(p),
    ),
    'components/counter': loadClient(
      i1.loadLibrary,
      (p) => i1.getComponentForParams(p),
    ),
  });
}
