# State Management

Modern Angular 20 state management using **Signals**, **Services**, and **RxJS** with a clear separation between global and feature-level state.

## 🎯 State Architecture Overview

```
/libs/state/                    # Global state management
  ├─ user/                     # User authentication state
  │   ├─ user.store.ts         # User state store
  │   ├─ user.service.ts       # User operations
  │   └─ index.ts
  ├─ theme/                    # Theme state
  │   ├─ theme.store.ts
  │   ├─ theme.service.ts
  │   └─ index.ts
  ├─ notifications/            # Global notifications
  │   ├─ notification.store.ts
  │   ├─ notification.service.ts
  │   └─ index.ts
  ├─ config/                   # App configuration
  │   ├─ config.store.ts
  │   ├─ config.service.ts
  │   └─ index.ts
  └─ index.ts                  # Barrel exports

/libs/features/*/state/         # Feature-specific state
  ├─ {feature}.store.ts        # Feature state store
  ├─ {feature}.service.ts      # Feature operations
  └─ index.ts
```

---

## 🔹 Global State Pattern

### User State Store

```ts
// libs/state/user/user.store.ts
import { Injectable, signal, computed } from "@angular/core";
import { User, Role } from "@myorg/interfaces";

export interface UserState {
  currentUser: User | null;
  isAuthenticated: boolean;
  permissions: string[];
  loading: boolean;
  error: string | null;
}

@Injectable({ providedIn: "root" })
export class UserStore {
  // Private state signals
  private _state = signal<UserState>({
    currentUser: null,
    isAuthenticated: false,
    permissions: [],
    loading: false,
    error: null,
  });

  // Public readonly computed signals
  readonly currentUser = computed(() => this._state().currentUser);
  readonly isAuthenticated = computed(() => this._state().isAuthenticated);
  readonly permissions = computed(() => this._state().permissions);
  readonly loading = computed(() => this._state().loading);
  readonly error = computed(() => this._state().error);

  // Computed derived state
  readonly isAdmin = computed(
    () => this.currentUser()?.roles.includes("ADMIN") ?? false
  );

  readonly canAccessBilling = computed(() =>
    this.permissions().includes("billing:read")
  );

  // State mutations
  setUser(user: User | null) {
    this._state.update((state) => ({
      ...state,
      currentUser: user,
      isAuthenticated: !!user,
      permissions: user?.permissions ?? [],
      error: null,
    }));
  }

  setLoading(loading: boolean) {
    this._state.update((state) => ({ ...state, loading }));
  }

  setError(error: string | null) {
    this._state.update((state) => ({ ...state, error, loading: false }));
  }

  clearUser() {
    this._state.set({
      currentUser: null,
      isAuthenticated: false,
      permissions: [],
      loading: false,
      error: null,
    });
  }
}
```

### User Service with Store Integration

```ts
// libs/state/user/user.service.ts
import { Injectable, inject } from "@angular/core";
import { HttpClient } from "@angular/common/http";
import { Router } from "@angular/router";
import { catchError, tap, finalize } from "rxjs/operators";
import { of } from "rxjs";
import { UserStore } from "./user.store";
import { User, LoginRequest } from "@myorg/interfaces";

@Injectable({ providedIn: "root" })
export class UserService {
  private http = inject(HttpClient);
  private router = inject(Router);
  private userStore = inject(UserStore);

  login(credentials: LoginRequest) {
    this.userStore.setLoading(true);

    return this.http
      .post<{ user: User; token: string }>("/api/auth/login", credentials)
      .pipe(
        tap((response) => {
          localStorage.setItem("token", response.token);
          this.userStore.setUser(response.user);
        }),
        catchError((error) => {
          this.userStore.setError(error.message || "Login failed");
          return of(null);
        }),
        finalize(() => this.userStore.setLoading(false))
      );
  }

  logout() {
    localStorage.removeItem("token");
    this.userStore.clearUser();
    this.router.navigate(["/login"]);
  }

  getCurrentUser() {
    this.userStore.setLoading(true);

    return this.http.get<User>("/api/auth/me").pipe(
      tap((user) => this.userStore.setUser(user)),
      catchError((error) => {
        this.userStore.setError("Failed to load user");
        return of(null);
      }),
      finalize(() => this.userStore.setLoading(false))
    );
  }

  updateProfile(updates: Partial<User>) {
    const currentUser = this.userStore.currentUser();
    if (!currentUser) return of(null);

    this.userStore.setLoading(true);

    return this.http.patch<User>(`/api/users/${currentUser.id}`, updates).pipe(
      tap((updatedUser) => this.userStore.setUser(updatedUser)),
      catchError((error) => {
        this.userStore.setError(error.message || "Update failed");
        return of(null);
      }),
      finalize(() => this.userStore.setLoading(false))
    );
  }
}
```

---

## 🔹 Theme State Example

```ts
// libs/state/theme/theme.store.ts
import { Injectable, signal, computed, effect } from "@angular/core";
import { Theme } from "@myorg/interfaces";

@Injectable({ providedIn: "root" })
export class ThemeStore {
  private _currentTheme = signal<Theme>("light");

  readonly currentTheme = computed(() => this._currentTheme());
  readonly isDark = computed(() => this._currentTheme() === "dark");
  readonly isLight = computed(() => this._currentTheme() === "light");

  constructor() {
    // Auto-persist theme changes
    effect(() => {
      localStorage.setItem("theme", this.currentTheme());
    });
  }

  setTheme(theme: Theme) {
    this._currentTheme.set(theme);
  }

  toggleTheme() {
    const current = this._currentTheme();
    const newTheme = current === "light" ? "dark" : "light";
    this.setTheme(newTheme);
  }

  initTheme() {
    const saved = localStorage.getItem("theme") as Theme;
    if (saved && ["light", "dark", "purple"].includes(saved)) {
      this.setTheme(saved);
    }
  }
}
```

---

## 🔹 Notification State Pattern

```ts
// libs/state/notifications/notification.store.ts
import { Injectable, signal, computed } from "@angular/core";
import { Notification } from "@myorg/interfaces";

@Injectable({ providedIn: "root" })
export class NotificationStore {
  private _notifications = signal<Notification[]>([]);

  readonly notifications = computed(() => this._notifications());
  readonly hasNotifications = computed(() => this._notifications().length > 0);
  readonly errorCount = computed(
    () => this._notifications().filter((n) => n.type === "error").length
  );

  addNotification(notification: Omit<Notification, "id" | "createdAt">) {
    const newNotification: Notification = {
      ...notification,
      id: crypto.randomUUID(),
      createdAt: new Date(),
    };

    this._notifications.update((notifications) => [
      ...notifications,
      newNotification,
    ]);

    // Auto-dismiss after 5 seconds for success/info
    if (notification.type !== "error") {
      setTimeout(() => {
        this.removeNotification(newNotification.id);
      }, 5000);
    }
  }

  removeNotification(id: string) {
    this._notifications.update((notifications) =>
      notifications.filter((n) => n.id !== id)
    );
  }

  clearAll() {
    this._notifications.set([]);
  }

  // Convenience methods
  addSuccess(message: string) {
    this.addNotification({ message, type: "success" });
  }

  addError(message: string) {
    this.addNotification({ message, type: "error" });
  }

  addInfo(message: string) {
    this.addNotification({ message, type: "info" });
  }
}
```

---

## 🔹 Feature-Level State Pattern

```ts
// libs/features/billing/product/state/product.store.ts
import { Injectable, signal, computed, inject } from "@angular/core";
import { Product } from "@myorg/interfaces";
import { NotificationStore } from "@myorg/state/notifications";

export interface ProductState {
  products: Product[];
  selectedProduct: Product | null;
  loading: boolean;
  error: string | null;
  filters: {
    search: string;
    category: string;
    status: "active" | "inactive" | "all";
  };
}

@Injectable({ providedIn: "root" })
export class ProductStore {
  private notificationStore = inject(NotificationStore);

  private _state = signal<ProductState>({
    products: [],
    selectedProduct: null,
    loading: false,
    error: null,
    filters: {
      search: "",
      category: "",
      status: "all",
    },
  });

  // Selectors
  readonly products = computed(() => this._state().products);
  readonly selectedProduct = computed(() => this._state().selectedProduct);
  readonly loading = computed(() => this._state().loading);
  readonly error = computed(() => this._state().error);
  readonly filters = computed(() => this._state().filters);

  // Filtered products based on current filters
  readonly filteredProducts = computed(() => {
    const { products, filters } = this._state();

    return products.filter((product) => {
      const matchesSearch = product.name
        .toLowerCase()
        .includes(filters.search.toLowerCase());
      const matchesCategory =
        !filters.category || product.category === filters.category;
      const matchesStatus =
        filters.status === "all" || product.status === filters.status;

      return matchesSearch && matchesCategory && matchesStatus;
    });
  });

  readonly productCount = computed(() => this.filteredProducts().length);

  // Mutations
  setProducts(products: Product[]) {
    this._state.update((state) => ({ ...state, products, error: null }));
  }

  selectProduct(product: Product | null) {
    this._state.update((state) => ({ ...state, selectedProduct: product }));
  }

  addProduct(product: Product) {
    this._state.update((state) => ({
      ...state,
      products: [...state.products, product],
    }));
    this.notificationStore.addSuccess("Product added successfully");
  }

  updateProduct(id: string, updates: Partial<Product>) {
    this._state.update((state) => ({
      ...state,
      products: state.products.map((p) =>
        p.id === id ? { ...p, ...updates } : p
      ),
    }));
    this.notificationStore.addSuccess("Product updated successfully");
  }

  removeProduct(id: string) {
    this._state.update((state) => ({
      ...state,
      products: state.products.filter((p) => p.id !== id),
      selectedProduct:
        state.selectedProduct?.id === id ? null : state.selectedProduct,
    }));
    this.notificationStore.addSuccess("Product removed successfully");
  }

  setLoading(loading: boolean) {
    this._state.update((state) => ({ ...state, loading }));
  }

  setError(error: string) {
    this._state.update((state) => ({ ...state, error, loading: false }));
    this.notificationStore.addError(error);
  }

  updateFilters(filters: Partial<ProductState["filters"]>) {
    this._state.update((state) => ({
      ...state,
      filters: { ...state.filters, ...filters },
    }));
  }

  clearFilters() {
    this._state.update((state) => ({
      ...state,
      filters: { search: "", category: "", status: "all" },
    }));
  }
}
```

---

## 🔹 Component Integration

### Using State in Components

```ts
// libs/features/billing/product/containers/product-list.container.ts
import { Component, inject, OnInit } from "@angular/core";
import { ProductStore } from "../state/product.store";
import { ProductService } from "../services/product.service";

@Component({
  selector: "app-product-list",
  standalone: true,
  template: `
    <div class="container-fluid">
      <!-- Search and filters -->
      <div class="row mb-3">
        <div class="col-md-6">
          <input
            class="form-control"
            placeholder="Search products..."
            [value]="productStore.filters().search"
            (input)="onSearchChange($event)"
          />
        </div>
        <div class="col-md-3">
          <select
            class="form-select"
            [value]="productStore.filters().status"
            (change)="onStatusChange($event)"
          >
            <option value="all">All Status</option>
            <option value="active">Active</option>
            <option value="inactive">Inactive</option>
          </select>
        </div>
        <div class="col-md-3">
          <button
            class="btn btn-outline-secondary"
            (click)="productStore.clearFilters()"
          >
            Clear Filters
          </button>
        </div>
      </div>

      <!-- Loading state -->
      @if (productStore.loading()) {
      <div class="text-center">
        <div class="spinner-border" role="status"></div>
      </div>
      }

      <!-- Error state -->
      @if (productStore.error(); as error) {
      <div class="alert alert-danger">{{ error }}</div>
      }

      <!-- Products grid -->
      <div class="row">
        @for (product of productStore.filteredProducts(); track product.id) {
        <div class="col-lg-4 col-md-6 mb-3">
          <app-product-card
            [product]="product"
            [isSelected]="productStore.selectedProduct()?.id === product.id"
            (select)="productStore.selectProduct(product)"
            (edit)="onEditProduct(product)"
            (delete)="onDeleteProduct(product.id)"
          />
        </div>
        } @empty {
        <div class="col-12">
          <div class="text-center text-muted py-5">
            <h5>No products found</h5>
            <p>Try adjusting your search criteria</p>
          </div>
        </div>
        }
      </div>

      <!-- Results count -->
      <div class="mt-3 text-muted">
        {{ productStore.productCount() }} products found
      </div>
    </div>
  `,
})
export class ProductListContainer implements OnInit {
  productStore = inject(ProductStore);
  private productService = inject(ProductService);

  ngOnInit() {
    this.loadProducts();
  }

  onSearchChange(event: Event) {
    const target = event.target as HTMLInputElement;
    this.productStore.updateFilters({ search: target.value });
  }

  onStatusChange(event: Event) {
    const target = event.target as HTMLSelectElement;
    this.productStore.updateFilters({
      status: target.value as "active" | "inactive" | "all",
    });
  }

  onEditProduct(product: Product) {
    // Navigate to edit form or open modal
  }

  onDeleteProduct(id: string) {
    if (confirm("Are you sure you want to delete this product?")) {
      this.productService.deleteProduct(id).subscribe();
    }
  }

  private loadProducts() {
    this.productService.getProducts().subscribe();
  }
}
```

---

## 🔹 Best Practices

### 1. **State Organization**

- **Global State**: User, theme, notifications, config
- **Feature State**: Domain-specific data and operations
- **Component State**: UI-only state (forms, toggles, local filters)

### 2. **Signal Usage Patterns**

```ts
// ✅ Good: Private signals, public computed
private _users = signal<User[]>([]);
readonly users = computed(() => this._users());

// ❌ Avoid: Direct signal exposure
users = signal<User[]>([]);
```

### 3. **State Updates**

```ts
// ✅ Good: Immutable updates
this._state.update((state) => ({ ...state, loading: true }));

// ❌ Avoid: Direct mutation
this._state().loading = true;
```

### 4. **Error Handling**

```ts
// ✅ Good: Centralized error handling
catchError((error) => {
  this.store.setError(error.message);
  this.notificationStore.addError("Operation failed");
  return of(null);
});
```

### 5. **Computed Signals for Derived State**

```ts
// ✅ Good: Computed for derived values
readonly hasProducts = computed(() => this.products().length > 0);
readonly activeProducts = computed(() =>
  this.products().filter(p => p.status === 'active')
);
```

---

## 🎯 State Testing

```ts
// product.store.spec.ts
import { TestBed } from "@angular/core/testing";
import { ProductStore } from "./product.store";

describe("ProductStore", () => {
  let store: ProductStore;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    store = TestBed.inject(ProductStore);
  });

  it("should initialize with empty state", () => {
    expect(store.products()).toEqual([]);
    expect(store.loading()).toBe(false);
    expect(store.error()).toBeNull();
  });

  it("should set products", () => {
    const mockProducts = [{ id: "1", name: "Test Product" }];

    store.setProducts(mockProducts);

    expect(store.products()).toEqual(mockProducts);
  });

  it("should filter products by search", () => {
    const products = [
      { id: "1", name: "Apple iPhone", category: "phones" },
      { id: "2", name: "Samsung Galaxy", category: "phones" },
    ];

    store.setProducts(products);
    store.updateFilters({ search: "apple" });

    expect(store.filteredProducts()).toHaveLength(1);
    expect(store.filteredProducts()[0].name).toBe("Apple iPhone");
  });
});
```

---

## ✅ Summary

- **Signals** for reactive state management
- **Services** for business operations
- **Stores** for state encapsulation
- **Clear boundaries** between global and feature state
- **Computed signals** for derived state
- **Immutable updates** for predictable state changes
- **Error handling** integrated with notifications
- **Testing** with focused unit tests
