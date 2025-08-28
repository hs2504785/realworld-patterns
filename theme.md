# Theme

1. **Tokens & variables → Sass vs CSS variables**
2. **Three themes (light, dark, purple)**
3. **How to avoid bloated CSS** (don’t bundle all themes into `main.scss`)
4. **How to lazy load a theme in Angular** (`angular.json` + dynamic loading)
5. **How to extend Bootstrap 5 theming** with our tokens.

---

## 🔹 1. Tokens: Sass vs CSS variables

- **Sass tokens (`abstracts/`)** → design time values

  - `$spacing-md: 1rem;`
  - `$radius-md: 8px;`
  - Used for _consistent compiled styles_.
  - Example: buttons, card padding, grid spacing.

- **CSS variables (`themes/`)** → runtime theming

  - `--primary: #0066ff;`
  - `--bg: #fff;`
  - Used for _values that can change dynamically at runtime_ (colors, shadows, etc).

👉 Rule of thumb:

- Use **Sass tokens** for static values (spacing, typography).
- Use **CSS variables** for dynamic theming (colors, elevations).

---

## 🔹 2. Define 3 themes

### `/libs/styles/themes/light.scss`

```scss
:root {
  --primary: #0d6efd; // bootstrap primary
  --bg: #ffffff;
  --text: #212529;
}
```

### `/libs/styles/themes/dark.scss`

```scss
:root {
  --primary: #0dcaf0; // cyan-ish
  --bg: #121212;
  --text: #f8f9fa;
}
```

### `/libs/styles/themes/purple.scss`

```scss
:root {
  --primary: #6f42c1; // bootstrap purple
  --bg: #f5f3f7;
  --text: #1a1a1a;
}
```

---

## 🔹 3. Avoid CSS bloat

⚠️ If you `@use` all three themes in `main.scss`, Angular will compile them into one CSS file → wasteful.

✅ Instead:

- Keep each theme **separate SCSS entry point**.
- Only load the needed theme at runtime.

So in `/libs/styles/` you’ll have:

```
globals/main.scss       # reset + typography + base layout
themes/light.scss       # theme css variables
themes/dark.scss
themes/purple.scss
```

---

## 🔹 4. Lazy loading themes in Angular

### `angular.json`

Register each theme as a **lazy CSS bundle**:

```json
"styles": [
    "libs/styles/src/globals/main.scss",
    {
        "input": "libs/styles/themes/light.scss",
        "inject": false,
        "bundleName": "light.min"
    },
    {
        "input": "libs/styles/themes/dark.scss",
        "inject": false,
        "bundleName": "dark.min"
    },
    {
        "input": "libs/styles/themes/purple.scss",
        "inject": false,
        "bundleName": "purple.min"
    }
],
"assets": [],
"stylePreprocessorOptions": {
  "includePaths": ["libs/styles"]
},
```

---

### Switch themes at runtime

In `theme.service.ts`:

```ts
@Injectable({ providedIn: "root" })
export class ThemeService {
  private themeLinkId = "theme-stylesheet";

  setTheme(name: "light" | "dark" | "purple") {
    // remove existing
    const existing = document.getElementById(this.themeLinkId);
    if (existing) existing.remove();

    // load new theme
    const link = document.createElement("link");
    link.id = this.themeLinkId;
    link.rel = "stylesheet";
    link.href = `${name}.css`; // Angular builds these into dist root
    document.head.appendChild(link);
  }
}
```

In `app.component.ts`:

```ts
constructor(private theme: ThemeService) {}

ngOnInit() {
  this.theme.setTheme('light'); // default
}
```

Now you can toggle via `this.theme.setTheme('dark')`.

---

## 🔹 5. Extending Bootstrap 5 theming

Bootstrap 5 already supports CSS variables for colors.
We just override them with ours:

```scss
// overrides in theme file
:root {
  --bs-primary: var(--primary); // map our token to bootstrap
  --bs-body-bg: var(--bg);
  --bs-body-color: var(--text);
}
```

Now `<button class="btn btn-primary">` automatically respects current theme 🎉.

---

## ✅ Summary

- `/abstracts/` → Sass tokens (spacing, radius, typography)
- `/themes/` → CSS variables (colors, dynamic runtime)
- `/globals/main.scss` → resets, typography, base CSS (compiled once)
- Each theme is **standalone SCSS entry** → built separately → lazy load with Angular.
- Extend **Bootstrap 5** by overriding `--bs-*` with your `--*` tokens.

---

/libs/styles/src/globals/main.scss

```css
// Import design tokens (Sass only, no CSS output)
@use "../abstracts" as *;

// Import the default theme (generates CSS variables in :root)
@use "../themes/light" as *;

// Import global resets and layout primitives
@use "reset" as *;
@use "typography" as *;
@use "layout" as *;

// Example usage
body {
  font-family: $font-family-base;
  background: var(--bg);
  color: var(--text);
}
```
