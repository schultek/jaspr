part of '../styles.dart';

class _ListStyles extends Styles {
  final ListStyle? style;
  final ImageStyle? image;
  final ListStylePosition? position;

  const _ListStyles({this.style, this.image, this.position}) : super._();

  @override
  Map<String, String> get styles => {
        if (style != null) 'list-style-type': style!.value,
        if (position != null) 'list-style-position': position!.value,
        if (image != null) 'list-style-image': image!.value,
      };
}
