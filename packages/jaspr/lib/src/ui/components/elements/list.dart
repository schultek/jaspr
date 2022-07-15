import 'package:jaspr/components.dart';

class ListView extends Box {
  final bool ordered;
  final bool? defaultType;
  final bool? insideMarkers;
  final String? markerImageUrl;

  const ListView({
    this.ordered = false,
    this.defaultType,
    this.insideMarkers,
    this.markerImageUrl,
    super.key,
    super.id,
    super.style,
    super.classes,
    super.attributes,
    super.events,
    super.children,
  }) : super(tag: ordered ? 'ol' : 'ul');

  @override
  BaseStyle getStyles() => MultipleStyle(
    styles: [
      if(defaultType == false) Style('list-style-type', ordered ? 'upper-roman' : 'square'),
      if(insideMarkers != null) Style('list-style-position', insideMarkers! ? 'inside' : 'outside'),
      if(markerImageUrl != null) Style('list-style-image', 'url("$markerImageUrl")'),
    ]
  );
}

class ListItem extends Box {
  const ListItem({
    super.key,
    super.id,
    super.style,
    super.classes,
    super.attributes,
    super.events,
    super.child,
  }) : super(tag: 'li');
}
