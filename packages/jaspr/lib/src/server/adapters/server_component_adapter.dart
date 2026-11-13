import '../../dom/validator.dart';
import '../../framework/framework.dart';
import '../components/client_component_registry.dart';
import '../markup_render_object.dart';
import 'element_boundary_adapter.dart';

final class ServerComponentAdapter extends ElementBoundaryAdapter {
  ServerComponentAdapter(this.registry, this.id, super.element)
    : super(priority: ElementBoundaryAdapter.serverComponentBoundaryPriority);

  final ClientComponentRegistryElement registry;
  final int id;

  @override
  void applyBoundary(ChildGroup group) {
    if (hasInheritedDomParams(element)) {
      _applyParamsToSubtree(element);
    }

    final startMarker = MarkupRenderText('<!--s${DomValidator.clientMarkerPrefix}$id-->', true);
    final endMarker = MarkupRenderText('<!--/s${DomValidator.clientMarkerPrefix}$id-->', true);

    group.children.insertAfter(startMarker);
    group.children.insertBefore(endMarker);
  }

  void _applyParamsToSubtree(Element element) {
    if (registry.clientBoundaries.contains(element)) {
      return;
    }
    if (element is DomElement) {
      if (_computeAppliedDiff(element) case final diff?) {
        if (element.renderObject case final MarkupRenderElement renderObject) {
          (renderObject.attributes ??= {})['data-j-apply'] = diff;
        }
      }
    }
    element.visitChildren(_applyParamsToSubtree);
  }

  String? _computeAppliedDiff(DomElement domElement) {
    final inheritedDomParams = domElement.inheritedDomParamsFor(domElement.renderObject);
    if (inheritedDomParams == null || inheritedDomParams.isEmpty) return null;

    final component = domElement.component;
    String? id = component.id;
    final classesSet = {
      if (component.classes case final c?) ...c.split(_htmlClassWhitespace).where((s) => s.isNotEmpty),
    };
    final styles = Map.of(component.styles?.properties ?? {});
    final attributes = Map.of(component.attributes ?? {});

    final appliedClasses = <String>[];
    final appliedStyles = <String>[];
    final appliedAttributes = <String>[];
    String? appliedId;

    for (final param in inheritedDomParams.reversed) {
      if (param.target.tag case final expectedTag? when expectedTag != component.tag) continue;
      // DOM Element.id is empty when neither the id field nor the attributes map supplies an ID.
      final effectiveId = id ?? attributes['id'] ?? '';
      if (param.target.id case final expectedId? when expectedId != effectiveId) continue;
      if (param.target.classes case final expectedClasses? when !expectedClasses.every(classesSet.contains)) {
        continue;
      }

      final isClient = _isClientManaged(param);

      if (param.id case final paramId? when id == null) {
        id = paramId;
        if (isClient) {
          appliedId = paramId;
        }
      }

      if (param.classes case final paramClasses?) {
        for (final c in paramClasses) {
          if (!classesSet.contains(c)) {
            if (isClient) {
              appliedClasses.add(c);
            }
          }
        }
        classesSet.addAll(paramClasses);
      }

      if (param.styles case final stylesProps?) {
        for (final MapEntry(:key, :value) in stylesProps.entries) {
          if (!styles.containsKey(key)) {
            styles[key] = value;
            if (isClient) {
              appliedStyles.add(key);
            }
          }
        }
      }

      if (param.attributes case final attributesMap?) {
        for (final MapEntry(:key, :value) in attributesMap.entries) {
          if (!attributes.containsKey(key)) {
            attributes[key] = value;
            if (isClient) {
              appliedAttributes.add(key);
            }
          }
        }
      }
    }

    if (appliedId != null || appliedClasses.isNotEmpty || appliedStyles.isNotEmpty || appliedAttributes.isNotEmpty) {
      final parts = <String>[];
      if (appliedId != null) {
        parts.add('i:${_escapeApplyValue(appliedId)}');
      }
      if (appliedClasses.isNotEmpty) {
        parts.add('c:${appliedClasses.map(_escapeApplyValue).join(',')}');
      }
      if (appliedStyles.isNotEmpty) {
        parts.add('s:${appliedStyles.map(_escapeApplyValue).join(',')}');
      }
      if (appliedAttributes.isNotEmpty) {
        parts.add('a:${appliedAttributes.map(_escapeApplyValue).join(',')}');
      }
      return parts.join(';');
    }
    return null;
  }

  bool _isClientManaged(ApplyParams param) {
    final source = param.source;
    if (source == null) return false;
    return source.depth < element.depth;
  }
}

final _htmlClassWhitespace = RegExp(r'[\t\n\f\r ]+');

String _escapeApplyValue(String val) => (val.contains(';') || val.contains(',') || val.contains('%'))
    ? val.replaceAll('%', '%25').replaceAll(';', '%3B').replaceAll(',', '%2C')
    : val;
