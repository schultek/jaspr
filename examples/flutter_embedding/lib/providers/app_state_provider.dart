import 'package:riverpod/riverpod.dart';

import '../shared/app_state.dart';
export '../shared/app_state.dart';

final appStateProvider = NotifierProvider<AppStateNotifier, AppState>(AppStateNotifier.new);