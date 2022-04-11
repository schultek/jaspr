# jaspr

Experimental web framework for Dart. Supports SPAs and SSR. 

**Main Features:**

- Familiar component model similar to Flutter widgets
- Easy Server Side Rendering
- Automatic hydration of component data on the client
- Fast incremental DOM updates using [package:domino](https://pub.dev/packages/domino)

> I'm looking for contributors. Don't hesitate to contact me if you want to help in any way.

## Directories

- **/demo**: Live demo app that is deployed [here](https://dart-web-demo.herokuapp.com/)
- **/experiments**: Experimental apps or features, that are not part of the core framework (yet?)
  - **/minimal_app**: A minimal example with a single entry point for both client and server
  - **/preload_images**: A component that automatically preloads images for a next route
  - **/riverpod**: Riverpod example for jaspr
  - **/scoped_styles**: A component that introduces scoped styles
  - **/server_handling**: An app that uses custom middleware on the server to host an api
- **/packages**:
  - **/jaspr**: The main framework package
  - **/jaspr_riverpod**: Riverpod implementation for jaspr
  - **/jaspr_test**: A test package for jaspr
  
## Todo

- Add documentation for foundation & components
- Bump coverage over 80%
- Add documentation website
- Add more complex demo app