# islands_app

A server-rendered app using the islands architecture for client hydration.

- Only specified **Island** components will be compiled as part of the javascript bundle and 
  hydrated on the client
- Everything under the subtree of the island component will be included and
  island components should not be nested (only 1 island component per subtree)
- Island components are annotated with `@island`