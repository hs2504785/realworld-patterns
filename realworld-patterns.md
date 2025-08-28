# 🎯 Realworld Angular Patterns

**Universal Reference for LLMs & AI Assistants**

Copy this entire file content for consistent enterprise Angular patterns across all AI tools (Cursor, ChatGPT, Claude, etc.).

**Repository**: https://github.com/hs2504785/realworld-patterns

---

## 📋 Instructions for AI Assistants

When generating Angular code, you **MUST**:

1. ✅ Follow the EXACT folder structure below
2. ✅ Use ONLY Angular 18+ standalone patterns (no NgModules)
3. ✅ Use ONLY Bootstrap 5 classes (no custom CSS)
4. ✅ Respect dependency boundaries strictly
5. ✅ Use signals for reactive state management
6. ✅ Follow security and performance best practices
7. ✅ Implement proper auth guards and error handling

---

## 📁 MANDATORY Project Structure

```
workspace/
├── apps/                          # Application entry points ONLY
│   ├── admin/                     # Admin portal (users, settings, audit)
│   ├── lab/                       # Laboratory management (experiments, samples)
│   └── billing/                   # Billing system (products, invoices)
│
├── libs/                          # Reusable libraries
│   ├── core/                      # Global singletons & infrastructure
│   │   ├── src/lib/
│   │   │   ├── interceptors/      # HTTP interceptors (auth, error, cache)
│   │   │   ├── guards/            # Route guards (auth, role-based)
│   │   │   ├── services/          # Core services (config, logger, platform)
│   │   │   └── handlers/          # Error handlers
│   │
│   ├── shared/                    # Reusable UI components & utilities
│   │   ├── src/lib/
│   │   │   ├── components/        # Shared UI components
│   │   │   ├── directives/        # Custom directives
│   │   │   ├── pipes/             # Custom pipes
│   │   │   └── validators/        # Form validators
│   │
│   ├── styles/                    # Design system & Bootstrap framework
│   │   ├── src/lib/
│   │   │   ├── tokens/            # Design tokens (colors, spacing)
│   │   │   ├── themes/            # Theme configurations
│   │   │   └── bootstrap/         # Bootstrap customizations
│   │
│   ├── auth/                      # Authentication & authorization
│   │   ├── src/lib/
│   │   │   ├── services/          # Auth services (login, token, permissions)
│   │   │   ├── guards/            # Auth guards (can-activate, role-based)
│   │   │   └── interceptors/      # Auth interceptors
│   │
│   ├── state/                     # Global state management
│   │   ├── src/lib/
│   │   │   ├── stores/            # State stores using signals
│   │   │   └── effects/           # Side effects management
│   │
│   ├── utils/                     # Pure utility functions
│   │   ├── src/lib/
│   │   │   ├── date/              # Date utilities
│   │   │   ├── string/            # String utilities
│   │   │   ├── validation/        # Validation utilities
│   │   │   └── rxjs/              # RxJS operators
│   │
│   ├── interfaces/                # TypeScript type definitions
│   │   ├── src/lib/
│   │   │   ├── api/               # API response interfaces
│   │   │   ├── entities/          # Business entity interfaces
│   │   │   └── common/            # Common type definitions
│   │
│   ├── i18n/                      # Internationalization
│   │   ├── src/lib/
│   │   │   ├── translations/      # Translation files
│   │   │   └── services/          # i18n services
│   │
│   └── features/                  # Domain-driven feature modules
│       ├── admin/                 # Admin domain features
│       │   ├── users/             # User management feature
│       │   ├── roles/             # Role management feature
│       │   └── audit/             # Audit logging feature
│       ├── lab/                   # Laboratory domain features
│       │   ├── experiments/       # Experiment management
│       │   ├── samples/           # Sample tracking
│       │   └── reports/           # Lab reports
│       └── billing/               # Billing domain features
│           ├── products/          # Product catalog
│           ├── invoices/          # Invoice management
│           └── reports/           # Billing reports
```

---

## 🚨 CRITICAL Dependency Rules

### ✅ ALLOWED Dependencies:

- `apps/*` → Can import from ANY `libs/*`
- `libs/features/*` → Can import from `libs/shared/*`, `libs/core/*`, `libs/interfaces/*`, `libs/utils/*`
- `libs/shared/*` → Can import from `libs/core/*`, `libs/interfaces/*`, `libs/utils/*`
- `libs/core/*` → Can import from `libs/interfaces/*`, `libs/utils/*` ONLY
- `libs/utils/*` → NO dependencies (pure functions only)
- `libs/interfaces/*` → NO dependencies (types only)

### ❌ FORBIDDEN Dependencies:

- **NEVER**: `libs/core/*` → `libs/features/*` or `libs/shared/*`
- **NEVER**: `libs/shared/*` → `libs/features/*`
- **NEVER**: Cross-domain imports between features (admin ↔ lab ↔ billing)
- **NEVER**: Circular dependencies anywhere

---

## 🎨 Angular 18+ Patterns (MANDATORY)

### Component Pattern (ALWAYS Standalone)

```typescript
import { Component, signal, computed, inject } from "@angular/core";
import { CommonModule } from "@angular/common";
import { FormsModule } from "@angular/forms";

@Component({
  selector: "app-user-list",
  standalone: true,
  imports: [CommonModule, FormsModule],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <div class="container-fluid">
      <div class="d-flex justify-content-between align-items-center mb-4">
        <h2 class="h4 mb-0">User Management</h2>
        <button class="btn btn-primary" (click)="addUser()">
          <i class="bi bi-plus-circle me-2"></i>Add User
        </button>
      </div>

      @if (loading()) {
      <div class="d-flex justify-content-center py-5">
        <div class="spinner-border text-primary" role="status">
          <span class="visually-hidden">Loading...</span>
        </div>
      </div>
      } @if (error()) {
      <div class="alert alert-danger alert-dismissible fade show" role="alert">
        {{ error() }}
        <button type="button" class="btn-close" (click)="clearError()"></button>
      </div>
      }

      <div class="row">
        @for (user of users(); track user.id) {
        <div class="col-md-6 col-lg-4 mb-3">
          <div class="card h-100">
            <div class="card-body">
              <h5 class="card-title">{{ user.name }}</h5>
              <p class="card-text text-muted">{{ user.email }}</p>
              <span class="badge bg-primary">{{ user.role }}</span>
            </div>
          </div>
        </div>
        }
      </div>
    </div>
  `,
})
export class UserListComponent {
  private userService = inject(UserService);

  // Reactive state using signals
  users = signal<User[]>([]);
  loading = signal(false);
  error = signal<string | null>(null);

  // Computed values
  userCount = computed(() => this.users().length);

  ngOnInit() {
    this.loadUsers();
  }

  async loadUsers() {
    this.loading.set(true);
    this.error.set(null);

    try {
      const users = await this.userService.getUsers();
      this.users.set(users);
    } catch (err) {
      this.error.set("Failed to load users");
    } finally {
      this.loading.set(false);
    }
  }

  addUser() {
    // Navigate to add user page
  }

  clearError() {
    this.error.set(null);
  }
}
```

### Service Pattern (ALWAYS Injectable)

```typescript
import { Injectable, signal, computed, inject } from "@angular/core";
import { HttpClient } from "@angular/common/http";

@Injectable({
  providedIn: "root",
})
export class UserService {
  private http = inject(HttpClient);

  // Private signals for internal state
  private _users = signal<User[]>([]);
  private _loading = signal(false);
  private _error = signal<string | null>(null);

  // Public readonly signals
  users = this._users.asReadonly();
  loading = this._loading.asReadonly();
  error = this._error.asReadonly();

  // Computed signals
  userCount = computed(() => this.users().length);
  activeUsers = computed(() => this.users().filter((u) => u.active));

  async loadUsers() {
    this._loading.set(true);
    this._error.set(null);

    try {
      const users = await this.http.get<User[]>("/api/users").toPromise();
      this._users.set(users);
    } catch (error) {
      this._error.set("Failed to load users");
    } finally {
      this._loading.set(false);
    }
  }
}
```

### Routing Pattern (ALWAYS Lazy)

```typescript
import { Routes } from "@angular/router";
import { authGuard, roleGuard } from "@auth/guards";

export const routes: Routes = [
  {
    path: "users",
    loadComponent: () =>
      import("./user-list.component").then((c) => c.UserListComponent),
    canActivate: [authGuard, roleGuard("admin")],
    title: "User Management",
  },
  {
    path: "features/admin",
    loadChildren: () => import("@features/admin").then((m) => m.ADMIN_ROUTES),
    canActivate: [authGuard],
  },
];
```

### Guard Pattern (ALWAYS Functional)

```typescript
import { CanActivateFn, Router } from "@angular/router";
import { inject } from "@angular/core";
import { AuthService } from "@auth/services";

export const authGuard: CanActivateFn = (route, state) => {
  const authService = inject(AuthService);
  const router = inject(Router);

  if (authService.isAuthenticated()) {
    return true;
  }

  router.navigate(["/login"], { queryParams: { returnUrl: state.url } });
  return false;
};

export const roleGuard = (requiredRole: string): CanActivateFn => {
  return (route, state) => {
    const authService = inject(AuthService);
    return authService.hasRole(requiredRole);
  };
};
```

---

## 🎨 Bootstrap 5 Patterns (MANDATORY)

**NO CUSTOM CSS ALLOWED - Use Bootstrap classes exclusively**

### Layout Components

```html
<!-- Always use Bootstrap containers -->
<div class="container-fluid">
  <div class="row">
    <div class="col-12 col-md-8 col-lg-6">
      <!-- Content -->
    </div>
  </div>
</div>

<!-- Cards for content grouping -->
<div class="card shadow-sm">
  <div class="card-header bg-primary text-white">
    <h5 class="card-title mb-0">Title</h5>
  </div>
  <div class="card-body">
    <p class="card-text">Content</p>
  </div>
</div>
```

### Form Components

```html
<form class="needs-validation" novalidate>
  <div class="mb-3">
    <label for="email" class="form-label">Email address</label>
    <input
      type="email"
      class="form-control"
      id="email"
      [value]="email()"
      (input)="email.set($event.target.value)"
      required
    />
    <div class="invalid-feedback">Please provide a valid email.</div>
  </div>

  <div class="mb-3">
    <label for="role" class="form-label">Role</label>
    <select
      class="form-select"
      id="role"
      [value]="selectedRole()"
      (change)="selectedRole.set($event.target.value)"
    >
      <option value="">Choose...</option>
      <option value="admin">Admin</option>
      <option value="user">User</option>
    </select>
  </div>

  <div class="d-flex justify-content-end gap-2">
    <button type="button" class="btn btn-outline-secondary">Cancel</button>
    <button type="submit" class="btn btn-primary">Save</button>
  </div>
</form>
```

### Navigation Components

```html
<nav class="navbar navbar-expand-lg navbar-light bg-light">
  <div class="container-fluid">
    <a class="navbar-brand" routerLink="/">
      <img src="/assets/logo.svg" alt="Logo" width="30" height="24" />
      MyApp
    </a>

    <div class="navbar-nav ms-auto">
      <a class="nav-link" routerLink="/dashboard">Dashboard</a>
      <a class="nav-link" routerLink="/users">Users</a>
      <div class="nav-item dropdown">
        <a
          class="nav-link dropdown-toggle"
          href="#"
          role="button"
          data-bs-toggle="dropdown"
        >
          Profile
        </a>
        <ul class="dropdown-menu">
          <li><a class="dropdown-item" href="#">Settings</a></li>
          <li><hr class="dropdown-divider" /></li>
          <li><a class="dropdown-item" (click)="logout()">Logout</a></li>
        </ul>
      </div>
    </div>
  </div>
</nav>
```

---

## 🔐 Security Patterns (MANDATORY)

### HTTP Interceptor (Required)

```typescript
import { HttpInterceptorFn } from "@angular/common/http";
import { inject } from "@angular/core";
import { AuthService } from "@auth/services";

export const authInterceptor: HttpInterceptorFn = (req, next) => {
  const authService = inject(AuthService);
  const token = authService.getToken();

  if (token) {
    req = req.clone({
      setHeaders: {
        Authorization: `Bearer ${token}`,
      },
    });
  }

  return next(req);
};
```

### Global Error Handler (Required)

```typescript
import { ErrorHandler, Injectable, inject } from "@angular/core";
import { LoggerService } from "@core/services";

@Injectable()
export class GlobalErrorHandler implements ErrorHandler {
  private logger = inject(LoggerService);

  handleError(error: any): void {
    this.logger.error("Global error:", error);

    // Send to monitoring service
    // Show user-friendly message
  }
}
```

---

## 📂 File Naming Convention

```
✅ CORRECT:
user-list.component.ts
user-management.service.ts
auth.guard.ts
error.interceptor.ts
user.interface.ts
api-response.type.ts

❌ INCORRECT:
UserList.component.ts
userManagement.service.ts
AuthGuard.ts
errorInterceptor.ts
user.Interface.ts
ApiResponse.type.ts
```

---

## 🎯 CRITICAL Enforcement Rules

**These rules MUST be followed:**

1. **Folder Structure**: NEVER deviate from the specified structure
2. **Dependencies**: ALWAYS respect boundary rules - core cannot import from features
3. **Bootstrap Only**: NEVER write custom CSS - use Bootstrap classes
4. **Standalone**: ALWAYS use standalone components (no NgModules)
5. **Signals**: ALWAYS use signals for reactive state
6. **Security**: ALWAYS implement auth guards on protected routes
7. **Domain Separation**: NEVER cross-import between feature domains
8. **Error Handling**: ALWAYS implement proper error boundaries
9. **Performance**: ALWAYS use lazy loading for feature routes
10. **Types**: ALWAYS use proper TypeScript interfaces from `@interfaces/*`

---

## 🚫 NEVER Do These

- **NEVER** use NgModules (use standalone components)
- **NEVER** put business logic in components
- **NEVER** create circular dependencies between libs
- **NEVER** import from a higher-level lib (e.g., core importing from features)
- **NEVER** skip auth guards on protected routes
- **NEVER** write custom CSS when Bootstrap classes exist
- **NEVER** use `any` types
- **NEVER** put HTTP calls directly in components

---

## ✅ ALWAYS Do These

- **ALWAYS** use `inject()` function for DI in guards/functions
- **ALWAYS** use `signal()` for reactive state
- **ALWAYS** use `computed()` for derived state
- **ALWAYS** use `effect()` for side effects
- **ALWAYS** use proper TypeScript types
- **ALWAYS** use Bootstrap utility classes
- **ALWAYS** follow domain boundaries strictly
- **ALWAYS** implement proper error handling
- **ALWAYS** use lazy loading for features
- **ALWAYS** implement proper loading states

---

**Repository Reference**: https://github.com/hs2504785/realworld-patterns

_Copy this entire content to ensure any AI assistant follows these enterprise Angular patterns consistently._
