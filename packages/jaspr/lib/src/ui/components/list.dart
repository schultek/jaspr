import '../../../jaspr.dart';

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

enum ListType {
  ordered,
  unordered;
}

class ListView extends StatelessComponent {
  const ListView({
    super.key,
    this.type = ListType.unordered,
    this.marker,
    required this.children,
  });

  factory ListView.ordered({
    Key? key,
    ListItemMarker? marker,
    required List<Component> children,
  }) {
    return ListView(
      key: key,
      type: ListType.ordered,
      marker: marker,
      children: children,
    );
  }

  factory ListView.unordered({
    Key? key,
    ListItemMarker? marker,
    required List<Component> children,
  }) {
    return ListView(
      key: key,
      type: ListType.unordered,
      marker: marker ?? ListItemMarker(type: ListStyleType.none),
      children: children,
    );
  }

  final ListType type;
  final ListItemMarker? marker;
  final List<Component> children;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    if (type == ListType.unordered) {
      yield ul(
        styles: Styles.raw({
          if (marker?.type == ListStyleType.none) 'margin': '0',
          if (marker?.type == ListStyleType.none) 'padding': '0',
          if (marker?.type != null) 'list-style-type': marker!.type!.value,
          if (marker?.isInside != null) 'list-style-position': marker!.isInside! ? 'inside' : 'outside',
          if (marker?.imageUrl != null) 'list-style-image': 'url("${marker?.imageUrl}")',
        }),
        children,
      );
    } else {
      yield ol(
        styles: Styles.raw({
          if (marker?.type == ListStyleType.none) 'margin': '0',
          if (marker?.type == ListStyleType.none) 'padding': '0',
          if (marker?.type != null) 'list-style-type': marker!.type!.value,
          if (marker?.isInside != null) 'list-style-position': marker!.isInside! ? 'inside' : 'outside',
          if (marker?.imageUrl != null) 'list-style-image': 'url("${marker?.imageUrl}")',
        }),
        children,
      );
    }
  }
}

class ListItem extends StatelessComponent {
  const ListItem({
    super.key,
    required this.children,
  });

  final List<Component> children;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield li(children);
  }
}
