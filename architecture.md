# Architecture Overview

Visual representation and detailed explanation of the Angular 20 + Nx monorepo architecture with dependency relationships and design patterns.

## 🏗️ System Architecture Diagram

```mermaid
graph TB
    subgraph "Apps Layer"
        A1[Admin App<br/>User Management<br/>Settings]
        A2[Lab App<br/>Experiments<br/>Reports]
        A3[Billing App<br/>Products<br/>Invoices]
    end

    subgraph "Infrastructure Libraries"
        C1[Core<br/>• Interceptors<br/>• Guards<br/>• Services<br/>• Error Handling]
        A4[Auth<br/>• JWT Tokens<br/>• Role Guards<br/>• Session Mgmt]
        ST1[Styles<br/>• Design Tokens<br/>• Themes<br/>• SCSS Utils]
    end

    subgraph "Shared Libraries"
        S1[Shared UI<br/>• Components<br/>• Directives<br/>• Pipes]
        S2[Utils<br/>• Date Helpers<br/>• String Utils<br/>• RxJS Operators]
        I1[Interfaces<br/>• Type Definitions<br/>• DTOs<br/>• Models]
        I2[i18n<br/>• Translations<br/>• Localization]
    end

    subgraph "State Management"
        ST2[Global State<br/>• User Store<br/>• Theme Store<br/>• Notifications]
    end

    subgraph "Feature Libraries"
        F1[Admin Features<br/>• Users<br/>• Roles<br/>• Audit]
        F2[Lab Features<br/>• Experiments<br/>• Reports]
        F3[Billing Features<br/>• Products<br/>• Invoices<br/>• Reports]
    end

    subgraph "External Services"
        API[REST API<br/>Backend Services]
        AUTH[Auth Provider<br/>OAuth/OIDC]
        CDN[CDN<br/>Static Assets]
    end

    %% App dependencies
    A1 --> C1
    A1 --> A4
    A1 --> S1
    A1 --> ST1
    A1 --> ST2
    A1 --> F1

    A2 --> C1
    A2 --> A4
    A2 --> S1
    A2 --> ST1
    A2 --> ST2
    A2 --> F2

    A3 --> C1
    A3 --> A4
    A3 --> S1
    A3 --> ST1
    A3 --> ST2
    A3 --> F3

    %% Feature dependencies
    F1 --> S1
    F1 --> C1
    F1 --> ST2
    F1 --> I1

    F2 --> S1
    F2 --> C1
    F2 --> ST2
    F2 --> I1

    F3 --> S1
    F3 --> C1
    F3 --> ST2
    F3 --> I1

    %% Infrastructure dependencies
    C1 --> S2
    A4 --> C1
    A4 --> I1

    %% Shared dependencies
    S1 --> ST1
    S1 --> I2

    %% External connections
    C1 -.-> API
    A4 -.-> AUTH
    ST1 -.-> CDN

    %% Styling
    classDef appLayer fill:#e1f5fe
    classDef infraLayer fill:#f3e5f5
    classDef sharedLayer fill:#e8f5e8
    classDef stateLayer fill:#fff3e0
    classDef featureLayer fill:#fce4ec
    classDef externalLayer fill:#f5f5f5

    class A1,A2,A3 appLayer
    class C1,A4,ST1 infraLayer
    class S1,S2,I1,I2 sharedLayer
    class ST2 stateLayer
    class F1,F2,F3 featureLayer
    class API,AUTH,CDN externalLayer
```

## 📋 Layer Descriptions

### 🔷 Apps Layer (Blue)

**Entry points for different business domains**

- **Admin App**: User management, system settings, audit logs
- **Lab App**: Laboratory management, experiments, sample tracking
- **Billing App**: Product management, invoicing, payment processing

Each app is a standalone Angular application with its own routing and layout components.

### 🔷 Infrastructure Layer (Purple)

**Core system services and cross-cutting concerns**

- **Core**: HTTP interceptors, error handlers, guards, logging
- **Auth**: Authentication, authorization, JWT token management
- **Styles**: Design system, themes, SCSS utilities

These libraries provide foundational services used across all applications.

### 🔷 Shared Layer (Green)

**Reusable components and utilities**

- **Shared UI**: Dumb components, directives, pipes
- **Utils**: Pure utility functions for common operations
- **Interfaces**: TypeScript type definitions and DTOs
- **i18n**: Translation files and localization utilities

Pure, stateless libraries that can be safely imported by any other layer.

### 🔷 State Layer (Orange)

**Global application state**

- **User Store**: Current user, authentication state
- **Theme Store**: Current theme, preferences
- **Notification Store**: Global notifications, alerts

Centralized state management using Angular Signals.

### 🔷 Feature Layer (Pink)

**Domain-specific business logic**

- **Admin Features**: User CRUD, role management, audit trails
- **Lab Features**: Experiment management, result analysis
- **Billing Features**: Product catalog, invoice generation

Each feature module encapsulates related components, services, and state.

### 🔷 External Layer (Gray)

**External services and APIs**

- **REST API**: Backend data services
- **Auth Provider**: OAuth/OIDC authentication
- **CDN**: Static asset delivery

External dependencies accessed through the infrastructure layer.

---

## 🔄 Data Flow Patterns

### User Authentication Flow

```mermaid
sequenceDiagram
    participant U as User
    participant App as Angular App
    participant Auth as Auth Service
    participant API as Backend API
    participant Store as User Store

    U->>App: Login Request
    App->>Auth: login(credentials)
    Auth->>API: POST /auth/login
    API-->>Auth: {token, user}
    Auth->>Store: setUser(user)
    Auth->>Auth: storeToken(token)
    Store-->>App: User State Updated
    App-->>U: Redirect to Dashboard
```

### Feature Data Loading

```mermaid
sequenceDiagram
    participant C as Component
    participant S as Service
    participant Store as Feature Store
    participant API as Backend API
    participant UI as User Interface

    C->>S: loadData()
    S->>Store: setLoading(true)
    S->>API: GET /api/data
    API-->>S: Response Data
    S->>Store: setData(data)
    S->>Store: setLoading(false)
    Store-->>UI: State Updated
    UI-->>C: UI Re-rendered
```

---

## 🎯 Dependency Rules

### ✅ Allowed Dependencies

```
Apps → Infrastructure, Shared, State, Features
Features → Infrastructure, Shared, State, Interfaces
Infrastructure → Shared (Utils only)
Shared → None (except Styles for UI components)
State → Infrastructure, Interfaces
```

### ❌ Prohibited Dependencies

```
Shared → Features (breaks reusability)
Infrastructure → Features (creates coupling)
Features → Apps (wrong direction)
Circular dependencies between any layers
```

---

## 🏗️ Component Architecture

### Container/Presentation Pattern

```mermaid
graph LR
    subgraph "Smart Container"
        SC[Smart Container<br/>• Data fetching<br/>• Event handling<br/>• State management]
    end

    subgraph "Dumb Components"
        DC1[Component A<br/>• Pure display<br/>• Input/Output only]
        DC2[Component B<br/>• Stateless<br/>• Reusable]
        DC3[Component C<br/>• Presentational<br/>• No side effects]
    end

    SC --> DC1
    SC --> DC2
    SC --> DC3

    classDef smart fill:#ffeb3b
    classDef dumb fill:#4caf50

    class SC smart
    class DC1,DC2,DC3 dumb
```

### State Management Flow

```mermaid
graph TD
    A[User Action] --> B[Component]
    B --> C[Service Method]
    C --> D[HTTP Request]
    D --> E[API Response]
    E --> F[Store Update]
    F --> G[Signal Change]
    G --> H[Computed Values]
    H --> I[UI Update]

    classDef action fill:#f44336
    classDef service fill:#2196f3
    classDef state fill:#ff9800
    classDef ui fill:#4caf50

    class A,B action
    class C,D,E service
    class F,G,H state
    class I ui
```

---

## 🎨 Design System Architecture

### Theme System Hierarchy

```mermaid
graph TD
    subgraph "Design Tokens"
        DT1[Sass Variables<br/>• Spacing<br/>• Typography<br/>• Breakpoints]
        DT2[CSS Custom Properties<br/>• Colors<br/>• Shadows<br/>• Transitions]
    end

    subgraph "Component Styles"
        CS1[Bootstrap Base]
        CS2[Custom Components]
        CS3[Theme Overrides]
    end

    subgraph "Runtime Themes"
        RT1[Light Theme]
        RT2[Dark Theme]
        RT3[Purple Theme]
    end

    DT1 --> CS1
    DT1 --> CS2
    DT2 --> RT1
    DT2 --> RT2
    DT2 --> RT3

    CS1 --> RT1
    CS2 --> RT1
    CS3 --> RT1

    classDef tokens fill:#e1bee7
    classDef components fill:#c8e6c9
    classDef themes fill:#ffecb3

    class DT1,DT2 tokens
    class CS1,CS2,CS3 components
    class RT1,RT2,RT3 themes
```

---

## 🔐 Security Architecture

### Authentication & Authorization Layers

```mermaid
graph TB
    subgraph "Client Security"
        CS1[Route Guards]
        CS2[HTTP Interceptors]
        CS3[Input Validation]
        CS4[XSS Prevention]
    end

    subgraph "Token Management"
        TM1[JWT Storage]
        TM2[Token Refresh]
        TM3[Session Management]
    end

    subgraph "Authorization"
        AUTH1[Role-Based Access]
        AUTH2[Permission Checks]
        AUTH3[Resource Guards]
    end

    subgraph "Backend Security"
        BS1[API Authentication]
        BS2[Rate Limiting]
        BS3[CORS Policies]
    end

    CS1 --> AUTH1
    CS2 --> TM1
    TM1 --> TM2
    AUTH1 --> AUTH2
    AUTH2 --> AUTH3
    CS2 --> BS1

    classDef client fill:#e3f2fd
    classDef token fill:#f3e5f5
    classDef auth fill:#e8f5e8
    classDef backend fill:#fff3e0

    class CS1,CS2,CS3,CS4 client
    class TM1,TM2,TM3 token
    class AUTH1,AUTH2,AUTH3 auth
    class BS1,BS2,BS3 backend
```

---

## 📊 Performance Architecture

### Bundle Optimization Strategy

```mermaid
graph LR
    subgraph "Source Code"
        SC1[App Code]
        SC2[Feature Modules]
        SC3[Shared Libraries]
    end

    subgraph "Build Process"
        BP1[Tree Shaking]
        BP2[Code Splitting]
        BP3[Lazy Loading]
        BP4[Bundle Analysis]
    end

    subgraph "Optimized Bundles"
        OB1[Main Bundle<br/>< 500KB]
        OB2[Vendor Bundle<br/>< 1MB]
        OB3[Feature Chunks<br/>< 200KB each]
    end

    SC1 --> BP1
    SC2 --> BP2
    SC3 --> BP3
    BP1 --> OB1
    BP2 --> OB2
    BP3 --> OB3
    BP4 --> OB1

    classDef source fill:#e1f5fe
    classDef build fill:#f3e5f5
    classDef bundle fill:#e8f5e8

    class SC1,SC2,SC3 source
    class BP1,BP2,BP3,BP4 build
    class OB1,OB2,OB3 bundle
```

---

## 🚀 Deployment Architecture

### Multi-Environment Strategy

```mermaid
graph TD
    subgraph "Development"
        DEV1[Local Development]
        DEV2[Feature Branches]
        DEV3[Hot Reload]
    end

    subgraph "Staging"
        STAGE1[Integration Testing]
        STAGE2[Performance Testing]
        STAGE3[Security Scanning]
    end

    subgraph "Production"
        PROD1[Blue-Green Deployment]
        PROD2[CDN Distribution]
        PROD3[Monitoring & Alerts]
    end

    DEV1 --> STAGE1
    DEV2 --> STAGE1
    STAGE1 --> STAGE2
    STAGE2 --> STAGE3
    STAGE3 --> PROD1
    PROD1 --> PROD2
    PROD2 --> PROD3

    classDef dev fill:#fff3e0
    classDef staging fill:#e8f5e8
    classDef prod fill:#ffebee

    class DEV1,DEV2,DEV3 dev
    class STAGE1,STAGE2,STAGE3 staging
    class PROD1,PROD2,PROD3 prod
```

---

## 📐 Architectural Principles

### 1. **Separation of Concerns**

Each layer has a specific responsibility and doesn't overlap with others.

### 2. **Dependency Inversion**

High-level modules don't depend on low-level modules. Both depend on abstractions.

### 3. **Single Responsibility**

Each library, service, and component has one reason to change.

### 4. **Open/Closed Principle**

Open for extension, closed for modification through interfaces and dependency injection.

### 5. **Interface Segregation**

Clients shouldn't depend on interfaces they don't use.

### 6. **DRY (Don't Repeat Yourself)**

Common functionality is abstracted into shared libraries.

### 7. **SOLID Principles**

All SOLID principles are applied throughout the architecture.

---

## 🎯 Architecture Benefits

### ✅ **Scalability**

- Easy to add new apps and features
- Clear separation of concerns
- Modular architecture

### ✅ **Maintainability**

- Dependency boundaries prevent coupling
- Shared libraries reduce duplication
- Clear architectural layers

### ✅ **Testability**

- Services and components are easily mockable
- Clear dependencies make testing straightforward
- Separation of smart/dumb components

### ✅ **Performance**

- Lazy loading and code splitting
- Tree shaking removes unused code
- Optimized bundle strategies

### ✅ **Developer Experience**

- Consistent patterns across the codebase
- Clear guidelines for adding new features
- Strong TypeScript integration

This architecture provides a solid foundation for building large-scale Angular applications while maintaining code quality, performance, and developer productivity.
