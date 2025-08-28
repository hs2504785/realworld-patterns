# Utils

`util/` is for **pure helper functions and reusable utilities** that are **app-agnostic**. These are not Angular services per se, just reusable code that multiple apps/modules can use.

---

## 1️⃣ Suggested `util/` Folder Structure

```
util/
├─ rxjs/                # reusable RxJS operators & helpers
│   ├─ error-handler.ts       # catchError helper
│   ├─ unsubscribe.ts         # auto unsubscribe helper
│   └─ retry-logic.ts         # custom retry operators
├─ date/                # date & time utilities
│   ├─ format-date.ts         # format to yyyy-mm-dd, locale, etc.
│   ├─ parse-date.ts          # string -> Date conversion
│   └─ relative-time.ts       # e.g., '2 hours ago'
├─ string/              # string helpers
│   ├─ slugify.ts             # generate URL-friendly slugs
│   ├─ capitalize.ts          # capitalize first letter
│   └─ truncate.ts            # truncate text safely
├─ number/              # numeric utilities
│   ├─ currency.ts            # format number as currency
│   ├─ round.ts               # rounding helpers
│   └─ percentage.ts          # percentage calculations
├─ array/               # array helpers
│   ├─ group-by.ts            # group array by key
│   ├─ unique.ts              # remove duplicates
│   └─ sort-by.ts             # custom sort function
├─ object/              # object utilities
│   ├─ deep-clone.ts           # clone nested objects
│   ├─ merge.ts                # deep merge
│   └─ pick.ts                 # pick selected keys
└─ index.ts             # barrel for all util exports
```

---

## 2️⃣ Example Implementations

### **rxjs/error-handler.ts**

```ts
import { catchError, throwError } from "rxjs";

export const handleApiError = (fn: string) =>
  catchError((error: any) => {
    console.error(`Error in ${fn}:`, error);
    return throwError(() => error);
  });
```

### **date/format-date.ts**

```ts
export const formatDate = (date: Date | string, locale = "en-US") => {
  return new Date(date).toLocaleDateString(locale, {
    year: "numeric",
    month: "short",
    day: "numeric",
  });
};
```

### **string/slugify.ts**

```ts
export const slugify = (str: string) =>
  str
    .toLowerCase()
    .trim()
    .replace(/\s+/g, "-")
    .replace(/[^\w-]+/g, "");
```

### **array/group-by.ts**

```ts
export const groupBy = <T>(arr: T[], key: keyof T) =>
  arr.reduce((acc, item) => {
    const k = String(item[key]);
    (acc[k] = acc[k] || []).push(item);
    return acc;
  }, {} as Record<string, T[]>);
```

---

## 3️⃣ How it’s used across apps

```ts
import { slugify } from "@myorg/util/string";
import { formatDate } from "@myorg/util/date";
import { handleApiError } from "@myorg/util/rxjs";

const slug = slugify("Hello World"); // hello-world
const dateStr = formatDate(new Date());
```

- No Angular dependencies → fully reusable across **admin, lab, billing** apps.
- Promotes **DRY** for common operations (dates, strings, arrays, objects, numbers).
- Can also include **pure TypeScript constants** like regex patterns, magic numbers, or config helpers.

---

## 4️⃣ Optional Enhancements

1. **Create a `pipe/` folder** inside `util/` for reusable **Angular pipes** (like date, currency, truncate) if you want UI-level helpers.
2. **Combine `rxjs` helpers** for auto-unsubscribe or retry logic.
3. **Make `index.ts` barrel file** so you can import everything like:

```ts
import { slugify, formatDate, handleApiError } from "@myorg/util";
```
