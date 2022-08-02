import 'package:jaspr/jaspr.dart';
import 'package:jaspr/styles.dart';

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
  StaticTheme get component => super.component as StaticTheme;

  @override
  Component? build() {
    return Builder(builder: (context) sync* {
      yield Style(styles: [
        StyleRule(
          selector: Selector.dot(component.theme.name),
          styles: component.theme.styles,
        ),
        for (var variant in component.theme.variants)
          StyleRule(
            selector: Selector.dot(component.theme.name).dot(variant.name),
            styles: variant.styles,
          ),
      ]);
      yield component.child;
    });
  }
}

abstract class ThemeData {
  final String name;

  const ThemeData(this.name);
  const factory ThemeData.variant(String name, Styles styles) = _VariantThemeData;

  Styles get styles;
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

  final Styles styles;

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
