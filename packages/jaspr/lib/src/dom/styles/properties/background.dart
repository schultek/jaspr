import 'unit.dart';

/// The `background-attachment` CSS property sets whether a background image's
/// position is fixed within the viewport or scrolls with its containing block.
///
/// Read more: [MDN `background-attachment`](https://developer.mozilla.org/en-US/docs/Web/CSS/background-attachment)
enum BackgroundAttachment {
  /// The background is fixed relative to the element itself and does not scroll
  /// with its contents. (It is effectively attached to the element's border.)
  scroll('scroll'),

  /// The background is fixed relative to the viewport. Even if an element has
  /// a scrolling mechanism, the background doesn't move with the element.
  /// (This is not compatible with background-clip: text.)
  fixed('fixed'),

  /// The background is fixed relative to the element's contents. If the element
  /// has a scrolling mechanism, the background scrolls with the element's contents,
  /// and the background painting area and background positioning area are relative
  /// to the scrollable area of the element rather than to the border framing them.
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

/// The `background-clip` CSS property sets whether an element's background
/// extends underneath its border box, padding box, or content box.
///
/// Read more: [MDN `background-clip`](https://developer.mozilla.org/en-US/docs/Web/CSS/background-clip)
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

/// The `background-image` CSS property sets one or more background images on
/// an element. It accepts images (`url()`), gradients, and the keyword `none`.
///
/// Read more: [MDN `background-image`](https://developer.mozilla.org/en-US/docs/Web/CSS/background-image)
class BackgroundImage {
  // TODO: support multiple layered images and gradients.

  /// The css value
  final String value;

  const BackgroundImage._(this.value);

  /// No background image (CSS `none`).
  static const BackgroundImage none = BackgroundImage._('none');

  /// Create a background image from an `ImageStyle` such as `url()`.
  const factory BackgroundImage.image(ImageStyle image) = _ImageBackgroundImage;

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

/// Helper representing an image style value such as `url(...)` or gradients.
class ImageStyle {
  /// The css value
  final String value;

  /// Creates an image style with `url(...)` syntax.
  const ImageStyle.url(String url) : value = 'url($url)';

  // TODO: gradients, image-set(), cross-fade(), element() etc.
}

/// The `background-origin` CSS property sets the background's origin: which
/// box (border-box, padding-box or content-box) the background's position is
/// relative to.
///
/// Read more: [MDN `background-origin`](https://developer.mozilla.org/en-US/docs/Web/CSS/background-origin)
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

/// The `background-position` CSS property sets the initial position for each
/// background image. The position is relative to the box established by
/// `background-origin`.
///
/// Read more: [MDN `background-position`](https://developer.mozilla.org/en-US/docs/Web/CSS/background-position)
class BackgroundPosition {
  /// The css value
  final String value;

  const BackgroundPosition._(this.value);

  /// A shorthand for the centered background position (`center`).
  static const BackgroundPosition center = BackgroundPosition._('center');

  /// Construct a background position from optional alignments and offsets.
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
    final x = [if (alignX != null) alignX!.name, if (offsetX != null) offsetX!.value];
    final y = [if (alignY != null) alignY!.name, if (offsetY != null) offsetY!.value];
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

/// The `background-repeat` CSS property sets how background images are
/// repeated. A background image can be repeated along the horizontal
/// and vertical axes, or not repeated at all.
///
/// Read more: [MDN `background-repeat`](https://developer.mozilla.org/en-US/docs/Web/CSS/background-repeat)
class BackgroundRepeat {
  /// The css value
  final String value;

  const BackgroundRepeat._(this.value);

  /// The default value. The image is repeated as many times as needed to cover the entire background image painting
  /// area, with the edge image being clipped if the dimension of the painting area is not a multiple of the dimension
  /// of your background image.
  static const BackgroundRepeat repeat = BackgroundRepeat._('repeat');

  /// The image is not repeated (and hence the background image painting area will not necessarily be entirely covered).
  /// The position of the non-repeated background image is defined by the background-position CSS property.
  static const BackgroundRepeat noRepeat = BackgroundRepeat._('no-repeat');

  /// The image is repeated as much as possible without clipping. The first and last images are pinned to either side of
  /// the element, and whitespace is distributed evenly between the images. The background-position property is ignored
  /// unless only one image can be displayed without clipping. The only case where clipping happens using space is when
  /// there isn't enough room to display one image.
  static const BackgroundRepeat space = BackgroundRepeat._('space');

  /// As the allowed space increases in size, the repeated images will stretch (leaving no gaps) until there is room for
  /// another one to be added. This is the only `<repeat-style>` value that can lead to the distortion of the background
  /// image's aspect ratio, which will occur if the aspect ratio of the background image differs from the aspect ratio
  /// of the background paint area.
  static const BackgroundRepeat round = BackgroundRepeat._('round');

  /// The background image repeats horizontally only, with the edge image being clipped if the width of the paint area
  /// is not a multiple of the background image's width.
  static const BackgroundRepeat repeatX = BackgroundRepeat._('repeat-x');

  /// The background image repeats vertically only, with the edge image being clipped if the height of the paint area is
  /// not a multiple of the background image's height.
  static const BackgroundRepeat repeatY = BackgroundRepeat._('repeat-y');

  /// Create an axis-specific repeat value from two axis repeat values.
  const factory BackgroundRepeat.axis(BackgroundAxisRepeat x, BackgroundAxisRepeat y) = _AxisBackgroundRepeat;

  static const BackgroundRepeat inherit = BackgroundRepeat._('inherit');
  static const BackgroundRepeat initial = BackgroundRepeat._('initial');
  static const BackgroundRepeat revert = BackgroundRepeat._('revert');
  static const BackgroundRepeat revertLayer = BackgroundRepeat._('revert-layer');
  static const BackgroundRepeat unset = BackgroundRepeat._('unset');
}

/// The background-repeat CSS property sets how background images are repeated.
/// Per-axis values for the [BackgroundRepeat] property.
enum BackgroundAxisRepeat {
  /// The image is repeated as much as needed to cover the whole background image painting area. The last image will be
  /// clipped if it doesn't fit.
  repeat('repeat'),

  /// The image is repeated as much as possible without clipping. The first and last images are pinned to either side of
  /// the element, and whitespace is distributed evenly between the images. The background-position property is ignored
  /// unless only one image can be displayed without clipping. The only case where clipping happens using space is when
  /// there isn't enough room to display one image.
  space('space'),

  /// As the allowed space increases in size, the repeated images will stretch (leaving no gaps) until there is room for
  /// another one to be added. This is the only `<repeat-style>` value that can lead to the distortion of the background
  /// image's aspect ratio, which will occur if the aspect ratio of the background image differs from the aspect ratio
  /// of the background paint area.
  round('round'),

  /// The image is not repeated (and hence the background image painting area will not necessarily be entirely covered).
  /// The position of the non-repeated background image is defined by the background-position CSS property.
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

/// The background-size CSS property sets the size of the element's background
/// image. The image can be left to its natural size, stretched, or constrained
/// to fit the available space.
class BackgroundSize {
  /// The css value
  final String value;

  const BackgroundSize._(this.value);

  /// The `contain` keyword: scale the image to be as large as possible while
  /// maintaining aspect ratio and fitting inside the background painting area.
  static const BackgroundSize contain = BackgroundSize._('contain');

  /// The `cover` keyword: scale the image to cover the whole background
  /// painting area while preserving aspect ratio; image may be cropped.
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
