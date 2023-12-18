# Table: Managed Experience vs Manual Experience

The smart components and other features require deep customization of the development and compilation pipeline of a
dart project.

However it should still be open enough for the user to choose not to use jasprs custom pipeline and use the standard
dart web tools instead - which then only can support a subset of jasprs features:

| \                      | jaspr_cli + jaspr_web_compilers | webdev + dart_web_compilers | other server |
|------------------------|---------------------------------|-----------------------------|--------------|
| Smart Components       | [x]                             | [ ]                         | [ ]          |
| Client side rendering  | [x]                             | [x]                         | [ ]          |
| Server side rendering  | [x]                             | [ ]                         | [x]          |
| Static site generation | [x]                             | [ ]                         | [ ]          |


Manual usage of jaspr includes:

- calling `runApp` on the client
- calling `serveApp` and `renderComponent`


Managed usage includes additionally:

- Component-only mode (no main function or runApp call needed)
- Smart components
- Automatic hydration
- Resumed state




