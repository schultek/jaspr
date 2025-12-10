# Hello World

A simple app that renders 'Hello World!' to the webpage.

To render something with **Jaspr** you have two main options: 

- Low level html components like `div()`, `button()` or `h1()` that reflect a specific html element. These can be 
  identified by their lowercase naming.
- Higher level components like `Builder()` or any custom component you write yourself that composes other components
  through their `build()` method.

> Jaspr calls its building blocks [Component]s instead of [Widget]s. 

Just like in Flutter, you use [runApp] to set the root component of your app.

---

## 🔎 Html components / DomComponent

A html component (like `div()`, `button()`, `h1()`, etc.) will render a single html element to the webpage. 

Each component has an `id`, `classes` and `styles` property as well as general `attributes` and `events` parameter.

However, many components also have additional typed properties that you can use, like the `href` property of `a()`, or the `onClick` property of `button()`.

Most components also take a list of `children`, since html elements usually can have multiple child elements.

## 🔎 Text / text

The `Component.text` constructor renders a plain text node.

A text node in html is just some standalone string, that is placed inside another html element. 
Therefore the `Component.text` constructor also only receives a single string to render to the page.

> As usual for web, styling is done through a combination of CSS attributes, either in a 
> **Stylesheet** or inline though the **`styles` attribute** of the parent elements.

---

# 🚀 Task

1. Wrap the `h1` element in another `div` element.
   <details>
     <summary>Tip</summary>
     Wrap with `div([])`.
   </details>
   
2. Inside the new `div` element, add a new paragraph under the heading, containing some text.
   <details>
     <summary>Tip</summary>
     The paragraph element is simply called `p` in html.
   </details>
