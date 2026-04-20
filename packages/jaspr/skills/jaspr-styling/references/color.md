# Jaspr Color

When coloring text, backgrounds, and borders using `Styles()`/`.styles()`, Jaspr uses the typed `Color` class.

## Color Properties in Styles
- `color: Colors.blue` (Text/foreground color)
- `backgroundColor: Colors.transparent` 
- `border: .all(color: Colors.black)`

## Defining Colors
You MUST use one of the standard `Color` formats provided by Jaspr:

**Predefined Colors**
```dart
color: Colors.black
color: Colors.white
color: Colors.red
color: Colors.transparent
```

**Color constants**
```dart
color: .currentColor
color: .inherit
```

**Hex Code and CSS Variables**
```dart
color: Color('#FF0000') // Starts with a hash
color: .variable('my-var') // CSS Variable
```

**RGB & RGBA**
```dart
color: .rgb(255, 0, 0)
color: .rgba(255, 0, 0, 0.5) // Optional alpha channel (0.0 - 1.0)
```

**HSL & HSLA**
```dart
color: .hsl(120, 100, 50)
color: .hsla(120, 100, 50, 0.8)
```

## Example
```dart
css('.alert').styles(
  color: Colors.white,
  backgroundColor: Color('#D32F2F'),
  border: .all(
    color: .rgba(0, 0, 0, 0.2),
  ),
)
```
