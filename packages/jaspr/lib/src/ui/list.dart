import '../../jaspr.dart';

class ListItemMarker {
  final ListStyle? style;
  final ImageStyle? image;
  final ListStylePosition? position;

  const ListItemMarker({
    this.style,
    this.image,
    this.position,
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
      marker: marker ?? ListItemMarker(style: ListStyle.none),
      children: children,
    );
  }

  final ListType type;
  final ListItemMarker? marker;
  final List<Component> children;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    final styles = Styles.list(
      style: marker?.style,
      image: marker?.image,
      position: marker?.position,
    ).box(
      margin: marker?.style == ListStyle.none ? EdgeInsets.zero : null,
      padding: marker?.style == ListStyle.none ? EdgeInsets.zero : null,
    );

    if (type == ListType.unordered) {
      yield ul(
        styles: styles,
        children,
      );
    } else {
      yield ol(
        styles: styles,
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
