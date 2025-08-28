## libs/shared

You’ve set up `/libs/shared` correctly → this is **not domain-specific**, not app-specific, but things that are:

- _reusable across many features and apps_,
- _stateless (or nearly stateless)_,
- _generic UI, utilities, or helpers_,
- _safe to import anywhere (no circular deps)_.

---

## 📂 `/libs/shared` — Detailed Expansion

```
/libs/shared/
  ├─ ui/                     # reusable dumb UI components
  │   ├─ button/
  │   │   ├─ button.component.ts
  │   │   ├─ button.component.html
  │   │   ├─ button.component.scss
  │   │   └─ index.ts
  │   ├─ modal/
  │   ├─ table/
  │   ├─ card/
  │   └─ ...
  │
  ├─ forms/                  # shared form controls + wrappers
  │   ├─ input/              # <app-input>
  │   │   ├─ input.component.ts
  │   │   ├─ input.component.html
  │   │   └─ input.component.scss
  │   │
  │   ├─ select/             # <app-select>
  │   │   ├─ select.component.ts
  │   │   ├─ select.component.html
  │   │   └─ select.component.scss
  │   │
  │   ├─ date-picker/        # <app-date-picker>
  │   │   ├─ date-picker.component.ts
  │   │   ├─ date-picker.component.html
  │   │   └─ date-picker.component.scss
  │   │
  │   ├─ wrappers/           # e.g. label + error message wrappers
  │   │   └─ field-wrapper.component.ts
  │   │
  │   ├─ form-error/         # central error display
  │   │   └─ form-error.component.ts
  │   │
  │   └─ index.ts
  │
  ├─ directives/             # structural/attribute directives
  │   ├─ autofocus.directive.ts
  │   ├─ debounce-click.directive.ts
  │   └─ has-permission.directive.ts
  │
  ├─ pipes/                  # pure transform utilities
  │   ├─ date-format.pipe.ts
  │   ├─ truncate.pipe.ts
  │   ├─ currency.pipe.ts
  │   └─ safe-html.pipe.ts
  │
  ├─ validators/             # all validators (form + non-form)
  │   ├─ email.validator.ts
  │   ├─ password-strength.validator.ts
  │   ├─ confirm-password.validator.ts
  │   └─ index.ts
  │
  ├─ utils/                  # generic stateless helpers
  │   ├─ date.util.ts
  │   ├─ string.util.ts
  │   └─ index.ts
  │
  ├─ icons/                  # svg icon registry or component wrapper
  │   ├─ icon.component.ts
  │   └─ registry.ts
  │
  └─ index.ts                # barrel exports for easy import
```

---

## 🔑 What goes in `/libs/shared`

1. **UI Components (Dumb/Presentational only)**

   - Generic, reusable building blocks.
   - Should never fetch data or hold business logic.
   - Examples: `button`, `modal`, `card`, `table`, `badge`, `spinner`.
   - Styling: consume `/libs/styles` design tokens, don’t hardcode colors/sizes.

2. **Directives**

   - Things like `debounceClick`, `autofocus`, `hasPermission`.
   - Small, self-contained behaviors.

3. **Pipes**

   - Pure functions to format data.
   - Safe to use across _any_ app or feature.

4. **Form Elements / Validators**

   - Common form components (input wrappers, select, date-picker).
   - Validators (email, strong password, etc.).

5. **Icons**

   - Centralized SVG/icon solution.
   - Could use a registry with tree-shakable imports.

---

## 🚫 What does _not_ go in `/libs/shared`

- **No feature-specific components** (e.g., `user-profile-card` belongs in `/libs/features/admin/users/components`).
- **No stateful services** (goes in `/libs/core` or `/libs/state`).
- **No domain models** (should go in `/libs/models`).
- **No app-only layouts** (those belong inside `/apps/*/layout`).

---

## 🌍 Boundaries

- ✅ Can be imported by **any app** (`/apps/admin`, `/apps/lab`, `/apps/billing`).
- ✅ Can be imported by **any feature lib** (`/libs/features/...`).
- ✅ Can depend on `/libs/styles` (design tokens), `/libs/util` (helpers).
- ❌ Should never depend on `/libs/core` (to avoid pulling in interceptors/guards).
- ❌ Should never depend on domain features (`/libs/features/...`).

Think of `/libs/shared` as a **toolbox of building blocks**.
Everyone is allowed to use the toolbox, but the toolbox doesn’t “know” about anyone’s house.
