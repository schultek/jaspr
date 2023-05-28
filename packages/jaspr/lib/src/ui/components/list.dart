import '../../../components.dart';
import '../styles/properties/list.dart';

class ListItemMarker {
  final bool? isInside;
  final Uri? imageUrl;
  final ListStyleType? type;

  const ListItemMarker({
    this.isInside,
    this.imageUrl,
    this.type,
  });
}

class ListView extends BaseComponent {
  final ListItemMarker? marker;

  const ListView({
    this.marker,
    required super.tag,
    super.key,
    super.id,
    super.styles,
    super.classes,
    super.attributes,
    super.events,
    super.children,
  });

  factory ListView.ordered({
    Key? key,
    String? id,
    Styles? styles,
    List<String>? classes,
    Map<String, String>? attributes,
    Map<String, EventCallback>? events,
    List<ListItem>? children,
    ListItemMarker? marker,
  }) {
    return ListView(
      key: key,
      id: id,
      styles: styles,
      classes: classes,
      attributes: attributes,
      events: events,
      children: children,
      tag: 'ol',
      marker: marker,
    );
  }

  factory ListView.unordered({
    Key? key,
    String? id,
    Styles? styles,
    List<String>? classes,
    Map<String, String>? attributes,
    Map<String, EventCallback>? events,
    List<ListItem>? children,
    ListItemMarker? marker,
  }) {
    return ListView(
      key: key,
      id: id,
      styles: styles,
      classes: classes,
      attributes: attributes,
      events: events,
      children: children,
      tag: 'ul',
      marker: marker,
    );
  }

  @override
  Styles getStyles() => Styles.combine([
        Styles.raw({
          if (marker?.type == ListStyleType.none) 'margin': '0',
          if (marker?.type == ListStyleType.none) 'padding': '0',
          if (marker?.type != null) 'list-style-type': marker!.type!.value,
          if (marker?.isInside != null) 'list-style-position': marker!.isInside! ? 'inside' : 'outside',
          if (marker?.imageUrl != null) 'list-style-image': 'url("${marker?.imageUrl}")',
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
