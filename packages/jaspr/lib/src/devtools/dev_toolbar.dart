import 'package:universal_web/js_interop.dart';
import 'package:universal_web/web.dart' as web;

import '../../client.dart';
import '../../dom.dart';
import '../client/slotted_child_view.dart';
import 'components/element_properties.dart';
import 'components/highlighted_element.dart';
import 'dev_tools_service.dart';
import 'icons.dart';

enum Attachment { top, bottom, left, right }

class JasprDevToolbar extends StatefulComponent {
  const JasprDevToolbar({super.key});

  @override
  State<JasprDevToolbar> createState() => _JasprDevToolbarState();
}

class _JasprDevToolbarState extends State<JasprDevToolbar> {
  final glassKey = GlobalNodeKey();

  bool active = true;
  Attachment attachment = Attachment.bottom;
  bool settingsOpened = false;
  bool showPropertyTooltips = true;

  bool isInspecting = false;
  bool isInspectingLayout = false;
  final List<HighlightedElement> boundaryElements = [];
  HighlightedElement? selectedElement;

  bool isDragging = false;
  Attachment? activeDropZone;
  (double, double) _dragStart = (0, 0);
  (double, double) _dragDelta = (0, 0);
  web.EventListener? _dragMoveListener;
  web.EventListener? _dragEndListener;

  @override
  void initState() {
    super.initState();
    DevToolsService.instance.selectedElement.addListener(_onElementSelected);
    active = web.window.sessionStorage.getItem('jaspr.dev-toolbar.active') != 'false';
    attachment = Attachment.values.byName(
      web.window.sessionStorage.getItem('jaspr.dev-toolbar.attachment') ?? 'bottom',
    );
  }

  @override
  void dispose() {
    DevToolsService.instance.selectedElement.removeListener(_onElementSelected);
    super.dispose();
  }

  void toggleInspectMode() {
    selectedElement = null;
    boundaryElements.clear();
    if (!isInspecting) {
      _inspectClientComponents(false);
    }
    setState(() {
      isInspecting = !isInspecting;
      isInspectingLayout = false;
      settingsOpened = false;
    });
  }

  void toggleInspectLayoutMode() {
    selectedElement = null;
    boundaryElements.clear();
    if (!isInspectingLayout) {
      _inspectClientComponents();
    }
    setState(() {
      isInspectingLayout = !isInspectingLayout;
      isInspecting = false;
      settingsOpened = false;
    });
  }

  void _inspectClientComponents([bool showDetails = true]) {
    void findClientApp(Element e) {
      if (e.component is ClientApp) {
        e.visitChildElements((e) {
          assert(e.component is SlottedChildView);
          e.visitChildElements((e) {
            assert(e is ChildSlotElement);
            final props = e.component.debugFillProperties();
            e.visitChildElements((e) {
              boundaryElements.add(
                HighlightedElement(
                  e,
                  HighlightStyle.boundary,
                  showLabel: showDetails,
                  showProperties: showDetails,
                  showOnHover: true,
                  properties: showDetails ? props : null,
                ),
              );
            });
          });
        });
        return;
      }
      e.visitChildElements(findClientApp);
    }

    context.binding.rootElement?.visitChildElements(findClientApp);
  }

  void _onElementSelected() {
    final element = DevToolsService.instance.selectedElement.value;
    setState(() {
      selectedElement = element != null
          ? HighlightedElement(element, HighlightStyle.client, showProperties: showPropertyTooltips)
          : null;
    });
  }

  void _handleClickEvent(web.Event event) {
    if (!isInspecting) return;
    final e = event as web.MouseEvent;
    final targetElement = _getHoveredElement(e);

    if (targetElement == null) return;

    setState(() {
      isInspecting = false;
    });
    DevToolsService.instance.selectElement(targetElement);
  }

  void _handleMoveEvent(web.Event event) {
    if (!isInspecting) return;
    if (isDragging) return;

    final e = event as web.MouseEvent;
    final targetElement = _getHoveredElement(e);

    if (targetElement == null) return;
    if (selectedElement?.element == targetElement) return;

    setState(() {
      selectedElement = HighlightedElement(targetElement, HighlightStyle.client, showProperties: showPropertyTooltips);
    });
  }

  void _handleOutEvent(web.Event event) {
    if (!isInspecting) return;
    if (isDragging) return;

    setState(() {
      selectedElement = null;
    });
  }

  Element? _getHoveredElement(web.MouseEvent event) {
    final targetNodes = web.document.elementsFromPoint(event.clientX, event.clientY).toDart;
    final targetNode = targetNodes.where((n) => n != glassKey.currentNode).firstOrNull;

    if (targetNode == null) {
      return null;
    }
    Element? element;
    web.Node? current = targetNode;
    while (current != null) {
      element = DevToolsService.instance.domRegistry[current];
      if (element != null) return element;
      current = current.parentNode;
    }

    return null;
  }

  void _startDrag(web.Event e) {
    e.preventDefault();
    final ext = e as web.MouseEvent;
    setState(() {
      isDragging = true;
      _dragStart = (ext.clientX.toDouble(), ext.clientY.toDouble());
      _dragDelta = (0, 0);
      settingsOpened = false;
      activeDropZone = attachment;
      if (isInspecting) {
        selectedElement = null;
      }
    });

    _dragMoveListener = _onDragMove.toJS;
    _dragEndListener = _onDragEnd.toJS;

    web.window.addEventListener('mousemove', _dragMoveListener!);
    web.window.addEventListener('mouseup', _dragEndListener!);
  }

  void _onDragMove(web.Event e) {
    if (!isDragging) return;
    final ext = e as web.MouseEvent;
    final x = ext.clientX.toDouble();
    final y = ext.clientY.toDouble();

    setState(() {
      _dragDelta = (x - _dragStart.$1, y - _dragStart.$2);
      activeDropZone = _getDropZone(x, y);
    });
  }

  void _onDragEnd(web.Event e) {
    if (_dragMoveListener != null) {
      web.window.removeEventListener('mousemove', _dragMoveListener!);
      _dragMoveListener = null;
    }
    if (_dragEndListener != null) {
      web.window.removeEventListener('mouseup', _dragEndListener!);
      _dragEndListener = null;
    }

    setState(() {
      isDragging = false;
      if (activeDropZone != null) {
        attachment = activeDropZone!;
        web.window.sessionStorage.setItem('jaspr.dev-toolbar.attachment', attachment.name);
      }
      activeDropZone = null;
      _dragDelta = (0, 0);
    });
  }

  Attachment? _getDropZone(double x, double y) {
    // If window sizes aren't ready natively, provide a fallback safe cast
    final wInnerWidth = web.window.innerWidth;
    final wInnerHeight = web.window.innerHeight;
    final width = (wInnerWidth as num?)?.toDouble() ?? 1000.0;
    final height = (wInnerHeight as num?)?.toDouble() ?? 1000.0;

    final distTop = y;
    final distBottom = height - y;
    final distLeft = x;
    final distRight = width - x;

    final minDist = [distTop, distBottom, distLeft, distRight].reduce((da, db) => da < db ? da : db);

    if (minDist == distTop) return Attachment.top;
    if (minDist == distBottom) return Attachment.bottom;
    if (minDist == distLeft) return Attachment.left;
    return Attachment.right;
  }

  void _disableToolbar() {
    web.window.sessionStorage.setItem('jaspr.dev-toolbar.active', 'false');
    setState(() => active = false);
  }

  final stylesChild = Document.head(
    children: [
      Style(
        styles: [
          ...HighlightedElement.styles,
          ...ElementPropertiesTooltip.styles,
          ...styles,
        ],
      ),
    ],
  );

  @override
  Component build(BuildContext context) {
    if (!active) return Component.empty();

    return fragment([
      stylesChild,
      if (isInspecting || isInspectingLayout)
        div(
          key: glassKey,
          classes: 'jaspr-dev-toolbar-glass',
          events: {
            'click': _handleClickEvent,
            'mousemove': _handleMoveEvent,
            'mouseout': _handleOutEvent,
          },
          [],
        ),
      for (final element in boundaryElements) element,
      ?selectedElement,
      if (isDragging) ...[
        _DevToolbarDropZone.create(Attachment.top, activeDropZone == Attachment.top),
        _DevToolbarDropZone.create(Attachment.bottom, activeDropZone == Attachment.bottom),
        _DevToolbarDropZone.create(Attachment.left, activeDropZone == Attachment.left),
        _DevToolbarDropZone.create(Attachment.right, activeDropZone == Attachment.right),
      ],
      div(
        classes: 'jaspr-dev-toolbar-container',
        attributes: {
          'data-attach': attachment.name,
          'data-axis': attachment == Attachment.left || attachment == Attachment.right ? 'x' : 'y',
          'data-expanded': settingsOpened.toString(),
          if (isDragging) 'data-dragging': 'true',
        },
        styles: isDragging
            ? Styles(
                raw: {
                  'transform': (attachment == Attachment.left || attachment == Attachment.right)
                      ? 'translate(${_dragDelta.$1}px, calc(-50% + ${_dragDelta.$2}px))'
                      : 'translate(calc(-50% + ${_dragDelta.$1}px), ${_dragDelta.$2}px)',
                  'transition': 'none',
                },
              )
            : null,
        [
          div(
            classes: 'jaspr-dev-toolbar',
            [
              button(
                classes: isInspecting ? 'active' : null,
                attributes: {'title': 'Inspect Components'},
                events: {
                  'click': (e) {
                    toggleInspectMode();
                  },
                },
                [InspectIcon()],
              ),
              button(
                attributes: {'title': 'Inspect Layout'},
                classes: isInspectingLayout ? 'active' : null,
                events: {
                  'click': (e) {
                    toggleInspectLayoutMode();
                  },
                },
                [InspectLayoutIcon()],
              ),
              button(
                attributes: {'title': 'Open DevTools'},
                events: {
                  'click': (e) {
                    web.window.open('http://localhost:5468', '_blank');
                  },
                },
                [OpenDevToolsIcon()],
              ),

              button(
                classes: settingsOpened ? 'active' : null,
                attributes: {'title': 'Settings'},
                events: {
                  'click': (e) {
                    setState(() => settingsOpened = !settingsOpened);
                  },
                },
                [SettingsIcon()],
              ),
              button(
                attributes: {'compact': '', 'directional': '', 'title': 'Move Toolbar'},
                events: {
                  'mousedown': (e) {
                    _startDrag(e);
                  },
                },
                [DragHandleIcon()],
              ),
            ],
          ),
          div(classes: 'jaspr-dev-toolbar-menu', [
            button(
              onClick: () {
                setState(() {
                  showPropertyTooltips = !showPropertyTooltips;
                });
              },
              [
                input<bool>(
                  type: InputType.checkbox,
                  checked: showPropertyTooltips,
                  onChange: (v) {
                    setState(() {
                      showPropertyTooltips = v;
                    });
                  },
                ),
                text('Show properties of inspected components'),
              ],
            ),
            button(
              onClick: () {
                setState(() {
                  // ignore: invalid_use_of_protected_member
                  DevToolsService.instance.debugVerboseLoggingActive =
                      !DevToolsService.instance.debugVerboseLoggingActive;
                });
              },
              [
                input<bool>(
                  type: InputType.checkbox,
                  checked: DevToolsService.instance.debugVerboseLoggingActive,
                  onChange: (v) {
                    setState(() {
                      // ignore: invalid_use_of_protected_member
                      DevToolsService.instance.debugVerboseLoggingActive = v;
                    });
                  },
                ),
                text('Enable verbose logging'),
              ],
            ),
            span([]),
            button([PowerIcon(), text('Disable toolbar for this session')], onClick: _disableToolbar),
          ]),
        ],
      ),
    ]);
  }

  static List<StyleRule> get styles => [
    css('.jaspr-dev-toolbar-glass').styles(
      position: Position.fixed(top: 0.px, left: 0.px, bottom: 0.px, right: 0.px),
      zIndex: ZIndex(999997),
      cursor: Cursor.crosshair,
    ),

    css('.jaspr-dev-toolbar-container', [
      css('&').styles(
        position: Position.fixed(),
        zIndex: ZIndex(999999),
      ),
      css('&[data-attach="top"]').styles(position: Position.fixed(top: 16.px)),
      css('&[data-attach="bottom"]').styles(position: Position.fixed(bottom: 16.px)),
      css('&[data-attach="left"]').styles(position: Position.fixed(left: 16.px)),
      css('&[data-attach="right"]').styles(position: Position.fixed(right: 16.px)),
      css('&[data-axis="y"]', [
        css('&').styles(
          position: Position.fixed(left: 50.percent),
          transform: Transform.translate(x: (-50).percent, y: 0.px),
        ),
        css('.jaspr-dev-toolbar', [
          css('> button:first-child').styles(
            radius: BorderRadius.horizontal(left: Radius.circular(24.px)),
          ),
          css('> button:last-child').styles(
            radius: BorderRadius.horizontal(right: Radius.circular(24.px)),
          ),
          css('> button').styles(
            padding: Padding.symmetric(horizontal: 20.px, vertical: 12.px),
          ),
        ]),
      ]),
      css('&[data-axis="x"]', [
        css('&').styles(
          position: Position.fixed(top: 50.percent),
          transform: Transform.translate(x: 0.px, y: (-50).percent),
        ),
        css('.jaspr-dev-toolbar', [
          css('&').styles(flexDirection: FlexDirection.column),
          css('> button:first-child').styles(
            radius: BorderRadius.vertical(top: Radius.circular(24.px)),
          ),
          css('> button:last-child').styles(
            radius: BorderRadius.vertical(bottom: Radius.circular(24.px)),
          ),
          css('> button').styles(
            padding: Padding.symmetric(horizontal: 12.px, vertical: 20.px),
          ),
          css('> button[directional] > *').styles(transform: Transform.rotate(90.deg)),
        ]),
      ]),
      css('.jaspr-dev-toolbar', [
        css('&').styles(
          display: Display.flex,
          backgroundColor: Color('#050505'),
          border: Border.all(color: Color('#111'), width: 1.px),
          shadow: BoxShadow(offsetX: 2.px, offsetY: 1.px, blur: 6.px, color: Color('#00000055')),
          flexDirection: FlexDirection.row,
          alignItems: AlignItems.stretch,
          color: Colors.white,
          radius: BorderRadius.circular(24.px),
          fontFamily: FontFamily('sans-serif'),
          fontSize: 14.px,
          userSelect: UserSelect.none,
        ),
        css('> button', [
          css('&').styles(
            display: Display.flex,
            alignItems: AlignItems.center,
            justifyContent: JustifyContent.center,
            backgroundColor: Colors.transparent,
            border: Border.unset,
            color: Colors.white,
            cursor: Cursor.pointer,
            fontSize: 18.px,
          ),
          css('&[compact]').styles(padding: Padding.all(8.px)),
          css('&:hover').styles(
            backgroundColor: Color('#222'), // highlight
          ),
          css('&.active').styles(
            backgroundColor: Color('#333'), // Highlighting select mode
            color: Colors.white,
          ),
        ]),
      ]),
      css('&[data-expanded="true"] .jaspr-dev-toolbar-menu').styles(
        display: Display.flex,
      ),
      css('&[data-expanded="false"] .jaspr-dev-toolbar-menu').styles(
        display: Display.none,
      ),
      css('&[data-attach="top"] .jaspr-dev-toolbar-menu').styles(
        position: Position.absolute(top: 100.percent, left: 50.percent),
        minWidth: 100.percent,
        transform: Transform.translate(x: (-50).percent, y: 4.px),
      ),
      css('&[data-attach="bottom"] .jaspr-dev-toolbar-menu').styles(
        position: Position.absolute(bottom: 100.percent, left: 50.percent),
        minWidth: 100.percent,
        transform: Transform.translate(x: (-50).percent, y: (-4).px),
      ),
      css('&[data-attach="left"] .jaspr-dev-toolbar-menu').styles(
        position: Position.absolute(left: 100.percent, top: 50.percent),
        minWidth: 20.rem,
        transform: Transform.translate(x: 4.px, y: (-50).percent),
      ),
      css('&[data-attach="right"] .jaspr-dev-toolbar-menu').styles(
        position: Position.absolute(right: 100.percent, top: 50.percent),
        minWidth: 20.rem,
        transform: Transform.translate(x: (-4).px, y: (-50).percent),
      ),
      css('.jaspr-dev-toolbar-menu', [
        css('&').styles(
          display: Display.flex,
          flexDirection: FlexDirection.column,
          gap: Gap.all(4.px),
          padding: Padding.all(4.px),
          border: Border.only(top: BorderSide(color: Color('#111'))),
          radius: BorderRadius.circular(12.px),
          backgroundColor: Color('#050505'),
        ),
        css('> span').styles(
          height: 1.px,
          margin: Margin.symmetric(horizontal: 12.px),
          backgroundColor: Color('#222'),
        ),
        css('button').styles(
          display: Display.flex,
          padding: Padding.symmetric(horizontal: 16.px, vertical: 12.px),
          border: Border.unset,
          radius: BorderRadius.circular(8.px),
          cursor: Cursor.pointer,
          alignItems: AlignItems.center,
          gap: Gap.all(8.px),
          color: Colors.white,
          fontSize: 14.px,
          textAlign: TextAlign.left,
          backgroundColor: Colors.transparent,
          whiteSpace: WhiteSpace.noWrap,
        ),
        css('button:hover').styles(
          backgroundColor: Color('#222'),
        ),
        css('input[type="checkbox"]', [
          css('&').styles(
            width: 32.px,
            height: 18.px,
            margin: Margin.zero,
            backgroundColor: Color('#444'),
            radius: BorderRadius.circular(9.px),
            position: Position.relative(),
            cursor: Cursor.pointer,
            appearance: Appearance.none,
            transition: Transition('background-color', duration: 200.ms),
          ),
          css('&::after').styles(
            content: '',
            position: Position.absolute(top: 2.px, left: 2.px),
            width: 14.px,
            height: 14.px,
            backgroundColor: Colors.white,
            radius: BorderRadius.circular(50.percent),
            transition: Transition('transform', duration: 200.ms),
          ),
          css('&:checked').styles(
            backgroundColor: Color('#3b82f6'),
          ),
          css('&:checked::after').styles(
            transform: Transform.translate(x: 14.px),
          ),
        ]),
      ]),
    ]),
    css('.jaspr-dev-toolbar-dropzone', [
      css('&').styles(
        position: Position.fixed(),
        zIndex: ZIndex(999996),
        pointerEvents: PointerEvents.none,
      ),
      css('path').styles(
        raw: {'fill': 'rgba(59, 130, 246, 0.05)'},
        transition: Transition('all', duration: 200.ms),
      ),
      css('&.active path').styles(
        raw: {'fill': 'rgba(59, 130, 246, 0.2)'},
      ),
    ]),
  ];
}

class _DevToolbarDropZone extends StatelessComponent {
  _DevToolbarDropZone.internal(this.zone);

  final Attachment zone;

  static final Map<Attachment, Component> _dropZones = {};

  static Component create(Attachment attachment, bool isActive) {
    final dropZone = _dropZones.putIfAbsent(attachment, () => _DevToolbarDropZone.internal(attachment));
    return Component.wrapElement(classes: isActive ? 'active' : null, child: dropZone);
  }

  @override
  Component build(BuildContext context) {
    final width = web.window.innerWidth;
    final height = web.window.innerHeight;

    const double gap = 8;
    const double size = 60;

    // Distance from the screen corner to the sharp intersection
    const double sharpBase = size + gap;

    // Distance from the sharp corner to the tangent curve points (half thickness)
    const double tangentDist = size / 2;

    // Math derivation for the 135 degree interior curve
    const double r = tangentDist * 2.41421356; // radius = d * tan(67.5)
    const double diagDist = tangentDist / 1.41421356; // d * cos(45)

    // Derived points mapping to dynamic screen boundaries
    final wGap = width - gap;
    final hGap = height - gap;

    final flatNear = sharpBase + tangentDist;
    final flatFarW = width - flatNear;
    final flatFarH = height - flatNear;

    final diagNearX = sharpBase - diagDist;
    final diagNearY = size - diagDist;
    final diagFarW = width - diagNearX;
    final diagFarH = height - diagNearX;

    String pathData = '';
    Styles? svgStyles;

    switch (zone) {
      case Attachment.top:
        svgStyles = Styles(
          position: Position.fixed(top: 0.px, left: 0.px, right: 0.px),
          height: size.px,
        );
        pathData =
            'M $gap 0 L $wGap 0 L $diagFarW $diagNearY A $r $r 0 0 1 $flatFarW $size L $flatNear $size A $r $r 0 0 1 $diagNearX $diagNearY Z';
      case Attachment.bottom:
        svgStyles = Styles(
          position: Position.fixed(bottom: 0.px, left: 0.px, right: 0.px),
          height: size.px,
        );
        pathData =
            'M $flatNear 0 L $flatFarW 0 A $r $r 0 0 1 $diagFarW $diagDist L $wGap $size L $gap $size L $diagNearX $diagDist A $r $r 0 0 1 $flatNear 0 Z';
      case Attachment.left:
        svgStyles = Styles(
          position: Position.fixed(top: 0.px, bottom: 0.px, left: 0.px),
          width: size.px,
        );
        pathData =
            'M 0 $gap L $diagNearY $diagNearX A $r $r 0 0 1 $size $flatNear L $size $flatFarH A $r $r 0 0 1 $diagNearY $diagFarH L 0 $hGap Z';
      case Attachment.right:
        svgStyles = Styles(
          position: Position.fixed(top: 0.px, bottom: 0.px, right: 0.px),
          width: size.px,
        );
        pathData =
            'M 0 $flatNear A $r $r 0 0 1 $diagDist $diagNearX L $size $gap L $size $hGap L $diagDist $diagFarH A $r $r 0 0 1 0 $flatFarH Z';
    }

    return svg(
      classes: 'jaspr-dev-toolbar-dropzone',
      styles: svgStyles..combine(Styles(raw: {'overflow': 'visible'})),
      attributes: {
        'data-zone': zone.name,
        'width': zone == Attachment.top || zone == Attachment.bottom ? width.toString() : size.toString(),
        'height': zone == Attachment.top || zone == Attachment.bottom ? size.toString() : height.toString(),
      },
      [
        path(d: pathData, []),
      ],
    );
  }
}
