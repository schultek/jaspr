{{flutter_js}}
{{flutter_build_config}}

_flutter.buildConfig.builds[0].mainWasmPath = "main.clients.wasm";
_flutter.buildConfig.builds[0].jsSupportRuntimePath = "main.clients.mjs";

_flutter.loader.load({
  onEntrypointLoaded: async function onEntrypointLoaded(engineInitializer) {
    let engine = await engineInitializer.initializeEngine({
      multiViewEnabled: true, // Enables embedded mode.
    });
    let app = await engine.runApp();
    window._flutter_app = app;
  }
});