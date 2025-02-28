import 'dart:async';
import 'dart:io';

import 'package:fbh_front_matter/fbh_front_matter.dart' as fm;
import 'package:jaspr/jaspr.dart';

import '../jaspr_content.dart';
import 'pages_repository.dart';

class Page {
  Page(this.path, this.content, this.data, this.config, this._repository);

  final String path;
  String content;
  Map<String, dynamic> data;
  final PageConfig config;

  final PagesRepository _repository;

  void apply({String? content, Map<String, dynamic>? data, bool mergeData = true}) {
    this.content = content ?? this.content;
    if (mergeData && data != null) {
      this.data = this.data.merge(data);
    } else {
      this.data = data ?? this.data;
    }
  }

  static Component wrap(Page page, Component child) {
    return _InheritedPage(page: page, child: child);
  }

  File access(Uri path) {
    return _repository.access(path, this);
  }
}

class PageConfig {
  const PageConfig({this.templateEngine, this.components, this.layouts});

  final TemplateEngine? templateEngine;
  final ComponentsConfig? components;
  final LayoutsConfig? layouts;
}

extension PageHandlers on Page {
  void parseFrontmatter() {
    final document = fm.parse(content);
    apply(content: document.content, data: document.data.cast());
  }

  FutureOr<void> renderTemplate() {
    if (config.templateEngine != null) {
      return config.templateEngine!.render(this);
    }
  }

  Component buildLayout(Component child) {
    if (config.layouts != null) {
      return config.layouts!.buildLayout(this, child);
    }
    return child;
  }
}

extension PageContext on BuildContext {
  Page get page => dependOnInheritedComponentOfExactType<_InheritedPage>()!.page;

  List<Page> get pages {
    var pages = page.data['pages'];
    return pages is List<Page> ? pages : [];
  }
}

class _InheritedPage extends InheritedComponent {
  _InheritedPage({required this.page, super.child});

  final Page page;

  @override
  bool updateShouldNotify(covariant _InheritedPage oldComponent) {
    return oldComponent.page != page;
  }
}

extension MergeData on Map<String, dynamic> {
  Map<String, dynamic> merge(Map<String, dynamic> other) {
    var merged = <String, dynamic>{};
    var otherKeys = other.keys.toSet();
    for (var key in keys) {
      if (otherKeys.remove(key)) {
        if (this[key] is Map<String, dynamic> && other[key] is Map<String, dynamic>) {
          merged[key] = (this[key] as Map<String, dynamic>).merge(other[key] as Map<String, dynamic>);
        } else {
          merged[key] = other[key];
        }
      } else {
        merged[key] = this[key];
      }
    }
    for (var key in otherKeys) {
      merged[key] = other[key];
    }
    return merged;
  }
}
