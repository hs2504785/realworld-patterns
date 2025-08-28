## Features

```
/apps/
  ├─ admin/
  │   └─ src/app/app.routes.ts
  │
  ├─ lab/
  │   └─ src/app/app.routes.ts
  │
  └─ billing-portal/
      └─ src/app/app.routes.ts

/libs/
  ├─ core/                          # global services & infra (auth, http, guards, interceptors)
  ├─ shared/                        # UI library (buttons, modals, pipes, directives)
  ├─ styles/                        # design tokens, global SCSS
  ├─ state/                         # cross-domain/global app state (user, config)
  │
  └─ features/                      # All business domains live here
      ├─ admin/
      │   ├─ users/
      │   │   ├─ users.routes.ts
      │   │   ├─ containers/
      │   │   │   ├─ users-page.component.ts
      │   │   │   └─ user-detail.container.ts
      │   │   ├─ components/
      │   │   │   ├─ user-card.component.ts
      │   │   │   └─ user-table.component.ts
      │   │   ├─ services/
      │   │   │   └─ users.api.ts
      │   │   └─ state/
      │   │       ├─ users.store.ts
      │   │       └─ users.query.ts
      │   │
      │   ├─ roles/
      │   │   ├─ roles.routes.ts
      │   │   ├─ containers/
      │   │   └─ state/
      │   │
      │   └─ audit/
      │       ├─ audit.routes.ts
      │       └─ containers/
      │
      ├─ lab/
      │   ├─ experiments/
      │   │   ├─ experiments.routes.ts
      │   │   ├─ containers/
      │   │   │   ├─ experiments-list.container.ts
      │   │   │   └─ experiment-detail.container.ts
      │   │   ├─ components/
      │   │   │   └─ experiment-card.component.ts
      │   │   └─ state/
      │   │       └─ experiments.store.ts
      │   │
      │   └─ reports/
      │       ├─ reports.routes.ts
      │       ├─ containers/
      │       └─ components/
      │
      └─ billing/
          ├─ product/
          │   ├─ product.routes.ts
          │   ├─ containers/
          │   │   └─ product-list.container.ts
          │   ├─ components/
          │   │   └─ product-card.component.ts
          │   ├─ services/
          │   │   └─ product.api.ts
          │   └─ state/
          │       └─ product.store.ts
          │
          ├─ invoice/
          │   ├─ invoice.routes.ts
          │   ├─ containers/
          │   └─ state/
          │
          └─ reports/
              ├─ reports.routes.ts
              └─ containers/
```

### `/libs/features/*` (Domain-Driven)

- **Every domain (admin, lab, billing) lives here**.
- Each domain has **sub-features** (users, roles, product, invoice, reports).
- Each feature contains:

  - `routes.ts` → for lazy loading
  - `containers/` → smart components (fetch, orchestrate)
  - `components/` → dumb components (presentational)
  - `state/` → feature-level state management (signals, stores)
  - `services/` → APIs

---

# Example: Billing/Product Routes

```ts
// libs/features/billing/product/product.routes.ts
import { Routes } from "@angular/router";
import { ProductListContainer } from "./containers/product-list.container";

export const productRoutes: Routes = [
  {
    path: "",
    component: ProductListContainer,
  },
];
```

---

# How Apps Import Features

```ts
// apps/billing-portal/src/app/app.routes.ts
import { Routes } from "@angular/router";
import { productRoutes } from "@org/features/billing/product";
import { invoiceRoutes } from "@org/features/billing/invoice";

export const appRoutes: Routes = [
  {
    path: "products",
    loadChildren: () =>
      import("@org/features/billing/product").then((m) => m.productRoutes),
  },
  {
    path: "invoices",
    loadChildren: () =>
      import("@org/features/billing/invoice").then((m) => m.invoiceRoutes),
  },
];
```

---

✅ This way:

- **Domains are grouped under `/libs/features`** (clear boundary).
- Each **domain owns multiple features**.
- No risk of **apps directly leaking into libs** (strict one-way dep).
- Scaling to **20+ features per domain** stays neat.

## Boundary

Excellent question 👍 — you’re thinking about **dependency boundaries** (which is exactly what Nx enforces with its `tag` and `depConstraints`).

Let’s lock down **what each layer can access** in this proposed structure.

---

# 🔐 Boundaries & Access Rules

### 1. **Apps (`/apps/*`)**

- ✅ Can access:

  - **Features** (`/libs/features/*`)
  - **Core** (`/libs/core/*`)
  - **Shared** (`/libs/shared/*`)
  - **Styles** (`/libs/styles/*`)
  - **State** (`/libs/state/*`)

- ❌ Should not export anything back to libs.
- 🔑 Idea: Apps are **entry points only** — they just bootstrap and wire up routes/state.

---

### 2. **Features (`/libs/features/*`)**

- ✅ Can access:

  - **Shared** → for reusable dumb components (`button`, `modal`).
  - **Core** → for infra (guards, interceptors, logging).
  - **State** → if they need to interact with global store (`user.store`, `config.store`).
  - **Other features in the same domain** (e.g. `billing/product` can talk to `billing/invoice`).

- ❌ Should **not depend on apps**.
- ❌ Should **not depend on other domains directly** (e.g. `billing/product` should not call `admin/users`). If needed → expose via **API at domain level**.
- 🔑 Idea: Features are **domain-driven** and self-contained.

---

### 3. **Shared (`/libs/shared/*`)**

- ✅ Can access:

  - Nothing else (purely reusable UI/utils).

- ❌ Must not depend on features, state, or apps.
- 🔑 Idea: **Dumb, generic, UI-only.**

---

### 4. **Core (`/libs/core/*`)**

- ✅ Can access:

  - Nothing else (acts like an infrastructure singleton).

- ❌ Must not depend on features or apps.
- 🔑 Idea: **Global singleton services, guards, interceptors**.

---

### 5. **State (`/libs/state/*`)**

- ✅ Can access:

  - **Core** (to make HTTP requests, auth checks).

- ❌ Must not depend on features or apps.
- 🔑 Idea: **Cross-domain state** (like `user.store`, `config.store`, `theme.store`).

---

### 6. **Styles (`/libs/styles/*`)**

- ✅ Can access:

  - Nothing else (design tokens are global).

- 🔑 Idea: **Design system foundation**.

---

# 📊 Example Dependency Graph (allowed direction)

```
apps ───▶ features ───▶ shared
   │           │
   │           └───▶ core
   │           └───▶ state
   │
   └───▶ core
   └───▶ shared
   └───▶ state
   └───▶ styles
```

- **Apps** can reach everything (they orchestrate).
- **Features** can only consume **shared, core, state**.
- **Shared, Core, Styles** are leaf libraries (cannot depend on features or apps).
- **State** sits in between — reusable by features, but not allowed to depend on them.

---

# 🔑 Nx Enforcement (via `nx.json`)

In Nx, you enforce this with `tags`:

```json
{
  "projects": {
    "admin": { "tags": ["app"] },
    "lab": { "tags": ["app"] },
    "billing-portal": { "tags": ["app"] },

    "features-admin-users": { "tags": ["feature", "domain:admin"] },
    "features-billing-product": { "tags": ["feature", "domain:billing"] },

    "core": { "tags": ["core"] },
    "shared": { "tags": ["shared"] },
    "state": { "tags": ["state"] },
    "styles": { "tags": ["styles"] }
  },

  "workspaceLayout": {
    "appsDir": "apps",
    "libsDir": "libs"
  },

  "nx": {
    "implicitDependencies": {},
    "targetDefaults": {},
    "generators": {},
    "pluginsConfig": {}
  },

  "depConstraints": [
    {
      "sourceTag": "app",
      "onlyDependOnLibsWithTags": [
        "feature",
        "core",
        "shared",
        "state",
        "styles"
      ]
    },
    {
      "sourceTag": "feature",
      "onlyDependOnLibsWithTags": ["feature", "core", "shared", "state"]
    },
    {
      "sourceTag": "core",
      "onlyDependOnLibsWithTags": []
    },
    {
      "sourceTag": "shared",
      "onlyDependOnLibsWithTags": []
    },
    {
      "sourceTag": "state",
      "onlyDependOnLibsWithTags": ["core"]
    }
  ]
}
```

This way Nx will **block bad dependencies** like:

- Feature importing an App.
- Shared importing a Feature.
- Core importing Shared.

---

⚡ So, to summarize:

- **Apps orchestrate.**
- **Features encapsulate business logic.**
- **Core = infra, Shared = UI, State = global store, Styles = design system.**
