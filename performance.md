# Performance Optimization

Comprehensive performance optimization strategies for Angular 20 + Nx applications with modern performance patterns and monitoring.

## 🎯 Performance Goals

- **First Contentful Paint (FCP)**: < 1.5s
- **Largest Contentful Paint (LCP)**: < 2.5s
- **First Input Delay (FID)**: < 100ms
- **Cumulative Layout Shift (CLS)**: < 0.1
- **Time to Interactive (TTI)**: < 3.5s
- **Bundle Size**: Main bundle < 500KB

## 📊 Performance Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                Performance Optimization Layers              │
├─────────────────────────────────────────────────────────────┤
│ 🚀 Loading Performance (Bundle Splitting, Lazy Loading)    │
│ ⚡ Runtime Performance (Change Detection, OnPush)          │
│ 💾 Memory Performance (Subscriptions, References)         │
│ 🌐 Network Performance (Caching, Compression)             │
│ 🎨 Rendering Performance (Virtual Scrolling, Optimization) │
│ 📱 Mobile Performance (PWA, Service Worker)               │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔹 Bundle Optimization

### Webpack Bundle Analysis

```ts
// tools/webpack-bundle-analyzer.config.js
const { BundleAnalyzerPlugin } = require("webpack-bundle-analyzer");

module.exports = {
  plugins: [
    new BundleAnalyzerPlugin({
      analyzerMode: "static",
      reportFilename: "bundle-report.html",
      defaultSizes: "gzip",
      openAnalyzer: false,
    }),
  ],
};
```

### Tree Shaking Configuration

```ts
// libs/shared/src/index.ts - Optimized barrel exports
// ❌ Bad: Exports everything, prevents tree shaking
// export * from './lib/components';

// ✅ Good: Explicit exports enable tree shaking
export { ButtonComponent } from "./lib/components/button/button.component";
export { CardComponent } from "./lib/components/card/card.component";
export { ModalComponent } from "./lib/components/modal/modal.component";

// For types only
export type {
  ButtonVariant,
  ButtonSize,
} from "./lib/components/button/button.types";
```

### Lazy Loading Strategy

```ts
// apps/admin/src/app/app.routes.ts
export const routes: Routes = [
  {
    path: "",
    redirectTo: "/dashboard",
    pathMatch: "full",
  },
  {
    path: "dashboard",
    loadComponent: () =>
      import("./dashboard/dashboard.component").then(
        (m) => m.DashboardComponent
      ),
  },
  {
    path: "users",
    loadChildren: () =>
      import("@myorg/features/admin/users").then((m) => m.userRoutes),
  },
  {
    path: "products",
    loadChildren: () =>
      import("@myorg/features/billing/products").then((m) => m.productRoutes),
  },
  {
    path: "settings",
    loadComponent: () =>
      import("./settings/settings.component").then((m) => m.SettingsComponent),
  },
];
```

### Dynamic Imports for Heavy Libraries

```ts
// libs/shared/services/chart.service.ts
import { Injectable } from "@angular/core";

@Injectable({ providedIn: "root" })
export class ChartService {
  async loadChartLibrary() {
    // Lazy load heavy charting library
    const { Chart, registerables } = await import("chart.js");
    Chart.register(...registerables);
    return Chart;
  }

  async createChart(canvas: HTMLCanvasElement, config: any) {
    const Chart = await this.loadChartLibrary();
    return new Chart(canvas, config);
  }
}

// Usage in component
export class DashboardComponent {
  async loadCharts() {
    this.loading = true;

    try {
      const chart = await this.chartService.createChart(
        this.canvas,
        this.config
      );
      // Chart is ready
    } finally {
      this.loading = false;
    }
  }
}
```

### Code Splitting by Route

```ts
// angular.json - Configure bundle budgets
{
  "budgets": [
    {
      "type": "initial",
      "maximumWarning": "500kb",
      "maximumError": "1mb"
    },
    {
      "type": "anyComponentStyle",
      "maximumWarning": "2kb",
      "maximumError": "4kb"
    }
  ]
}
```

---

## 🔹 Runtime Performance

### OnPush Change Detection Strategy

```ts
// libs/shared/components/product-card/product-card.component.ts
import {
  Component,
  Input,
  Output,
  EventEmitter,
  ChangeDetectionStrategy,
} from "@angular/core";

@Component({
  selector: "app-product-card",
  standalone: true,
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <div class="card">
      <h5>{{ product.name }}</h5>
      <p>{{ product.price | currency }}</p>
      <button class="btn btn-primary" (click)="onSelect()">Select</button>
    </div>
  `,
})
export class ProductCardComponent {
  @Input() product!: Product; // Immutable input
  @Output() select = new EventEmitter<Product>();

  onSelect() {
    this.select.emit(this.product);
  }
}
```

### TrackBy Functions for \*ngFor

```ts
// libs/features/billing/products/containers/product-list.container.ts
export class ProductListContainer {
  products = signal<Product[]>([]);

  // TrackBy function for performance
  trackByProductId(index: number, product: Product): string {
    return product.id;
  }

  // Use in template
  /*
  @for (product of products(); track trackByProductId($index, product)) {
    <app-product-card [product]="product" />
  }
  */
}
```

### Optimized Computed Signals

```ts
// libs/state/product/product.store.ts
export class ProductStore {
  private _products = signal<Product[]>([]);
  private _filters = signal<ProductFilters>({
    search: "",
    category: "",
    status: "all",
  });

  // Memoized computed signal
  readonly filteredProducts = computed(() => {
    const products = this._products();
    const filters = this._filters();

    // Early return if no filters
    if (!filters.search && !filters.category && filters.status === "all") {
      return products;
    }

    return products.filter((product) => {
      if (
        filters.search &&
        !product.name.toLowerCase().includes(filters.search.toLowerCase())
      ) {
        return false;
      }

      if (filters.category && product.category !== filters.category) {
        return false;
      }

      if (filters.status !== "all" && product.status !== filters.status) {
        return false;
      }

      return true;
    });
  });

  // Derived computed signals
  readonly productCount = computed(() => this.filteredProducts().length);
  readonly hasProducts = computed(() => this.productCount() > 0);
}
```

### Async Pipe with OnPush

```ts
// libs/features/admin/users/containers/user-list.container.ts
@Component({
  selector: "app-user-list",
  standalone: true,
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    @if (users$ | async; as users) { @for (user of users; track user.id) {
    <app-user-card [user]="user" />
    } } @if (loading$ | async) {
    <div class="spinner-border"></div>
    }
  `,
})
export class UserListContainer {
  users$ = this.userService.getUsers();
  loading$ = this.userService.loading$;

  constructor(private userService: UserService) {}
}
```

---

## 🔹 Memory Management

### Automatic Subscription Management

```ts
// libs/core/utils/destroy.util.ts
import { Injectable, OnDestroy } from "@angular/core";
import { Subject } from "rxjs";

@Injectable()
export class DestroyService extends Subject<void> implements OnDestroy {
  ngOnDestroy() {
    this.next();
    this.complete();
  }
}

// Usage in components
@Component({
  providers: [DestroyService],
})
export class ExampleComponent implements OnInit {
  private destroy$ = inject(DestroyService);

  ngOnInit() {
    this.dataService
      .getData()
      .pipe(takeUntil(this.destroy$))
      .subscribe((data) => {
        // Handle data
      });
  }
}
```

### takeUntilDestroyed Operator (Angular 16+)

```ts
// Modern approach with takeUntilDestroyed
import { takeUntilDestroyed } from "@angular/core/rxjs-interop";

@Component({
  selector: "app-example",
  standalone: true,
})
export class ExampleComponent implements OnInit {
  private destroyRef = inject(DestroyRef);

  ngOnInit() {
    this.dataService
      .getData()
      .pipe(takeUntilDestroyed(this.destroyRef))
      .subscribe((data) => {
        // Automatically unsubscribed on component destroy
      });
  }
}
```

### Memory Leak Detection

```ts
// libs/core/services/memory-monitor.service.ts
@Injectable({ providedIn: "root" })
export class MemoryMonitorService {
  startMonitoring() {
    if (!this.isProduction() && "memory" in performance) {
      setInterval(() => {
        const memory = (performance as any).memory;

        if (memory) {
          console.log("Memory Usage:", {
            used: Math.round(memory.usedJSHeapSize / 1048576) + " MB",
            total: Math.round(memory.totalJSHeapSize / 1048576) + " MB",
            limit: Math.round(memory.jsHeapSizeLimit / 1048576) + " MB",
          });

          // Alert if memory usage is high
          if (memory.usedJSHeapSize / memory.jsHeapSizeLimit > 0.8) {
            console.warn("High memory usage detected!");
          }
        }
      }, 30000); // Check every 30 seconds
    }
  }

  private isProduction(): boolean {
    return !window.location.hostname.includes("localhost");
  }
}
```

---

## 🔹 Virtual Scrolling

### CDK Virtual Scrolling Implementation

```ts
// libs/shared/components/virtual-list/virtual-list.component.ts
import { Component, Input, ChangeDetectionStrategy } from "@angular/core";
import {
  CdkVirtualScrollViewport,
  CdkVirtualForOf,
} from "@angular/cdk/scrolling";

@Component({
  selector: "app-virtual-list",
  standalone: true,
  imports: [CdkVirtualScrollViewport, CdkVirtualForOf],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <cdk-virtual-scroll-viewport
      itemSize="60"
      class="virtual-scroll-viewport"
      [style.height.px]="height"
    >
      <div
        *cdkVirtualFor="let item of items; trackBy: trackByFn"
        class="virtual-item"
      >
        <ng-content
          [ngTemplateOutlet]="itemTemplate"
          [ngTemplateOutletContext]="{ $implicit: item }"
        ></ng-content>
      </div>
    </cdk-virtual-scroll-viewport>
  `,
  styles: [
    `
      .virtual-scroll-viewport {
        width: 100%;
        border: 1px solid #ccc;
      }
      .virtual-item {
        height: 60px;
        padding: 10px;
        border-bottom: 1px solid #eee;
      }
    `,
  ],
})
export class VirtualListComponent<T> {
  @Input() items: T[] = [];
  @Input() height = 400;
  @Input() trackByFn!: (index: number, item: T) => any;
  @Input() itemTemplate!: any;
}

// Usage
/*
<app-virtual-list 
  [items]="products" 
  [trackByFn]="trackByProductId"
  [itemTemplate]="productTemplate"
>
</app-virtual-list>

<ng-template #productTemplate let-product>
  <app-product-card [product]="product"></app-product-card>
</ng-template>
*/
```

---

## 🔹 Image Optimization

### Responsive Image Component

```ts
// libs/shared/components/responsive-image/responsive-image.component.ts
@Component({
  selector: "app-responsive-image",
  standalone: true,
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <picture>
      @if (webpSrc) {
      <source [srcset]="webpSrc" type="image/webp" />
      }

      <img
        [src]="src"
        [alt]="alt"
        [loading]="loading"
        [width]="width"
        [height]="height"
        class="img-fluid"
        (load)="onLoad()"
        (error)="onError()"
      />
    </picture>
  `,
})
export class ResponsiveImageComponent {
  @Input() src!: string;
  @Input() webpSrc?: string;
  @Input() alt!: string;
  @Input() width?: number;
  @Input() height?: number;
  @Input() loading: "lazy" | "eager" = "lazy";

  @Output() imageLoad = new EventEmitter<void>();
  @Output() imageError = new EventEmitter<void>();

  onLoad() {
    this.imageLoad.emit();
  }

  onError() {
    this.imageError.emit();
  }
}
```

### Image Lazy Loading Directive

```ts
// libs/shared/directives/lazy-image.directive.ts
import { Directive, ElementRef, Input, OnInit, inject } from "@angular/core";

@Directive({
  selector: "img[appLazyImage]",
  standalone: true,
})
export class LazyImageDirective implements OnInit {
  @Input() appLazyImage!: string;
  @Input() placeholder =
    "data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMzIwIiBoZWlnaHQ9IjI0MCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj48cmVjdCB3aWR0aD0iMTAwJSIgaGVpZ2h0PSIxMDAlIiBmaWxsPSIjZGRkIi8+PC9zdmc+";

  private el = inject(ElementRef<HTMLImageElement>);
  private observer?: IntersectionObserver;

  ngOnInit() {
    // Set placeholder initially
    this.el.nativeElement.src = this.placeholder;

    // Set up intersection observer
    this.observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            this.loadImage();
            this.observer?.disconnect();
          }
        });
      },
      { threshold: 0.1 }
    );

    this.observer.observe(this.el.nativeElement);
  }

  private loadImage() {
    const img = this.el.nativeElement;
    img.src = this.appLazyImage;
  }

  ngOnDestroy() {
    this.observer?.disconnect();
  }
}

// Usage: <img appLazyImage="/assets/images/product.jpg" alt="Product">
```

---

## 🔹 Network Performance

### HTTP Caching Strategy

```ts
// libs/core/interceptors/cache.interceptor.ts
import { HttpInterceptorFn, HttpResponse } from "@angular/common/http";
import { inject } from "@angular/core";
import { of, tap } from "rxjs";

export const cacheInterceptor: HttpInterceptorFn = (req, next) => {
  const cache = inject(HttpCacheService);

  // Only cache GET requests
  if (req.method !== "GET") {
    return next(req);
  }

  // Check if we should skip cache
  if (req.context.get(SKIP_CACHE)) {
    return next(req);
  }

  // Try to get from cache
  const cachedResponse = cache.get(req.urlWithParams);

  if (cachedResponse && !cache.isExpired(req.urlWithParams)) {
    return of(
      new HttpResponse({
        body: cachedResponse,
        status: 200,
        statusText: "OK",
        url: req.urlWithParams,
      })
    );
  }

  // Make request and cache response
  return next(req).pipe(
    tap((event) => {
      if (event instanceof HttpResponse) {
        cache.set(req.urlWithParams, event.body, getCacheDuration(req));
      }
    })
  );
};

function getCacheDuration(req: HttpRequest<any>): number {
  // Different cache durations for different endpoints
  if (req.url.includes("/api/config")) return 24 * 60 * 60 * 1000; // 24 hours
  if (req.url.includes("/api/users")) return 5 * 60 * 1000; // 5 minutes
  return 60 * 1000; // 1 minute default
}
```

### Request Debouncing

```ts
// libs/shared/services/debounced-search.service.ts
import { Injectable } from "@angular/core";
import { debounceTime, distinctUntilChanged, switchMap } from "rxjs/operators";
import { Subject, Observable } from "rxjs";

@Injectable({ providedIn: "root" })
export class DebouncedSearchService {
  private searchSubject = new Subject<string>();

  createSearch<T>(
    searchFn: (term: string) => Observable<T>,
    debounceMs = 300
  ): {
    search: (term: string) => void;
    results$: Observable<T>;
  } {
    const results$ = this.searchSubject.pipe(
      debounceTime(debounceMs),
      distinctUntilChanged(),
      switchMap((term) => (term ? searchFn(term) : of([] as any)))
    );

    return {
      search: (term: string) => this.searchSubject.next(term),
      results$,
    };
  }
}

// Usage in component
export class SearchComponent {
  private debouncedSearch = inject(DebouncedSearchService);

  search = this.debouncedSearch.createSearch((term: string) =>
    this.productService.searchProducts(term)
  );

  onSearchInput(event: Event) {
    const target = event.target as HTMLInputElement;
    this.search.search(target.value);
  }
}
```

---

## 🔹 Service Worker & PWA

### Service Worker Configuration

```ts
// apps/admin/src/app/app.config.ts
import { provideServiceWorker } from "@angular/service-worker";

export const appConfig: ApplicationConfig = {
  providers: [
    // Other providers...
    provideServiceWorker("ngsw-worker.js", {
      enabled: !isDevMode(),
      registrationStrategy: "registerWhenStable:30000",
    }),
  ],
};
```

### Update Service

```ts
// libs/core/services/update.service.ts
import { Injectable, inject } from "@angular/core";
import { SwUpdate, VersionReadyEvent } from "@angular/service-worker";
import { filter, map } from "rxjs/operators";

@Injectable({ providedIn: "root" })
export class UpdateService {
  private swUpdate = inject(SwUpdate);

  constructor() {
    if (this.swUpdate.isEnabled) {
      this.checkForUpdates();
    }
  }

  private checkForUpdates() {
    // Check for updates every 6 hours
    setInterval(() => {
      this.swUpdate.checkForUpdate();
    }, 6 * 60 * 60 * 1000);

    // Listen for available updates
    this.swUpdate.versionUpdates
      .pipe(
        filter((evt): evt is VersionReadyEvent => evt.type === "VERSION_READY"),
        map((evt) => ({
          type: "UPDATE_AVAILABLE",
          current: evt.currentVersion,
          available: evt.latestVersion,
        }))
      )
      .subscribe((update) => {
        if (this.promptUserForUpdate()) {
          this.swUpdate.activateUpdate().then(() => {
            document.location.reload();
          });
        }
      });
  }

  private promptUserForUpdate(): boolean {
    return confirm("A new version of the app is available. Update now?");
  }
}
```

### Background Sync for Offline Actions

```ts
// libs/core/services/offline-sync.service.ts
@Injectable({ providedIn: "root" })
export class OfflineSyncService {
  private pendingActions: Array<{ action: string; data: any }> = [];

  addPendingAction(action: string, data: any) {
    this.pendingActions.push({ action, data });
    localStorage.setItem("pendingActions", JSON.stringify(this.pendingActions));
  }

  async syncPendingActions() {
    const actions = this.getPendingActions();

    for (const action of actions) {
      try {
        await this.processAction(action);
        this.removePendingAction(action);
      } catch (error) {
        console.error("Failed to sync action:", error);
      }
    }
  }

  private getPendingActions() {
    const stored = localStorage.getItem("pendingActions");
    return stored ? JSON.parse(stored) : [];
  }

  private removePendingAction(action: any) {
    this.pendingActions = this.pendingActions.filter((a) => a !== action);
    localStorage.setItem("pendingActions", JSON.stringify(this.pendingActions));
  }

  private processAction(action: any): Promise<any> {
    // Process different types of actions
    switch (action.action) {
      case "CREATE_PRODUCT":
        return this.http.post("/api/products", action.data).toPromise();
      default:
        return Promise.resolve();
    }
  }
}
```

---

## 🔹 Performance Monitoring

### Core Web Vitals Monitoring

```ts
// libs/core/services/performance-monitor.service.ts
import { Injectable } from "@angular/core";

interface PerformanceMetric {
  name: string;
  value: number;
  timestamp: number;
}

@Injectable({ providedIn: "root" })
export class PerformanceMonitorService {
  constructor() {
    this.setupCoreWebVitalsMonitoring();
  }

  private setupCoreWebVitalsMonitoring() {
    // LCP (Largest Contentful Paint)
    this.observePerformance("largest-contentful-paint", (entry: any) => {
      this.reportMetric({
        name: "LCP",
        value: entry.startTime,
        timestamp: Date.now(),
      });
    });

    // FID (First Input Delay)
    this.observePerformance("first-input", (entry: any) => {
      this.reportMetric({
        name: "FID",
        value: entry.processingStart - entry.startTime,
        timestamp: Date.now(),
      });
    });

    // CLS (Cumulative Layout Shift)
    this.observePerformance("layout-shift", (entry: any) => {
      if (!entry.hadRecentInput) {
        this.reportMetric({
          name: "CLS",
          value: entry.value,
          timestamp: Date.now(),
        });
      }
    });
  }

  private observePerformance(type: string, callback: (entry: any) => void) {
    try {
      const observer = new PerformanceObserver((list) => {
        list.getEntries().forEach(callback);
      });

      observer.observe({ entryTypes: [type] });
    } catch (error) {
      console.warn(`Performance observer not supported for ${type}`);
    }
  }

  private reportMetric(metric: PerformanceMetric) {
    // Send to analytics service
    console.log("Performance Metric:", metric);

    // You can send to your analytics service here
    // this.analytics.track('performance_metric', metric);
  }

  // Manual performance tracking
  trackUserTiming(name: string, startTime?: number) {
    const endTime = performance.now();
    const duration = startTime ? endTime - startTime : endTime;

    performance.mark(name);

    this.reportMetric({
      name,
      value: duration,
      timestamp: Date.now(),
    });
  }

  // Route change performance
  trackRouteChange(routeName: string) {
    const startTime = performance.now();

    return () => {
      const endTime = performance.now();
      this.reportMetric({
        name: `route_${routeName}`,
        value: endTime - startTime,
        timestamp: Date.now(),
      });
    };
  }
}
```

### Bundle Size Monitoring

```ts
// tools/performance/bundle-monitor.js
const fs = require("fs");
const path = require("path");

class BundleMonitor {
  analyzeBundles(distPath) {
    const files = fs.readdirSync(distPath);
    const jsFiles = files.filter((f) => f.endsWith(".js"));

    const analysis = {
      totalSize: 0,
      bundles: [],
      timestamp: new Date().toISOString(),
    };

    jsFiles.forEach((file) => {
      const filePath = path.join(distPath, file);
      const stats = fs.statSync(filePath);

      analysis.bundles.push({
        name: file,
        size: stats.size,
        sizeKB: Math.round(stats.size / 1024),
      });

      analysis.totalSize += stats.size;
    });

    analysis.totalSizeKB = Math.round(analysis.totalSize / 1024);

    return analysis;
  }

  checkSizeLimits(analysis) {
    const warnings = [];
    const errors = [];

    // Check total bundle size
    if (analysis.totalSizeKB > 1024) {
      // 1MB
      errors.push(
        `Total bundle size (${analysis.totalSizeKB}KB) exceeds 1MB limit`
      );
    } else if (analysis.totalSizeKB > 512) {
      // 512KB
      warnings.push(
        `Total bundle size (${analysis.totalSizeKB}KB) is approaching 1MB limit`
      );
    }

    // Check individual bundle sizes
    analysis.bundles.forEach((bundle) => {
      if (bundle.name.includes("main") && bundle.sizeKB > 500) {
        errors.push(`Main bundle (${bundle.sizeKB}KB) exceeds 500KB limit`);
      }

      if (bundle.sizeKB > 200) {
        warnings.push(`Bundle ${bundle.name} (${bundle.sizeKB}KB) is large`);
      }
    });

    return { warnings, errors };
  }
}
```

---

## 🔹 Advanced Optimization Techniques

### Preloading Strategies

```ts
// apps/admin/src/app/app.config.ts
import { PreloadAllModules, Router } from "@angular/router";

// Custom preloading strategy
export class CustomPreloadingStrategy implements PreloadingStrategy {
  preload(route: Route, fn: () => Observable<any>): Observable<any> {
    // Preload based on route data
    if (route.data?.["preload"]) {
      return fn();
    }

    // Preload on network conditions
    if (this.shouldPreload()) {
      return fn();
    }

    return of(null);
  }

  private shouldPreload(): boolean {
    // Check network connection
    const connection = (navigator as any).connection;
    if (connection) {
      // Don't preload on slow connections
      return (
        connection.effectiveType !== "slow-2g" &&
        connection.effectiveType !== "2g"
      );
    }

    return true;
  }
}

export const appConfig: ApplicationConfig = {
  providers: [provideRouter(routes, withPreloading(CustomPreloadingStrategy))],
};
```

### Intersection Observer for Performance

```ts
// libs/shared/directives/viewport-trigger.directive.ts
@Directive({
  selector: "[appViewportTrigger]",
  standalone: true,
})
export class ViewportTriggerDirective implements OnInit, OnDestroy {
  @Output() inViewport = new EventEmitter<boolean>();

  private observer?: IntersectionObserver;
  private element = inject(ElementRef);

  ngOnInit() {
    this.observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          this.inViewport.emit(entry.isIntersecting);
        });
      },
      {
        threshold: 0.1,
        rootMargin: "50px",
      }
    );

    this.observer.observe(this.element.nativeElement);
  }

  ngOnDestroy() {
    this.observer?.disconnect();
  }
}

// Usage for lazy component initialization
/*
<div appViewportTrigger (inViewport)="loadComponent($event)">
  @if (shouldLoad) {
    <app-heavy-component></app-heavy-component>
  }
</div>
*/
```

---

## 🎯 Performance Testing

### Lighthouse CI Configuration

```json
// .lighthouserc.js
module.exports = {
  ci: {
    collect: {
      numberOfRuns: 3,
      url: [
        'http://localhost:4200/',
        'http://localhost:4200/dashboard',
        'http://localhost:4200/products',
      ],
    },
    assert: {
      assertions: {
        'categories:performance': ['error', { minScore: 0.9 }],
        'categories:accessibility': ['warn', { minScore: 0.9 }],
        'first-contentful-paint': ['warn', { maxNumericValue: 1500 }],
        'largest-contentful-paint': ['error', { maxNumericValue: 2500 }],
        'cumulative-layout-shift': ['error', { maxNumericValue: 0.1 }],
      },
    },
    upload: {
      target: 'temporary-public-storage',
    },
  },
};
```

### Performance Budget in CI

```yaml
# .github/workflows/performance.yml
name: Performance Budget

on:
  pull_request:
    branches: [main]

jobs:
  performance:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: "18"
          cache: "npm"

      - name: Install dependencies
        run: npm ci

      - name: Build application
        run: npm run build:prod

      - name: Run Lighthouse CI
        run: npx lhci autorun
        env:
          LHCI_GITHUB_APP_TOKEN: ${{ secrets.LHCI_GITHUB_APP_TOKEN }}

      - name: Check bundle size
        run: npm run bundle:analyze
```

---

## ✅ Performance Checklist

### 🚀 Loading Performance

- ✅ Lazy loading for routes and components
- ✅ Tree shaking and dead code elimination
- ✅ Bundle splitting and optimization
- ✅ Dynamic imports for heavy libraries
- ✅ Preloading strategies

### ⚡ Runtime Performance

- ✅ OnPush change detection strategy
- ✅ TrackBy functions for \*ngFor
- ✅ Computed signals for derived state
- ✅ Virtual scrolling for large lists
- ✅ Debounced user inputs

### 💾 Memory Management

- ✅ Automatic subscription cleanup
- ✅ Weak references for caches
- ✅ Memory leak detection
- ✅ Efficient object pooling

### 🌐 Network Performance

- ✅ HTTP caching strategies
- ✅ Request deduplication
- ✅ Compression (gzip/brotli)
- ✅ CDN for static assets

### 🎨 Rendering Performance

- ✅ Image lazy loading and optimization
- ✅ CSS containment
- ✅ Efficient animations
- ✅ Viewport-based rendering

### 📱 Mobile Performance

- ✅ Service worker caching
- ✅ Offline-first strategies
- ✅ Touch optimization
- ✅ Responsive images

### 📊 Monitoring

- ✅ Core Web Vitals tracking
- ✅ Bundle size monitoring
- ✅ Performance budgets
- ✅ Real user monitoring (RUM)
