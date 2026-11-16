import { JapsrComponentVariant, JasprNewComponentOptions } from "../new_item";
import { isValidDartIdentifier } from "./new_item_helper";
import * as vs from "vscode";

// prompts the user for the flutter app/widget name
export async function promptForFlutterName(defaultName: string): Promise<string> {
  let flutterAppName;
  const response = await vs.window.showInputBox({
    title: "Flutter App/Widget name",
    prompt: "Specifiy the Flutter App/Widget name",
    value: defaultName,
  });
  if (response !== undefined && response.length > 0) {
    if (!isValidDartIdentifier(response)) {
      flutterAppName = defaultName;
      vs.window.showWarningMessage("'" + response + "' is  not a valid Dart identifier, will use '" + flutterAppName + "' instead.");
    } else {
      flutterAppName = response;
    }
  } else {
    flutterAppName = defaultName;
    vs.window.showWarningMessage("Setting Flutter App/Widget name to '" + flutterAppName + "'");
  }
  return flutterAppName;
}


export function getJasprComponentVariants(): Array<JapsrComponentVariant> {
  let items: Array<JapsrComponentVariant> = [
    {
      kind: vs.QuickPickItemKind.Separator,
      label: "Components",
    },
    {
      detail:
        "Stateless components are non interactive, great for static information.",
      label: "$(symbol-structure) Stateless Component",
      description: "Static component",
      data: {
        type: "stateless",
      },
    },
    {
      detail:
        "Stateful components hold state and re-render when it changes, great for interactive UIs.",
      label: "$(sync) Stateful Component",
      description: "Interactive component",
      data: {
        type: "stateful",
      },
    },
    {
      detail:
        "Async components load data asynchronously on the server, great for fetching from an API or database.",
      label: "$(cloud) Async Component",
      description: "Async data loading",
      data: {
        type: "async",
      },
    },
    {
      detail:
        "Inherited components provide data down the component tree, great for shared state like themes or configuration,...",
      label: "$(arrow-down) Inherited Component",
      description: "Shared state",
      data: {
        type: "inherited",
      },
    },
    {
      detail:
        "Flutter embed views run a Flutter app inside a Jaspr page, great for complex client-side UIs.",
      label: "$(device-mobile) Flutter Embed View",
      description: "Embed a Flutter app",
      data: {
        type: "flutter",
        flutterEmbedOptions: ["with-sample-widget"],
      },
    },
    {
      kind: vs.QuickPickItemKind.Separator,
      label: "More",
    },
    {
      label: "More ...",
      data: "more",
    }
  ];

  return items;
}

export function getJasprComponentVariantsAll(): Array<vs.QuickPickItem & { data?: JasprNewComponentOptions }> {
  const items: Array<vs.QuickPickItem & { data?: JasprNewComponentOptions }> = [
    {
      kind: vs.QuickPickItemKind.Separator,
      label: "Stateless",
    },
    {
      label: "Stateless Component",
      data: {
        type: "stateless",
      },
    },
    {
      label: "Stateless Client Component",
      data: {
        type: "stateless",
        componentOptions: ["client"],
      },
    },
    {
      label: "Stateless Component with Styles",
      data: {
        type: "stateless",
        componentOptions: ["with-styles"],
      },
    },
    {
      label: "Stateless Component with Test",
      data: {
        type: "stateless",
        componentOptions: ["with-test"],
      },
    },
    {
      label: "Stateless Client Component with Test",
      data: {
        type: "stateless",
        componentOptions: ["client", "with-test"],
      },
    },
    {
      kind: vs.QuickPickItemKind.Separator,
      label: "Stateful",
    },
    {
      label: "Stateful Component",
      data: {
        type: "stateful",
      },
    },
    {
      label: "Stateful Client Component",
      data: {
        type: "stateful",
        componentOptions: ["client"],
      },
    },
    {
      label: "Stateful Component with Styles",
      data: {
        type: "stateful",
        componentOptions: ["with-styles"],
      },
    },
    {
      label: "Stateful Component with Test",
      data: {
        type: "stateful",
        componentOptions: ["with-test"],
      },
    },
    {
      label: "Stateful Client Component with Test",
      data: {
        type: "stateful",
        componentOptions: ["client", "with-test"],
      },
    },
    {
      kind: vs.QuickPickItemKind.Separator,
      label: "Async",
    },
    {
      label: "Async Component",
      data: {
        type: "async",
      },
    },
    {
      label: "Async Component with Styles",
      data: {
        type: "async",
        componentOptions: ["with-styles"],
      },
    },
    {
      label: "Async Component with Test",
      data: {
        type: "async",
        componentOptions: ["with-test"],
      },
    },
    {
      kind: vs.QuickPickItemKind.Separator,
      label: "Inherited",
    },
    {
      label: "Inherited Component",
      data: {
        type: "inherited",
      },
    },
    {
      kind: vs.QuickPickItemKind.Separator,
      label: "Flutter Embed",
    },
    {
      label: "Flutter Embed View",
      data: {
        type: "flutter",
      },
    },
    {
      label: "Flutter Embed View with Sample Widget",
      data: {
        type: "flutter",
        flutterEmbedOptions: ["with-sample-widget"],
      },
    },
  ];

  return items;
}
