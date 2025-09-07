import * as vscode from "vscode";
import { checkJasprInstalled } from "./helpers/install_helper";
import { runJaspr, runJasprInFolder } from "./helpers/process_helper";
import { HTMLElement, Node, NodeType, parse } from "node-html-parser";
import { htmlSpec } from "./jaspr/html_spec";

export type JasprMode = "static" | "server" | "client";
export type JasprModeOption = JasprMode | "static:auto" | "server:auto";
export type JasprRoutingOption = "none" | "single-page" | "multi-page";
export type JasprFlutterOption = "none" | "embedded" | "plugins-only";
export type JasprBackendOption = "none" | "shelf";

export interface JasprCreateOptions {
  readonly mode?: JasprModeOption;
  readonly routing?: JasprRoutingOption;
  readonly flutter?: JasprFlutterOption;
  readonly backend?: JasprBackendOption;
}

export type JasprTemplate = "docs";

export async function jasprCreate(
  projectPath: string,
  options: JasprCreateOptions | JasprTemplate | undefined
): Promise<boolean> {
  const isInstalled = await checkJasprInstalled();
  if (!isInstalled) {
    return false;
  }

  const args = ["create"];

  if (typeof options === "string") {
    args.push("--template");
    args.push(options);
  } else {
    args.push("--mode");
    args.push(options?.mode ?? "static:auto");

    args.push("--routing");
    args.push(options?.routing ?? "none");

    args.push("--flutter");
    args.push(options?.flutter ?? "none");

    if (options?.mode === "server" || options?.mode === "server:auto") {
      args.push("--backend");
      args.push(options?.backend ?? "none");
    }
  }

  args.push(".");

  const exitCode = await runJasprInFolder(projectPath, args, undefined);

  return exitCode === 0;
}

export async function jasprClean(): Promise<number | undefined> {
  return runJaspr(["clean"]);
}

export function jasprDoctor(): Promise<number | undefined> {
  return runJaspr(["doctor"], true);
}

export async function pastHtmlAsJaspr(): Promise<number | undefined> {
  var editor = vscode.window.activeTextEditor;
  if (!editor) {
    vscode.window.showErrorMessage("No active editor found.");
    return -1;
  }

  var clipboardText = await vscode.env.clipboard.readText();
  if (!clipboardText) {
    vscode.window.showErrorMessage("Clipboard is empty.");
    return -1;
  }

  editor.edit((editBuilder) => {
    editBuilder.replace(editor!.selection, convertHtmlToJaspr(clipboardText));
  });

  return 0;
}

function convertHtmlToJaspr(html: string): string {
  let parsed = parse(html);

  return convertNodeToJaspr(parsed.firstChild, "    ").trimStart();
}

function convertNodeToJaspr(node: Node | undefined, indent: string): string {
  if (!node) {
    return "";
  }
  if (node.nodeType === NodeType.TEXT_NODE) {
    let text = node.textContent;
    if (text.trim() === "") {
      return "";
    }
    if (text.includes('\n')) {
       return indent + "text('''" + node.textContent + "''')";
    }
    return indent + "text('" + node.textContent + "')";
  } else if (node.nodeType === NodeType.ELEMENT_NODE) {

    let element = node as HTMLElement;
    let tagName = element.rawTagName;
    let attrs = element.attributes || {};
    let children = element.childNodes || [];

    let spec = specConfig[tagName];

    let idString: string | null = null;
    let classString: string | null = null;
    let paramStrings = [];
    let attrStrings = [];

    for (let [key, value] of Object.entries(attrs)) {
      if (key === 'class') {
        classString = value;
      } else if (key === 'id') {
        idString = value;
      } else  {
        if (spec && spec["attributes"] && spec["attributes"][key] !== undefined) {
        let attrSpec = spec["attributes"][key];
        let attrName = attrSpec["name"] || key;
        let attrType = attrSpec["type"];

        if (attrType === 'string') {
          paramStrings.push(`${attrName}: '${value}'`);
          continue;
        } else if (attrType === 'boolean') {
           paramStrings.push(`${attrName}: true`);
          continue;
        }
      }
        attrStrings.push(`'${key}': '${value}'`);
      }
    }

    let result = indent + `${tagName}(`;

    if (idString !== null) {
      result += 'id: \'' + idString + '\', ';
    }

    if (classString !== null) {
      result += 'classes: \'' + classString + '\', ';
    }

    if (paramStrings.length > 0) {
      for (let param of paramStrings) {
        result += param + ', ';
      }
    }

    if (attrStrings.length > 0) {
      result += "attributes: {";
      let isFirst = true;
      for (let attrString of attrStrings) {
        if (!isFirst) {
          result += ', ';
        }
        isFirst = false;
        result += attrString;
      }
      result += "}, ";
    }

    if (children.length === 0) {
      result += "[]";
    } else  {
      result += "[\n";
      for (let child of children) {
        let childHtml = convertNodeToJaspr(child, indent + "  ");
        if (childHtml.trim() === "") {
          continue;
        }
        result += childHtml + ",\n";
      }
      result += indent + "]";
    }

    result += ")";

    return result;
  } else {
    return "";
  }
}

const specConfig = (() => {
  const config: { [key: string]: any } = {};
  for (const group of Object.values(htmlSpec)) {
    for (const name of Object.keys(group)) {
      const tag = (group as any)[name].tag || name;
      config[tag] = (group as any)[name];
    }
  }
  return config;
})();
