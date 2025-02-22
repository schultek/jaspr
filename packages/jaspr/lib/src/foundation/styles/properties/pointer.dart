/// The pointer-events CSS property sets under what circumstances (if any) a particular graphic element can become the target of pointer events.
enum PointerEvents {
  // Keyword values

  /// The element on its own is never the target of pointer events. However its subtree could be kept targetable by setting pointer-events to some other value. In these circumstances, pointer events will trigger event listeners on this parent element as appropriate on their way to or from the descendant during the event capture and bubble phases.
  none("none"),

  /// The element behaves as it would if the pointer-events property were not specified. In SVG content, this value and the value visiblePainted have the same effect.
  auto("auto"),

  // Values used in SVGs
  visiblePainted("visiblePainted"),
  visibleFill("visibleFill"),
  visibleStroke("visibleStroke"),
  visible("visible"),
  painted("painted"),
  fill("fill"),
  stroke("stroke"),
  boundingBox("bounding-box"),
  all("all"),

  // Global values
  inherit("inherit"),
  initial("initial"),
  revert("revert"),
  revertLayer("revert-layer"),
  unset("unset");

  /// The css value
  final String value;
  const PointerEvents(this.value);
}

/// The user-select CSS property controls whether the user can select text. This doesn't have any effect on content loaded as part of a browser's user interface (its chrome), except in textboxes.
enum UserSelect {
  // Keyword values

  /// The text of the element and its sub-elements is not selectable. Note that the Selection object can contain these elements.
  none("none"),
  /// The used value of auto is determined as follows:
  /// 
  /// On the ::before and ::after pseudo elements, the used value is none
  /// If the used value of user-select on the parent of this element is none, the used value is none
  /// Otherwise, if the used value of user-select on the parent of this element is all, the used value is all
  /// Otherwise, the used value is text
  auto("auto"),
  /// The text can be selected by the user.
  text("text"),
  /// The content of the element shall be selected atomically: If a selection would contain part of the element, then the selection must contain the entire element including all its descendants. If a double-click or context-click occurred in sub-elements, the highest ancestor with this value will be selected.
  all("all"),

  // Global values
  
  inherit("inherit"),
  initial("initial"),
  revert("revert"),
  revertLayer("revert-layer"),
  unset("unset");

  /// The css value
  final String value;
  const UserSelect(this.value);
}
