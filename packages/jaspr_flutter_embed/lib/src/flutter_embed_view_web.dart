import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import 'flutter_embed_view_fallback.dart' as fallback;
import 'flutter_embed_view_flutter.dart' deferred as flutter;
import 'view_constraints.dart';
import 'widget.dart';

class FlutterEmbedView extends StatefulComponent {
  const FlutterEmbedView({
    this.id,
    this.classes,
    this.styles,
    this.constraints,
    this.loader,
    this.widget,
    super.key,
  }) : loadLibrary = null,
       builder = null;

  const FlutterEmbedView.deferred({
    this.id,
    this.classes,
    this.styles,
    this.constraints,
    this.loader,
    this.loadLibrary,
    this.builder,
    super.key,
  }) : widget = null;

  final String? id;
  final String? classes;
  final Styles? styles;
  final ViewConstraints? constraints;
  final Component? loader;
  final Future<void>? loadLibrary;
  final Widget? widget;
  final Widget Function()? builder;

  static final Future<void> _libraryFuture = flutter.loadLibrary().then((_) => flutter.FlutterEmbedView.preload());

  static Future<void> preload() => _libraryFuture;

  @override
  State<StatefulComponent> createState() => _FlutterEmbedViewState();

  Component _buildFlutter() {
    return flutter.FlutterEmbedView(
      id: id,
      classes: classes,
      styles: styles,
      constraints: constraints,
      loader: loader,
      // Casted to dynamic to work around different widget types
      // without needing to import the one from Flutter.
      // ignore: argument_type_not_assignable
      widget: (widget ?? builder?.call()) as dynamic,
    );
  }

  Component _buildFallback() {
    return fallback.FlutterEmbedView(
      id: id,
      classes: classes,
      styles: styles,
      constraints: constraints,
      loader: loader,
    );
  }
}

class _FlutterEmbedViewState extends State<FlutterEmbedView> {
  bool flutterLoading = true;
  bool libraryLoading = true;

  @override
  void initState() {
    super.initState();

    FlutterEmbedView._libraryFuture.whenComplete(() {
      if (!mounted) return;
      setState(() {
        flutterLoading = false;
      });
    });

    if (component.loadLibrary case final loadLibrary?) {
      loadLibrary.whenComplete(() {
        if (!mounted) return;
        setState(() {
          libraryLoading = false;
        });
      });
    } else {
      libraryLoading = false;
    }
  }

  @override
  Component build(BuildContext context) {
    if (flutterLoading || libraryLoading) {
      return component._buildFallback();
    }

    return component._buildFlutter();
  }
}
