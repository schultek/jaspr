![Banner](/assets/jaspr_banner.png)

# jaspr

Experimental web framework for Dart. Supports SPAs and SSR. 

**Main Features:**

- Familiar component model similar to Flutter widgets
- Easy Server Side Rendering
- Automatic hydration of component data on the client
- Fast incremental DOM updates

> I'm looking for contributors. Don't hesitate to contact me if you want to help in any way.

[Demo & Playground](https://jasprpad.schultek.de)

## About

Jaspr was made with the premise to make a web-framework that looks and feels just like Flutter, but 
renders normal html/css like Vue or React. It is targeted mainly at Flutter developers that want to 
build websites but don't want to use Flutter Web (for various reasons). Since it uses Dart, it is
also strong in terms of type-safety and null-safety compared to JS.

### Differences to Flutter and Design Principles

As you might know Flutter renders Widgets by manually painting pixels to a canvas. However rendering web-pages
with HTML & CSS works fundamentally different to Flutters painting approach. Also Flutter has a vast variety 
of widgets with different purposes and styling, whereas in html you can uniquely style each html element however 
you like.

Instead of trying to mirror every little thing from Flutter, `jaspr` tries to give a general Fluttery feeling 
by matching features where it makes sense without compromising on the unique properties of the web platform.
Rather it embraces these differences to give the best of both worlds.

[More](https://github.com/schultek/jaspr/tree/main/packages/jaspr#differences-to-flutter)

## Directories

- **/experiments**: Experimental apps or features, that are not part of the core framework (yet?).
  - **/minimal_app**: A minimal example with a single entry point for both client and server.
  - **/preload_images**: A component that automatically preloads images for a next route.
  - **/riverpod**: Riverpod example for jaspr.
  - **/scoped_styles**: A component that introduces scoped styles.
  - **/server_handling**: An app that uses custom middleware on the server to host an api.
- **/packages**:
  - [**/jaspr**](https://github.com/schultek/jaspr/tree/main/packages/jaspr): The main framework package.
  - **/jaspr_builder**: Polyfill builder for integrating js libraries with jaspr.
  - **/jaspr_pad**: DartPad inspired online playground for jaspr apps.
  - **/jaspr_riverpod**: Riverpod implementation for jaspr.
  - **/jaspr_test**: A test package for jaspr.
  
## Roadmap

- [x] Implement core framework
- [x] Write test package and framework tests
- [x] Add riverpod integration package
- [x] Add jasprpad as online playground with samples
- [x] Add tutorial to jasprpad
- [ ] Add documentation in readme files
- [ ] Add ssg support
- [ ] Add website
- [ ] Expand framework with missing concepts (Animations, ...)
- [ ] Bump test coverage over 80%