// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/jaspr.dart';
import 'package:package_riverpod/components/counter2.dart';
import 'package:package_riverpod/models/color.dart';

mixin Counter2StateSyncMixin on State<Counter2> implements SyncStateMixin<Counter2, Map<String, dynamic>> {
  int get count;
  set count(int count);

  Color? get color;
  set color(Color? color);

  @override
  void updateState(Map<String, dynamic> value) {
    count = value['count'];
    color = value['color'] != null ? ColorCodec.decode(value['color']!) : null;
  }

  @override
  Map<String, dynamic> getState() {
    return {
      'count': count,
      'color': color != null ? ColorCodec(color!).encode() : null,
    };
  }

  @override
  void initState() {
    super.initState();
    SyncStateMixin.initSyncState(this);
  }
}
