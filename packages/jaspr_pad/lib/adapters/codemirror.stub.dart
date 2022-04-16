// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_web_builder
// ignore_for_file: annotate_overrides, non_constant_identifier_names

class Doc {
  CodeMirror getEditor() => throw UnimplementedError('getEditor');
  String? getValue([String? separator]) => throw UnimplementedError('getValue');
  void setValue(String value) => throw UnimplementedError('setValue');
  int? lineCount() => throw UnimplementedError('lineCount');
  int? firstLine() => throw UnimplementedError('firstLine');
  int? lastLine() => throw UnimplementedError('lastLine');
  String? getLine(int? n) => throw UnimplementedError('getLine');
  void eachLine(void Function(dynamic) callback, {int? start, int? end}) => throw UnimplementedError('eachLine');
  bool somethingSelected() => throw UnimplementedError('somethingSelected');
  String? getSelection([String? lineSep]) => throw UnimplementedError('getSelection');
  void setSelection(dynamic anchor, {dynamic head, Map<dynamic, dynamic>? options}) =>
      throw UnimplementedError('setSelection');
  void replaceSelection(String replacement, [String? select]) => throw UnimplementedError('replaceSelection');
  Iterable<String> getSelections([String? lineSep]) => throw UnimplementedError('getSelections');
  void setSelections(dynamic ranges, {int? primary, Map<dynamic, dynamic>? options}) =>
      throw UnimplementedError('setSelections');
  void replaceSelections(Iterable<String> replacement, {String? select}) =>
      throw UnimplementedError('replaceSelections');
  void addSelection({required dynamic anchor, dynamic head}) => throw UnimplementedError('addSelection');
  void extendSelection(dynamic from, [dynamic to, Map<dynamic, dynamic>? options]) =>
      throw UnimplementedError('extendSelection');
  void extendSelections(dynamic heads, [Map<dynamic, dynamic>? options]) =>
      throw UnimplementedError('extendSelections');
  void extendSelectionsBy(dynamic Function(dynamic, int) f, [Map<dynamic, dynamic>? options]) =>
      throw UnimplementedError('extendSelectionsBy');
  void setExtending(bool value) => throw UnimplementedError('setExtending');
  bool? getExtending() => throw UnimplementedError('getExtending');
  dynamic listSelections() => throw UnimplementedError('listSelections');
  void replaceRange(String replacement, dynamic from, [dynamic to, String? origin]) =>
      throw UnimplementedError('replaceRange');
  void markClean() => throw UnimplementedError('markClean');
  int? changeGeneration([bool? closeEvent]) => throw UnimplementedError('changeGeneration');
  bool isClean([int? generation]) => throw UnimplementedError('isClean');
  void undo() => throw UnimplementedError('undo');
  void redo() => throw UnimplementedError('redo');
  void undoSelection() => throw UnimplementedError('undoSelection');
  void redoSelection() => throw UnimplementedError('redoSelection');
  Map<String, int?> historySize() => throw UnimplementedError('historySize');
  void clearHistory() => throw UnimplementedError('clearHistory');
  dynamic getHistory() => throw UnimplementedError('getHistory');
  void setHistory(dynamic history) => throw UnimplementedError('setHistory');
  dynamic getCursor([String? start]) => throw UnimplementedError('getCursor');
  void setCursor(dynamic pos, {Map<dynamic, dynamic>? options}) => throw UnimplementedError('setCursor');
  String? getRange(dynamic from, dynamic to, [String? separator]) => throw UnimplementedError('getRange');
  dynamic posFromIndex(int index) => throw UnimplementedError('posFromIndex');
  int? indexFromPos(dynamic pos) => throw UnimplementedError('indexFromPos');
  dynamic markText(dynamic from, dynamic to,
          {String? className,
          bool? inclusiveLeft,
          bool? inclusiveRight,
          bool? atomic,
          bool? collapsed,
          bool? clearOnEnter,
          bool? clearWhenEmpty,
          dynamic replacedWith,
          bool? handleMouseEvents,
          bool? readOnly,
          bool? addToHistory,
          String? startStyle,
          String? endStyle,
          String? css,
          String? title,
          bool? shared}) =>
      throw UnimplementedError('markText');
  dynamic setBookmark(dynamic pos, {dynamic widget, bool? insertLeft, bool? shared}) =>
      throw UnimplementedError('setBookmark');
  dynamic findMarks(dynamic from, dynamic to) => throw UnimplementedError('findMarks');
  dynamic findMarksAt(dynamic pos) => throw UnimplementedError('findMarksAt');
  dynamic getAllMarks() => throw UnimplementedError('getAllMarks');
  dynamic getMode() => throw UnimplementedError('getMode');
  String? getModeName() => throw UnimplementedError('getModeName');
  dynamic getModeAt(dynamic pos) => throw UnimplementedError('getModeAt');
  String? getModeNameAt(dynamic pos) => throw UnimplementedError('getModeNameAt');
  dynamic getLineHandle(int? line) => throw UnimplementedError('getLineHandle');
  int? getLineNumber(dynamic handle) => throw UnimplementedError('getLineNumber');
  CodeMirror get editor => throw UnimplementedError('editor');
  Stream<dynamic> get onChange => throw UnimplementedError('onChange');
  Doc(String text, [String? mode, int? firstLineNumber]);
  Doc.fromProxy(dynamic proxy);
  dynamic call(String methodName) => throw UnimplementedError('call');
  dynamic callArg(String methodName, dynamic arg) => throw UnimplementedError('callArg');
  dynamic callArgs(String methodName, List<dynamic> args) => throw UnimplementedError('callArgs');
  Stream<T?> onEvent<T>(String eventName, {int argCount = 1}) => throw UnimplementedError('onEvent');
  bool operator ==(Object other) => throw UnimplementedError('==');
  void dispose() => throw UnimplementedError('dispose');
  dynamic get jsProxy => throw UnimplementedError('jsProxy');
  int get hashCode => throw UnimplementedError('hashCode');
}

class CodeMirror {
  static dynamic findModeByExtension(String ext) => throw UnimplementedError('findModeByExtension');
  static dynamic findModeByMime(String mime) => throw UnimplementedError('findModeByMime');
  static dynamic findModeByFileName(String name) => throw UnimplementedError('findModeByFileName');
  static dynamic findModeByName(String name) => throw UnimplementedError('findModeByName');
  static void defineExtension(String name, dynamic value) => throw UnimplementedError('defineExtension');
  static void defineDocExtension(String name, dynamic value) => throw UnimplementedError('defineDocExtension');
  static void registerHelper(String type, String mode, dynamic helper) => throw UnimplementedError('registerHelper');
  static void addCommand(String name, void Function(CodeMirror) callback) => throw UnimplementedError('addCommand');
  Doc getDoc() => throw UnimplementedError('getDoc');
  void swapDoc(Doc doc) => throw UnimplementedError('swapDoc');
  dynamic getOption(String option) => throw UnimplementedError('getOption');
  void setOption(String option, dynamic value) => throw UnimplementedError('setOption');
  String? getTheme() => throw UnimplementedError('getTheme');
  void setTheme(String theme) => throw UnimplementedError('setTheme');
  String? getMode() => throw UnimplementedError('getMode');
  void setMode(String mode) => throw UnimplementedError('setMode');
  String? getKeyMap() => throw UnimplementedError('getKeyMap');
  void setKeyMap(String value) => throw UnimplementedError('setKeyMap');
  bool? getLineNumbers() => throw UnimplementedError('getLineNumbers');
  void setLineNumbers(bool? value) => throw UnimplementedError('setLineNumbers');
  String? getLine(int? n) => throw UnimplementedError('getLine');
  bool getIndentWithTabs() => throw UnimplementedError('getIndentWithTabs');
  void setIndentWithTabs(bool? value) => throw UnimplementedError('setIndentWithTabs');
  bool getReadOnly() => throw UnimplementedError('getReadOnly');
  void setReadOnly(bool value, [bool noCursor = false]) => throw UnimplementedError('setReadOnly');
  int getTabSize() => throw UnimplementedError('getTabSize');
  void setTabSize(int value) => throw UnimplementedError('setTabSize');
  int? getIndentUnit() => throw UnimplementedError('getIndentUnit');
  void setIndentUnit(int value) => throw UnimplementedError('setIndentUnit');
  void refresh() => throw UnimplementedError('refresh');
  void focus() => throw UnimplementedError('focus');
  dynamic getInputField() => throw UnimplementedError('getInputField');
  dynamic getCursor([String? start]) => throw UnimplementedError('getCursor');
  void execCommand(String name) => throw UnimplementedError('execCommand');
  void setGutterMarker(int line, String gutterID, dynamic value) => throw UnimplementedError('setGutterMarker');
  void clearGutter(String gutterID) => throw UnimplementedError('clearGutter');
  void addWidget(dynamic pos, dynamic node, [bool scrollIntoView = false]) => throw UnimplementedError('addWidget');
  dynamic addLineWidget(dynamic line, dynamic node,
          {bool? coverGutter,
          bool? noHScroll,
          bool? above,
          bool? handleMouseEvents,
          int? insertAt,
          String? className}) =>
      throw UnimplementedError('addLineWidget');
  dynamic addLineClass(dynamic line, String where, String cssClass) => throw UnimplementedError('addLineClass');
  dynamic removeLineClass(dynamic line, String where, [String? cssClass]) =>
      throw UnimplementedError('removeLineClass');
  dynamic getTokenAt(dynamic pos, [bool? precise]) => throw UnimplementedError('getTokenAt');
  dynamic getLineTokens(int line, [bool? precise]) => throw UnimplementedError('getLineTokens');
  String? getTokenTypeAt(dynamic pos) => throw UnimplementedError('getTokenTypeAt');
  void setSize(num width, num height) => throw UnimplementedError('setSize');
  void scrollTo(num x, num y) => throw UnimplementedError('scrollTo');
  dynamic getScrollInfo() => throw UnimplementedError('getScrollInfo');
  void scrollIntoView(int line, int ch, {int? margin}) => throw UnimplementedError('scrollIntoView');
  dynamic getHelpers(dynamic pos, String type) => throw UnimplementedError('getHelpers');
  dynamic getHelper(dynamic pos, String type) => throw UnimplementedError('getHelper');
  void save() => throw UnimplementedError('save');
  void toTextArea() => throw UnimplementedError('toTextArea');
  dynamic getTextArea() => throw UnimplementedError('getTextArea');
  void dispose() => throw UnimplementedError('dispose');
  static List<String> get themes => throw UnimplementedError('themes');
  static List<String> get THEMES => throw UnimplementedError('THEMES');
  static List<String> get keyMaps => throw UnimplementedError('keyMaps');
  static List<String> get KEY_MAPS => throw UnimplementedError('KEY_MAPS');
  static List<String> get modes => throw UnimplementedError('modes');
  static List<String> get MODES => throw UnimplementedError('MODES');
  static List<String> get mimeModes => throw UnimplementedError('mimeModes');
  static List<String> get MIME_MODES => throw UnimplementedError('MIME_MODES');
  static List<String> get commands => throw UnimplementedError('commands');
  static List<String> get COMMANDS => throw UnimplementedError('COMMANDS');
  static String? get version => throw UnimplementedError('version');
  Stream<dynamic> get onChange => throw UnimplementedError('onChange');
  Stream<dynamic> get onCursorActivity => throw UnimplementedError('onCursorActivity');
  dynamic get onMouseDown => throw UnimplementedError('onMouseDown');
  dynamic get onDoubleClick => throw UnimplementedError('onDoubleClick');
  Stream<int?> get onGutterClick => throw UnimplementedError('onGutterClick');
  Doc get doc => throw UnimplementedError('doc');
  CodeMirror.fromElement(dynamic element, {Map<dynamic, dynamic>? options});
  factory CodeMirror.fromJsObject(dynamic object) => throw UnimplementedError('fromJsObject');
  CodeMirror.fromTextArea(dynamic textArea, {Map<dynamic, dynamic>? options});
  dynamic call(String methodName) => throw UnimplementedError('call');
  dynamic callArg(String methodName, dynamic arg) => throw UnimplementedError('callArg');
  dynamic callArgs(String methodName, List<dynamic> args) => throw UnimplementedError('callArgs');
  Stream<T?> onEvent<T>(String eventName, {int argCount = 1}) => throw UnimplementedError('onEvent');
  bool operator ==(Object other) => throw UnimplementedError('==');
  dynamic get jsProxy => throw UnimplementedError('jsProxy');
  int get hashCode => throw UnimplementedError('hashCode');
}
