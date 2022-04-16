const codeMirrorOptions = {
  'continueComments': {'continueLineComment': false},
  'autofocus': false,
  'autoCloseTags': {
    'whenOpening': true,
    'whenClosing': true,
    'indentTags': [] // Android Studio/VSCode do not auto indent/add newlines for any completed tags
    //  The default (below) would be the following tags cause indenting and blank line inserted
    // ['applet', 'blockquote', 'body', 'button', 'div', 'dl', 'fieldset',
    //    'form', 'frameset', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'head',
    //    'html', 'iframe', 'layer', 'legend', 'object', 'ol', 'p', 'select', \
    //    'table', 'ul']
  },
  'autoCloseBrackets': true,
  'matchBrackets': true,
  'tabSize': 2,
  'lineWrapping': false,
  'indentUnit': 2,
  'cursorHeight': 0.85,
  'viewportMargin': 100,
  'extraKeys': {
    'Cmd-/': 'toggleComment',
    'Ctrl-/': 'toggleComment',
    'Shift-Tab': 'indentLess',
    'Tab': 'indentIfMultiLineSelectionElseInsertSoftTab',
    'Cmd-F': 'weHandleElsewhere',
    'Cmd-H': 'weHandleElsewhere',
    'Ctrl-F': 'weHandleElsewhere',
    'Ctrl-H': 'weHandleElsewhere',
    'Cmd-G': 'weHandleElsewhere',
    'Shift-Ctrl-G': 'weHandleElsewhere',
    'Ctrl-G': 'weHandleElsewhere',
    'Shift-Cmd-G': 'weHandleElsewhere',
    'F4': 'weHandleElsewhere',
    'Shift-F4': 'weHandleElsewhere',
    // vscode folding key combos (pc/mac)
    'Shift-Ctrl-[': 'ourFoldWithCursorToStart',
    'Cmd-Alt-[': 'ourFoldWithCursorToStart',
    'Shift-Ctrl-]': 'unfold',
    'Cmd-Alt-]': 'unfold',
    'Shift-Ctrl-Alt-[': 'foldAll', // made our own keycombo since VSCode and AndroidStudio's
    'Shift-Cmd-Alt-[': 'foldAll', //  are taken by browser
    'Shift-Ctrl-Alt-]': 'unfoldAll',
    'Shift-Cmd-Alt-]': 'unfoldAll',
  },
  'foldGutter': true,
  'foldOptions': {
    'minFoldSize': 1,
    'widget': '\u00b7\u00b7\u00b7', // like '...', but middle dots
  },
  'matchTags': {
    'bothTags': true,
  },
  'gutters': ['CodeMirror-linenumbers', 'CodeMirror-foldgutter'],
  'highlightSelectionMatches': {
    'style': 'highlight-selection-matches',
    'showToken': false,
    'annotateScrollbar': true,
  },
  'hintOptions': {'completeSingle': false},
  'scrollbarStyle': 'simple',
  'theme': 'darkpad', // ambiance, vibrant-ink, monokai, zenburn
  'mode': 'dart',
  'lineNumbers': true,
};
