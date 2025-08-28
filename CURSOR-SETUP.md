# 🎯 Cursor IDE Setup for Realworld Angular Patterns

Modern Cursor IDE setup using the new `.mdc` format that inherits from official Angular 20 patterns.

## 🚀 Quick Setup

### Option 1: Copy Both .mdc Files (Recommended)

```bash
# In your Angular project root:
curl -O https://raw.githubusercontent.com/hs2504785/realworld-patterns/main/angular-20.mdc
curl -O https://raw.githubusercontent.com/hs2504785/realworld-patterns/main/realworld-patterns.mdc
```

### Option 2: Individual Files

```bash
# If you already have angular-20.mdc, just add our patterns:
curl -O https://raw.githubusercontent.com/hs2504785/realworld-patterns/main/realworld-patterns.mdc
```

## 📁 File Structure in Your Project

Your Angular project should have these Cursor rule files:

```
your-angular-project/
├── angular-20.mdc              # Official Angular 20 patterns
├── realworld-patterns.mdc      # Enterprise patterns (inherits from angular-20.mdc)
└── src/
    ├── apps/
    ├── libs/
    └── ...
```

## 🎯 What Each File Does

| File                     | Purpose                                | Inheritance            |
| ------------------------ | -------------------------------------- | ---------------------- |
| `angular-20.mdc`         | Official Angular 20 best practices     | Base patterns          |
| `realworld-patterns.mdc` | Enterprise patterns + folder structure | Extends angular-20.mdc |

## ✅ Verification

After setup, Cursor will automatically:

1. ✅ Follow Angular 20 best practices (standalone components, signals, etc.)
2. ✅ Enforce enterprise folder structure (`/apps`, `/libs/core`, `/libs/features`)
3. ✅ Use Bootstrap 5 classes only (no custom CSS)
4. ✅ Respect dependency boundaries (core ← shared ← features)
5. ✅ Generate proper auth guards and error handling
6. ✅ Implement lazy loading patterns

## 🔧 Team Usage

### For New Projects:

```bash
# Setup new Angular project with patterns
ng new my-project
cd my-project

# Add Cursor rules
curl -O https://raw.githubusercontent.com/hs2504785/realworld-patterns/main/angular-20.mdc
curl -O https://raw.githubusercontent.com/hs2504785/realworld-patterns/main/realworld-patterns.mdc

# Start coding - Cursor will follow patterns automatically!
```

### For Existing Projects:

```bash
# Add to existing project
curl -O https://raw.githubusercontent.com/hs2504785/realworld-patterns/main/realworld-patterns.mdc

# Cursor will start enforcing patterns for new code
```

## 🆕 Modern .mdc Format Benefits

The `.mdc` format provides:

- **Inheritance**: `realworld-patterns.mdc` inherits from `angular-20.mdc`
- **Better Organization**: Structured metadata and descriptions
- **Official Support**: Built on Cursor's official Angular 20 patterns
- **Automatic Updates**: When Angular patterns update, you get them automatically
- **Future-Proof**: Modern standard that will continue to evolve

## 📝 Example Generated Code

With these rules, Cursor will generate code like:

```typescript
// Automatic enterprise patterns
@Component({
  selector: "app-user-list",
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <div class="container-fluid">
      @if (loading()) {
      <div class="spinner-border"></div>
      } @for (user of users(); track user.id) {
      <div class="card">{{ user.name }}</div>
      }
    </div>
  `,
})
export class UserListComponent {
  // Signals for reactive state
  users = signal<User[]>([]);
  loading = signal(false);

  // Inject function (Angular 20 pattern)
  private userService = inject(UserService);
}
```

## 🔄 Keeping Updated

```bash
# Update to latest patterns
curl -O https://raw.githubusercontent.com/hs2504785/realworld-patterns/main/realworld-patterns.mdc
```

## 🆘 Troubleshooting

**Q: Cursor not following patterns?**

- Make sure `.mdc` files are in project root
- Restart Cursor IDE
- Check file names are exact: `angular-20.mdc` and `realworld-patterns.mdc`

**Q: Inheritance not working?**

- Ensure both `angular-20.mdc` and `realworld-patterns.mdc` are present
- Check the `inherits: ["angular-20.mdc"]` line in `realworld-patterns.mdc`

**Q: Why use .mdc instead of .cursorrules?**

- `.mdc` format is the modern Cursor standard
- Supports inheritance from official Angular patterns
- Better organization and metadata support

---

**Ready!** Your Cursor IDE will now automatically follow enterprise Angular patterns while building on official Angular 20 best practices. 🎉
