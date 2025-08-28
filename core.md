## Core

```
/libs/core
  ├─ src/
  │  ├─ lib/
  │  │  ├─ initializers/                # APP_INITIALIZER and bootstrap wiring
  │  │  │  ├─ app-init.provider.ts
  │  │  │  └─ sentry-init.provider.ts
  │  │  ├─ interceptors/               # HttpClient interceptors (global)
  │  │  │  ├─ error.interceptor.ts
  │  │  │  ├─ retry.interceptor.ts
  │  │  │  ├─ timeout.interceptor.ts
  │  │  │  ├─ cache.interceptor.ts
  │  │  │  ├─ correlation-id.interceptor.ts
  │  │  │  ├─ lang.interceptor.ts
  │  │  │  ├─ content-type.interceptor.ts
  │  │  │  └─ logging.interceptor.ts
  │  │  ├─ guards/                     # Generic, cross-app route guards
  │  │  │  ├─ feature-flag.guard.ts
  │  │  │  ├─ network.guard.ts
  │  │  │  └─ unsaved-changes.guard.ts
  │  │  ├─ resolvers/                  # Cross-app resolvers
  │  │  │  └─ app-config.resolver.ts
  │  │  ├─ handlers/                   # Global Angular handlers
  │  │  │  └─ global-error.handler.ts
  │  │  ├─ services/                   # Core singletons
  │  │  │  ├─ config.service.ts        # runtime config (assets/config.json)
  │  │  │  ├─ logger.service.ts        # pluggable logger
  │  │  │  ├─ error.service.ts         # error mapping/reporting
  │  │  │  ├─ http-cache.service.ts    # in-memory cache
  │  │  │  ├─ connectivity.service.ts  # online/offline, network status
  │  │  │  ├─ storage.service.ts       # platform-safe storage abstraction
  │  │  │  ├─ platform.service.ts      # SSR/browser detection
  │  │  │  ├─ feature-flags.service.ts # flags provider
  │  │  │  └─ analytics.service.ts     # optional analytics facade
  │  │  ├─ tokens/                     # DI tokens (do NOT confuse w/ SCSS tokens)
  │  │  │  ├─ api-base-url.token.ts
  │  │  │  ├─ app-config.token.ts
  │  │  │  ├─ app-name.token.ts
  │  │  │  ├─ feature-flags.token.ts
  │  │  │  └─ logger.token.ts
  │  │  ├─ operators/                  # Reusable RxJS/Signals helpers
  │  │  │  ├─ retry-with-backoff.ts
  │  │  │  └─ catch-and-report.ts
  │  │  ├─ utils/                      # Tiny pure helpers used only by core
  │  │  │  ├─ http-context.util.ts     # SKIP_CACHE, REQUIRE_AUTH, TIMEOUT…
  │  │  │  └─ http-params.util.ts
  │  │  ├─ providers.ts                # `provideCore()` aggregator
  │  │  └─ index.ts
  │  └─ public-api.ts
  └─ project.json
```

> 🔒 **Auth-specific logic** (JWT, `AuthGuard`, token interceptor) should live in `/libs/auth`. If you already created those in `core`, move them to `auth` and wire via tokens (e.g., a `SESSION_TOKEN_PROVIDER`) so `core` stays auth-agnostic.

---

### 🧩 What lives here (and why)

- **initializers/**: all `APP_INITIALIZER` providers (e.g., load runtime config, init logging/monitoring before app boots).
- **interceptors/**: network cross-cutting concerns usable by every app/feature:

  - `error.interceptor` → map HTTP errors to domain errors; delegate to `ErrorService`.
  - `retry.interceptor` → backoff retry for idempotent GETs (via context opt-in).
  - `timeout.interceptor` → per-request timeout using `HttpContext`.
  - `cache.interceptor` → stale-while-revalidate in-memory cache (context opt-in/out).
  - `correlation-id.interceptor` → inject request ID header; propagate from server if provided.
  - `lang.interceptor` → attach `Accept-Language`/`X-Locale` from i18n service.
  - `content-type.interceptor` → set default `Content-Type` if missing.
  - `logging.interceptor` → debug logs in dev only.

- **guards/**: generic guards that don’t depend on a specific domain (auth guards go in `/libs/auth`).
- **resolvers/**: e.g., `app-config.resolver` to guarantee config before entering certain routes.
- **handlers/**: `GlobalErrorHandler` top-level error capture.
- **services/**: singletons used across apps (config, logger, cache, connectivity, storage abstraction, platform, feature flags, analytics).
- **tokens/**: DI tokens to decouple implementations (e.g., provide a different `Logger` in dev/prod).
- **operators/**: reusable RxJS helpers (`retryWithBackoff`, `catchAndReport`).
- **providers.ts**: a single function you call from each app to wire core once.
- **utils/**: small helpers (e.g., declare `HttpContextToken`s).

---

### 🧪 Sample Snippets (short, practical)

### 1) `providers.ts` – one-stop wiring

```ts
// libs/core/src/lib/providers.ts
import { EnvironmentProviders, makeEnvironmentProviders } from "@angular/core";
import {
  HttpClientModule,
  provideHttpClient,
  withInterceptors,
} from "@angular/common/http";
import { GlobalErrorHandler } from "./handlers/global-error.handler";
import { ErrorHandler } from "@angular/core";
import { provideCoreInterceptors } from "./interceptors/_provide";
import { provideCoreInitializers } from "./initializers/app-init.provider";
import { LoggerToken, createConsoleLogger } from "./tokens/logger.token";
import { API_BASE_URL } from "./tokens/api-base-url.token";

export interface CoreOptions {
  apiBaseUrl: string;
  appName: string;
}

export function provideCore(opts: CoreOptions): EnvironmentProviders {
  return makeEnvironmentProviders([
    HttpClientModule,
    provideHttpClient(withInterceptors(provideCoreInterceptors())),
    { provide: ErrorHandler, useClass: GlobalErrorHandler },
    provideCoreInitializers(opts),
    {
      provide: LoggerToken,
      useFactory: () => createConsoleLogger(opts.appName),
    },
    { provide: API_BASE_URL, useValue: opts.apiBaseUrl },
  ]);
}
```

### 2) Interceptor registration helper

```ts
// libs/core/src/lib/interceptors/_provide.ts
import { HttpInterceptorFn } from "@angular/common/http";
import { errorInterceptor } from "./error.interceptor";
import { retryInterceptor } from "./retry.interceptor";
import { timeoutInterceptor } from "./timeout.interceptor";
import { cacheInterceptor } from "./cache.interceptor";
import { correlationIdInterceptor } from "./correlation-id.interceptor";
import { langInterceptor } from "./lang.interceptor";
import { loggingInterceptor } from "./logging.interceptor";

export function provideCoreInterceptors(): HttpInterceptorFn[] {
  return [
    correlationIdInterceptor,
    langInterceptor,
    timeoutInterceptor,
    retryInterceptor,
    cacheInterceptor,
    errorInterceptor,
    loggingInterceptor,
  ];
}
```

### 3) Context flags (opt-in/out per request)

```ts
// libs/core/src/lib/utils/http-context.util.ts
import { HttpContextToken } from "@angular/common/http";

export const SKIP_CACHE = new HttpContextToken<boolean>(() => false);
export const RETRY_ENABLED = new HttpContextToken<boolean>(() => true);
export const TIMEOUT_MS = new HttpContextToken<number>(() => 15000);
```

Usage:

```ts
this.http.get(url, { context: new HttpContext().set(SKIP_CACHE, true) });
```

### 4) Runtime config initializer

```ts
// libs/core/src/lib/initializers/app-init.provider.ts
import { APP_INITIALIZER } from "@angular/core";
import { ConfigService } from "../services/config.service";
import { CoreOptions } from "../providers";

export function provideCoreInitializers(opts: CoreOptions) {
  return {
    provide: APP_INITIALIZER,
    multi: true,
    useFactory: (cfg: ConfigService) => () => cfg.load(opts),
    deps: [ConfigService],
  };
}
```

`ConfigService.load()` can fetch `/assets/config.${env}.json` and expose typed config.

### 5) Global error handler

```ts
// libs/core/src/lib/handlers/global-error.handler.ts
import { ErrorHandler, inject, Injectable } from "@angular/core";
import { LoggerToken } from "../tokens/logger.token";

@Injectable()
export class GlobalErrorHandler implements ErrorHandler {
  private logger = inject(LoggerToken);
  handleError(err: unknown) {
    this.logger.error("Unhandled error", { err });
    // Optionally forward to monitoring service via Analytics/ErrorService
  }
}
```

### 6) Feature flags service + token

```ts
// libs/core/src/lib/tokens/feature-flags.token.ts
import { InjectionToken } from "@angular/core";
export interface FeatureFlags {
  [key: string]: boolean;
}
export const FEATURE_FLAGS = new InjectionToken<FeatureFlags>("FEATURE_FLAGS");
```

```ts
// libs/core/src/lib/services/feature-flags.service.ts
import { inject, Injectable } from "@angular/core";
import { FEATURE_FLAGS, FeatureFlags } from "../tokens/feature-flags.token";

@Injectable({ providedIn: "root" })
export class FeatureFlagsService {
  private flags = inject(FEATURE_FLAGS, { optional: true }) ?? {};
  isOn(key: string) {
    return !!this.flags[key];
  }
}
```

### 7) Cache interceptor (sketch)

```ts
// libs/core/src/lib/interceptors/cache.interceptor.ts
import { HttpInterceptorFn, HttpResponse } from "@angular/common/http";
import { inject } from "@angular/core";
import { HttpCacheService } from "../services/http-cache.service";
import { SKIP_CACHE } from "../utils/http-context.util";
import { tap, of } from "rxjs";

export const cacheInterceptor: HttpInterceptorFn = (req, next) => {
  const cache = inject(HttpCacheService);
  if (req.method !== "GET" || req.context.get(SKIP_CACHE)) return next(req);

  const hit = cache.get(req.urlWithParams);
  if (hit)
    return of(
      new HttpResponse({ status: 200, body: hit, url: req.urlWithParams })
    );

  return next(req).pipe(
    tap((event) => {
      if (event instanceof HttpResponse)
        cache.set(req.urlWithParams, event.body);
    })
  );
};
```

---

### 🧭 Boundaries & What **Not** to put in `core`

- ❌ **Domain API clients** → put in each domain’s `data-access` lib.
- ❌ **State stores** → use `/libs/state` (global) or `/libs/{app}/state` (app-level) or feature’s own `state/`.
- ❌ **Auth specifics** (JWT, login guard, token interceptor) → `/libs/auth`.
- ❌ **Presentational UI** → `/libs/shared/ui` or domain feature libs.

---

## 🧱 Nx tags (suggested)

- `core`: can be imported by `apps`, `auth`, `shared`, `features/*`, `state`, `styles`. Depends on no `features/*`.
- `auth`: may depend on `core`, `state`, `shared`, `util`.
- `features/*`: may depend on `core`, `auth`, `state`, `shared`, `styles`, `util`, `models`, but **not** other `features/*`.

(Enforce with `@nx/enforce-module-boundaries` in `eslint`.)

---

## ⚙️ App usage (standalone bootstrap)

```ts
// apps/billing/src/main.ts
bootstrapApplication(AppComponent, {
  providers: [
    provideRouter(appRoutes),
    provideCore({ appName: "billing", apiBaseUrl: environment.apiBaseUrl }),
    // provideAuth(), provideI18n(), provideStyles()...
  ],
});
```
