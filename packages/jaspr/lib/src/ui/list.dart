import '../../jaspr.dart';

class ListItemMarker {
  final ListStyle? style;
  final ImageStyle? image;
  final ListStylePosition? position;

  const ListItemMarker({this.style, this.image, this.position});
}

enum ListType { ordered, unordered }

class ListView extends StatelessComponent {
  const ListView({super.key, this.type = ListType.unordered, this.marker, required this.children});

  factory ListView.ordered({Key? key, ListItemMarker? marker, required List<Component> children}) {
    return ListView(key: key, type: ListType.ordered, marker: marker, children: children);
  }

  factory ListView.unordered({Key? key, ListItemMarker? marker, required List<Component> children}) {
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
  Component build(BuildContext context) {
    final styles = Styles(
      listStyle: marker?.style,
      listImage: marker?.image,
      listPosition: marker?.position,
      margin: marker?.style == ListStyle.none ? Margin.zero : null,
      padding: marker?.style == ListStyle.none ? Padding.zero : null,
    );

    if (type == ListType.unordered) {
      return ul(styles: styles, children);
    } else {
      return ol(styles: styles, children);
    }
  }
}

class ListItem extends StatelessComponent {
  const ListItem({super.key, required this.children});

  final List<Component> children;

  @override
  Component build(BuildContext context) {
    return li(children);
  }
}
