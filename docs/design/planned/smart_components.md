
# Concept: Smart Component

Inspired from React Server Component, we want simple component types that distinguish between interactive client
components and static server components.

Lower-tier components cannot be imported from higher-tier components.


| \            | Tier | pre-rendered | interactive |
|--------------|------|--------------|-------------|
| @static      | 0    | on build     | no          |
| @dynamic     | 1    | on request   | no          |
| @interactive | 2    | yes          | yes         |


Mode: Auto
Based on which components are used in the project, the framework can automatically pick any of the needed rendering
phases of SSG, SSR or CSR.
If no @interactive is used, no client scripts are generated.
If neither @static or @dynamic are used (or nothing), nothing is built (+ warning).

Mode: Client
Build outputs main file to web/ directory if not exists.
Requires index.html in web/ directory.

Mode: Server
Build outputs executable.
Manual scripting required.

Mode: Static
Build outputs prerendered files at build time.
Manual scripting required.

Mode: Hybrid
Build outputs prerendered files and executable at build time.
Requires manual handling of static vs dynamic runtime for server code.
Manual scripting required



# Relationships:


```
static() {
  dynamic(child: static()) {
    child,
    interactive(child: dynamic()) {
      child,
    },
  },
  interactive() {},
),
dynamic() {
  interactive() {}
},
interactive() {}
```
