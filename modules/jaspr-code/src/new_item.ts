import * as vs from "vscode";
import * as fs from "fs";
import * as path from "path";
import { checkJasprVersion } from "./helpers/install_helper";
import { getFolderToRunCommandIn } from "./helpers/project_helper";
import { jasprNewComponent, jasprNewPage } from "./commands";
import { promptForComponentLocation, promptForComponentName, promptForGenType, toSnakeCase } from "./helpers/new_item_helper";
import { promptForCustomPageOptions, promptForPageType } from "./helpers/new_page_helper";
import { getJasprComponentVariants, getJasprComponentVariantsAll, promptForFlutterName } from "./helpers/new_component_helper";

// Component types and flags
export type JasprComponentType = "stateless" | "stateful" | "async" | "flutter" | "inherited";
export type JasprComponentOptions = "client" | "with-styles" | "with-test";
export type JasprFlutterEmbedOptions = "with-sample-widget";

export interface JasprNewComponentOptions {
  readonly type?: JasprComponentType;
  readonly componentOptions?: Array<JasprComponentOptions>;
  readonly flutterEmbedOptions?: Array<JasprFlutterEmbedOptions>;
}

export type JapsrComponentVariant = vs.QuickPickItem & {
  data?: JasprNewComponentOptions | "more";
};

// Pages types and flags
export type JasprPageFormat = "md" | "mdx" | "html" | "custom";
export type JasprPageLayout = "blog" | "docs" | "empty" | "custom";
export type JasprPageOptions = "index" | "sitemap" | "meta" | "frontmatter" | "sitemap-exclude";

export interface JasprNewPageOption {
  readonly format: JasprPageFormat,
  readonly layout?: JasprPageLayout,
  title?: string,
  description?: string,
  options: Array<JasprPageOptions>
}

// Creates a new Jaspr component or page by prompting the user
export async function createNewJasprItem()
  : Promise<vs.Uri | undefined> {
  const v = await checkJasprVersion();
  if (!v) {
    return;
  }

  // prompt the user for what they want to generate, either a component or a page
  const generationType = await promptForGenType();
  if (generationType === undefined) {
    vs.window.showErrorMessage("Please select what you wish to generate");
    return;
  }

  if (generationType === "component") {
    const jasprComponentVariants = getJasprComponentVariants();

    let selectedModeItem = await vs.window.showQuickPick(jasprComponentVariants, {
      ignoreFocusOut: true,
      matchOnDescription: true,
      placeHolder: "Select a component type",
    });


    if (selectedModeItem?.data === "more") {
      const jasprComponentVariantsAll = getJasprComponentVariantsAll();

      selectedModeItem = await vs.window.showQuickPick(jasprComponentVariantsAll, {
        ignoreFocusOut: true,
        matchOnDescription: true,
        placeHolder: "Select a configuration",
      });
    }

    if (!selectedModeItem?.data) {
      return;
    }

    return createJasprComponentWithType(selectedModeItem.data as JasprNewComponentOptions);
  } else if (generationType === "page") {
    return createNewJasprPage();
  }
}

async function createJasprComponentWithType(data: JasprNewComponentOptions): Promise<vs.Uri | undefined> {
  // get the root of the jaspr project
  const projectDir = await getFolderToRunCommandIn("Select a Jaspr project");
  if (!projectDir) {
    return;
  }

  // ask the user where they would like the component to be created
  // it suggest lib/components and lib but also allows the user to pick a directory of their choosing
  const defaultSubDir = data.type === "inherited" ? "lib" : "lib/components";
  const folderPath = await promptForComponentLocation(defaultSubDir, projectDir);
  if (!folderPath) {
    return;
  }

  let flutterAppName = "";
  // when creating a FlutterEmbedView, prompt for the Flutter App name
  if (data.type !== undefined && data.type === "flutter") {
    flutterAppName = await promptForFlutterName("MyFlutterApp");
  }

  // prompt for the component name
  const name = await promptForComponentName("Component Name", "Enter a name for your new component", "MyComponent", true, false);
  if (!name) {
    return;
  }

  const success = await jasprNewComponent(projectDir, folderPath, data, name, flutterAppName);
  if (success) {
    // open the newly created component file
    const componentFile = path.join(folderPath, toSnakeCase(name) + ".dart");
    if (fs.existsSync(componentFile)) {
      await vs.commands.executeCommand("vscode.open", vs.Uri.file(componentFile));
      return vs.Uri.file(componentFile);
    }
    return vs.Uri.file(folderPath);
  }

  return undefined;
}

async function createNewJasprPage(): Promise<vs.Uri | undefined> {
  // get the root of the jaspr project
  const projectDir = await getFolderToRunCommandIn("Select a Jaspr project");
  if (!projectDir) {
    return;
  }

  // premade page types prompt shown first
  // NOTE: if the user picks "custom", they will be prompted for the custom page options after the name and location prompts
  const pageType = await promptForPageType();
  if (!pageType) {
    return undefined;
  }

  // prompt for the page name
  const name = await promptForComponentName("Page file name", "Enter a name for your page", "getting_started", false, false,);
  if (!name) {
    return;
  }

  const folderPath = await promptForComponentLocation("content", projectDir);
  if (!folderPath) {
    return;
  }

  let pageOptions: JasprNewPageOption;
  if (pageType === "custom") {
    const customOptions = await promptForCustomPageOptions();
    if (!customOptions) {
      return undefined;
    }
    pageOptions = customOptions;
  } else {
    pageOptions = pageType;
  }

  const success = await jasprNewPage(projectDir, folderPath, pageOptions, name);
  if (success) {
    // open the newly created component file
    const componentFile = path.join(folderPath, toSnakeCase(name) + ".dart");
    if (fs.existsSync(componentFile)) {
      await vs.commands.executeCommand("vscode.open", vs.Uri.file(componentFile));
      return vs.Uri.file(componentFile);
    }
    return vs.Uri.file(folderPath);
  }

  return undefined;
}
