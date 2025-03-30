[![Github](https://img.shields.io/github/stars/schultek/jaspr?style=flat&label=stars&labelColor=333940&color=8957e5&logo=github)](https://github.com/schultek/jaspr)
[![Discord Chat](https://img.shields.io/discord/993167615587520602?logo=discord&logoColor=fff&labelColor=333940)](https://discord.gg/XGXrGEk4c6)
[![Contribute](https://img.shields.io/github/contributors/schultek/jaspr?logo=github&labelColor=333940)](https://github.com/schultek/jaspr)

The official [VS Code](https://code.visualstudio.com/) extension for the Jaspr web framework.

## Installation

This extension also requires the [Dart VSCode Extension](https://marketplace.visualstudio.com/items?itemName=Dart-Code.dart-code) to be installed.

## Debugging a Jaspr application

To run and debug a Jaspr applications, launch it using F5 or the Debug menu. The extension will start the debug process and attach the Dart debugger to it. 

---

When developing a Jaspr project in `static` or `server` mode, this will open **two** separate debugging sessions, one for the server and one for the client. Switch between the two using the debugging sidebar or process dropdown.

| Sidebar | Dropdown. |
|---|---|
| ![Sidebar](media/screenshots/sidebar.png) | ![Dropdown](media/screenshots/dropdown.png)

Both processes will be managed by the main Jaspr terminal.

![Terminal](media/screenshots/terminal.png)

To stop the server, focus the terminal and press `Ctrl+C`. This will stop both debugging sessions and the main process.
You can also detach the debugging sessions individually using the detach button in the debug bar, but this will keep the app running.