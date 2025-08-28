# 📂 `/libs/styles/`

/libs/styles is where your design system lives.

```
/libs/styles/
  ├─ abstracts/               # design tokens (NO CSS output)
  │   ├─ _variables.scss      # Sass tokens: $spacing, $radius, $font-family
  │   ├─ _colors.scss         # Sass tokens: $primary, $secondary, semantic ||colors
  │   ├─ _mixins.scss         # mixins: clearfix, flex-center, etc.
  │   ├─ _functions.scss      # Sass functions: colorShade(), rem()
  │   └─ index.scss           # @forward all abstracts
  │
  ├─ themes/                  # runtime CSS variables (switchable at runtime)
  │   ├─ light.scss           # :root { --primary: #0066ff; --bg: #fff; }
  │   ├─ dark.scss            # :root { --primary: #222; --bg: #111; }
  │   └─ index.scss           # optional helper to load/switch themes
  │
  ├─ globals/                 # global styles (one-time load at app level)
  │   ├─ reset.scss           # normalize/reset CSS
  │   ├─ typography.scss      # base font, headings, links
  │   ├─ layout.scss          # spacing system, grid helpers
  │   └─ main.scss            # imports reset + typography + layout
  │
  ├─ components/              # style-only components (no Angular/React)
  │   ├─ button.scss          # .btn { ... }
  │   ├─ card.scss            # .card { ... }
  │   ├─ table.scss
  │   └─ index.scss           # central export
  │
  └─ index.scss               # barrel exports (abstracts + themes + globals + components)
```

---

## 🔹 Folder Purpose

### **1. `abstracts/`**

- Pure **Sass design tokens**.
- Contain **no actual CSS rules** → only variables, mixins, functions.
- Imported inside components or globals to build real CSS.
- Example:

```scss
// abstracts/_variables.scss
$spacing-sm: 0.5rem;
$spacing-md: 1rem;
$radius-md: 8px;
$font-family-base: "Inter", sans-serif;
```

---

### **2. `themes/`**

- Define **runtime CSS variables** so you can toggle themes (light/dark/system) without recompiling.
- Example:

```scss
// themes/light.scss
:root {
  --primary: #0066ff;
  --text: #222;
  --bg: #fff;
}
```

At runtime you just switch `<html data-theme="dark">` or swap a theme file.

---

### **3. `globals/`**

- Only imported **once per app** (like in `apps/admin/styles.scss`).
- Contains:

  - `reset.scss` (CSS reset / normalize)
  - `typography.scss` (base font rules)
  - `layout.scss` (container, grid, spacing utilities)
  - `main.scss` that combines them.

Example `main.scss`:

```scss
@use "../abstracts" as *;

@forward "reset";
@forward "typography";
@forward "layout";

body {
  font-family: $font-family-base;
  background: var(--bg);
  color: var(--text);
}
```

---

### **4. `components/`**

- Encapsulated SCSS for **primitive UI building blocks** that aren’t tied to Angular/React logic.
- Useful if you want “barebones styling” available everywhere.

```scss
// components/button.scss
@use "../abstracts" as *;

.btn {
  padding: $spacing-sm $spacing-md;
  border-radius: $radius-md;
  font-family: $font-family-base;
  background: var(--primary);
  color: var(--text);
}
```

---

### **5. `index.scss` (root)**

- Central export that re-forwards everything.
- Apps usually import **only this**.

```scss
// libs/styles/index.scss
@forward "abstracts";
@forward "themes";
@forward "globals/main";
@forward "components";
```

---

## 🔹 How to Use in Angular Feature

**App global styles (apps/admin/styles.scss):**

```scss
// pull everything once
@use "@myorg/styles/index" as *;
```

**Inside a feature component SCSS:**

```scss
// only pull tokens (no CSS duplication!)
@use "@myorg/styles/abstracts" as *;

.card {
  padding: $spacing-md;
  border-radius: $radius-md;
  background: var(--bg);
}
```

---

✅ This way:

- **Apps** load globals + components + themes once.
- **Feature components** only use **tokens** (no duplicate CSS).
- **No global pollution** (`@use` deduplicates).

---

# Mixins, Functions, %placeholder

## 🔹 1. SCSS Functions (`@function`)

- **What**: A function takes inputs and **returns a value** (like math or color result).
- **When to use**: When you want to **calculate and return a single value** (number, string, color, etc.), not CSS rules.

✅ Example: A function to convert pixel to `rem`

```scss
// functions.scss
@function px-to-rem($px, $base: 16) {
  @return ($px / $base) * 1rem;
}

// usage
.button {
  font-size: px-to-rem(18); // 1.125rem
  padding: px-to-rem(12) px-to-rem(24);
}
```

👉 Functions are **best for returning values** (numbers, colors, strings) that can be used inside properties.

---

## 🔹 2. SCSS Mixins (`@mixin`)

- A mixin defines reusable CSS blocks.
- You include them wherever you need.
- Each @include duplicates the CSS into the compiled file.

```css
@mixin button-styles($color) {
  background: $color;
  border: none;
  padding: 10px 16px;
  border-radius: 6px;
}

.btn-primary {
  @include button-styles(blue);
}

.btn-danger {
  @include button-styles(red);
}
```

👉 Output CSS will repeat the properties for each .btn-\*.

## 3. %placeholder + @extend

- A placeholder selector (%name) is like a class that won’t appear in CSS until extended.
- @extend tells one selector to inherit the rules from a placeholder (or another selector).
- SCSS will merge selectors instead of duplicating properties.

```css
%button-styles {
  border: none;
  padding: 10px 16px;
  border-radius: 6px;
}

.btn-primary {
  @extend %button-styles;
  background: blue;
}

.btn-danger {
  @extend %button-styles;
  background: red;
}
```

Output

```css
.btn-primary,
.btn-danger {
  border: none;
  padding: 10px 16px;
  border-radius: 6px;
}

.btn-primary {
  background: blue;
}

.btn-danger {
  background: red;
}
```

👉 Rule of thumb

- Use @include when you want parametric, flexible, reusable CSS.
- Use %placeholder + @extend when you want to group common static styles without duplication.

# @import vs @use/@forward

We’ll create two small SCSS files and see how the compiler treats them under `@import` vs `@use`.

---

## 🟣 Case 1: Using `@import`

```scss
// abstracts/_variables.scss
$spacing: 1rem;
$color: red;

// button.scss
@import "abstracts/variables";
.button {
  margin: $spacing;
  color: $color;
}

// card.scss
@import "abstracts/variables";
.card {
  padding: $spacing;
  border: 1px solid $color;
}

// main.scss
@import "button";
@import "card";
```

### 🔹 Compiled CSS

```css
.button {
  margin: 1rem;
  color: red;
}

.card {
  padding: 1rem;
  border: 1px solid red;
}
```

👉 Looks fine here, **but behind the scenes**:

- `variables.scss` was “copied” twice (once for button, once for card).
- If `variables.scss` had `body { font-family: ... }` → it would appear twice in final CSS!
- Also, if both button and card defined `$spacing`, **they’d override each other globally**.

---

## 🟢 Case 2: Using `@use`

```scss
// abstracts/_variables.scss
$spacing: 1rem;
$color: red;

// button.scss
@use "abstracts/variables" as vars;
.button {
  margin: vars.$spacing;
  color: vars.$color;
}

// card.scss
@use "abstracts/variables" as vars;
.card {
  padding: vars.$spacing;
  border: 1px solid vars.$color;
}

// main.scss
@use "button";
@use "card";
```

### 🔹 Compiled CSS

```css
.button {
  margin: 1rem;
  color: red;
}

.card {
  padding: 1rem;
  border: 1px solid red;
}
```

👉 Looks the **same in output**, but key differences:

- `variables.scss` was **only evaluated once** no matter how many files used it.
- No duplication if it had CSS in it.
- Variables stay scoped to `vars.*`, so no accidental collisions.

---

## 🟠 Special Case: `@use ... as *`

```scss
// button.scss
@use "abstracts/variables" as *;
.button {
  margin: $spacing;
  color: $color;
}
```

- Works like global, but **without duplication**.
- Still only evaluated once globally.
- Safer than `@import`.

---

## ✅ TL;DR

- Both ways give same final CSS **for pure variables**.
- Big difference is when you scale:

  - `@import` = duplication, global pollution.
  - `@use` = deduplicated, scoped, future-proof.

---

⚡ So in your Angular feature SCSS, if you only want **tokens (no CSS)**, you should always use:

```scss
@use "@myorg/styles/src/abstracts" as *; // safe, no duplication
```

and **never `@import`**.

---
