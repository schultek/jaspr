import 'package:dart_mappable/dart_mappable.dart';

import 'project.dart';

part 'tutorial.mapper.dart';

@MappableClass()
class TutorialData with TutorialDataMappable implements ProjectData {
  @override
  final String id;
  @override
  final String description;
  final int currentStep;
  final List<TutorialStepConfig> configs;
  final Map<String, TutorialStep> steps;

  TutorialData(this.id, this.description, this.currentStep, this.configs, this.steps);

  String get currentStepId => configs[currentStep].id;
  TutorialStep get step => steps[currentStepId]!;

  @override
  String? get cssFile => step.cssFile;

  @override
  Map<String, String> get dartFiles => step.dartFiles;

  @override
  Map<String, String> get allDartFiles => step.allDartFiles;

  @override
  String? fileContentFor(String key) => step.fileContentFor(key);

  @override
  List<String> get fileNames => step.fileNames;

  @override
  String? get htmlFile => step.htmlFile;

  @override
  bool isDart(String key) => step.isDart(key);

  @override
  String get mainDartFile => step.mainDartFile;

  @override
  TutorialData updateContent(String key, String? content) {
    return copyWith.steps.get(currentStepId)!.apply((s) => s.updateContent(key, content));
  }

  TutorialData toggleSolution() {
    return copyWith.steps.get(currentStepId)!.apply((s) => s.copyWith(showSolution: !s.showSolution));
  }

  @override
  ProjectData copy() => copyWith();

  static TutorialData fromConfig(TutorialConfig config) {
    return TutorialData(
      'tutorial-${config.id}',
      config.name,
      config.steps.indexWhere((c) => c.id == config.initialStep.id),
      config.steps,
      {config.initialStep.id: config.initialStep},
    );
  }
}

@MappableClass()
class TutorialStep with TutorialStepMappable implements ProjectData {
  @override
  final String id;
  final String name;

  final String text;

  final ProjectData step;
  final ProjectData? solution;

  final bool showSolution;

  TutorialStep(this.id, this.name, this.text, this.step, this.solution, [this.showSolution = false]);

  ProjectData get data => showSolution && solution != null ? solution! : step;

  @override
  Map<String, String> get allDartFiles => data.allDartFiles;

  @override
  String? get cssFile => data.cssFile;

  @override
  Map<String, String> get dartFiles => data.dartFiles;

  @override
  String? get description => data.description;

  @override
  String? fileContentFor(String key) => data.fileContentFor(key);

  @override
  List<String> get fileNames => data.fileNames;

  @override
  String? get htmlFile => data.htmlFile;

  @override
  bool isDart(String key) => data.isDart(key);

  @override
  String get mainDartFile => data.mainDartFile;

  @override
  TutorialStep updateContent(String key, String? content) {
    if (showSolution) {
      return copyWith.solution?.apply((s) => s.updateContent(key, content)) ?? copyWith();
    } else {
      return copyWith.step.apply((s) => s.updateContent(key, content));
    }
  }

  @override
  ProjectData copy() => copyWith();
}

@MappableClass()
class TutorialResponse with TutorialResponseMappable {
  TutorialConfig? tutorial;
  String? error;

  TutorialResponse(this.tutorial, this.error);
}

@MappableClass()
class TutorialConfig with TutorialConfigMappable {
  String id;
  String name;
  List<TutorialStepConfig> steps;
  TutorialStep initialStep;

  TutorialConfig(this.id, this.name, this.steps, this.initialStep);
}

@MappableClass()
class TutorialStepConfig with TutorialStepConfigMappable {
  String id;
  String name;

  TutorialStepConfig(this.id, this.name);
}
