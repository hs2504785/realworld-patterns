# 🎯 Realworld Angular Patterns - LLM Context Rules

**For LLMs/AI Assistants: When working on Angular projects, ALWAYS follow these enterprise patterns.**

## 📋 Context Instructions for LLMs

When generating Angular code, you MUST:

1. ✅ Follow the EXACT folder structure below
2. ✅ Use ONLY Angular 18+ standalone patterns
3. ✅ Use ONLY Bootstrap 5 classes (no custom CSS)
4. ✅ Respect dependency boundaries strictly
5. ✅ Use signals for reactive state management
6. ✅ Follow security and performance best practices

**Reference Repository**: https://github.com/hs2504785/realworld-patterns

---

## 📁 MANDATORY Project Structure

```
workspace/
├── apps/                          # Application entry points
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
│   ├── styles/                    # Design system & SCSS framework
│   │   ├── src/lib/
│   │   │   ├── tokens/            # Design tokens (colors, spacing)
│   │   │   ├── themes/            # Theme configurations
│   │   │   └── utilities/         # SCSS utility functions
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
│       ├── admin/                 # Admin domain
│       │   ├── users/             # User management feature
│       │   ├── roles/             # Role management feature
│       │   └── audit/             # Audit logging feature
│       ├── lab/                   # Laboratory domain
│       │   ├── experiments/       # Experiment management
│       │   ├── samples/           # Sample tracking
│       │   └── reports/           # Lab reports
│       └── billing/               # Billing domain
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
- `libs/utils/*` → NO dependencies (pure functions)
- `libs/interfaces/*` → NO dependencies (types only)

### ❌ FORBIDDEN Dependencies:

- **NEVER**: `libs/core/*` → `libs/features/*` or `libs/shared/*`
- **NEVER**: `libs/shared/*` → `libs/features/*`
- **NEVER**: Cross-domain imports in features (admin ↔ lab ↔ billing)
- **NEVER**: Circular dependencies

---

## 🎨 Angular 18+ Code Patterns

### Component Pattern (ALWAYS Standalone)

```typescript
import { Component, signal, computed, inject } from "@angular/core";
import { CommonModule } from "@angular/common";
import { FormsModule } from "@angular/forms";

@Component({
  selector: "app-user-list",
  standalone: true,
  imports: [CommonModule, FormsModule],
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
      } @if (!loading() && users().length === 0) {
      <div class="text-center py-5">
        <i class="bi bi-people display-1 text-muted"></i>
        <p class="text-muted mt-3">No users found</p>
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
  styleUrls: ["./user-list.component.scss"],
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
import { Injectable, inject, signal } from "@angular/core";
import { HttpClient } from "@angular/common/http";
import { User } from "@interfaces/entities";

@Injectable({
  providedIn: "root",
})
export class UserService {
  private http = inject(HttpClient);

  // Private state
  private _users = signal<User[]>([]);
  private _loading = signal(false);

  // Public readonly state
  users = this._users.asReadonly();
  loading = this._loading.asReadonly();

  async getUsers(): Promise<User[]> {
    this._loading.set(true);
    try {
      const users = await this.http.get<User[]>("/api/users").toPromise();
      this._users.set(users);
      return users;
    } finally {
      this._loading.set(false);
    }
  }

  async createUser(userData: CreateUserRequest): Promise<User> {
    const newUser = await this.http
      .post<User>("/api/users", userData)
      .toPromise();
    this._users.update((users) => [...users, newUser]);
    return newUser;
  }
}
```

### Routing Pattern (ALWAYS Lazy)

```typescript
import { Routes } from "@angular/router";
import { authGuard } from "@auth/guards";

export const routes: Routes = [
  {
    path: "users",
    loadComponent: () =>
      import("./user-list.component").then((c) => c.UserListComponent),
    canActivate: [authGuard],
    title: "User Management",
  },
  {
    path: "users/:id",
    loadComponent: () =>
      import("./user-detail.component").then((c) => c.UserDetailComponent),
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
    const router = inject(Router);

    if (authService.hasRole(requiredRole)) {
      return true;
    }

    router.navigate(["/unauthorized"]);
    return false;
  };
};
```

---

## 🎨 Bootstrap 5 Mandatory Patterns

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
      [(ngModel)]="email"
      required
    />
    <div class="invalid-feedback">Please provide a valid email.</div>
  </div>

  <div class="mb-3">
    <label for="role" class="form-label">Role</label>
    <select class="form-select" id="role" [(ngModel)]="selectedRole">
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

## 🔐 Security Patterns

### HTTP Interceptor

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

### Error Handler

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
user.service.ts
user.interface.ts
auth.guard.ts
error.interceptor.ts

❌ INCORRECT:
UserList.component.ts
userService.ts
User.interface.ts
authGuard.ts
ErrorInterceptor.ts
```

---

## 🎯 Critical LLM Instructions

When generating Angular code, you MUST:

1. **Structure**: Always place files in the correct lib folder according to the structure above
2. **Dependencies**: Never violate the dependency rules - check imports carefully
3. **Standalone**: Always use standalone components, never NgModules
4. **Signals**: Always use signals for reactive state, never observables for local state
5. **Bootstrap**: Always use Bootstrap classes, never write custom CSS
6. **Security**: Always implement proper auth guards and error handling
7. **TypeScript**: Always use proper interfaces from `@interfaces/*`
8. **Performance**: Always use lazy loading and OnPush change detection
9. **Accessibility**: Always include proper ARIA labels and semantic HTML
10. **Testing**: Always include basic unit test structure

**Repository Reference**: https://github.com/hs2504785/realworld-patterns

---

_This context ensures all LLMs follow the same enterprise Angular patterns for consistency and maintainability._
