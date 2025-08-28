# Enterprise Angular 20 + Nx Monorepo Specification

A comprehensive folder structure specification for scalable Angular applications using modern architectural patterns.

## 🎯 Core Principles

- **Domain-Driven Design**: Features organized by business domains
- **Standalone Components**: Leveraging Angular 20's standalone architecture
- **Signal-Based State**: Modern reactive state management
- **Dependency Boundaries**: Strict rules preventing circular dependencies
- **Micro-Frontend Ready**: Clear separation enabling future micro-frontend adoption

## 📁 Top-Level Structure

```
workspace/
├── apps/                          # Application entry points
│   ├── admin/                     # Admin portal (users, settings, audit)
│   ├── lab/                       # Laboratory management (experiments, samples)
│   └── billing/                   # Billing system (products, invoices)
│
├── libs/                          # Reusable libraries
│   ├── core/                      # Global singletons & infrastructure
│   ├── shared/                    # Reusable UI components & utilities
│   ├── styles/                    # Design system & SCSS framework
│   ├── auth/                      # Authentication & authorization
│   ├── state/                     # Global state management
│   ├── utils/                     # Pure utility functions
│   ├── interfaces/                # TypeScript type definitions
│   ├── i18n/                      # Internationalization
│   │
│   └── features/                  # Domain-driven features
│       ├── admin/                 # Admin domain
│       │   ├── users/             # User management feature
│       │   ├── roles/             # Role management feature
│       │   └── audit/             # Audit logging feature
│       ├── lab/                   # Laboratory domain
│       │   ├── experiments/       # Experiment management
│       │   └── reports/           # Lab reporting
│       └── billing/               # Billing domain
│           ├── products/          # Product catalog
│           ├── invoices/          # Invoice management
│           └── reports/           # Billing reports
│
├── tools/                         # Build tools and scripts
├── docs/                          # Documentation
└── nx.json                        # Nx workspace configuration
```

## 📋 Detailed Structure with Modern Examples

### 🔷 Applications (`/apps`)

Each application is a standalone Angular 20 app with its own bootstrap and routing.

```
apps/
├─ admin/                                    # Admin Portal Application
│   ├─ src/
│   │   ├─ main.ts                          # Bootstrap with standalone components
│   │   ├─ index.html                       # Entry HTML with CSP headers
│   │   ├─ styles.scss                      # Global styles import
│   │   ├─ assets/                          # App-specific assets
│   │   └─ app/
│   │       ├─ app.component.ts             # Root shell component
│   │       ├─ app.routes.ts                # Lazy-loaded route definitions
│   │       ├─ app.config.ts                # Application configuration
│   │       └─ layout/                      # App-specific layout components
│   ├─ project.json                         # Nx project configuration
│   └─ jest.config.ts                       # Jest testing configuration
│
├─ lab/                                     # Laboratory Management App
│   └─ src/app/app.routes.ts                # Lab-specific routes
│
└─ billing/                                 # Billing & Invoicing App
    └─ src/app/app.routes.ts                # Billing-specific routes
```

#### Example: Modern App Bootstrap (`apps/admin/src/main.ts`)

```typescript
import { bootstrapApplication } from "@angular/platform-browser";
import { provideRouter } from "@angular/router";
import { provideHttpClient, withInterceptors } from "@angular/common/http";
import { AppComponent } from "./app/app.component";
import { routes } from "./app/app.routes";
import { provideCore } from "@myorg/core";
import { provideAuth } from "@myorg/auth";
import { environment } from "./environments/environment";

bootstrapApplication(AppComponent, {
  providers: [
    provideRouter(routes),
    provideHttpClient(
      withInterceptors([authInterceptor, errorInterceptor, cacheInterceptor])
    ),
    provideCore({
      apiBaseUrl: environment.apiBaseUrl,
      appName: "admin",
    }),
    provideAuth({
      domain: environment.auth.domain,
      clientId: environment.auth.clientId,
    }),
  ],
});
```

---

### 🔷 Core Infrastructure (`/libs/core`)

```
/libs
  ├─ core/
  │   ├─ src/lib/http.interceptor.ts
  │   ├─ src/lib/error-handler.service.ts
  │   ├─ src/lib/auth.guard.ts
  │   └─ src/index.ts
  │
  ├─ shared/
  │   ├─ components/
  │   │   ├─ button/
  │   │   │   ├─ button.component.ts   (dumb)
  │   │   │   ├─ button.component.scss
  │   │   │   └─ index.ts
  │   │   └─ card/
  │   │       ├─ card.component.ts
  │   │       └─ card.component.scss
  │   ├─ pipes/
  │   ├─ directives/
  │   └─ index.ts
  │
  ├─ styles/
  │   ├─ _tokens.scss       # design tokens (colors, spacing, typography)
  │   ├─ _mixins.scss       # SCSS helpers
  │   ├─ _reset.scss        # normalize/reset
  │   ├─ themes/
  │   │   ├─ light.scss
  │   │   └─ dark.scss
  │   └─ index.scss         # entry for apps
  │
  ├─ auth/
  │   ├─ login.service.ts
  │   ├─ session.service.ts
  │   └─ index.ts
  │
  ├─ state/
  │   ├─ theme.store.ts     # global theme
  │   ├─ notification.store.ts
  │   └─ index.ts
  │
  ├─ util/
  │   ├─ date.util.ts
  │   ├─ rx.util.ts
  │   └─ index.ts
  │
  ├─ models/
  │   ├─ product.model.ts
  │   └─ user.model.ts
  │
  ├─ admin/
  │   ├─ state/
  │   │   ├─ admin.store.ts
  │   │   └─ index.ts
  │   └─ feature-users/
  │       ├─ users.routes.ts
  │       ├─ smart-users.component.ts
  │       ├─ dumb-user-card.component.ts
  │       └─ state/
  │           └─ users.store.ts
  │
  ├─ lab/
  │   ├─ state/
  │   │   └─ lab.store.ts
  │   └─ feature-results/
  │       ├─ results.routes.ts
  │       └─ results.component.ts
  │
  └─ billing/
      ├─ state/
      │   └─ billing.store.ts
      │
      └─ feature-product/
          ├─ product.routes.ts
          ├─ smart-product.component.ts   # smart (fetch, orchestrate)
          ├─ dumb-product-card.component.ts # dumb (pure presentational)
          ├─ state/
          │   ├─ product.store.ts
          │   └─ product.query.ts
          └─ services/
              └─ product.api.ts

```
