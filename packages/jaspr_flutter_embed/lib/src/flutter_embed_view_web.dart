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
  })  : loadLibrary = null,
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
  final Future? loadLibrary;
  final Widget? widget;
  final Widget Function()? builder;

  static final Future<void> _libraryFuture = flutter.loadLibrary().then((_) => flutter.FlutterEmbedView.preload());

  static Future<void> preload() => _libraryFuture;

  @override
  State<StatefulComponent> createState() => FlutterEmbedViewState();

  Component _buildFlutter() {
    return flutter.FlutterEmbedView(
      id: id,
      classes: classes,
      styles: styles,
      constraints: constraints,
      loader: loader,
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

class FlutterEmbedViewState extends State<FlutterEmbedView> {
  var flutterLoading = true;
  var libraryLoading = true;

  @override
  void initState() {
    super.initState();

    FlutterEmbedView._libraryFuture.whenComplete(() {
      if (!mounted) return;
      setState(() {
        flutterLoading = false;
      });
    });

    if (component.loadLibrary != null) {
      component.loadLibrary!.whenComplete(() {
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
