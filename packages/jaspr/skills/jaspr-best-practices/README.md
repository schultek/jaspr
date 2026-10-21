# Jaspr Best Practices Skill

This directory contains the Jaspr Best Practices skill definitions.

## Structure

- **`rules/`** — **The single source of truth**. Individual markdown files containing rule titles, impact, tags, explanations, and Incorrect vs Correct code examples.
- **`rules/_sections.md`** — Defines rule categories, display priority order, impact levels, and prefix conventions.
- **`SKILL.md`** — Generated skill entrypoint with YAML frontmatter, category overview, and quick reference index.
- **`AGENTS.md`** — Generated all-in-one compiled reference containing all rules, descriptions, and code examples for fast AI/agent lookups.

## Adding or Modifying Rules

1. **Add or edit a rule** in `rules/<prefix>-<rule-name>.md` following this template:

   ```markdown
   ---
   title: Rule Title Here
   impact: CRITICAL # CRITICAL | HIGH | MEDIUM-HIGH | MEDIUM | LOW-MEDIUM
   impactDescription: Optional one-line summary of impact
   tags: tag1, tag2
   ---

   ## Rule Title Here

   **Impact: CRITICAL (Optional one-line summary of impact)**

   Brief explanation of the rule and why it matters...

   **Incorrect (description of problem):**
   ```dart
   // code
   ```

   **Correct (description of solution):**
   ```dart
   // code
   ```
   ```

2. **Re-generate `AGENTS.md` and `SKILL.md`**:

   From `packages/jaspr`, run:

   ```bash
   dart run tool/generate_best_practices.dart
   ```

   This command parses all files in `rules/` and rebuilds `AGENTS.md` and `SKILL.md` in this directory.

3. **Update installed `.agents/skills` copies (if applicable)**:

   If you maintain workspace skills in `.agents/skills/`, copy the updated files separately:

   ```bash
   cp -R packages/jaspr/skills/* .agents/skills/
   ```
