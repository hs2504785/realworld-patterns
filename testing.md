# Testing Strategy

Comprehensive testing approach for Angular 20 + Nx monorepo with modern testing tools and patterns.

## 🎯 Testing Pyramid

```
        E2E Tests (Cypress)
       ↗ Integration Tests ↖
    Unit Tests ← Component Tests
  ↙ Utilities ← Services ← Stores ↘
```

## 🛠 Testing Stack

- **Unit Tests**: Jest + Angular Testing Library
- **Component Tests**: Jest + @angular/testing + @testing-library/angular
- **Integration Tests**: Jest + HTTP Testing
- **E2E Tests**: Cypress with component testing
- **Visual Testing**: Chromatic (optional)
- **Performance Testing**: Lighthouse CI

---

## 🔹 Jest Configuration

### Root Jest Config (`jest.config.ts`)

```ts
import { getJestProjects } from "@nx/jest";

export default {
  projects: getJestProjects(),
  coverageReporters: ["html", "lcov", "text-summary"],
  collectCoverageFrom: [
    "libs/**/*.ts",
    "apps/**/*.ts",
    "!**/*.spec.ts",
    "!**/*.stories.ts",
    "!**/index.ts",
    "!**/*.d.ts",
  ],
  coverageThreshold: {
    global: {
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80,
    },
  },
};
```

### Library Jest Config (`libs/shared/jest.config.ts`)

```ts
export default {
  displayName: "shared",
  preset: "../../jest.preset.js",
  setupFilesAfterEnv: ["<rootDir>/src/test-setup.ts"],
  coverageDirectory: "../../coverage/libs/shared",
  transform: {
    "^.+\\.(ts|mjs|js|html)$": [
      "jest-preset-angular",
      {
        tsconfig: "<rootDir>/tsconfig.spec.json",
        stringifyContentPathRegex: "\\.(html|svg)$",
      },
    ],
  },
  transformIgnorePatterns: ["node_modules/(?!.*\\.mjs$)"],
  snapshotSerializers: [
    "jest-preset-angular/build/serializers/no-ng-attributes",
    "jest-preset-angular/build/serializers/ng-snapshot",
    "jest-preset-angular/build/serializers/html-comment",
  ],
};
```

### Test Setup (`libs/shared/src/test-setup.ts`)

```ts
import "jest-preset-angular/setup-jest";
import { configure } from "@testing-library/angular";

// Configure Testing Library
configure({
  defaultHidden: true,
  asyncUtilTimeout: 5000,
});

// Mock ResizeObserver
global.ResizeObserver = class ResizeObserver {
  observe() {}
  unobserve() {}
  disconnect() {}
};

// Mock IntersectionObserver
global.IntersectionObserver = class IntersectionObserver {
  constructor() {}
  observe() {}
  unobserve() {}
  disconnect() {}
};

// Mock CSS Custom Properties
Object.defineProperty(window, "getComputedStyle", {
  value: () => ({
    getPropertyValue: () => "",
  }),
});
```

---

## 🔹 Unit Testing Patterns

### Service Testing with Signals

```ts
// libs/state/user/user.store.spec.ts
import { TestBed } from "@angular/core/testing";
import { UserStore } from "./user.store";
import { User } from "@myorg/interfaces";

describe("UserStore", () => {
  let store: UserStore;

  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [UserStore],
    });
    store = TestBed.inject(UserStore);
  });

  describe("initial state", () => {
    it("should have empty initial state", () => {
      expect(store.currentUser()).toBeNull();
      expect(store.isAuthenticated()).toBe(false);
      expect(store.loading()).toBe(false);
      expect(store.error()).toBeNull();
    });
  });

  describe("setUser", () => {
    it("should set user and update authentication state", () => {
      const mockUser: User = {
        id: "1",
        name: "Test User",
        email: "test@example.com",
        roles: ["USER"],
        permissions: ["read:profile"],
      };

      store.setUser(mockUser);

      expect(store.currentUser()).toEqual(mockUser);
      expect(store.isAuthenticated()).toBe(true);
      expect(store.permissions()).toEqual(["read:profile"]);
    });

    it("should compute admin status correctly", () => {
      const adminUser: User = {
        id: "1",
        name: "Admin User",
        email: "admin@example.com",
        roles: ["ADMIN"],
        permissions: ["admin:all"],
      };

      store.setUser(adminUser);

      expect(store.isAdmin()).toBe(true);
    });
  });

  describe("clearUser", () => {
    it("should reset to initial state", () => {
      const mockUser: User = {
        id: "1",
        name: "Test User",
        email: "test@example.com",
        roles: ["USER"],
        permissions: [],
      };

      store.setUser(mockUser);
      store.clearUser();

      expect(store.currentUser()).toBeNull();
      expect(store.isAuthenticated()).toBe(false);
      expect(store.permissions()).toEqual([]);
    });
  });
});
```

### HTTP Service Testing

```ts
// libs/features/billing/product/services/product.service.spec.ts
import { TestBed } from "@angular/core/testing";
import {
  HttpClientTestingModule,
  HttpTestingController,
} from "@angular/common/http/testing";
import { ProductService } from "./product.service";
import { ProductStore } from "../state/product.store";
import { Product } from "@myorg/interfaces";

describe("ProductService", () => {
  let service: ProductService;
  let httpMock: HttpTestingController;
  let storeSpy: jasmine.SpyObj<ProductStore>;

  beforeEach(() => {
    const spy = jasmine.createSpyObj("ProductStore", [
      "setProducts",
      "addProduct",
      "updateProduct",
      "removeProduct",
      "setLoading",
      "setError",
    ]);

    TestBed.configureTestingModule({
      imports: [HttpClientTestingModule],
      providers: [ProductService, { provide: ProductStore, useValue: spy }],
    });

    service = TestBed.inject(ProductService);
    httpMock = TestBed.inject(HttpTestingController);
    storeSpy = TestBed.inject(ProductStore) as jasmine.SpyObj<ProductStore>;
  });

  afterEach(() => {
    httpMock.verify();
  });

  describe("getProducts", () => {
    it("should fetch products and update store", () => {
      const mockProducts: Product[] = [
        {
          id: "1",
          name: "Product 1",
          category: "electronics",
          status: "active",
        },
        { id: "2", name: "Product 2", category: "clothing", status: "active" },
      ];

      service.getProducts().subscribe();

      const req = httpMock.expectOne("/api/products");
      expect(req.request.method).toBe("GET");

      req.flush(mockProducts);

      expect(storeSpy.setLoading).toHaveBeenCalledWith(true);
      expect(storeSpy.setProducts).toHaveBeenCalledWith(mockProducts);
      expect(storeSpy.setLoading).toHaveBeenCalledWith(false);
    });

    it("should handle error and update store", () => {
      service.getProducts().subscribe();

      const req = httpMock.expectOne("/api/products");
      req.error(new ProgressEvent("Network error"));

      expect(storeSpy.setError).toHaveBeenCalledWith("Failed to load products");
    });
  });

  describe("createProduct", () => {
    it("should create product and add to store", () => {
      const newProduct = { name: "New Product", category: "electronics" };
      const createdProduct: Product = {
        id: "3",
        ...newProduct,
        status: "active" as const,
      };

      service.createProduct(newProduct).subscribe();

      const req = httpMock.expectOne("/api/products");
      expect(req.request.method).toBe("POST");
      expect(req.request.body).toEqual(newProduct);

      req.flush(createdProduct);

      expect(storeSpy.addProduct).toHaveBeenCalledWith(createdProduct);
    });
  });
});
```

---

## 🔹 Component Testing

### Standalone Component Testing

```ts
// libs/shared/ui/button/button.component.spec.ts
import { render, screen, fireEvent } from "@testing-library/angular";
import { ButtonComponent } from "./button.component";

describe("ButtonComponent", () => {
  it("should render with default props", async () => {
    await render(ButtonComponent, {
      componentInputs: {
        variant: "primary",
        size: "md",
      },
      componentOutputs: {
        click: jest.fn(),
      },
    });

    expect(screen.getByRole("button")).toBeInTheDocument();
    expect(screen.getByRole("button")).toHaveClass(
      "btn",
      "btn-primary",
      "btn-md"
    );
  });

  it("should emit click event", async () => {
    const clickSpy = jest.fn();

    await render(ButtonComponent, {
      componentInputs: {
        variant: "primary",
      },
      componentOutputs: {
        click: clickSpy,
      },
    });

    fireEvent.click(screen.getByRole("button"));

    expect(clickSpy).toHaveBeenCalled();
  });

  it("should be disabled when loading", async () => {
    await render(ButtonComponent, {
      componentInputs: {
        loading: true,
      },
    });

    expect(screen.getByRole("button")).toBeDisabled();
    expect(screen.getByText("Loading...")).toBeInTheDocument();
  });

  it("should render with custom content", async () => {
    await render("<app-button>Custom Text</app-button>", {
      imports: [ButtonComponent],
    });

    expect(screen.getByText("Custom Text")).toBeInTheDocument();
  });
});
```

### Container Component Testing

```ts
// libs/features/billing/product/containers/product-list.container.spec.ts
import { render, screen, fireEvent, waitFor } from "@testing-library/angular";
import { provideHttpClient } from "@angular/common/http";
import {
  HttpTestingController,
  provideHttpClientTesting,
} from "@angular/common/http/testing";
import { ProductListContainer } from "./product-list.container";
import { ProductStore } from "../state/product.store";
import { ProductService } from "../services/product.service";

describe("ProductListContainer", () => {
  let httpMock: HttpTestingController;

  const renderComponent = async () => {
    const result = await render(ProductListContainer, {
      providers: [
        provideHttpClient(),
        provideHttpClientTesting(),
        ProductStore,
        ProductService,
      ],
    });

    httpMock = result.fixture.debugElement.injector.get(HttpTestingController);
    return result;
  };

  it("should display loading state initially", async () => {
    await renderComponent();

    // Component should trigger data loading
    expect(screen.getByRole("status")).toBeInTheDocument();
  });

  it("should display products after loading", async () => {
    await renderComponent();

    const req = httpMock.expectOne("/api/products");
    req.flush([
      { id: "1", name: "Product 1", category: "electronics", status: "active" },
      { id: "2", name: "Product 2", category: "clothing", status: "active" },
    ]);

    await waitFor(() => {
      expect(screen.getByText("Product 1")).toBeInTheDocument();
      expect(screen.getByText("Product 2")).toBeInTheDocument();
    });
  });

  it("should filter products by search", async () => {
    await renderComponent();

    const req = httpMock.expectOne("/api/products");
    req.flush([
      { id: "1", name: "iPhone 15", category: "electronics", status: "active" },
      {
        id: "2",
        name: "Samsung Galaxy",
        category: "electronics",
        status: "active",
      },
    ]);

    await waitFor(() => {
      expect(screen.getByText("iPhone 15")).toBeInTheDocument();
    });

    const searchInput = screen.getByPlaceholderText("Search products...");
    fireEvent.input(searchInput, { target: { value: "iPhone" } });

    await waitFor(() => {
      expect(screen.getByText("iPhone 15")).toBeInTheDocument();
      expect(screen.queryByText("Samsung Galaxy")).not.toBeInTheDocument();
    });
  });

  it("should show error message on API failure", async () => {
    await renderComponent();

    const req = httpMock.expectOne("/api/products");
    req.error(new ProgressEvent("Network error"));

    await waitFor(() => {
      expect(screen.getByText(/failed to load products/i)).toBeInTheDocument();
    });
  });

  it("should show empty state when no products", async () => {
    await renderComponent();

    const req = httpMock.expectOne("/api/products");
    req.flush([]);

    await waitFor(() => {
      expect(screen.getByText("No products found")).toBeInTheDocument();
    });
  });
});
```

---

## 🔹 Integration Testing

### Route Testing

```ts
// apps/admin/src/app/app.routes.spec.ts
import { TestBed } from "@angular/core/testing";
import { Router } from "@angular/router";
import { Location } from "@angular/common";
import { Component } from "@angular/core";
import { provideRouter } from "@angular/router";
import { routes } from "./app.routes";

@Component({ template: "" })
class TestComponent {}

describe("App Routes", () => {
  let router: Router;
  let location: Location;

  beforeEach(async () => {
    TestBed.configureTestingModule({
      providers: [
        provideRouter([...routes, { path: "test", component: TestComponent }]),
      ],
    });

    router = TestBed.inject(Router);
    location = TestBed.inject(Location);
  });

  it("should navigate to dashboard", async () => {
    await router.navigate(["/dashboard"]);
    expect(location.path()).toBe("/dashboard");
  });

  it("should redirect to login for protected routes", async () => {
    await router.navigate(["/admin/users"]);
    // Assuming auth guard redirects to login
    expect(location.path()).toBe("/login");
  });

  it("should lazy load feature modules", async () => {
    const route = routes.find((r) => r.path === "admin");
    expect(route?.loadChildren).toBeDefined();
  });
});
```

### Feature Module Integration

```ts
// libs/features/billing/product/integration/product.integration.spec.ts
import { TestBed } from "@angular/core/testing";
import { provideHttpClient } from "@angular/common/http";
import {
  HttpTestingController,
  provideHttpClientTesting,
} from "@angular/common/http/testing";
import { ProductService } from "../services/product.service";
import { ProductStore } from "../state/product.store";
import { NotificationStore } from "@myorg/state/notifications";

describe("Product Feature Integration", () => {
  let service: ProductService;
  let store: ProductStore;
  let notificationStore: NotificationStore;
  let httpMock: HttpTestingController;

  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [
        provideHttpClient(),
        provideHttpClientTesting(),
        ProductService,
        ProductStore,
        NotificationStore,
      ],
    });

    service = TestBed.inject(ProductService);
    store = TestBed.inject(ProductStore);
    notificationStore = TestBed.inject(NotificationStore);
    httpMock = TestBed.inject(HttpTestingController);
  });

  afterEach(() => {
    httpMock.verify();
  });

  it("should handle complete product creation flow", async () => {
    const newProduct = { name: "Test Product", category: "electronics" };
    const createdProduct = {
      id: "1",
      ...newProduct,
      status: "active" as const,
    };

    // Start creation
    service.createProduct(newProduct).subscribe();

    // Verify loading state
    expect(store.loading()).toBe(true);

    // Complete HTTP request
    const req = httpMock.expectOne("/api/products");
    req.flush(createdProduct);

    // Verify final state
    expect(store.loading()).toBe(false);
    expect(store.products()).toContain(createdProduct);
    expect(notificationStore.notifications()).toHaveLength(1);
    expect(notificationStore.notifications()[0].message).toBe(
      "Product added successfully"
    );
  });

  it("should handle error scenarios gracefully", async () => {
    service.createProduct({ name: "Test", category: "test" }).subscribe();

    const req = httpMock.expectOne("/api/products");
    req.error(new ProgressEvent("Server Error"));

    expect(store.loading()).toBe(false);
    expect(store.error()).toBeTruthy();
    expect(notificationStore.errorCount()).toBeGreaterThan(0);
  });
});
```

---

## 🔹 E2E Testing with Cypress

### Basic E2E Test Structure

```ts
// apps/admin-e2e/src/e2e/products.cy.ts
describe("Product Management", () => {
  beforeEach(() => {
    cy.login("admin@example.com", "password");
    cy.visit("/admin/products");
  });

  it("should display product list", () => {
    cy.get('[data-cy="product-card"]').should("have.length.greaterThan", 0);
    cy.get('[data-cy="product-count"]').should("contain", "products found");
  });

  it("should filter products by search", () => {
    cy.get('[data-cy="search-input"]').type("iPhone");
    cy.get('[data-cy="product-card"]').should("contain", "iPhone");
    cy.get('[data-cy="product-card"]').should("not.contain", "Samsung");
  });

  it("should create new product", () => {
    cy.get('[data-cy="create-product-btn"]').click();

    cy.get('[data-cy="product-name-input"]').type("Test Product");
    cy.get('[data-cy="product-category-select"]').select("electronics");
    cy.get('[data-cy="product-price-input"]').type("99.99");

    cy.get('[data-cy="save-product-btn"]').click();

    cy.get('[data-cy="success-notification"]').should(
      "contain",
      "Product created successfully"
    );

    cy.get('[data-cy="product-card"]').should("contain", "Test Product");
  });

  it("should handle validation errors", () => {
    cy.get('[data-cy="create-product-btn"]').click();
    cy.get('[data-cy="save-product-btn"]').click();

    cy.get('[data-cy="name-error"]').should(
      "contain",
      "Product name is required"
    );
  });
});
```

### Cypress Commands

```ts
// apps/admin-e2e/src/support/commands.ts
declare global {
  namespace Cypress {
    interface Chainable {
      login(email: string, password: string): Chainable<void>;
      seedData(): Chainable<void>;
      cleanupData(): Chainable<void>;
    }
  }
}

Cypress.Commands.add("login", (email: string, password: string) => {
  cy.session([email, password], () => {
    cy.visit("/login");
    cy.get('[data-cy="email-input"]').type(email);
    cy.get('[data-cy="password-input"]').type(password);
    cy.get('[data-cy="login-btn"]').click();
    cy.url().should("include", "/dashboard");
  });
});

Cypress.Commands.add("seedData", () => {
  cy.task("db:seed");
});

Cypress.Commands.add("cleanupData", () => {
  cy.task("db:cleanup");
});
```

### Cypress Configuration

```ts
// cypress.config.ts
import { defineConfig } from "cypress";
import { nxE2EPreset } from "@nx/cypress/plugins/cypress-preset";

export default defineConfig({
  e2e: {
    ...nxE2EPreset(__filename, {
      cypressDir: "src",
      webServerCommands: {
        default: "nx run admin:serve",
        production: "nx run admin:preview",
      },
      ciWebServerCommand: "nx run admin:serve-static",
    }),
    baseUrl: "http://localhost:4200",
    supportFile: "src/support/e2e.ts",
    setupNodeEvents(on, config) {
      // Database tasks for seeding/cleanup
      on("task", {
        "db:seed": () => {
          // Seed database logic
          return null;
        },
        "db:cleanup": () => {
          // Cleanup database logic
          return null;
        },
      });
    },
  },
  component: {
    devServer: {
      framework: "angular",
      bundler: "webpack",
    },
    specPattern: "**/*.cy.ts",
  },
});
```

---

## 🔹 Performance Testing

### Lighthouse CI Configuration

```json
// .lighthouserc.js
module.exports = {
  ci: {
    collect: {
      url: [
        'http://localhost:4200',
        'http://localhost:4200/admin/dashboard',
        'http://localhost:4200/admin/products',
      ],
      numberOfRuns: 3,
    },
    assert: {
      assertions: {
        'categories:performance': ['warn', { minScore: 0.9 }],
        'categories:accessibility': ['error', { minScore: 0.9 }],
        'categories:best-practices': ['warn', { minScore: 0.9 }],
        'categories:seo': ['warn', { minScore: 0.9 }],
      },
    },
    upload: {
      target: 'temporary-public-storage',
    },
  },
};
```

### Bundle Analysis Testing

```ts
// tools/bundle-analyzer.spec.ts
import { execSync } from "child_process";
import { readFileSync } from "fs";

describe("Bundle Analysis", () => {
  it("should not exceed bundle size limits", () => {
    // Build the application
    execSync("nx build admin --prod");

    // Read bundle stats
    const stats = JSON.parse(
      readFileSync("dist/apps/admin/stats.json", "utf8")
    );

    const mainBundle = stats.assets.find(
      (asset: any) => asset.name.includes("main") && asset.name.endsWith(".js")
    );

    expect(mainBundle.size).toBeLessThan(500 * 1024); // 500KB limit
  });
});
```

---

## 🔹 Test Utilities

### Testing Library Custom Renders

```ts
// libs/shared/testing/src/lib/render-utils.ts
import { render, RenderOptions } from "@testing-library/angular";
import { provideHttpClient } from "@angular/common/http";
import { provideHttpClientTesting } from "@angular/common/http/testing";
import { provideRouter } from "@angular/router";

export interface CustomRenderOptions extends RenderOptions {
  withRouter?: boolean;
  withHttp?: boolean;
  initialRoute?: string;
}

export async function customRender(
  component: any,
  options: CustomRenderOptions = {}
) {
  const {
    withRouter = false,
    withHttp = false,
    initialRoute = "/",
    ...renderOptions
  } = options;

  const providers = [...(renderOptions.providers || [])];

  if (withHttp) {
    providers.push(provideHttpClient(), provideHttpClientTesting());
  }

  if (withRouter) {
    providers.push(provideRouter([]));
  }

  const result = await render(component, {
    ...renderOptions,
    providers,
  });

  if (withRouter && initialRoute !== "/") {
    // Navigate to initial route if needed
  }

  return result;
}
```

### Mock Factories

```ts
// libs/shared/testing/src/lib/mock-factories.ts
import { User, Product, Notification } from "@myorg/interfaces";

export const createMockUser = (overrides: Partial<User> = {}): User => ({
  id: "1",
  name: "Test User",
  email: "test@example.com",
  roles: ["USER"],
  permissions: ["read:profile"],
  ...overrides,
});

export const createMockProduct = (
  overrides: Partial<Product> = {}
): Product => ({
  id: "1",
  name: "Test Product",
  category: "electronics",
  status: "active",
  price: 99.99,
  description: "Test product description",
  ...overrides,
});

export const createMockNotification = (
  overrides: Partial<Notification> = {}
): Notification => ({
  id: "1",
  message: "Test notification",
  type: "info",
  createdAt: new Date(),
  ...overrides,
});
```

---

## 🎯 Test Scripts

### Package.json Scripts

```json
{
  "scripts": {
    "test": "nx run-many --target=test --all",
    "test:watch": "nx run-many --target=test --all --watch",
    "test:coverage": "nx run-many --target=test --all --coverage",
    "test:affected": "nx affected --target=test",
    "e2e": "nx run-many --target=e2e --all",
    "e2e:affected": "nx affected --target=e2e",
    "lint": "nx run-many --target=lint --all",
    "lint:affected": "nx affected --target=lint"
  }
}
```

---

## ✅ Best Practices Summary

1. **Test Structure**: Follow AAA pattern (Arrange, Act, Assert)
2. **Test Isolation**: Each test should be independent
3. **Mock External Dependencies**: Use TestBed and spies
4. **Use Data Attributes**: `data-cy` for E2E, `data-testid` for unit tests
5. **Test User Behavior**: Focus on what users do, not implementation
6. **Coverage Goals**: Aim for 80%+ coverage with meaningful tests
7. **Fast Feedback**: Unit tests should run quickly
8. **Continuous Testing**: Run tests in CI/CD pipeline
9. **Visual Testing**: Consider Chromatic for UI regression testing
10. **Performance Testing**: Include bundle size and Lighthouse checks
