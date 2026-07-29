import 'dart:convert';

import 'client_basic.dart';
import 'client_model_class.dart';
import 'client_model_extension.dart';
import 'client_with_server_components.dart';

final clientBundleOutputs = {
  'site|lib/clients.bundle.json': jsonEncode([
    clientWithServerComponentsModuleData,
    clientBasicModuleData,
    clientModelClassModuleData,
    clientModelExtensionModuleData,
  ]),
};
