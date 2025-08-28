# Enterprise Angular 20 + Nx Monorepo Architecture

A comprehensive, production-ready monorepo specification for real-world Angular applications using the latest Angular 20 features, Nx workspace management, and enterprise-grade architectural patterns.

## 🚀 Quick Start

This specification defines a scalable architecture for Angular applications using:

- **Angular 20** with standalone components and modern APIs
- **Nx** for workspace management and build optimization
- **Bootstrap 5** for consistent UI design system
- **Modern state management** with signals and services
- **Micro-frontend ready** architecture with clear boundaries

## 📁 Project Structure Overview

```
/apps                    # Application entry points
  ├─ admin/             # Admin portal application
  ├─ lab/               # Laboratory management app
  └─ billing/           # Billing and invoicing app

/libs                    # Reusable libraries
  ├─ core/              # Global singletons and infrastructure
  ├─ shared/            # Reusable UI components and utilities
  ├─ styles/            # Design system and SCSS framework
  ├─ auth/              # Authentication and authorization
  ├─ state/             # Global state management
  ├─ utils/             # Pure utility functions
  ├─ interfaces/        # TypeScript type definitions
  ├─ i18n/              # Internationalization
  └─ features/          # Domain-driven feature modules
      ├─ admin/         # Admin domain features
      ├─ lab/           # Lab domain features
      └─ billing/       # Billing domain features
```

## 🎯 Key Architectural Principles

- **Domain-Driven Design**: Features organized by business domains
- **Dependency Boundaries**: Strict rules preventing circular dependencies
- **Standalone Components**: Leveraging Angular 20's standalone architecture
- **Lazy Loading**: Optimized bundle splitting for performance
- **Design System**: Consistent UI/UX with Bootstrap 5 integration
- **Type Safety**: Comprehensive TypeScript interfaces and types

## 📚 Documentation Index

| Document                                                 | Description                                |
| -------------------------------------------------------- | ------------------------------------------ |
| [spec.md](./spec.md)                                     | Detailed folder structure specification    |
| [apps.md](./apps.md)                                     | Application architecture and routing       |
| [core.md](./core.md)                                     | Core infrastructure and services           |
| [auth.md](./auth.md)                                     | Authentication and authorization patterns  |
| [features.md](./features.md)                             | Feature module organization and boundaries |
| [shared.md](./shared.md)                                 | Shared UI components library               |
| [styles.md](./styles.md)                                 | Design system and SCSS architecture        |
| [theme.md](./theme.md)                                   | Theming system and runtime switching       |
| [interfaces.md](./interfaces.md)                         | TypeScript type definitions                |
| [i18n.md](./i18n.md)                                     | Internationalization strategy              |
| [utils.md](./utils.md)                                   | Utility functions and helpers              |
| [state.md](./state.md)                                   | State management patterns                  |
| [testing.md](./testing.md)                               | Testing strategies and patterns            |
| [security.md](./security.md)                             | Security best practices                    |
| [performance.md](./performance.md)                       | Performance optimization guidelines        |
| [build-deploy.md](./build-deploy.md)                     | Build and deployment configuration         |
| [architecture.md](./architecture.md)                     | Visual architecture diagrams and patterns  |
| [angular-best-practices.md](./angular-best-practices.md) | Enterprise extensions to Angular patterns  |
| [best-practices.md](./best-practices.md)                 | Project coding preferences for Angular 20  |

## 🛠 Technology Stack

- **Frontend**: Angular 20, TypeScript 5+
- **Styling**: Bootstrap 5, SCSS, CSS Custom Properties
- **Build**: Nx, Webpack 5, Vite (for dev)
- **State**: Angular Signals, Services
- **Testing**: Jest, Cypress, Angular Testing Library
- **Linting**: ESLint, Prettier, Stylelint

## 🎨 Design System

Built on Bootstrap 5 with custom design tokens:

- Consistent spacing, typography, and color schemes
- Light/Dark/Purple theme support
- Responsive grid system
- Accessible components

## 🔒 Security Features

- JWT-based authentication
- Role-based access control (RBAC)
- HTTP interceptors for security headers
- Input validation and sanitization
- CSP (Content Security Policy) ready

## 📊 Performance Optimizations

- Tree-shakable libraries
- Lazy-loaded feature modules
- Optimized bundle splitting
- Efficient change detection strategies
- Service worker ready

## 🌍 Internationalization

- Lazy-loaded translation bundles
- Feature-specific translations
- Angular i18n compatible
- RTL language support ready

## 🧪 Testing Strategy

- Unit tests with Jest
- Integration tests with Angular Testing Library
- E2E tests with Cypress
- Component testing in isolation

## 🚀 Getting Started

1. **Review the Architecture**: Start with [spec.md](./spec.md) for the complete structure
2. **Understand Boundaries**: Check [features.md](./features.md) for dependency rules
3. **Setup Styling**: Review [styles.md](./styles.md) and [theme.md](./theme.md)
4. **Configure Auth**: Implement patterns from [auth.md](./auth.md)
5. **Add Features**: Follow guidelines in [features.md](./features.md)

## 🎯 For LLMs and AI Development

See [llm-context.md](./llm-context.md) for a comprehensive context file optimized for AI-assisted development and code generation.

## 📦 Reusing Across Projects & Frameworks

Want to use these patterns in multiple projects? Here are the most effective approaches:

### 🎭 **GitHub Template** (Recommended - Fastest Start)

```bash
# Create framework-specific templates
gh repo create my-angular-project --template yourorg/realworld-patterns-angular
gh repo create my-react-project --template yourorg/realworld-patterns-react
```

### 📦 **NPM Package** (For Shared Code)

```bash
npm install @yourorg/realworld-patterns

# Framework-specific imports
import { EnterpriseStore } from '@yourorg/realworld-patterns/angular';
import { useEnterpriseStore } from '@yourorg/realworld-patterns/react';
import { validateInput } from '@yourorg/realworld-patterns/shared';
```

### 📚 **Documentation Site** (For Reference)

Host these docs on GitHub Pages, Netlify, or any static site host for team reference.

> 🌟 **Framework Flexibility**: While examples use Angular 20, these enterprise patterns adapt beautifully to React, Vue, and other modern frameworks!

| Pattern              | Angular             | React         | Vue         | Universal     |
| -------------------- | ------------------- | ------------- | ----------- | ------------- |
| **Folder Structure** | ✅ Direct           | ✅ Adapted    | ✅ Adapted  | ✅ Principles |
| **Domain Design**    | ✅                  | ✅            | ✅          | ✅            |
| **State Management** | Signals             | Zustand/Redux | Pinia       | ✅ Patterns   |
| **Security**         | Guards/Interceptors | HOCs/Hooks    | Composables | ✅ Validation |

## 🤝 Contributing

This documentation is designed to stay current with Angular's latest patterns:

- **Primary Reference**: Always check [Angular's official docs](https://angular.dev/context/llm-files/llms-full.txt) first
- **Keep Current**: Feel free to update patterns when Angular releases new features
- **Share Knowledge**: Submit PRs to improve examples and patterns

## 🌟 Angular Official Guidelines Integration

This specification follows and extends [Angular's official best practices](https://angular.dev/style-guide):

- **File naming conventions** from Angular's style guide
- **Project structure** following Angular's recommendations
- **Security patterns** based on Angular's security guide
- **Performance optimizations** aligned with Angular's performance guide
- **Testing strategies** using Angular's testing utilities

See [angular-best-practices.md](./angular-best-practices.md) for detailed integration of official Angular patterns with our enterprise architecture.

---

**Built for Enterprise Scale** • **Modern Angular Best Practices** • **Production Ready**
