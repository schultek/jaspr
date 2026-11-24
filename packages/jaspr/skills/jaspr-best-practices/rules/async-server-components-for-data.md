---
title: Fetch Data on the Server with AsyncStatelessComponent to Eliminate Client Waterfalls
impact: HIGH
impactDescription: Eliminates loading spinners, renders full HTML on initial request, and improves SEO/LCP
tags: async, server, ssr, data-fetching
---

## Fetch Data on the Server with AsyncStatelessComponent to Eliminate Client Waterfalls

**Impact: HIGH (Eliminates loading spinners, renders full HTML on initial request, and improves SEO/LCP)**

Fetching data inside a client component's `initState()` causes a network waterfall: the user waits for the initial HTML, downloads and parses the JavaScript bundle, and only then initiates the HTTP request to fetch data, seeing a flash of loading spinners or skeletons.

In Jaspr's server or static mode, fetch data directly on the server during the build phase using `AsyncStatelessComponent` or `AsyncBuilder`. The server waits for the data to resolve and renders the complete, populated HTML in the initial HTTP response. If client interactivity is needed, pass the resolved data down to a `@client` component as initial state.

**Incorrect (client-side data fetching causing network waterfall and blank layout):**

```dart
@client
class ProductList extends StatefulComponent {
  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  List<Product>? products;

  @override
  void initState() {
    super.initState();
    // Waterfall: user waits for JS to load, then waits for API response:
    fetchProducts().then((data) => setState(() => products = data));
  }

  @override
  Component build(BuildContext context) {
    if (products == null) return div([.text('Loading...')]); // Blank during SSR!
    return ul([
      for (final p in products!) li([.text(p.title)]),
    ]);
  }
}
```

**Correct (server fetches data before responding with complete HTML):**

```dart
import 'package:jaspr/server.dart';
import 'package:jaspr/dom.dart';

class ServerProductList extends AsyncStatelessComponent {
  const ServerProductList({super.key});

  @override
  Future<Component> build(BuildContext context) async {
    // Data is fetched on server directly before HTML is generated:
    final products = await database.getProducts();

    return ul([
      for (final p in products) li([.text(p.title)]),
    ]);
  }
}
```
