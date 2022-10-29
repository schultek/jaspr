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

- [Documentation](https://docs.page/schultek/jaspr)
- [Demo & Playground](https://jasprpad.schultek.de)
- [Benchmarks](https://jaspr-benchmarks.web.app)

![JasprPad Screenshot](https://user-images.githubusercontent.com/13920539/170837732-9e09d5f3-e79e-4ddd-b118-72e49456a7cd.png)

## About

Jaspr was made with the premise to make a web-framework that looks and feels just like Flutter, but 
renders normal html/css like Vue or React. It is targeted mainly at Flutter developers that want to 
build websites but don't want to use Flutter Web (for various reasons). Since it uses Dart, it is
also strong in terms of type-safety and null-safety compared to JS.

### Differences to Flutter and Design Principles

Jaspr is an **alternative to Flutter Web**, when you want to **build any kind of website with Dart**.

The Flutter team itself has stated on multiple occasions that
> Flutter Web is for building **Web-Apps**, not **Web-Sites**.

That just means that while Flutter Web is a great technology for sharing your apps across multiple
platforms including the web, it may not be suited for all types of websites that you want to build.

Jaspr works by giving you the familiar look and feel of the Flutter framework, while using native web
technologies, like HTML, the DOM and CSS to enable you building **all** kinds of websites using **Dart**.

Instead of trying to mirror every little thing from Flutter, `jaspr` tries to give a general Fluttery feeling 
by matching features where it makes sense without compromising on the unique properties of the web platform.
Rather it embraces these differences to give the best of both worlds.

[More](https://docs.page/schultek/jaspr/jaspr-vs-flutter-web)

## Directories

- **/apps**: Production apps built with jaspr
  - **/jaspr_pad**: Online Editor and Playground inspired by DartPad, built with jaspr.
- **/docs**: Documentation hosted at [docs.page/schultek/jaspr](https://docs.page/schultek/jaspr~develop)
- **/examples**: Well-maintained and documented examples
- **/experiments**: Experimental apps or features, that are not part of the core framework (yet?) (may be broken).
- **/packages**:
  - [**/jaspr**](https://github.com/schultek/jaspr/tree/main/packages/jaspr): The core framework package.
  - **/jaspr_builder**: Code-generation builders for jaspr.
  - **/jaspr_riverpod**: Riverpod implementation for jaspr.
  - **/jaspr_router**: A router implementation for jaspr.
  - **/jaspr_test**: A testing package for jaspr.