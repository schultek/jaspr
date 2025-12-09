/// The `pointer-events` CSS property sets under what circumstances (if any) a particular graphic element can become the
/// target of pointer events.
///
/// Read more: [MDN `pointer-events`](https://developer.mozilla.org/en-US/docs/Web/CSS/pointer-events)
enum PointerEvents {
  // Keyword values

  /// The element on its own is never the target of pointer events. However its subtree could be kept targetable by setting
  /// pointer-events to some other value. In these circumstances, pointer events will trigger event listeners on this parent
  /// element as appropriate on their way to or from the descendant during the event capture and bubble phases.
  none('none'),

  /// The element behaves as it would if the pointer-events property were not specified. In SVG content, this value and the
  /// value visiblePainted have the same effect.
  auto('auto'),

  // Values used in SVGs

  /// **SVG only (experimental for HTML).** The element can only be the target of a pointer event when the visibility
  /// property is set to visible and e.g., when a mouse cursor is over the interior (i.e., 'fill') of the element and
  /// the fill property is set to a value other than none, or when a mouse cursor is over the perimeter (i.e., 'stroke')
  /// of the element and the stroke property is set to a value other than none.
  visiblePainted('visiblePainted'),

  /// **SVG only.** The element can only be the target of a pointer event when the visibility property is set to visible
  /// and when e.g., a mouse cursor is over the interior (i.e., fill) of the element. The value of the fill property does
  /// not affect event processing.
  visibleFill('visibleFill'),

  /// **SVG only.** The element can only be the target of a pointer event when the visibility property is set to visible
  /// and e.g., when the mouse cursor is over the perimeter (i.e., stroke) of the element. The value of the stroke property
  /// does not affect event processing.
  visibleStroke('visibleStroke'),

  /// **SVG only (experimental for HTML).** The element can be the target of a pointer event when the visibility property
  /// is set to visible and e.g., the mouse cursor is over either the interior (i.e., fill) or the perimeter (i.e., stroke)
  /// of the element. The values of the fill and stroke do not affect event processing.
  visible('visible'),

  /// **SVG only (experimental for HTML).** The element can only be the target of a pointer event when e.g., the mouse
  /// cursor is over the interior (i.e., 'fill') of the element and the fill property is set to a value other than none,
  /// or when the mouse cursor is over the perimeter (i.e., 'stroke') of the element and the stroke property is set to a
  /// value other than none. The value of the visibility property does not affect event processing.
  painted('painted'),

  /// **SVG only.** The element can only be the target of a pointer event when the pointer is over the interior (i.e.,
  /// fill) of the element. The values of the fill and visibility properties do not affect event processing.
  fill('fill'),

  /// **SVG only.** The element can only be the target of a pointer event when the pointer is over the perimeter (i.e.,
  /// stroke) of the element. The values of the stroke and visibility properties do not affect event processing.
  stroke('stroke'),

  /// **SVG only.** The element can only be the target of a pointer event when the pointer is over the bounding box of
  /// the element.
  boundingBox('bounding-box'),

  /// **SVG only (experimental for HTML).** The element can only be the target of a pointer event when the pointer is
  /// over the interior (i.e., fill) or the perimeter (i.e., stroke) of the element. The values of the fill, stroke, and
  /// visibility properties do not affect event processing.
  all('all'),

  // Global values
  inherit('inherit'),
  initial('initial'),
  revert('revert'),
  revertLayer('revert-layer'),
  unset('unset');

  /// The css value
  final String value;
  const PointerEvents(this.value);
}

/// The `user-select` CSS property controls whether the user can select text. This doesn't have any effect on content
/// loaded as part of a browser's user interface (its chrome), except in textboxes.
///
/// Read more: [MDN `user-select`](https://developer.mozilla.org/en-US/docs/Web/CSS/user-select)
enum UserSelect {
  // Keyword values

  /// The text of the element and its sub-elements is not selectable. Note that the Selection object can contain these elements.
  none('none'),

  /// The used value of `auto` is determined as follows:
  ///
  /// - On the `::before` and `::after` pseudo elements, the used value is `none`.
  /// - If the used value of `user-select` on the parent of this element is `none`, the used value is `none`.
  /// - Otherwise, if the used value of `user-select` on the parent of this element is `all`, the used value is `all`.
  /// - Otherwise, the used value is `text`.
  auto('auto'),

  /// The text can be selected by the user.
  text('text'),

  /// The content of the element shall be selected atomically: If a selection would contain part of the element, then
  /// the selection must contain the entire element including all its descendants. If a double-click or context-click
  /// occurred in sub-elements, the highest ancestor with this value will be selected.
  all('all'),

  // Global values

  inherit('inherit'),
  initial('initial'),
  revert('revert'),
  revertLayer('revert-layer'),
  unset('unset');

  /// The css value
  final String value;
  const UserSelect(this.value);
}
