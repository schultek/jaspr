part of style;

class _ListStyles implements Styles {
  final ListMarkerPosition? markerPosition;
  final ListMarkerType? markerType;
  final ListMarkerImage? markerImage;

  const _ListStyles({this.markerType, this.markerPosition, this.markerImage});

  @override
  Map<String, String> get styles => {
        ...?markerType?.styles,
        if (markerPosition != null) 'list-style-position': markerPosition!.value,
        if (markerImage != null) 'list-style-image': markerImage!.value,
      };
}
