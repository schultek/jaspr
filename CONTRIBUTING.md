# Contributing to Jaspr

## New contributor guide

To get an overview of the project, read the [README](README.md) 
and [Documentation](https://docs.page/schultek/jaspr).

## What to contribute

We welcome all contributions to the project, however some contributions are better suited 
for new contributors or easier to get accepted.

Read [Contributing Docs](https://docs.page/schultek/jaspr) for some guidance on the types
of possible contributions.

## Issues

### Create a new issue

If you spot a problem, [search if an issue already exists](https://github.com/schultek/jaspr/issues). 
If a related issue doesn't exist, you can [open a new issue](https://github.com/schultek/jaspr/issues/new).

For other contributions like documentation, examples, etc. please also open an issue so we know what you
want to work on and discuss any details.

#### Solve an issue

Scan through our [existing issues](https://github.com/schultek/jaspr/issues) to find one that interests you. 
If you find an issue to work on, first comment on it to express interest in solving it. 
Then you are welcome to open a PR with a fix.

## Setup and running

### 1. Cloning and setup

Make sure that you are at least on **Dart SDK version 2.17.0**.

Clone the project with the following command:
```shell
git clone https://github.com/schultek/jaspr.git
```

Next activate the jaspr command globally for this local project:
```shell
cd jaspr/packages
dart pub global activate jaspr --source path
```

With this, whenever you use the `jaspr ...` command, it will use your local project.

Jaspr uses [Melos](https://github.com/invertase/melos) to manage the project and dependencies.
To install Melos, run the following command:

```dart
dart pub global activate melos
```

Next, at the root of your locally cloned repository run the bootstrap command:

```dart
melos bootstrap
```

The bootstrap command locally links all dependencies within the project without having to provide manual `dependency_overrides`. 
This allows all packages, examples and tests to build from the local clone project.

> You do not need to run `dart pub get` once bootstrap has been completed.

### 2. Running tests and compute coverage

To run all tests across packages, run:

```shell
melos run test
```

To also compute the coverage and open the report in your browser, run:

```shell
melos run coverage
```

### 3. Generate html component methods

When you change something in the html component library, re-generate the component
methods by running:

```shell
melos run generate:html
```

### 4. Generate templates

When you change or add a template, re-generate the template bundles for the cli by running:

```shell
melos run generate:templates
```
