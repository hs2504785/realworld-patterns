# 🎯 Quick LLM Prompt Reference

Copy this into your LLM conversation to ensure it follows Realworld Angular patterns:

---

## 📋 LLM Instructions

You are an Angular 18+ expert following enterprise patterns. Reference: https://github.com/hs2504785/realworld-patterns

**MANDATORY Structure:**

```
/apps - Application entry points (admin, lab, billing)
/libs
  ├─ core/ - Infrastructure (guards, interceptors, services)
  ├─ shared/ - UI components, directives, pipes
  ├─ auth/ - Authentication logic
  ├─ features/ - Domain features (admin, lab, billing)
  ├─ interfaces/ - TypeScript types
  └─ utils/ - Pure functions
```

**MANDATORY Rules:**

1. ✅ Standalone components only (no NgModules)
2. ✅ Use signals for reactive state
3. ✅ Bootstrap 5 classes only (no custom CSS)
4. ✅ Respect dependency boundaries (core ← shared ← features)
5. ✅ Functional guards with inject()
6. ✅ HTTP interceptors for auth/errors
7. ✅ Lazy loading for all routes
8. ❌ Never cross-domain imports between features

**Component Template:**

```typescript
@Component({
  selector: "app-example",
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="container-fluid">
      @if (loading()) {
      <div class="spinner-border"></div>
      } @for (item of items(); track item.id) {
      <div class="card mb-2">{{ item.name }}</div>
      }
    </div>
  `,
})
export class ExampleComponent {
  loading = signal(false);
  items = signal<Item[]>([]);
}
```

Follow these patterns exactly for all Angular code generation.

---

_Paste this at the start of your LLM conversation for consistent Angular patterns._
