# Design System Specification: The Technical Monolith

## 1. Overview & Creative North Star
**Creative North Star: The Architectural Console**

This design system moves beyond the "standard" dashboard. It is a high-density, high-precision environment engineered for the professional developer. Rather than a flat web interface, it is treated as a **Technical Monolith**—a tool that feels carved out of a single, dark obsidian block where information is revealed through light, depth, and precise syntax-driven accents.

We break the "template" look by rejecting the generic "sidebar-and-header" grid. Instead, we use **Asymmetric Instrumentation**: primary controls are clustered with high density, while secondary data breathes in expansive, low-contrast zones. We avoid "consumer-grade" roundedness in favor of tight, micro-radii that signal mechanical precision.

## 2. Colors & Surface Philosophy
The palette is rooted in the "Syntax Dark" tradition—blues, purples, and oranges that serve as functional indicators, not just decoration.

### Surface Hierarchy & Nesting
To achieve a premium, integrated feel, we follow the **Tonal Nesting** principle. 
- **The "No-Line" Rule:** Do not use 1px solid borders to section off major UI areas. Instead, define boundaries by shifting between `surface_container_lowest` (#0e0e0e) for the most recessed "wells" and `surface_container_high` (#2a2a2a) for active tool panels.
- **Glass & Gradient:** Floating command palettes or hover-menus must use **Glassmorphism**. Use `surface_container` with a `backdrop-blur` of 12px and 80% opacity to let the code underneath subtly bleed through.
- **Signature Textures:** For primary CTAs, use a subtle linear gradient from `primary` (#a3c9ff) to `primary_container` (#3399ff) at a 135-degree angle. This adds a "lithographic" depth that flat hex codes lack.

### Key Token Applications:
*   **Primary (#a3c9ff):** Logic, Functions, and Active States.
*   **Secondary (#dab9ff):** Strings, Constants, and Secondary Actions.
*   **Tertiary (#ffb86c):** Keywords, Warnings, and Crucial Alerts.
*   **Background (#131313):** The void; the base layer of the IDE.

## 3. Typography: The Dual-Engine System
We use a high-contrast typographic pairing to distinguish between "The UI" and "The Work."

*   **The Interface Engine (Inter):** Used for labels, menus, and metadata. It is clean, neutral, and stays out of the way. 
    *   *Body-sm* (0.75rem) is your workhorse for high-density property panels.
*   **The Display Engine (Space Grotesk):** Used for `headline` and `display` levels. Its quirky, technical terminals provide a "bespoke tool" feel.
*   **The Code Engine (Monospace):** All code elements, IDs, and terminal outputs must use a high-legibility monospace font (e.g., JetBrains Mono) mapped to `body-md` or `label-sm`.

**Hierarchy Tip:** Use `label-sm` in `on_surface_variant` (#c0c7d5) for non-interactive labels to create a clear visual gap between "Description" and "Value."

## 4. Elevation & Depth
In this design system, depth is a function of light, not structure.

*   **The Layering Principle:** 
    1.  **Base:** `surface` (#131313)
    2.  **In-set Panels (Terminal/Console):** `surface_container_lowest` (#0e0e0e)
    3.  **Workspace Cards:** `surface_container_low` (#1b1b1c)
*   **Ambient Shadows:** For floating modals, use an extra-diffused shadow: `offset: 0 8px, blur: 32px, color: rgba(0,0,0,0.5)`. 
*   **The "Ghost Border" Fallback:** If a separator is required for accessibility, use a **Ghost Border**: `outline_variant` (#404753) at 15% opacity. This creates a "hairline" feel common in premium hardware interfaces.

## 5. Components

### Buttons: The Tactile Toggle
*   **Primary:** Gradient fill (`primary` to `primary_container`), `md` (0.375rem) radius. On hover, increase the `surface_tint` brightness.
*   **Secondary:** Ghost-style. No fill, `outline_variant` ghost border. Text in `primary`.
*   **Density:** Use `spacing-2.5` (0.5rem) vertical padding for a compact, "pro" feel.

### Input Fields: The Command Line
*   **Base:** `surface_container_highest` (#353535). 
*   **Bottom-Bar Only:** Instead of a full box, try a 2px bottom border in `outline_variant` that transitions to `primary` on focus.
*   **Typography:** Always use Monospaced font for input values to ensure alignment and technical accuracy.

### Chips: Syntax Tags
*   Use `secondary_container` (#602b9d) for background and `on_secondary_container` (#cfa7ff) for text. 
*   Radius: `full` for a distinct "pill" shape that breaks the rectangular grid of the IDE.

### Cards & Lists: High-Density Data
*   **Forbid Dividers:** Do not use lines between list items. Use a `spacing-1` (0.2rem) vertical gap and a background shift to `surface_bright` on hover.
*   **The "Active" Indicator:** Instead of highlighting the whole row, use a 2px vertical "power-bar" of `primary` color on the left edge of the active list item.

### New Component: The "Breadcrumb Trace"
For complex developer paths, use a horizontally scrolling list of `label-sm` elements separated by a `tertiary` (#ffb86c) "chevron" icon. This provides a clear, syntax-like path through the application state.

## 6. Do's and Don'ts

### Do:
*   **Do** embrace high density. Use `spacing-2` and `spacing-3` for most internal margins.
*   **Do** use color as a status. If something is "Live," use a `primary` glow; if it's "Static," use `outline`.
*   **Do** treat the scrollbar as part of the UI. Make it thin, non-rounded, and colored `surface_container_highest`.

### Don't:
*   **Don't** use large border-radii (`xl` or `lg`). It makes the tool feel like a toy. Stick to `sm` and `md`.
*   **Don't** use pure white (#ffffff). It causes eye strain in dark technical environments. Always use `on_surface` (#e5e2e1).
*   **Don't** use standard drop shadows. If it's not floating (like a menu), it shouldn't have a shadow. Use tonal shifts instead.