
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
  - Sets up the project to be able to use Flutter web plugins (not Flutter widgets). 
7. (If 2 Is Auto|Server) Use custom backend? (None, Shelf, Dart Frog, ?)
  - Sets up a custom backend framework to use for the server part of your project. 

Additional options to be considered:

- Using tailwind

---
Welcome to the Jaspr setup wizard. We will go through a series of
questions to set up your jaspr project.

You can either toggle a setting for Yes or No, or select an item from a list of options.
You can also directly press [ENTER] to select the recommended default setting (marked in UPPERCASE letters). 

Enter '?' to get a help description for the current question.

Now lets get started.
---
([ENTER] = Continue, [X] = Don't show again)

1. Project Name
2. Select Mode (Static, Server, Client, ?)
- Static: Build a static prerendered site with optional client-side rendering.
- Server: Build a server-rendered site with optional client-side hydration.
- Client: Build a purely client-rendered website.
3. (If 2 is Static or Server) Use automatic client hydration? (Y/n/?)
- Using the new @client annotation.
4. Setup routing? (Y/n/?)
- Uses jaspr_router to route to different pages of your app.
5. (If 4 is Yes And 2 is not Client) Use multi-page routing? (Y/n/?)
- Sets up routing on the server. Choosing [no] sets up client-side routing instead.
6. Use Flutter Embedding? (y/N/?)
- Sets up Flutter web embedding for your project.
7. (If 6 Is No) Use Flutter plugin interop? (Y/n/?)
- Sets up the project to be able to use Flutter web plugins (not Flutter widgets).
8. (If 2 Is Server) Use custom backend? (None, Shelf, Dart Frog, ?)
- Sets up a custom backend framework to use for the server part of your project. 


4=N: Single Page App
4=Y: Multi Page App

6=Y: Run flutter create
