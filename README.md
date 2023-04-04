![Banner](/assets/jaspr_banner.png)

<p align="center">
  <a href="https://github.com/sponsors/schultek"><img src="https://img.shields.io/badge/sponsor-30363D?style=for-the-badge&logo=GitHub-Sponsors&logoColor=#white" alt="sponsor"></a>
</p>

<p align="center">
  <a href="https://pub.dev/packages/jaspr"><img src="https://img.shields.io/pub/v/jaspr?label=pub.dev&logo=dart" alt="pub"></a>
  <a href="https://github.com/schultek/jaspr"><img src="https://img.shields.io/github/stars/schultek/jaspr?logo=github" alt="github"></a>
  <a href="https://github.com/schultek/jaspr/actions/workflows/test.yml"><img src="https://img.shields.io/github/actions/workflow/status/schultek/jaspr/test.yml?branch=main&label=tests&labelColor=333940&logo=github" alt="tests"></a>
  <a href="https://app.codecov.io/gh/schultek/jaspr"><img src="https://img.shields.io/codecov/c/github/schultek/jaspr?logo=codecov&logoColor=fff&labelColor=333940" alt="codecov"></a>
  <a href="https://discord.gg/XGXrGEk4c6"><img src="https://img.shields.io/discord/993167615587520602?logo=discord" alt="discord"></a>
  <a href="https://github.com/schultek/jaspr"><img src="https://img.shields.io/github/contributors/schultek/jaspr?logo=github" alt="contributors"></a>
</p>

<p align="center">
  <a href="https://docs.page/schultek/jaspr/quick-start">Quickstart</a> •
  <a href="https://docs.page/schultek/jaspr">Documentation</a> •
  <a href="https://jasprpad.schultek.de">Playground</a> •
  <a href="https://github.com/schultek/jaspr/tree/main/examples/">Examples</a> •
  <a href="https://discord.gg/XGXrGEk4c6">Community & Support</a> •
  <a href="https://jaspr-benchmarks.web.app">Benchmarks</a>
</p>

# Jaspr

> A modern web framework for building websites in Dart with support for both **client-side** and **server-side rendering**.

- 🔮 **Why?**: Jaspr was made with the premise to make a web-framework that looks and feels just like Flutter, but
  renders normal html/css like Vue or React.
- 👥 **Who?**: Jaspr is targeted mainly at Flutter developers that want to build any type of websites
  (especially ones that are not suitable for Flutter Web).
- 🚀 **What?**: Jaspr wants to push the boundaries of Dart on the web and server, by giving you a thought-through fullstack
  web framework written completely in Dart.

> Want to contribute to Jaspr? Join our open [Discord Community](https://discord.gg/XGXrGEk4c6) of
> developers around Jaspr and check out the [Contributing Guide](https://docs.page/schultek/jaspr/eco/contributing).

### Core Features

- 💙 **Familiar**: Works with a similar component model to flutter widgets.
- 🚀 **Powerful**: Comes with server side rendering out of the box.
- ♻️ **Easy**: Syncs component state between server and client automatically.
- ⚡️ **Fast**: Performs incremental DOM updates only where needed.
- 🎛 **Flexible**: Runs on the server, client or both with manual or automatic setup. You decide.

> If you want to say thank you, star the project on GitHub and like the package on pub.dev 🙌💙

### Online Editor & Playground

Inspired by DartPad, **Jaspr** has it's own online editor and playground, called **JasprPad**.

[Check it out here!](https://jasprpad.schultek.de)

You can check out the samples, take the tutorial or try out jaspr for yourself, all live in the browser.
When you want to continue coding offline, you can quickly download the current files bundled in a complete dart project, ready to start coding locally.

JasprPad is also built with **Jaspr** itself, so you can [**check out its source code**](https://github.com/schultek/jaspr/tree/main/apps/jaspr_pad) to get a feel for how jaspr would be used in a larger app.

![JasprPad Screenshot](https://user-images.githubusercontent.com/13920539/170837732-9e09d5f3-e79e-4ddd-b118-72e49456a7cd.png)

## Differences to Flutter Web - Design Principles

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
- **/docs**: Documentation hosted at [docs.page/schultek/jaspr](https://docs.page/schultek/jaspr)
- **/examples**: Well-maintained and documented examples
- **/experiments**: Experimental apps or features, that are not part of the core framework (yet?) (may be broken).
- **/packages**:
  - [**/jaspr**](https://github.com/schultek/jaspr/tree/main/packages/jaspr): The core framework package.
  - **/jaspr_builder**: Code-generation builders for jaspr.
  - **/jaspr_riverpod**: Riverpod implementation for jaspr.
  - **/jaspr_router**: A router implementation for jaspr.
  - **/jaspr_test**: A testing package for jaspr.
