# Interfaces

## 1️⃣ Folder Naming

```
interfaces/       # or types/
├─ user.interface.ts
├─ role.interface.ts
├─ auth.interface.ts
├─ theme.interface.ts
├─ notification.interface.ts
└─ index.ts
```

## 2️⃣ Examples

### **user.interface.ts**

```ts
export interface User {
  id: number;
  name: string;
  email: string;
  roles: Role[];
}
```

### **role.interface.ts**

```ts
export type Role = "ADMIN" | "LAB" | "BILLING" | "GUEST";
```

### **auth.interface.ts**

```ts
export interface LoginResponse {
  token: string;
  user: User;
}
```

### **notification.interface.ts**

```ts
export interface Notification {
  id: string;
  message: string;
  type: "success" | "error" | "info";
  createdAt: Date;
}
```

### **theme.interface.ts**

```ts
export type Theme = "light" | "dark" | "purple";
```

---

## 3️⃣ Usage Across Apps

```ts
import type { User, Role } from "@myorg/interfaces/user.interface";
import type { Theme } from "@myorg/interfaces/theme.interface";
import type { Notification } from "@myorg/interfaces/notification.interface";

// Example usage in signals
import { signal } from "@angular/core";
export const userSignal = signal<User | null>(null);
export const notificationsSignal = signal<Notification[]>([]);
export const themeSignal = signal<Theme>("light");
```

---

## 4️⃣ Benefits of `interfaces/` / `types/` approach

- Makes **intent clear**: these are **type definitions only**, no runtime logic.
- Works seamlessly with **signals**, services, and HTTP DTOs.
- Easy to import across multiple apps (admin, lab, billing).
- Helps maintain **consistent typing** in API responses, state, and components.

---

### ✅ Recommended naming

- `interfaces/` → primarily `interface` definitions
- `types/` → for `type` aliases, unions, or mapped types
- Optional: `dto/` → if you want to separate **API request/response DTOs**
