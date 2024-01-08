
# Concept: Cli Project Scaffolding

Instead of using predefined and static templates when creating a new project, the cli should prompt the user for
choices on the architecture and structure of a project.

We already do this for the compiler choice. This should be extended to be a singular unified creation flow.

The flow is modeled below:

1. Project Name
2. Select Mode (SSR, CSR, SSG)
3. Setup routing for a multi page application? (Y/n)
4. (If 3 is Yes And 2 is not CSR) Use client side routing? (y/N)
5. Use Flutter Embedding? (y/N)
6. (If 5 Is No) Use custom compiler (Enabled Flutter Plugins) (y/N)
7. (If 2 Is SSR) Use custom backend? (None, Shelf, Dart Frog)

Additional options to be considered:

- Adding a router scaffolding
- Using tailwind
