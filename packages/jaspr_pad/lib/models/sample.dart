import 'package:dart_mappable/dart_mappable.dart';

import 'project.dart';

@MappableClass()
class Sample implements Comparable<Sample> {
  String id;
  String description;
  int? index;

  Sample(this.id, this.description, this.index);

  @override
  int compareTo(Sample other) {
    if (other.index == null || index == null) return 0;
    return index! - other.index!;
  }
}

@MappableClass()
class SampleResponse {
  ProjectData? project;
  String? error;

  SampleResponse(this.project, this.error);
}
