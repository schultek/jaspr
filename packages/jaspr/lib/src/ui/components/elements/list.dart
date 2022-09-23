import 'package:jaspr/components.dart';
import 'package:jaspr/styles.dart';

class ListView extends Box {
  final bool ordered;
  final ListMarkerType? markerType;
  final ListMarkerPosition? markerPosition;
  final ListMarkerImage? markerImage;

  const ListView({
    this.ordered = false,
    this.markerType,
    this.markerPosition,
    this.markerImage,
    super.key,
    super.id,
    super.style,
    super.classes,
    super.attributes,
    super.events,
    super.children,
  }) : super(tag: ordered ? 'ol' : 'ul');

  @override
  Styles getStyles() => Styles.combine(
      [super.getStyles(), Styles.list(markerType: markerType, markerPosition: markerPosition, markerImage: markerImage)]);
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
