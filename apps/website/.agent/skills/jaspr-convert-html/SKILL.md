---
name: jaspr-convert-html
description: Use when you need to convert / rewrite existing HTML (from a file or url) into Jaspr code.
---

## Rules

- ALWAYS use the tooling daemon to convert existing HTML to idiomatic Jaspr code automatically.
- Take the output UNCHANGED and use it as is.
- NEVER attempt to convert HTML to Jaspr code manually.

## Usage

To convert HTML to Jaspr code, use this command:

1. From file: `jaspr tooling-daemon convert-html --file some/path/to/file.html`
2. From url: `jaspr tooling-daemon convert-html --url https://example.com`

The resulting Jaspr code is printed to the console. The code is ready to be used in a Jaspr component's build method, or as the child parameter for another component.

### Options

The command also allows for selecting specific elements to convert using a CSS query:

```bash
jaspr tooling-daemon convert-html --file some/path/to/file.html --query "#my-id"
```

This will convert and output only the element with the id `my-id` of the HTML file to Jaspr code.

**Tip:** To convert everything inside but excluding `<body>` use `--query "body>*"`.