import 'package:jaspr/jaspr.dart';

class StaticTheme extends InheritedComponent {
  StaticTheme({required this.theme, required Component child}) : super(child: child);

  final ThemeData theme;

  @override
  bool updateShouldNotify(covariant InheritedComponent oldComponent) {
    return true;
  }

  @override
  InheritedElement createElement() => StaticThemeElement(this);
}

class StaticThemeElement extends InheritedElement {
  StaticThemeElement(super.component);

  @override
  Component? build() {
    return Builder(builder: (context) sync* {
      yield DomComponent(tag: 'style', child: SkipContent());
      yield component.child;
    });
  }
}

abstract class ThemeData {
  final String name;

  const ThemeData(this.name);
  const factory ThemeData.variant(String name, dynamic styles) = _VariantThemeData;

  dynamic get styles;
  List<ThemeData> get variants;

  ResolvedThemeData resolve({bool isOutlined = false}) => applyVariants([]);

  @protected
  ResolvedThemeData applyVariants(List<String> variants) {
    var v = this.variants.where((v) => variants.contains(v.name));
    return ResolvedThemeData(this, v.toList());
  }
}

class _VariantThemeData extends ThemeData {
  const _VariantThemeData(super.name, this.styles);

  final dynamic styles;

  @override
  List<ThemeData> get variants => [];
}

class ResolvedThemeData {
  ResolvedThemeData(this.base, this.variants);

  final ThemeData base;
  final List<ThemeData> variants;

  List<String> get classes => [
        base.name,
        ...variants.map((v) => v.name),
      ];
}
