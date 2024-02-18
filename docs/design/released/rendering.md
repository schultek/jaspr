
### Change building / rendering implementation

1. Build synchronization

- Flutter has a build phase where all dirty widgets are build, before having a unified rendering phase
- All widgets must be build before any widget is rendered

- In html we can rebuild and update elements at any time, independent from other elements
- It still makes sense to batch updates to
  - not update the same widget multiple times for a single frame
  - not make unneccessary updates if some changes in the upper tree affect the lower tree

Therefore:

- keep flutters 'update from root to leaf' update order
- keep the batched scheduled build phase
- change to combine build and render step for a single component

We need to remove the dependency on domino and implement in-place dom updates

- extend build scheduler to expose methods to attach new child elements
- rename to better name (DomNode)
- when rebuilding only invalidate closest DomNode ancestor (or self)
- when rendering a dom element, get all children in order (visit children) and compare with child elements
- separate flags for attributes dirty vs children dirty to increase performance
