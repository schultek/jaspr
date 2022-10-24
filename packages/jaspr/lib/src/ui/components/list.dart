import 'package:jaspr/jaspr.dart';
import 'package:jaspr/src/ui/components/base.dart';
import 'package:jaspr/src/ui/styles/properties/list.dart';

class ListView extends BaseComponent {
  final bool? insideMarkers;
  final Uri? markerImageUrl;
  final ListStyleType? markerType;

  const ListView({
    this.insideMarkers,
    this.markerImageUrl,
    this.markerType,
    super.key,
    super.id,
    super.styles,
    super.classes,
    super.attributes,
    super.events,
    super.children,
  }) : super(tag: 'ul');

  factory ListView.basic({List<Component>? children}) {
    return ListView(markerType: ListStyleType.none, children: children);
  }

  factory ListView.standard({List<Component>? children, ListStyleType? type}) {
    return ListView(markerType: type, children: children);
  }

  factory ListView.own({List<Component>? children, required Uri imageUrl}) {
    return ListView(markerImageUrl: imageUrl, children: children);
  }

  @override
  Styles getStyles() => Styles.combine([
    Styles.raw({
      if(markerType != null) 'list-style-type': markerType!.value,
      if(insideMarkers != null) 'list-style-position': insideMarkers! ? 'inside' : 'outside',
      if(markerImageUrl != null) 'list-style-image': 'url("$markerImageUrl")',
    }),
    if (styles != null) styles!
  ]);
}

class ListItem extends BaseComponent {
  const ListItem({
    super.key,
    super.id,
    super.styles,
    super.classes,
    super.attributes,
    super.events,
    super.child,
  }) : super(tag: 'li');
}