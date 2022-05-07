import 'dart:async';

import 'package:domino/domino.dart';
import 'package:html/dom.dart';

/// Register DOM view in browser.
DomView registerTestView({
  required Document document,
  required Element root,
  required DomBuilderFn builderFn,
  bool skipInitialUpdate = false,
}) {
  final view = TestDomView(document, root, builderFn);
  if (!skipInitialUpdate) view.update();
  return view;
}

class TestDomView extends DomView {
  final Document _document;
  final Element _root;
  final DomBuilderFn _builderFn;

  Future? _invalidate;
  bool _isDisposed = false;

  TestDomView(this._document, this._root, this._builderFn);

  @override
  Future? invalidate() {
    return _invalidate ??= Future.microtask(() {
      try {
        update();
      } finally {
        _invalidate = null;
      }
    });
  }

  @override
  Future? dispose() async {
    _isDisposed = true;
    return invalidate();
  }

  @override
  void update() {
    if (_isDisposed) {
      _updateWith((_) {});
    } else {
      _updateWith(_builderFn);
    }
  }

  void _updateWith(DomBuilderFn fn) {
    final builder = _DomBuilder(this, _root);
    fn(builder);
    builder.close();
    for (final fn in builder._callbacks) {
      fn();
    }
  }
}

class _Position {
  final String tag;
  final Element container;
  int cursor = 0;
  bool mayHaveContent = true;

  _Position(this.tag, this.container);

  Node? get current => container.nodes.length > cursor ? container.nodes[cursor] : null;
}

class _DomBuilder extends DomBuilder {
  final TestDomView _view;
  final _positions = <_Position>[];
  final _callbacks = <Function>[];
  _DomBuilder(this._view, Element _container) {
    _positions.add(_Position(_container.localName ?? '', _container));
  }

  @override
  void open(
    String tag, {
    String? key,
    String? id,
    Iterable<String>? classes,
    Map<String, String>? styles,
    Map<String, String>? attributes,
    Map<String, DomEventFn>? events,
    DomLifecycleEventFn? onCreate,
    DomLifecycleEventFn? onUpdate,
    DomLifecycleEventFn? onRemove,
  }) {
    late final tagLc = tag.toLowerCase();
    final last = _positions.last;
    if (!last.mayHaveContent) {
      throw AssertionError('Must not have content at this point.');
    }
    final current = last.current;
    Element? elem;
    late Set<String> attributesToRemove;
    var isNewElem = true;

    final reuseKey = key ?? id;
    if (elem == null) {
      Element? matched;
      for (final n in last.container.nodes.skip(last.cursor)) {
        if (n is Element && n.localName?.toLowerCase() == tagLc) {
          final nd = n.getData();
          if (nd?.key == reuseKey) {
            matched = n;
            break;
          }
        }
      }
      if (matched != null && matched != current) {
        last.container.insertBefore(matched, last.current);
      }
      if (matched != null) {
        elem = matched;
        isNewElem = false;
        last.cursor++;
      }
    }

    if (elem == null) {
      elem = _view._document.createElement(tag);
      attributesToRemove = <String>{};
      if (current == null) {
        last.container.append(elem);
      } else {
        last.container.insertBefore(elem, current);
      }
      last.cursor++;
    } else {
      attributesToRemove = elem.attributes.keys.toSet().cast(); // TODO is this cast safe?
    }
    _positions.add(_Position(tag, elem));
    elem.clearOrSetAttribute('id', id);
    elem.clearOrSetAttribute('class', classes == null || classes.isEmpty ? null : classes.join(' '));
    elem.clearOrSetAttribute('style',
        styles == null || styles.isEmpty ? null : styles.entries.map((e) => '${e.key}: ${e.value}').join('; '));
    attributes?.forEach((name, value) {
      elem!.clearOrSetAttribute(name, value);
    });
    attributesToRemove.removeAll(['id', 'class', 'style', ...?attributes?.keys]);
    for (final name in attributesToRemove) {
      elem.attributes.remove(name);
    }
    var data = elem.getData();
    final hadData = data != null;

    if (events != null && events.isNotEmpty) {
      data ??= _ElementData();
      final prevEventTypes = data.events?.keys.toSet();
      data.events ??= <String, _EventBinding>{};
      final dataEvents = data.events!;
      events.forEach((type, fn) {
        prevEventTypes?.remove(type);
        final currentBinding = dataEvents[type];
        if (currentBinding != null) {
          currentBinding.fn = fn;
        } else {
          dataEvents[type] = _EventBinding(_view, elem!, type, fn);
        }
      });
      prevEventTypes?.forEach((type) {
        dataEvents.remove(type)?.clear();
      });
    } else if (data != null) {
      data.clearEvents();
    }

    if (onRemove != null) {
      data ??= _ElementData();
      data.onRemove = onRemove;

      for (var i = _positions.length - 2; i > 0; i--) {
        final elem = _positions[i].container;
        var data = elem.getData();
        if (data == null) {
          data = _ElementData();
          _elemExpando[elem] = data;
        }
        if (data.subTreeOnRemove) break;
        data.subTreeOnRemove = true;
      }
    } else if (data?.onRemove != null) {
      data!.onRemove = null;
    }

    if (data != null) {
      data.key = reuseKey;
    } else if (reuseKey != null) {
      data ??= _ElementData();
      data.key = reuseKey;
    }

    if (!hadData && data != null && data.isNotEmpty) {
      _elemExpando[elem] = data;
    } else if (hadData && (data == null || data.isEmpty)) {
      _elemExpando[elem] = null;
    }

    if (isNewElem && onCreate != null) {
      _callbacks.add(() {
        onCreate(_DomLifecycleEvent(_view, elem!));
      });
    }
    if (!isNewElem && onUpdate != null) {
      _callbacks.add(() {
        onUpdate(_DomLifecycleEvent(_view, elem!));
      });
    }
  }

  @override
  Element close({String? tag}) {
    final last = _positions.removeLast();
    if (tag != null && last.tag != tag) {
      throw AssertionError('Tag missmatch: "$tag" != "$last".');
    }

    while (last.container.nodes.length > last.cursor) {
      _onRemove(last.container.nodes.removeLast());
    }

    return last.container;
  }

  void _onRemove(Node removed) {
    if (removed is Element) {
      final data = removed.getData();
      if (data == null) return;
      if (data.subTreeOnRemove) {
        for (final e in removed.children) {
          _onRemove(e);
        }
      }
      if (data.onRemove != null) {
        _callbacks.add(() {
          data.onRemove!(_DomLifecycleEvent(_view, removed));
        });
      }
    }
  }

  @override
  void skipNode() {
    final last = _positions.last;
    if (!last.mayHaveContent) {
      throw AssertionError('Must not have content at this point.');
    }
    if (last.container.nodes.length > last.cursor) {
      last.cursor++;
    } else {
      throw AssertionError('No node to skip.');
    }
  }

  @override
  void skipRemainingNodes() {
    final last = _positions.last;
    if (!last.mayHaveContent) {
      throw AssertionError('Must not have content at this point.');
    }
    if (last.container.nodes.length > last.cursor) {
      last.cursor = last.container.nodes.length;
      last.mayHaveContent = false;
    } else {
      throw AssertionError('No node to skip.');
    }
  }

  @override
  void text(String value) {
    final last = _positions.last;
    if (!last.mayHaveContent) {
      throw AssertionError('Must not have content at this point.');
    }
    final current = last.current;
    if (current == null) {
      last.container.append(Text(value));
    } else if (current is Text) {
      if (current.text == value) {
        // nothing
      } else {
        current.text = value;
      }
    } else {
      current.replaceWith(Text(value));
    }
    last.cursor++;
  }

  @override
  void innerHtml(String value) {
    final last = _positions.last;
    if (last.cursor != 0) {
      throw AssertionError('Cursor has been moved.');
    }
    if (!last.mayHaveContent) {
      throw AssertionError('Must not have content at this point.');
    }
    last.container.innerHtml = value;
    last.cursor = last.container.nodes.length;
    last.mayHaveContent = false;
  }
}

extension ElementData on Element {
  void clearOrSetAttribute(String name, String? value) {
    final current = attributes[name];
    if (current == value) return;
    if (value == null) {
      attributes.remove(name);
    } else {
      attributes[name] = value;
    }
  }

  _ElementData? getData() {
    return _elemExpando[this];
  }
}

class _ElementData {
  String? key;
  Map<String, _EventBinding>? events;
  DomLifecycleEventFn? onRemove;
  bool subTreeOnRemove = false;

  bool get isNotEmpty => key != null || (events != null && events!.isNotEmpty) || onRemove != null || subTreeOnRemove;
  bool get isEmpty => !isNotEmpty;

  void clearEvents() {
    events?.forEach((type, binding) {
      binding.clear();
    });
    events = null;
  }
}

class _EventBinding {
  final TestDomView view;
  final Element element;
  final String type;
  DomEventFn fn;

  _EventBinding(this.view, this.element, this.type, this.fn);

  void dispatch(dynamic event) {
    fn(_DomEvent(view, type, element, event));
  }

  void clear() {}
}

final _elemExpando = Expando<_ElementData>();

class _DomLifecycleEvent implements DomLifecycleEvent<Element> {
  @override
  final DomView view;
  @override
  final Element source;

  _DomLifecycleEvent(this.view, this.source);
}

class _DomEvent implements DomEvent<Element, dynamic> {
  @override
  final DomView view;
  @override
  final String type;
  @override
  final Element source;
  @override
  final dynamic event;

  _DomEvent(this.view, this.type, this.source, this.event);
}
