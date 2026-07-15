# Jaspr Sizing & Units

In Jaspr's `Styles()`/`.styles()`, dimensional values (width, height, margin, padding, border-radius, etc.) use the `Unit` class. 

## Number Extensions
You MUST use the built-in extensions on `num` to create `Unit` values:
- `10.px` (Pixels)
- `2.em` or `2.rem` (Relative to font-size)
- `50.percent` (Percentage dimensions)
- `100.vh` / `100.vw` (Viewport Height / Width)
You MUST parenthesize negative numbers:
- `(-10).px`
You can also use one of the static constants on `Unit`:
- `.auto`, `.zero`, `.maxContent`, `.minContent`, `.fitContent`
You can also create a `Unit` from a variable or expression:
- `.variable('my-var')`
- `.expression('calc(100% - 20px)')`

## Dimensions
Properties for component sizing:
- `Unit? width`: `100.px`
- `Unit? height`: `100.px`
- `Unit? minWidth`: `50.percent`
- `Unit? minHeight`: `10.rem`
- `Unit? maxWidth`: `100.vw`
- `Unit? maxHeight`: `100.vh`
- `AspectRatio? aspectRatio`: `AspectRatio(16/9)`
- `BoxSizing? boxSizing`: `.borderBox` or `.contentBox`

## Margin & Padding
Properties for margin and padding:
- `Padding? padding`: `.zero`, `.all(10.px)`, `.symmetric(vertical: 10.px, horizontal: 20.px)`, `.only(left: 5.px, top: 10.px)`
- `Margin? margin`: `.zero`, `.all(10.px)`, `.symmetric(vertical: 10.px, horizontal: 20.px)`, `.only(left: 5.px, top: 10.px)`

## Borders and Radius
Properties for borders and border radius:
- `Border? border`: `.none`, `.only(top: BorderSide.solid(color: Colors.black, width: 1.px))`, `.all(style: BorderStyle.dotted, color: Colors.blue, width: 2.px)`
- `BorderRadius? radius`: `.circular(10.px)`, `.all(.circular(10.px))`, `.only(topLeft: .circular(10.px), bottomRight: .zero)`, `.vertical(top: .elliptical(10.px, 20.px), bottom: .zero)`
