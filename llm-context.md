# Enterprise Angular 20 + Nx Monorepo - LLM Context

This document provides comprehensive context for Large Language Models (LLMs) to assist with development, code generation, and architectural decisions for Angular 20 + Nx monorepo applications.

## 🎯 Project Overview

**Architecture Type**: Monorepo with micro-frontend capabilities  
**Framework**: Angular 20 with standalone components  
**Build System**: Nx workspace with optimized build pipelines  
**Styling**: Bootstrap 5 + SCSS with design tokens  
**State Management**: Angular Signals + Services  
**Testing**: Jest + Cypress + Angular Testing Library

---

## 📁 Folder Structure Reference

Following Angular's [official coding style guide](https://angular.dev/style-guide) and enterprise patterns:

```
workspace/
├── apps/                          # Application entry points
│   ├── admin/                     # Admin portal (user management, settings)
│   │   ├── src/
│   │   │   ├── main.ts           # Bootstrap with standalone components
│   │   │   └── app/
│   │   │       ├── app.component.ts    # Root shell component
│   │   │       ├── app.routes.ts       # Lazy-loaded routes
│   │   │       └── layout/             # App-specific layout components
│   │   └── project.json          # Nx project configuration
│   ├── lab/                      # Laboratory management application
│   └── billing/                  # Billing and invoicing application
│
├── libs/                         # Reusable libraries
│   ├── core/                     # Global singletons and infrastructure
│   │   ├── src/lib/
│   │   │   ├── interceptors/     # HTTP interceptors (auth, error, cache)
│   │   │   ├── guards/           # Route guards (auth, role-based)
│   │   │   ├── services/         # Core services (config, logger, platform)
│   │   │   ├── handlers/         # Error handlers
│   │   │   ├── tokens/           # DI tokens
│   │   │   ├── operators/        # RxJS operators
│   │   │   ├── utils/            # Core utilities
│   │   │   └── providers.ts      # Provider aggregation
│   │   └── index.ts              # Public API
│   │
│   ├── shared/                   # Reusable UI components and utilities
│   │   ├── ui/                   # Dumb UI components
│   │   │   ├── button/           # Standalone button component
│   │   │   ├── modal/            # Standalone modal component
│   │   │   ├── card/             # Standalone card component
│   │   │   └── table/            # Standalone table component
│   │   ├── forms/                # Form controls and wrappers
│   │   ├── directives/           # Standalone directives
│   │   ├── pipes/                # Standalone pipes
│   │   ├── validators/           # Form validators
│   │   ├── utils/                # Pure utility functions
│   │   └── icons/                # Icon components
│   │
│   ├── styles/                   # Design system and SCSS architecture
│   │   ├── abstracts/            # Sass variables, mixins, functions
│   │   │   ├── _variables.scss   # Design tokens
│   │   │   ├── _colors.scss      # Color system
│   │   │   ├── _mixins.scss      # Reusable mixins
│   │   │   └── _functions.scss   # Sass functions
│   │   ├── themes/               # Runtime CSS variables for theming
│   │   │   ├── light.scss        # Light theme
│   │   │   ├── dark.scss         # Dark theme
│   │   │   └── purple.scss       # Purple theme
│   │   ├── globals/              # Global styles (reset, typography, layout)
│   │   ├── components/           # Style-only components
│   │   └── index.scss            # Main entry point
│   │
│   ├── auth/                     # Authentication and authorization
│   │   ├── components/           # Login forms, logout buttons
│   │   ├── services/             # Auth, token, session services
│   │   ├── guards/               # Auth and role guards
│   │   ├── interceptors/         # JWT interceptor
│   │   ├── models/               # User and role models
│   │   └── utils/                # JWT helpers
│   │
│   ├── state/                    # Global state management
│   │   ├── user/                 # User state store and service
│   │   ├── theme/                # Theme state store
│   │   ├── notifications/        # Notification state
│   │   └── config/               # App configuration state
│   │
│   ├── utils/                    # Pure utility functions
│   │   ├── rxjs/                 # RxJS utilities
│   │   ├── date/                 # Date utilities
│   │   ├── string/               # String utilities
│   │   ├── array/                # Array utilities
│   │   └── object/               # Object utilities
│   │
│   ├── interfaces/               # TypeScript type definitions
│   │   ├── user.interface.ts
│   │   ├── product.interface.ts
│   │   ├── notification.interface.ts
│   │   └── theme.interface.ts
│   │
│   ├── i18n/                     # Internationalization
│   │   ├── en.json               # Root English translations
│   │   ├── fr.json               # Root French translations
│   │   ├── auth/                 # Feature-specific translations
│   │   └── dashboard/
│   │
│   └── features/                 # Domain-driven feature modules
│       ├── admin/                # Admin domain
│       │   ├── users/            # User management feature
│       │   │   ├── users.routes.ts
│       │   │   ├── containers/   # Smart components
│       │   │   ├── components/   # Dumb components
│       │   │   ├── services/     # Feature-specific services
│       │   │   └── state/        # Feature state
│       │   ├── roles/
│       │   └── audit/
│       ├── lab/                  # Laboratory domain
│       │   ├── experiments/
│       │   └── reports/
│       └── billing/              # Billing domain
│           ├── products/
│           ├── invoices/
│           └── reports/
│
├── tools/                        # Build tools and scripts
├── docs/                         # Documentation
└── nx.json                       # Nx workspace configuration
```

---

## 🏗️ Architectural Patterns

### 1. Standalone Components (Angular 20)

All components use `standalone: true` and explicitly import dependencies.

```typescript
@Component({
  selector: "app-button",
  standalone: true,
  imports: [CommonModule],
  template: `<button [class]="classes" (click)="onClick()">
    {{ label }}
  </button>`,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class ButtonComponent {
  @Input() label = "";
  @Input() variant: "primary" | "secondary" = "primary";
  @Output() click = new EventEmitter<void>();

  get classes() {
    return `btn btn-${this.variant}`;
  }

  onClick() {
    this.click.emit();
  }
}
```

### 2. Signal-Based State Management

Use Angular Signals for reactive state with computed derived values.

```typescript
@Injectable({ providedIn: "root" })
export class UserStore {
  private _users = signal<User[]>([]);
  private _loading = signal(false);
  private _filters = signal({ search: "", role: "" });

  // Public readonly signals
  readonly users = computed(() => this._users());
  readonly loading = computed(() => this._loading());

  // Filtered and computed state
  readonly filteredUsers = computed(() => {
    const users = this._users();
    const filters = this._filters();

    return users.filter((user) => {
      const matchesSearch =
        !filters.search ||
        user.name.toLowerCase().includes(filters.search.toLowerCase());
      const matchesRole = !filters.role || user.roles.includes(filters.role);
      return matchesSearch && matchesRole;
    });
  });

  readonly userCount = computed(() => this.filteredUsers().length);

  // State mutations
  setUsers(users: User[]) {
    this._users.set(users);
  }

  updateFilters(filters: Partial<typeof this._filters>) {
    this._filters.update((current) => ({ ...current, ...filters }));
  }
}
```

### 3. Feature-Based Architecture

Organize code by business domains with clear boundaries.

```typescript
// libs/features/billing/products/products.routes.ts
export const productRoutes: Routes = [
  {
    path: "",
    component: ProductListContainer,
    canActivate: [authGuard, roleGuard(["ADMIN", "BILLING_USER"])],
  },
  {
    path: ":id",
    component: ProductDetailContainer,
    resolve: { product: productResolver },
  },
];
```

### 4. Container/Presentation Pattern

Separate smart containers from dumb presentation components.

```typescript
// Container (Smart Component)
@Component({
  selector: "app-product-list",
  standalone: true,
  imports: [ProductCardComponent, LoadingSpinnerComponent],
  template: `
    @if (productStore.loading()) {
    <app-loading-spinner />
    } @else { @for (product of productStore.filteredProducts(); track
    product.id) {
    <app-product-card
      [product]="product"
      (select)="onSelectProduct(product)"
      (edit)="onEditProduct(product)"
    />
    } }
  `,
})
export class ProductListContainer {
  productStore = inject(ProductStore);

  onSelectProduct(product: Product) {
    this.productStore.selectProduct(product);
  }

  onEditProduct(product: Product) {
    // Navigate to edit form
  }
}

// Presentation (Dumb Component)
@Component({
  selector: "app-product-card",
  standalone: true,
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <div class="card">
      <h5>{{ product.name }}</h5>
      <p>{{ product.price | currency }}</p>
      <button class="btn btn-primary" (click)="select.emit()">Select</button>
    </div>
  `,
})
export class ProductCardComponent {
  @Input({ required: true }) product!: Product;
  @Output() select = new EventEmitter<void>();
  @Output() edit = new EventEmitter<void>();
}
```

---

## 🎨 Styling Guidelines

### 1. Bootstrap 5 Integration

Use Bootstrap classes with custom design tokens.

```scss
// libs/styles/abstracts/_variables.scss
$primary: #0066ff;
$secondary: #6c757d;
$success: #28a745;
$spacing-sm: 0.5rem;
$spacing-md: 1rem;
$spacing-lg: 1.5rem;
$border-radius: 8px;
```

### 2. Component Styling

Use SCSS with design tokens and Bootstrap utilities.

```scss
// Component styles
@use "@myorg/styles/abstracts" as *;

.product-card {
  padding: $spacing-md;
  border-radius: $border-radius;
  background: var(--bs-body-bg);
  border: 1px solid var(--bs-border-color);
  transition: box-shadow 0.2s ease;

  &:hover {
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  }

  &__title {
    font-size: 1.25rem;
    font-weight: 600;
    margin-bottom: $spacing-sm;
  }
}
```

### 3. Theme System

Runtime theme switching with CSS custom properties.

```typescript
@Injectable({ providedIn: "root" })
export class ThemeService {
  private currentTheme = signal<Theme>("light");

  setTheme(theme: Theme) {
    this.currentTheme.set(theme);
    this.loadThemeStylesheet(theme);
  }

  private loadThemeStylesheet(theme: Theme) {
    const link = document.createElement("link");
    link.rel = "stylesheet";
    link.href = `${theme}.css`;
    document.head.appendChild(link);
  }
}
```

---

## 🔐 Security Patterns

### 1. Authentication & Authorization

JWT-based authentication with role-based access control.

```typescript
@Injectable({ providedIn: "root" })
export class AuthService {
  private userStore = inject(UserStore);

  login(credentials: LoginRequest) {
    return this.http.post<AuthResponse>("/api/auth/login", credentials).pipe(
      tap((response) => {
        this.tokenService.setTokens(
          response.accessToken,
          response.refreshToken
        );
        this.userStore.setUser(response.user);
      })
    );
  }

  hasPermission(permission: string): boolean {
    const user = this.userStore.currentUser();
    return user?.permissions.includes(permission) ?? false;
  }
}

// Usage in guards
export const roleGuard = (requiredRoles: string[]): CanActivateFn => {
  return () => {
    const authService = inject(AuthService);
    return requiredRoles.some((role) => authService.hasRole(role));
  };
};
```

### 2. Input Validation

Comprehensive form validation with security checks.

```typescript
export class SecurityValidators {
  static noScriptTags(): ValidatorFn {
    return (control: AbstractControl) => {
      if (!control.value) return null;
      const scriptRegex = /<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi;
      return scriptRegex.test(control.value)
        ? { scriptTags: { message: "Script tags are not allowed" } }
        : null;
    };
  }
}
```

---

## ⚡ Performance Optimization

### 1. Lazy Loading

Route-based and component-based lazy loading.

```typescript
// Route lazy loading
const routes: Routes = [
  {
    path: "admin",
    loadChildren: () =>
      import("@myorg/features/admin").then((m) => m.adminRoutes),
  },
];

// Component lazy loading
@Component({
  template: `
    @if (shouldLoadChart) {
    <app-chart [data]="chartData" />
    }
  `,
})
export class DashboardComponent {
  @ViewChild("chartContainer") chartContainer!: ElementRef;

  async loadChart() {
    const { ChartComponent } = await import("./chart/chart.component");
    // Dynamically create component
  }
}
```

### 2. OnPush Change Detection

Use OnPush strategy with immutable data patterns.

```typescript
@Component({
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    @for (item of items; track trackByFn) {
    <app-item [data]="item" />
    }
  `,
})
export class ListComponent {
  @Input() items: Item[] = [];

  trackByFn = (index: number, item: Item) => item.id;
}
```

### 3. Virtual Scrolling

For large datasets.

```typescript
@Component({
  template: `
    <cdk-virtual-scroll-viewport itemSize="60" class="viewport">
      <div *cdkVirtualFor="let item of items; trackBy: trackByFn">
        {{ item.name }}
      </div>
    </cdk-virtual-scroll-viewport>
  `,
})
export class VirtualListComponent {
  @Input() items: any[] = [];
  trackByFn = (index: number, item: any) => item.id;
}
```

---

## 🧪 Testing Patterns

### 1. Component Testing

Use Angular Testing Library for component tests.

```typescript
describe("ProductCardComponent", () => {
  it("should emit select event on button click", async () => {
    const selectSpy = jest.fn();

    await render(ProductCardComponent, {
      componentInputs: {
        product: createMockProduct(),
      },
      componentOutputs: {
        select: selectSpy,
      },
    });

    fireEvent.click(screen.getByRole("button", { name: /select/i }));
    expect(selectSpy).toHaveBeenCalled();
  });
});
```

### 2. Service Testing

Test services with dependency injection.

```typescript
describe("UserService", () => {
  let service: UserService;
  let httpMock: HttpTestingController;

  beforeEach(() => {
    TestBed.configureTestingModule({
      imports: [HttpClientTestingModule],
      providers: [UserService],
    });

    service = TestBed.inject(UserService);
    httpMock = TestBed.inject(HttpTestingController);
  });

  it("should fetch users", () => {
    const mockUsers = [createMockUser()];

    service.getUsers().subscribe((users) => {
      expect(users).toEqual(mockUsers);
    });

    const req = httpMock.expectOne("/api/users");
    expect(req.request.method).toBe("GET");
    req.flush(mockUsers);
  });
});
```

### 3. E2E Testing

Use Cypress for end-to-end testing.

```typescript
describe("Product Management", () => {
  beforeEach(() => {
    cy.login("admin@example.com", "password");
    cy.visit("/admin/products");
  });

  it("should create a new product", () => {
    cy.get('[data-cy="create-product-btn"]').click();
    cy.get('[data-cy="product-name-input"]').type("Test Product");
    cy.get('[data-cy="save-btn"]').click();

    cy.get('[data-cy="success-message"]').should(
      "contain",
      "Product created successfully"
    );
  });
});
```

---

## 🔧 Development Guidelines

Following [Angular's official style guide](https://angular.dev/style-guide) and enterprise patterns:

### 1. Code Organization

- **Features**: Organize by business domain (Angular recommended)
- **Shared**: Reusable across features
- **Core**: Infrastructure and singletons
- **Utils**: Pure functions only
- **One concept per file**: Components, services, pipes in separate files

### 2. Naming Conventions

- **Components**: PascalCase with suffix (UserListComponent)
- **Services**: PascalCase with suffix (UserService)
- **Interfaces**: PascalCase (User, Product)
- **Files**: kebab-case (user-list.component.ts)
- **Folders**: kebab-case (user-management)

### 3. Import Patterns

```typescript
// Angular imports first
import { Component, Input, Output, EventEmitter } from "@angular/core";

// Third-party imports
import { Observable } from "rxjs";

// Internal imports (workspace libraries)
import { User } from "@myorg/interfaces";
import { UserService } from "@myorg/features/admin/users";

// Relative imports last
import { UserCardComponent } from "./user-card.component";
```

### 4. Dependency Injection

Use the modern `inject()` function.

```typescript
@Component({})
export class ExampleComponent {
  private userService = inject(UserService);
  private router = inject(Router);
  private destroyRef = inject(DestroyRef);

  ngOnInit() {
    this.userService
      .getUsers()
      .pipe(takeUntilDestroyed(this.destroyRef))
      .subscribe((users) => {
        // Handle users
      });
  }
}
```

### 5. Error Handling

Consistent error handling patterns.

```typescript
@Injectable()
export class ApiService {
  handleError = (operation: string) => (error: any) => {
    console.error(`${operation} failed:`, error);
    this.notificationService.showError(`${operation} failed`);
    return throwError(() => error);
  };

  getUsers() {
    return this.http
      .get<User[]>("/api/users")
      .pipe(catchError(this.handleError("Get users")));
  }
}
```

---

## 📦 Nx Configuration

### 1. Project Tags

Use tags to enforce architectural boundaries.

```json
// nx.json
{
  "projects": {
    "admin": { "tags": ["app", "domain:admin"] },
    "shared-ui": { "tags": ["shared", "type:ui"] },
    "features-admin-users": { "tags": ["feature", "domain:admin"] },
    "core": { "tags": ["core"] }
  },
  "namedInputs": {
    "default": ["{projectRoot}/**/*", "sharedGlobals"],
    "production": ["default", "!{projectRoot}/**/?(*.)+(spec|test).[jt]s?(x)?"],
    "sharedGlobals": []
  },
  "targetDefaults": {
    "build": {
      "dependsOn": ["^build"],
      "inputs": ["production", "^production"]
    },
    "test": {
      "inputs": ["default", "^production", "{workspaceRoot}/jest.preset.js"]
    }
  }
}
```

### 2. Library Generation

Commands for generating libraries.

```bash
# Generate feature library
nx g @nx/angular:library features-admin-users --directory=libs/features/admin/users

# Generate shared UI library
nx g @nx/angular:library shared-ui --directory=libs/shared/ui

# Generate service
nx g @nx/angular:service user --project=features-admin-users
```

---

## 🌐 Build & Deployment

### 1. Production Build

Optimized build configuration.

```json
// angular.json
{
  "projects": {
    "admin": {
      "architect": {
        "build": {
          "configurations": {
            "production": {
              "budgets": [
                {
                  "type": "initial",
                  "maximumWarning": "500kb",
                  "maximumError": "1mb"
                }
              ],
              "optimization": true,
              "outputHashing": "all",
              "sourceMap": false,
              "namedChunks": false,
              "extractLicenses": true,
              "vendorChunk": false,
              "buildOptimizer": true
            }
          }
        }
      }
    }
  }
}
```

### 2. Environment Configuration

Environment-specific configurations.

```typescript
// environments/environment.prod.ts
export const environment = {
  production: true,
  apiBaseUrl: "https://api.example.com",
  auth: {
    domain: "example.auth0.com",
    clientId: "your-client-id",
  },
  features: {
    analytics: true,
    notifications: true,
  },
};
```

---

## 📋 Common Patterns Summary

### Component Creation

```typescript
@Component({
  selector: "app-example",
  standalone: true,
  imports: [CommonModule, FormsModule],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `<!-- template -->`,
  styleUrls: ["./example.component.scss"],
})
export class ExampleComponent implements OnInit {
  // Use inject() for dependencies
  private service = inject(ExampleService);

  // Use signals for reactive state
  data = signal<Data[]>([]);
  loading = signal(false);

  // Computed values
  filteredData = computed(() => this.data().filter(/* filter logic */));

  ngOnInit() {
    this.loadData();
  }

  private loadData() {
    this.loading.set(true);
    this.service
      .getData()
      .pipe(finalize(() => this.loading.set(false)))
      .subscribe((data) => this.data.set(data));
  }
}
```

### Service Creation

```typescript
@Injectable({ providedIn: "root" })
export class ExampleService {
  private http = inject(HttpClient);
  private store = inject(ExampleStore);

  getData() {
    return this.http.get<Data[]>("/api/data").pipe(
      tap((data) => this.store.setData(data)),
      catchError(this.handleError)
    );
  }

  private handleError = (error: any) => {
    console.error("Service error:", error);
    return throwError(() => error);
  };
}
```

This context provides LLMs with comprehensive understanding of the Angular 20 + Nx architecture, patterns, and best practices for generating appropriate code and providing accurate assistance.

## 🔗 Official Angular References

For additional context and the latest Angular patterns, reference:

- **[Angular Official LLM Context](https://angular.dev/context/llm-files/llms-full.txt)** - Primary reference for all Angular patterns
- **[Angular Style Guide](https://angular.dev/style-guide)** - Official coding conventions
- **[Project Coding Standards](./best-practices.md)** - Project-specific Angular 20 patterns and preferences
- **[Angular Security](https://angular.dev/best-practices/security)** - XSS, CSRF protection patterns
- **[Angular Performance](https://angular.dev/best-practices/runtime-performance)** - Change detection, OnPush patterns
- **[Angular Testing](https://angular.dev/guide/testing)** - Testing utilities and patterns
- **[Angular Update Guide](https://update.angular.io/)** - Migration strategies

These guidelines work together: Angular's official patterns as foundation, our team standards for specifics, and enterprise extensions for scale.
