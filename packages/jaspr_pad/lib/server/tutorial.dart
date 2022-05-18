import 'dart:io';

import 'package:jaspr/server.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart' as yaml;

import '../main.mapper.g.dart';
import '../models/project.dart';
import '../models/sample.dart';
import '../models/tutorial.dart';
import '../providers/utils.dart';
import 'project.dart';

Future<TutorialStep> getTutorialStep(String stepId) async {
  var dir = Directory(path.join(tutorialPath, stepId));

  if (!(await dir.exists())) {
    throw 'Tutorial step $stepId does not exist';
  } else {
    var text = await File(path.join(dir.path, 'text.md')).readAsString();

    var app = await loadProjectFromDirectory(stepId, path.join(dir.path, 'app'));

    var solutionDir = Directory(path.join(dir.path, 'solution'));

    ProjectData? solution;
    if (await solutionDir.exists()) {
      solution = await loadProjectFromDirectory(stepId, solutionDir.path);
    }

    return TutorialStep(stepId, stepId, text, app, solution);
  }
}

Future<Response> getTutorial(Request request, String? stepId) async {
  var dir = Directory(tutorialPath);
  var specFile = File(path.join(tutorialPath, 'tutorial.yaml'));

  TutorialResponse result;

  if (!(await dir.exists())) {
    result = TutorialResponse(null, 'Tutorial does not exist');
  } else {
    var data = yaml.loadYaml(await specFile.readAsString());

    var name = data['name'] as String;
    var steps = (data['steps'] as List).map((s) => TutorialStepConfig(s['id'], s['name'])).toList();

    var initialStepId = stepId ?? steps[0].id;

    var initialStep = await getTutorialStep(initialStepId);

    result = TutorialResponse(TutorialConfig('tutorial', name, steps, initialStep), null);
  }

  return Response.ok(Mapper.toJson(result), headers: {'Content-Type': 'application/json'});
}
