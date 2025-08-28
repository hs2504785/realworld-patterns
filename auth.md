# Auth

## 1️⃣ Purpose of `AuthModule`

Following [Angular's security best practices](https://angular.dev/best-practices/security):

- Encapsulates all **authentication-related services, guards, interceptors, and components**.
- Makes it **reusable across multiple apps** (admin, lab, billing).
- Avoids having to declare or import auth services repeatedly in each app module.
- Implements Angular's recommended XSRF/CSRF protection patterns
- Uses Angular's built-in DomSanitizer for XSS prevention

---

```
auth/
├─ components/            # Standalone UI components
│   ├─ login-form/
│   │   ├─ login-form.component.ts   # standalone: true
│   │   └─ login-form.component.html
│   └─ logout-button/
│       ├─ logout-button.component.ts
│       └─ logout-button.component.html
├─ services/              # Singleton services
│   ├─ auth.service.ts           # login/logout/session
│   ├─ token.service.ts          # JWT storage, refresh
│   └─ session.service.ts        # Optional session handling
├─ guards/                # Standalone route guards
│   ├─ auth.guard.ts            # CanActivateFn
│   └─ role.guard.ts            # CanActivateFn for role-based access
├─ interceptors/
│   └─ auth.interceptor.ts       # HTTP interceptor for JWT
├─ models/                # Data models / enums
│   ├─ user.model.ts
│   └─ roles.model.ts
├─ utils/                 # Helper functions
│   └─ jwt.helper.ts
└─ index.ts               # Barrel file for easy imports
```

---

### Notes on Angular 20 Standalone Usage

1. **Components**

   - Use `standalone: true`
   - Import required Angular modules locally (`CommonModule`, `FormsModule`, etc.)
   - Export nothing here; they are imported directly in routes or parent components.

2. **Services**

   - Provided via `@Injectable({ providedIn: 'root' })` → singleton automatically.

3. **Guards**

   - Use **functional guards**: `CanActivateFn` with `inject()`.
   - No need to declare in a module.

4. **Interceptors**

   - Register at **bootstrapApplication** using `provideHttpClient(withInterceptors([...]))`.
   - No NgModule required.

5. **Models / Utils**

   - Standard TS files; imported wherever needed.

6. **index.ts**

   - Optional barrel to export all services, guards, and components for cleaner imports in apps.

---

### Example App Integration

**App routing (admin/lab/billing)**

```ts
import { Routes } from "@angular/router";
import { LoginFormComponent } from "@myorg/auth/components/login-form/login-form.component";
import { authGuard } from "@myorg/auth/guards/auth.guard";

export const routes: Routes = [
  { path: "login", component: LoginFormComponent },
  {
    path: "dashboard",
    component: DashboardComponent,
    canActivate: [authGuard],
  },
];
```

**App bootstrap**

```ts
import { provideHttpClient, withInterceptors } from "@angular/common/http";
import { AuthInterceptor } from "@myorg/auth/interceptors/auth.interceptor";

bootstrapApplication(AppComponent, {
  providers: [provideHttpClient(withInterceptors([AuthInterceptor]))],
});
```

---

## 🔒 Angular Built-in Security Features

### XSRF/CSRF Protection (Angular Official)

Angular provides built-in XSRF protection that complements our auth setup:

```ts
// app.config.ts - Configure XSRF protection
export const appConfig: ApplicationConfig = {
  providers: [
    provideHttpClient(
      withInterceptors([authInterceptor]),
      withXsrfConfiguration({
        cookieName: "XSRF-TOKEN",
        headerName: "X-XSRF-TOKEN",
      })
    ),
  ],
};
```

### Sanitization Integration

```ts
// libs/auth/services/auth.service.ts
import { DomSanitizer } from "@angular/platform-browser";

@Injectable({ providedIn: "root" })
export class AuthService {
  private sanitizer = inject(DomSanitizer);

  sanitizeUserProfile(profile: any) {
    // Use Angular's built-in sanitization
    return {
      ...profile,
      bio: this.sanitizer.sanitize(SecurityContext.HTML, profile.bio),
      website: this.sanitizer.sanitize(SecurityContext.URL, profile.website),
    };
  }
}
```

These Angular features work seamlessly with our enterprise security patterns.
