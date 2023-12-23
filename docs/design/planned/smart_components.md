
# Concept: Smart Component

Inspired from React Server Component, we want simple component types that distinguish between interactive client
components and static server components.

Lower tier components cannot be imported from higher tier components.


| \            | Tier | pre-rendered | interactive |
|--------------|------|--------------|-------------|
| @static      | 0    | on build     | no          |
| @dynamic     | 1    | on request   | no          |
| @interactive | 2    | yes          | yes         |
| @client      | 2    | no           | yes         |

Based on which components are used in the project, the framework can automatically pick any of the needed rendering 
phases of SSG, SSR or CSR.
