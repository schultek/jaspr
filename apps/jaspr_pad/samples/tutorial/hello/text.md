# Hello World

A simple app that renders 'Hello World!' to the webpage.

To render html with **Jaspr** you have two main components: [DomComponent] and [Text].
You can combine and nest multiple components using the [child] parameter of a component.

> Jaspr calls its building blocks [Component]s instead of [Widget]s. 

Just like in Flutter, you use [runApp] to set the root component of your app.

---

## 🔎 DomComponent

The `DomComponent` will render a single html element to the webpage. It takes a tag, and optionally 
some attributes and events.

It also takes a single `child` or a list of `children`, since html elements can have multiple child nodes.

## 🔎 Text

The `Text` component renders a plain text node.

A text node in html is just some standalone string, that is placed inside another html element. 
Therefore the `Text` component also only receives a single string to render to the page.

> As usual for web, styling is done through a combination of CSS attributes, either in a 
> **Stylesheet** or inline though the **`style` attribute** of the parent elements.

---

# 🚀 Task

1. Wrap the `h1` element in another `div` element.
   <details>
     <summary>Tip</summary>
     Wrap with a new `DomComponent`.
   </details>
   
2. Inside the new `div` element, add a new paragraph under the heading, containing some text.
   <details>
     <summary>Tip</summary>
     Change the `child` property of the div component to `children` and use a list.
   </details>