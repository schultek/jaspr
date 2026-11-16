import * as vs from "vscode";
import { JasprNewPageOption, JasprPageFormat, JasprPageLayout, JasprPageOptions } from "../new_item";
import { promptForComponentName } from "./new_item_helper";

// prompts the user for a default page type, or "custom" to configure everything manually
export async function promptForPageType(): Promise<JasprNewPageOption | "custom" | undefined> {
  const items: Array<vs.QuickPickItem & { data?: JasprNewPageOption | "custom" }> = [
    {
      kind: vs.QuickPickItemKind.Separator,
      label: "Pick a page type",
    },
    {
      label: "$(markdown) Plain Markdown page",
      detail: "Plain page with frontmatter",
      data: {
        format: "md",
        layout: "empty",
        options: ["frontmatter"],
      },
    },
    {
      label: "$(browser) Plain HTML page",
      detail: "Plain HTML page with frontmatter",
      data: {
        format: "html",
        layout: "empty",
        options: ["frontmatter"],
      },
    },
    {
      label: "$(markdown) Markdown Blog",
      detail: "Blog post in Markdown",
      data: {
        format: "md",
        layout: "blog",
        options: ["frontmatter", "sitemap"],
      },
    },
    {
      label: "$(browser) HTML Blog",
      detail: "Blog post in HTML",
      data: {
        format: "html",
        layout: "blog",
        options: ["frontmatter", "sitemap"],
      },
    },
    {
      label: "$(markdown) Markdown Docs",
      detail: "Documentation page in Markdown",
      data: {
        format: "md",
        layout: "docs",
        options: ["frontmatter", "sitemap"],
      },
    },
    {
      label: "$(browser) HTML Docs",
      detail: "Documentation page in HTML",
      data: {
        format: "html",
        layout: "docs",
        options: ["frontmatter", "sitemap"],
      },
    },
    {
      kind: vs.QuickPickItemKind.Separator,
      label: "More",
    },
    {
      label: "$(gear) Custom...",
      detail: "Configure everything manually",
      data: "custom",
    },
  ];

  const selected = await vs.window.showQuickPick(items, {
    ignoreFocusOut: true,
    matchOnDescription: true,
    placeHolder: "Select a page type",
  });

  return selected?.data;
}

export async function promptForCustomPageOptions(): Promise<JasprNewPageOption | undefined> {
  // page format prompt
  const items: Array<vs.QuickPickItem & { format?: JasprPageFormat }> = [
    {
      kind: vs.QuickPickItemKind.Separator,
      label: "Pick a format for the page",
    },
    {
      label: "$(markdown) Markdown",
      detail: "Plain text markup",
      format: "md",
    },
    {
      label: "$(code) MDX",
      detail: "Markdown + JSX",
      format: "mdx",
    },
    {
      label: "$(browser) HTML",
      detail: "Full HTML markup",
      format: "html"
    },
    {
      label: "$(gear) Custom",
      detail: "Custom format",
      format: "custom"
    },
  ];

  let selectedFormatItem = await vs.window.showQuickPick(items, {
    ignoreFocusOut: true,
    matchOnDescription: true,
    placeHolder: "Select page format",
  });

  if (!selectedFormatItem || !selectedFormatItem.format) {
    vs.window.showErrorMessage("Please select a format");
    return undefined;
  }
  const format = selectedFormatItem.format;


  // page layout prompt
  const layoutItems: Array<vs.QuickPickItem & { layout?: JasprPageLayout }> = [
    {
      kind: vs.QuickPickItemKind.Separator,
      label: "Pick a layout for the page",
    },
    {
      label: "$(rss) Blog",
      detail: "For blog posts",
      layout: "blog",
    },
    {
      label: "$(book) Docs",
      detail: "For documentation",
      layout: "docs",
    },
    {
      label: "$(empty-window) Empty",
      detail: "No layout",
      layout: "empty",
    },
    {
      label: "$(gear) Custom",
      detail: "Custom layout",
      layout: "custom",
    },
  ];

  let selectedLayoutItem = await vs.window.showQuickPick(layoutItems, {
    ignoreFocusOut: true,
    matchOnDescription: true,
    placeHolder: "Select page layout",
  });

  if (!selectedLayoutItem || !selectedLayoutItem.layout) {
    vs.window.showErrorMessage("Please select a layout");
    return undefined;
  }
  const layout = selectedLayoutItem.layout;

  const pageOptions = await getJasprNewPageOptions();

  // prompt for the optional page title and description
  const title = await promptForComponentName("Page title (Optional)", "(Optional) Enter a title for your page", "", false, true);
  const description = await promptForComponentName("Page description (Optional)", "(Optional) Enter a description for your page", "", false, true);

  return {
    options: pageOptions,
    title: title,
    description: description,
    format: format,
    layout: layout,
  }

}

export async function getJasprNewPageOptions(): Promise<Array<JasprPageOptions>> {
  const items: Array<vs.QuickPickItem & { option?: JasprPageOptions }> = [
    {
      kind: vs.QuickPickItemKind.Separator,
      label: "Select page options",
    },
    {
      label: "$(bracket) Frontmatter",
      detail: "Enable the frontmatter",
      option: "frontmatter",
      picked: true,
    },
    {
      label: "$(home) Index",
      detail: "Create an index page instead of a normal page",
      option: "index",
      picked: false,
    },
    {
      label: "$(list-tree) Sitemap",
      detail: "Include sitemap configuration keys in the frontmatter",
      option: "sitemap",
      picked: false,
    },
    {
      label: "$(exclude) Sitemap Exclude",
      detail: "Exclude this page from the sitemap",
      option: "sitemap-exclude",
      picked: false,
    },
    {
      label: "$(tag) Meta",
      detail: "Include sample meta tag keys in the frontmatter",
      option: "meta",
      picked: false,
    },
  ];

  const selectedItems = await vs.window.showQuickPick(items, {
    canPickMany: true,
    ignoreFocusOut: true,
    matchOnDescription: true,
    placeHolder: "Select page options",
  });

  if (!selectedItems) {
    return [];
  }

  const options: Array<JasprPageOptions> = selectedItems
    .map((item) => item.option)
    .filter((o): o is JasprPageOptions => o !== undefined);

  if (options.includes("sitemap") && options.includes("sitemap-exclude")) {
    vs.window.showWarningMessage(
      "Cannot combine 'Sitemap' and 'Sitemap Exclude' — please select only one."
    );
    return [];
  }

  return options;
}
