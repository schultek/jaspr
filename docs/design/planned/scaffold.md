
# Concept: Cli Project Scaffolding

Instead of using predefined and static templates when creating a new project, the cli should prompt the user for
choices on the architecture and structure of a project.

We already do this for the compiler choice. This should be extended to be a singular unified creation flow.

The flow is modeled below:

1. Project Name
2. Select Mode (Auto, Static, Server, Client, Hybrid, ?)
  - Auto: Let jaspr automatically determine the rendering modes based on the used smart components.
  - Static: Build a statically rendered site with optional client-side rendering.
  - Server: Build a server-rendered site with optional client-side hydration.
  - Client: Build a purely client-rendered website.
  - Hybrid: Use static and server mode for separate pages of your site.
3. Setup routing? (Y/n/?)
  - Uses jaspr_router to route to different pages of your app.
4. (If 3 is Yes And 2 is not Client) Use multipage routing? (Y/n/?)
  - Sets up routing on the server. Choosing No sets up client-side routing. 
5. Use Flutter Embedding? (y/N/?)
  - Sets up Flutter web embedding for your project. 
6. (If 5 Is No) Use Flutter Plugin Interop? (Y/n/?)
  - Sets up the project to be able to use flutter web plugins (not Flutter widgets). 
7. (If 2 Is Auto|Server) Use custom backend? (None, Shelf, Dart Frog, ?)
  - Sets up a custom backend framework to use for the server part of your project. 

Additional options to be considered:

- Adding a router scaffolding
- Using tailwind
