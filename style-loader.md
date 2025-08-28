# Loader

```js
import { Injectable } from '@angular/core';

@Injectable({ providedIn: 'root' })
export class StyleLoaderService {

  private loadedBundles = new Set<string>();

  /**
   * Load any CSS bundle by name (automatically appends `.min.css`)
   */
  load(bundleName: string): Promise<void> {
    return new Promise((resolve, reject) => {
      if (this.loadedBundles.has(bundleName)) {
        resolve(); // already loaded
        return;
      }

      const link = document.createElement('link');
      link.rel = 'stylesheet';
      link.href = `${bundleName}.min.css`;
      link.id = `css-${bundleName}`;

      link.onload = () => {
        this.loadedBundles.add(bundleName);
        resolve();
      };
      link.onerror = (err) => reject(err);

      document.head.appendChild(link);
    });
  }

  /**
   * Remove a previously loaded CSS bundle
   */
  remove(bundleName: string) {
    const link = document.getElementById(`css-${bundleName}`);
    if (link) {
      link.remove();
      this.loadedBundles.delete(bundleName);
    }
  }

  /** Theme helpers */
  setTheme(theme: 'light' | 'dark' | 'purple') {
    this.load(theme).then(() => localStorage.setItem('theme', theme));
  }

    initTheme(defaultTheme = 'light') {
        const saved = localStorage.getItem('theme') as 'light' | 'dark' | 'purple' ?? defaultTheme;

        // Only load if saved theme differs from default (already included)
        if (saved !== defaultTheme) {
            this.setTheme(saved);
        }
    }
}
```

### ✅ Usage examples

**Switch theme**

```ts
this.styleLoader.setTheme("dark"); // loads dark.min.css
```

**Load other CSS (ag-grid, markdown)**

```ts
this.styleLoader.load("ag-grid"); // loads ag-grid.min.css
this.styleLoader.load("markdown"); // loads markdown.min.css
```

**Remove a bundle**

```ts
this.styleLoader.remove("markdown");
```

## Load theme

```js
export class AppComponent {
    constructor(private styleLoader: StyleLoaderService) {
        this.styleLoader.initTheme(); // safely loads only if needed
    }
}
```
