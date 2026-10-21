---
title: Use Structured Frontmatter for Page Metadata, Layout Selection, and Navigation
impact: MEDIUM
impactDescription: Enables automated metadata generation, SEO tags, layout routing, and table of contents generation
tags: content, frontmatter, seo, layouts, jaspr_content
---

## Use Structured Frontmatter for Page Metadata, Layout Selection, and Navigation

**Impact: MEDIUM (Enables automated metadata generation, SEO tags, layout routing, and table of contents generation)**

`jaspr_content` parses YAML frontmatter at the head of content Markdown files. This frontmatter drives automatic metadata generation (page titles, `<meta name="description">`, OpenGraph tags), layout selection (`layout: docs`, `layout: blog`), and navigation sidebar grouping.

Always provide structured frontmatter on Markdown pages rather than hardcoding headings and metadata manually.

**Incorrect (missing frontmatter, leaving pages without metadata or automated layout):**

```markdown
# My Post
Posted on Jan 2026 by Author

Here is the body text...
```

**Correct (structured frontmatter providing layout, SEO, and navigation data):**

```markdown
---
title: Getting Started with Jaspr
description: A comprehensive beginner's guide to building with Jaspr.
layout: docs
date: 2026-10-21
tags: [tutorial, beginner]
---

# Getting Started with Jaspr

Here is the body text...
```
