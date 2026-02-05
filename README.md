[![Banner](/assets/banner.png)](https://jaspr.site)

<p align="center">
  <a href="https://github.com/sponsors/schultek"><img src="https://img.shields.io/badge/sponsor-30363D?style=for-the-badge&logo=GitHub-Sponsors&logoColor=#white" alt="sponsor"></a>
</p>

<p align="center">
  <a href="https://pub.dev/packages/jaspr"><img src="https://img.shields.io/pub/v/jaspr?label=pub.dev&labelColor=333940&logo=dart&color=00589B" alt="pub"></a>
  <a href="https://github.com/schultek/jaspr"><img src="https://img.shields.io/github/stars/schultek/jaspr?style=flat&label=stars&labelColor=333940&color=8957e5&logo=github" alt="github"></a>
  <a href="https://github.com/schultek/jaspr/actions/workflows/test.yml"><img src="https://img.shields.io/github/actions/workflow/status/schultek/jaspr/test.yml?branch=main&label=tests&labelColor=333940&logo=github" alt="tests"></a>
  <a href="https://app.codecov.io/gh/schultek/jaspr"><img src="https://img.shields.io/codecov/c/github/schultek/jaspr?logo=codecov&logoColor=fff&labelColor=333940" alt="codecov"></a>
  <a href="https://discord.gg/XGXrGEk4c6"><img src="https://img.shields.io/discord/993167615587520602?logo=discord&logoColor=fff&labelColor=333940" alt="discord"></a>
  <a href="https://github.com/schultek/jaspr"><img src="https://img.shields.io/github/contributors/schultek/jaspr?logo=github&labelColor=333940" alt="contributors"></a>
</p>

<p align="center">
  <a href="https://jaspr.site">Website</a> •
  <a href="https://docs.jaspr.site/quick_start">Quickstart</a> •
  <a href="https://docs.jaspr.site">Documentation</a> •
  <a href="https://playground.jaspr.site">Playground</a> •
  <a href="https://discord.gg/XGXrGEk4c6">Community & Support</a> •
  <a href="https://jaspr-benchmarks.web.app">Benchmarks</a>
</p>

# Jaspr

> A modern web framework for building websites in Dart with support for both **client-side** and **server-side rendering**, as well as **static site generation**.

- 🔮 **Why?**: Jaspr was made with the premise to make a web-framework that looks and feels just like Flutter, but renders normal HTML and CSS.
- 👥 **Who?**: Jaspr is targeted mainly at Flutter developers that want to build any type of websites (especially ones that are not suitable for Flutter Web).
- 🚀 **What?**: Jaspr wants to push the boundaries of Dart on the web and server, by giving you a thought-through fullstack web framework written completely in Dart.

> Want to contribute to Jaspr? Join our open [Discord Community](https://discord.gg/XGXrGEk4c6) of
> developers around Jaspr and check out the [Contributing Guide](https://docs.jaspr.site/going_further/contributing).

### Core Features

- 💙 **Familiar**: Works with a similar component model to Flutter widgets.
- 🚀 **Powerful**: Comes with server side rendering out of the box.
- ♻️ **Easy**: Syncs component state between server and client automatically.
- ⚡️ **Fast**: Performs direct DOM updates only where needed.
- 🎛 **Flexible**: Runs on the server, client or both with manual or automatic setup. You decide.

> If you want to say thank you, star the project on GitHub and like the package on pub.dev 🙌💙

### Online Editor & Playground

Inspired by DartPad, **Jaspr** has it's own online editor and playground, called **JasprPad**.

[Check it out here!](https://playground.jaspr.site)

You can check out the samples, take the tutorial or try out Jaspr for yourself, all live in the browser.
When you want to continue coding offline, you can quickly download the current files bundled in a complete dart project, ready to start coding locally.

JasprPad is also built with **Jaspr** itself, so you can [**check out its source code**](https://github.com/schultek/jaspr/tree/main/apps/jaspr_pad) to get a feel for how Jaspr would be used in a larger app.

![JasprPad Screenshot](https://user-images.githubusercontent.com/13920539/170837732-9e09d5f3-e79e-4ddd-b118-72e49456a7cd.png)

## Differences to Flutter Web - Design Principles

Jaspr is an **alternative to Flutter Web**, when you want to **build any kind of website with Dart**.

The Flutter team itself has stated on multiple occasions that
> Flutter Web is for building **Web-Apps**, not **Web-Sites**.

That just means that while Flutter Web is a great technology for sharing your apps across multiple
platforms including the web, it may not be suited for all types of websites that you want to build.

Jaspr works by giving you the familiar look and feel of the Flutter framework, while using native web
technologies, like HTML, the DOM and CSS to enable you to build **all** kinds of websites using **Dart**.

Instead of trying to mirror every little thing from Flutter, Jaspr tries to give a general Fluttery feeling
by matching features where it makes sense without compromising on the unique properties of the web platform.
Rather, it embraces these differences to give the best of both worlds.

[Learn more.](https://docs.jaspr.site/jaspr-vs-flutter-web)

## Directories

- **/apps**: Production apps built with Jaspr.
  - **/jaspr_pad**: Online Editor and Playground inspired by DartPad, built with Jaspr. Hosted at [playground.jaspr.site](https://playground.jaspr.site).
  - **/website**: The Jaspr website, built with Jaspr itself. Hosted at [jaspr.site](https://jaspr.site).
- **/assets**: Branding images and other assets for Jaspr.
- **/docs**: Documentation hosted at [docs.jaspr.site](https://docs.jaspr.site).
- **/examples**: Examples for showcasing different Jaspr features.
- **/packages**:
  - **/jaspr**: The core framework package.
  - **/jaspr_builder**: Code-generation builders for Jaspr.
  - **/jaspr_cli**: The command line interface of Jaspr.
  - **/jaspr_content**: Jaspr plugin for building content-driven sites like documentation, blogs, or marketing pages. Documented at [docs.jaspr.site/content](https://docs.jaspr.site/content).
  - **/jaspr_flutter_embed**: Flutter element embedding bindings for Jaspr.
  - **/jaspr_lints**: A collection of lints and assists for Jaspr projects.
  - **/jaspr_riverpod**: An unofficial Riverpod implementation for Jaspr.
  - **/jaspr_router**: A router implementation for Jaspr.
  - **/jaspr_serverpod**: An official Jaspr integration for [Serverpod](serverpod.dev).
  - **/jaspr_test**: A testing package for Jaspr.
