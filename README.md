![Banner](/assets/jaspr_banner.png)

<p align="center">
  <a href="https://pub.dev/packages/jaspr"><img src="https://img.shields.io/pub/v/jaspr.svg" alt="pub"></a>
  <a href="https://github.com/schultek/jaspr"><img src="https://img.shields.io/github/stars/schultek/jaspr" alt="github"></a>
  <a href="https://discord.gg/XGXrGEk4c6"><img src="https://img.shields.io/discord/993167615587520602" alt="discord"></a>
</p>

# jaspr

Experimental web framework for Dart. Supports SPAs and SSR. 

**Core Features:**

- Familiar component model similar to Flutter widgets
- Easy Server Side Rendering
- Automatic hydration of component data on the client
- Fast incremental DOM updates
- Well tested (~70% test coverage)

> I'm looking for contributors. Don't hesitate to contact me if you want to help in any way.

- [Wiki & Documentation](https://github.com/schultek/jaspr/wiki)
- [Demo & Playground](https://jasprpad.schultek.de)
- [Benchmarks](https://jaspr-benchmarks.web.app)

![JasprPad Screenshot](https://user-images.githubusercontent.com/13920539/170837732-9e09d5f3-e79e-4ddd-b118-72e49456a7cd.png)

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

[More](https://github.com/schultek/jaspr/wiki#-jaspr-vs-flutter-web)

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
  - **/jaspr_router**: A router implementation for jaspr.
  - **/jaspr_test**: A testing package for jaspr.
  - **/jaspr_ui**: UI components for jaspr.
  
## Roadmap

- ✅ Implement core framework
- ✅ Write test package and framework tests
- ✅ Add riverpod integration package
- ✅ Add jasprpad as online playground with samples
- ✅ Add tutorial to jasprpad
- ✅ Add wiki and documentation
- ✅ Add benchmarks
- 🚧 Bump test coverage over 80%
- 🔜 Improve router package
- 🔜 Add ssg support
- 🔜 Add css preprocessing and scoped styles
- 🔜 Improve tutorial on jasprpad
- 🔜 Improve wiki and add website
- 🔜 Extend framework with missing concepts (Animations, ...)
