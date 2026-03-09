# Table: Managed Experience vs Manual Experience

The smart components and other features require deep customization of the
development and compilation pipeline of a Dart project.

However it should still be open enough for the user to choose not to use jasprs custom pipeline and use the standard
Dart web tools instead - which then only can support a subset of jasprs features:

| \                      | jaspr_cli + jaspr_web_compilers | webdev + dart_web_compilers | other server |
|------------------------|---------------------------------|-----------------------------|--------------|
| Smart Components       | [x]                             | [ ]                         | [ ]          |
| Client side rendering  | [x]                             | [x]                         | [ ]          |
| Server side rendering  | [x]                             | [ ]                         | [x]          |
| Static site generation | [x]                             | [ ]                         | [ ]          |


Manual usage of jaspr includes:

- Calling `runApp` on the client
- Calling `serveApp` and `renderComponent`


Managed usage additionally includes:

- Component-only mode (no main function or runApp call needed)
- Smart components
- Automatic hydration
- Resumed state

