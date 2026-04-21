---
name: jaspr-convert-html
description: Use when you need to convert / rewrite existing HTML (from a file or url) into Jaspr code.
metadata:
  jaspr_version: 0.23.0
---

## Rules

Converting existing HTML into Jaspr component syntax by hand is prone to errors and wastes time.

- **Rule 1:** You MUST ALWAYS use the `jaspr convert-html` command to convert existing HTML.
- **Rule 2:** You MUST NEVER attempt to convert HTML to Jaspr code manually.
- **Rule 3:** You MUST take the output from the daemon UNCHANGED and use it exactly as provided.

## Usage

To convert HTML to Jaspr code, run one of the following commands in the terminal depending on your source:

**From a local file:**
```bash
jaspr convert-html --file some/path/to/file.html
```

**From a URL:**
```bash
jaspr convert-html --url https://example.com
```

The resulting Jaspr code is printed directly to the console. You can then copy this code directly into your component's `build` method.

### Selecting Specific Elements

If you only need a portion of the HTML, you MUST use the `--query` option with a CSS selector to target specific elements rather than converting the whole file and deleting pieces manually.

```bash
jaspr convert-html --file some/path/to/file.html --query "#my-id"
```
*This will only convert and output the element with the id `my-id`.*

**Tip:** To convert everything inside the `<body>` tag but exclude the `<body>` tag itself, use:
```bash
jaspr convert-html --file some/path/to/file.html --query "body > *"
```