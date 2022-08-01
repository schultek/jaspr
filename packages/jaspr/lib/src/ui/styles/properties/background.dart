import 'unit.dart';

/// The background-attachment CSS property sets whether a background image's position is fixed within the viewport, or scrolls with its containing block.
enum BackgroundAttachment {
  /// The background is fixed relative to the element itself and does not scroll with its contents. (It is effectively attached to the element's border.)
  scroll('scroll'),

  /// The background is fixed relative to the viewport. Even if an element has a scrolling mechanism, the background doesn't move with the element. (This is not compatible with background-clip: text.)
  fixed('fixed'),

  /// The background is fixed relative to the element's contents. If the element has a scrolling mechanism, the background scrolls with the element's contents, and the background painting area and background positioning area are relative to the scrollable area of the element rather than to the border framing them.
  local('local'),

  inherit('inherit'),
  initial('initial'),
  revert('revert'),
  revertLayer('revert-layer'),
  unset('unset');

  /// The css value
  final String value;
  const BackgroundAttachment(this.value);
}

/// The background-clip CSS property sets whether an element's background extends underneath its border box, padding box, or content box.
enum BackgroundClip {
  /// The background extends to the outside edge of the border (but underneath the border in z-ordering).
  borderBox('border-box'),

  /// The background extends to the outside edge of the padding. No background is drawn beneath the border.
  paddingBox('padding-box'),

  /// The background is painted within (clipped to) the content box.
  contentBox('content-box'),

  /// The background is painted within (clipped to) the foreground text.
  text('text'),

  inherit('inherit'),
  initial('initial'),
  revert('revert'),
  revertLayer('revert-layer'),
  unset('unset');

  /// The css value
  final String value;
  const BackgroundClip(this.value);
}

/// The background-image CSS property sets one or more background images on an element.
class BackgroundImage {
  /// The css value
  final String value;

  const BackgroundImage._(this.value);

  static const BackgroundImage none = BackgroundImage._('none');

  const factory BackgroundImage.image(ImageStyle image) = _ImageBackgroundImage;

  // TODO multiple background images

  static const BackgroundImage inherit = BackgroundImage._('inherit');
  static const BackgroundImage initial = BackgroundImage._('initial');
  static const BackgroundImage revert = BackgroundImage._('revert');
  static const BackgroundImage revertLayer = BackgroundImage._('revert-layer');
  static const BackgroundImage unset = BackgroundImage._('unset');
}

class _ImageBackgroundImage implements BackgroundImage {
  final ImageStyle image;
  const _ImageBackgroundImage(this.image);

  @override
  String get value => image.value;
}

class ImageStyle {
  /// The css value
  final String value;

  const ImageStyle.url(String url) : value = 'url($url)';

  // TODO
  // const ImageStyle.gradient() : value = '';

  // TODO element, image, crossFade, imageSet
}

/// The background-origin CSS property sets the background's origin: from the border start, inside the border, or inside the padding.
enum BackgroundOrigin {
  /// The background is positioned relative to the border box.
  borderBox('border-box'),

  /// The background is positioned relative to the padding box.
  paddingBox('padding-box'),

  /// The background is positioned relative to the content box.
  contentBox('content-box'),

  inherit('inherit'),
  initial('initial'),
  revert('revert'),
  revertLayer('revert-layer'),
  unset('unset');

  /// The css value
  final String value;
  const BackgroundOrigin(this.value);
}

/// The background-position CSS property sets the initial position for each background image. The position is relative to the position layer set by background-origin.
class BackgroundPosition {
  /// The css value
  final String value;

  const BackgroundPosition._(this.value);

  static const BackgroundPosition center = BackgroundPosition._('center');
  const factory BackgroundPosition({BackgroundAlignX? alignX, BackgroundAlignY? alignY, Unit? offsetX, Unit? offsetY}) =
      _BackgroundPosition;

  static const BackgroundPosition inherit = BackgroundPosition._('inherit');
  static const BackgroundPosition initial = BackgroundPosition._('initial');
  static const BackgroundPosition revert = BackgroundPosition._('revert');
  static const BackgroundPosition revertLayer = BackgroundPosition._('revert-layer');
  static const BackgroundPosition unset = BackgroundPosition._('unset');
}

enum BackgroundAlignX { left, center, right }

enum BackgroundAlignY { top, center, bottom }

class _BackgroundPosition implements BackgroundPosition {
  final BackgroundAlignX? alignX;
  final BackgroundAlignY? alignY;
  final Unit? offsetX;
  final Unit? offsetY;

  const _BackgroundPosition({this.alignX, this.alignY, this.offsetX, this.offsetY});

  @override
  String get value {
    var x = [if (alignX != null) alignX!.name, if (offsetX != null) offsetX!.value];
    var y = [if (alignY != null) alignY!.name, if (offsetY != null) offsetY!.value];
    if (x.isEmpty) {
      x.add('left');
    } else if (x.length == 1 && y.length == 2 && alignX == null) {
      x.insert(0, 'left');
    } else if (x.length == 2 && y.length == 1 && alignY == null) {
      y.insert(0, 'top');
    }
    return [...x, ...y].join(' ');
  }
}

/// The background-repeat CSS property sets how background images are repeated. A background image can be repeated along the horizontal and vertical axes, or not repeated at all.
class BackgroundRepeat {
  /// The css value
  final String value;

  const BackgroundRepeat._(this.value);

  static const BackgroundRepeat repeatX = BackgroundRepeat._('repeat-y');
  static const BackgroundRepeat repeatY = BackgroundRepeat._('repeat-y');
  static const BackgroundRepeat repeat = BackgroundRepeat._('repeat');
  static const BackgroundRepeat space = BackgroundRepeat._('space');
  static const BackgroundRepeat round = BackgroundRepeat._('round');
  static const BackgroundRepeat noRepeat = BackgroundRepeat._('no-repeat');

  const factory BackgroundRepeat.axis(BackgroundAxisRepeat x, BackgroundAxisRepeat y) = _AxisBackgroundRepeat;

  static const BackgroundRepeat inherit = BackgroundRepeat._('inherit');
  static const BackgroundRepeat initial = BackgroundRepeat._('initial');
  static const BackgroundRepeat revert = BackgroundRepeat._('revert');
  static const BackgroundRepeat revertLayer = BackgroundRepeat._('revert-layer');
  static const BackgroundRepeat unset = BackgroundRepeat._('unset');
}

/// The background-repeat CSS property sets how background images are repeated.
enum BackgroundAxisRepeat {
  /// The image is repeated as much as needed to cover the whole background image painting area. The last image will be clipped if it doesn't fit.
  repeat('repeat'),

  /// The image is repeated as much as possible without clipping. The first and last images are pinned to either side of the element, and whitespace is distributed evenly between the images. The background-position property is ignored unless only one image can be displayed without clipping. The only case where clipping happens using space is when there isn't enough room to display one image.
  space('space'),

  /// As the allowed space increases in size, the repeated images will stretch (leaving no gaps) until there is room (space left >= half of the image width) for another one to be added. When the next image is added, all of the current ones compress to allow room. Example: An image with an original width of 260px, repeated three times, might stretch until each repetition is 300px wide, and then another image will be added. They will then compress to 225px.
  round('round'),

  /// The image is not repeated (and hence the background image painting area will not necessarily be entirely covered). The position of the non-repeated background image is defined by the background-position CSS property.
  noRepeat('no-repeat');

  /// The css value
  final String value;
  const BackgroundAxisRepeat(this.value);
}

class _AxisBackgroundRepeat implements BackgroundRepeat {
  final BackgroundAxisRepeat x;
  final BackgroundAxisRepeat y;

  const _AxisBackgroundRepeat(this.x, this.y);

  @override
  String get value => '${x.value} ${y.value}';
}

/// The background-size CSS property sets the size of the element's background image. The image can be left to its natural size, stretched, or constrained to fit the available space.
class BackgroundSize {
  /// The css value
  final String value;

  const BackgroundSize._(this.value);

  static const BackgroundSize contain = BackgroundSize._('contain');
  static const BackgroundSize cover = BackgroundSize._('cover');

  const factory BackgroundSize.width(Unit? width) = _WidthBackgroundSize;
  const factory BackgroundSize.sides(Unit? width, Unit? height) = _SidesBackgroundSize;

  static const BackgroundSize inherit = BackgroundSize._('inherit');
  static const BackgroundSize initial = BackgroundSize._('initial');
  static const BackgroundSize revert = BackgroundSize._('revert');
  static const BackgroundSize revertLayer = BackgroundSize._('revert-layer');
  static const BackgroundSize unset = BackgroundSize._('unset');
}

class _WidthBackgroundSize implements BackgroundSize {
  final Unit? width;
  const _WidthBackgroundSize(this.width);

  @override
  String get value => width?.value ?? 'auto';
}

class _SidesBackgroundSize implements BackgroundSize {
  final Unit? width;
  final Unit? height;
  const _SidesBackgroundSize(this.width, this.height);

  @override
  String get value => '${width?.value ?? 'auto'} ${height?.value ?? 'auto'}';
}
