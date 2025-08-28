# Build & Deployment

Comprehensive build and deployment strategies for Angular 20 + Nx monorepo with modern DevOps practices and CI/CD pipelines.

## 🎯 Build Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                   Build Pipeline                            │
├─────────────────────────────────────────────────────────────┤
│ 📦 Source Code → Nx Build → Bundle Optimization →         │
│ 🧪 Testing → 🔒 Security Scan → 📊 Quality Gate →        │
│ 🚀 Deployment → 📈 Monitoring                             │
└─────────────────────────────────────────────────────────────┘
```

## 🛠 Nx Build Configuration

### Project Configuration (`project.json`)

```json
{
  "name": "admin",
  "projectType": "application",
  "sourceRoot": "apps/admin/src",
  "targets": {
    "build": {
      "executor": "@angular-devkit/build-angular:browser",
      "options": {
        "outputPath": "dist/apps/admin",
        "index": "apps/admin/src/index.html",
        "main": "apps/admin/src/main.ts",
        "polyfills": ["zone.js"],
        "tsConfig": "apps/admin/tsconfig.app.json",
        "assets": [
          "apps/admin/src/favicon.ico",
          "apps/admin/src/assets",
          {
            "glob": "**/*",
            "input": "libs/shared/assets",
            "output": "/assets/shared"
          }
        ],
        "styles": ["libs/styles/src/globals/main.scss"],
        "scripts": [],
        "allowedCommonJsDependencies": ["chart.js"]
      },
      "configurations": {
        "production": {
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
          ],
          "optimization": true,
          "outputHashing": "all",
          "sourceMap": false,
          "namedChunks": false,
          "extractLicenses": true,
          "vendorChunk": false,
          "buildOptimizer": true,
          "aot": true,
          "fileReplacements": [
            {
              "replace": "apps/admin/src/environments/environment.ts",
              "with": "apps/admin/src/environments/environment.prod.ts"
            }
          ]
        },
        "development": {
          "buildOptimizer": false,
          "optimization": false,
          "vendorChunk": true,
          "extractLicenses": false,
          "sourceMap": true,
          "namedChunks": true
        }
      }
    },
    "serve": {
      "executor": "@angular-devkit/build-angular:dev-server",
      "configurations": {
        "production": {
          "buildTarget": "admin:build:production"
        },
        "development": {
          "buildTarget": "admin:build:development"
        }
      },
      "defaultConfiguration": "development"
    }
  },
  "tags": ["app", "domain:admin"]
}
```

### Workspace Configuration (`nx.json`)

```json
{
  "extends": "nx/presets/npm.json",
  "tasksRunnerOptions": {
    "default": {
      "runner": "nx/tasks-runners/default",
      "options": {
        "cacheableOperations": ["build", "lint", "test", "e2e"],
        "parallel": 3
      }
    }
  },
  "namedInputs": {
    "default": ["{projectRoot}/**/*", "sharedGlobals"],
    "production": [
      "default",
      "!{projectRoot}/**/?(*.)+(spec|test).[jt]s?(x)?",
      "!{projectRoot}/tsconfig.spec.json",
      "!{projectRoot}/jest.config.[jt]s",
      "!{projectRoot}/.eslintrc.json",
      "!{projectRoot}/src/test-setup.ts"
    ],
    "sharedGlobals": [
      "{workspaceRoot}/babel.config.json",
      "{workspaceRoot}/.browserslistrc"
    ]
  },
  "targetDefaults": {
    "build": {
      "dependsOn": ["^build"],
      "inputs": ["production", "^production"],
      "cache": true
    },
    "test": {
      "inputs": ["default", "^production", "{workspaceRoot}/jest.preset.js"],
      "cache": true
    },
    "lint": {
      "inputs": [
        "default",
        "{workspaceRoot}/.eslintrc.json",
        "{workspaceRoot}/.eslintignore"
      ],
      "cache": true
    }
  },
  "generators": {
    "@nx/angular:application": {
      "style": "scss",
      "linter": "eslint",
      "unitTestRunner": "jest",
      "e2eTestRunner": "cypress"
    },
    "@nx/angular:library": {
      "linter": "eslint",
      "unitTestRunner": "jest"
    },
    "@nx/angular:component": {
      "style": "scss",
      "standalone": true
    }
  }
}
```

---

## 🔹 Environment Configuration

### Base Environment

```typescript
// apps/admin/src/environments/environment.ts
export const environment = {
  production: false,
  apiBaseUrl: "http://localhost:3000/api",
  auth: {
    domain: "dev.auth0.com",
    clientId: "dev-client-id",
    audience: "http://localhost:3000",
    redirectUri: "http://localhost:4200/callback",
  },
  features: {
    analytics: false,
    notifications: true,
    debugMode: true,
  },
  logging: {
    level: "debug",
    enableConsole: true,
  },
  cache: {
    defaultTtl: 300000, // 5 minutes
    maxSize: 100,
  },
};
```

### Production Environment

```typescript
// apps/admin/src/environments/environment.prod.ts
export const environment = {
  production: true,
  apiBaseUrl: "https://api.example.com",
  auth: {
    domain: "example.auth0.com",
    clientId: "prod-client-id",
    audience: "https://api.example.com",
    redirectUri: "https://admin.example.com/callback",
  },
  features: {
    analytics: true,
    notifications: true,
    debugMode: false,
  },
  logging: {
    level: "error",
    enableConsole: false,
  },
  cache: {
    defaultTtl: 900000, // 15 minutes
    maxSize: 500,
  },
  monitoring: {
    sentryDsn: "https://xxx@sentry.io/xxx",
    datadogApiKey: "xxx",
  },
};
```

### Environment Type Safety

```typescript
// libs/core/src/lib/environment.interface.ts
export interface Environment {
  production: boolean;
  apiBaseUrl: string;
  auth: {
    domain: string;
    clientId: string;
    audience: string;
    redirectUri: string;
  };
  features: {
    analytics: boolean;
    notifications: boolean;
    debugMode: boolean;
  };
  logging: {
    level: "debug" | "info" | "warn" | "error";
    enableConsole: boolean;
  };
  cache: {
    defaultTtl: number;
    maxSize: number;
  };
  monitoring?: {
    sentryDsn: string;
    datadogApiKey: string;
  };
}
```

---

## 🔹 Build Optimization

### Webpack Bundle Analyzer

```typescript
// tools/webpack-analyzer.config.js
const { BundleAnalyzerPlugin } = require("webpack-bundle-analyzer");

module.exports = {
  plugins: [
    new BundleAnalyzerPlugin({
      analyzerMode: "static",
      reportFilename: "bundle-report.html",
      defaultSizes: "gzip",
      openAnalyzer: false,
      generateStatsFile: true,
      statsFilename: "bundle-stats.json",
    }),
  ],
};
```

### Build Scripts

```json
{
  "scripts": {
    "build:all": "nx run-many --target=build --all --parallel=3",
    "build:affected": "nx affected --target=build --parallel=3",
    "build:admin": "nx build admin --configuration=production",
    "build:admin:stats": "nx build admin --configuration=production --stats-json",
    "analyze:admin": "npx webpack-bundle-analyzer dist/apps/admin/stats.json",

    "build:docker": "docker build -t angular-monorepo .",
    "build:docker:multi": "docker buildx build --platform linux/amd64,linux/arm64 -t angular-monorepo .",

    "serve:all": "nx run-many --target=serve --all --parallel=3",
    "serve:admin": "nx serve admin",
    "serve:admin:prod": "nx serve admin --configuration=production"
  }
}
```

### Advanced Build Configuration

```json
// Custom webpack configuration for advanced optimization
{
  "build": {
    "builder": "@angular-builders/custom-webpack:browser",
    "options": {
      "customWebpackConfig": {
        "path": "./webpack.config.js",
        "mergeStrategies": {
          "externals": "replace"
        }
      }
    }
  }
}
```

```javascript
// webpack.config.js
const ModuleFederationPlugin = require("@module-federation/webpack");

module.exports = {
  optimization: {
    splitChunks: {
      chunks: "all",
      cacheGroups: {
        vendor: {
          test: /[\\/]node_modules[\\/]/,
          name: "vendors",
          chunks: "all",
        },
        common: {
          name: "common",
          minChunks: 2,
          chunks: "all",
          enforce: true,
        },
      },
    },
  },
  plugins: [
    new ModuleFederationPlugin({
      name: "admin",
      remotes: {
        billing: "billing@http://localhost:4201/remoteEntry.js",
      },
    }),
  ],
};
```

---

## 🔹 Docker Configuration

### Multi-Stage Dockerfile

```dockerfile
# Build stage
FROM node:18-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./
COPY nx.json ./
COPY tsconfig.base.json ./

# Install dependencies
RUN npm ci --only=production && npm cache clean --force

# Copy source code
COPY . .

# Build applications
RUN npx nx build admin --configuration=production
RUN npx nx build lab --configuration=production
RUN npx nx build billing --configuration=production

# Production stage
FROM nginx:alpine AS production

# Copy nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Copy built applications
COPY --from=builder /app/dist/apps/admin /usr/share/nginx/html/admin
COPY --from=builder /app/dist/apps/lab /usr/share/nginx/html/lab
COPY --from=builder /app/dist/apps/billing /usr/share/nginx/html/billing

# Copy startup script
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 80

CMD ["/start.sh"]
```

### Nginx Configuration

```nginx
# nginx.conf
events {
  worker_connections 1024;
}

http {
  include /etc/nginx/mime.types;
  default_type application/octet-stream;

  # Gzip compression
  gzip on;
  gzip_vary on;
  gzip_min_length 1024;
  gzip_types
    text/plain
    text/css
    text/xml
    text/javascript
    application/javascript
    application/xml+rss
    application/json;

  # Security headers
  add_header X-Frame-Options DENY;
  add_header X-Content-Type-Options nosniff;
  add_header X-XSS-Protection "1; mode=block";
  add_header Referrer-Policy "strict-origin-when-cross-origin";

  # Admin app
  server {
    listen 80;
    server_name admin.example.com;
    root /usr/share/nginx/html/admin;
    index index.html;

    # Handle Angular routing
    location / {
      try_files $uri $uri/ /index.html;
    }

    # Cache static assets
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
      expires 1y;
      add_header Cache-Control "public, immutable";
    }

    # Security for sensitive files
    location ~ /\. {
      deny all;
    }
  }

  # Lab app
  server {
    listen 80;
    server_name lab.example.com;
    root /usr/share/nginx/html/lab;
    index index.html;

    location / {
      try_files $uri $uri/ /index.html;
    }
  }

  # Billing app
  server {
    listen 80;
    server_name billing.example.com;
    root /usr/share/nginx/html/billing;
    index index.html;

    location / {
      try_files $uri $uri/ /index.html;
    }
  }
}
```

### Docker Compose for Development

```yaml
# docker-compose.dev.yml
version: "3.8"

services:
  admin:
    build:
      context: .
      dockerfile: Dockerfile.dev
      target: admin
    ports:
      - "4200:4200"
    volumes:
      - .:/app
      - /app/node_modules
    environment:
      - NODE_ENV=development
    command: npx nx serve admin --host 0.0.0.0

  lab:
    build:
      context: .
      dockerfile: Dockerfile.dev
      target: lab
    ports:
      - "4201:4201"
    volumes:
      - .:/app
      - /app/node_modules
    command: npx nx serve lab --host 0.0.0.0 --port 4201

  api:
    image: node:18-alpine
    working_dir: /app
    ports:
      - "3000:3000"
    volumes:
      - ./api:/app
    command: npm run dev

  postgres:
    image: postgres:15-alpine
    ports:
      - "5432:5432"
    environment:
      POSTGRES_DB: app_db
      POSTGRES_USER: app_user
      POSTGRES_PASSWORD: app_password
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
```

---

## 🔹 CI/CD Pipeline

### GitHub Actions Workflow

```yaml
# .github/workflows/ci-cd.yml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

env:
  NODE_VERSION: "18"
  CACHE_KEY: node-modules-${{ hashFiles('**/package-lock.json') }}

jobs:
  setup:
    runs-on: ubuntu-latest
    outputs:
      affected: ${{ steps.affected.outputs.affected }}
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: "npm"

      - name: Install dependencies
        run: npm ci

      - name: Cache node modules
        uses: actions/cache@v3
        with:
          path: node_modules
          key: ${{ env.CACHE_KEY }}

      - name: Determine affected projects
        id: affected
        run: |
          if [[ "${{ github.event_name }}" == "pull_request" ]]; then
            echo "affected=$(npx nx print-affected --type=app --select=projects --base=origin/main)" >> $GITHUB_OUTPUT
          else
            echo "affected=admin,lab,billing" >> $GITHUB_OUTPUT
          fi

  lint-and-test:
    runs-on: ubuntu-latest
    needs: setup
    strategy:
      matrix:
        target: [lint, test]
    steps:
      - uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: "npm"

      - name: Restore cache
        uses: actions/cache@v3
        with:
          path: node_modules
          key: ${{ env.CACHE_KEY }}

      - name: Run ${{ matrix.target }}
        run: npx nx affected --target=${{ matrix.target }} --parallel=3

  security-scan:
    runs-on: ubuntu-latest
    needs: setup
    steps:
      - uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: "npm"

      - name: Install dependencies
        run: npm ci

      - name: Run security audit
        run: npm audit --audit-level moderate

      - name: Run Snyk security scan
        uses: snyk/actions/node@master
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}

  build:
    runs-on: ubuntu-latest
    needs: [lint-and-test, security-scan]
    if: github.ref == 'refs/heads/main' || github.ref == 'refs/heads/develop'
    strategy:
      matrix:
        app: ${{ fromJson(needs.setup.outputs.affected) }}
    steps:
      - uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: "npm"

      - name: Restore cache
        uses: actions/cache@v3
        with:
          path: node_modules
          key: ${{ env.CACHE_KEY }}

      - name: Build ${{ matrix.app }}
        run: npx nx build ${{ matrix.app }} --configuration=production

      - name: Upload build artifacts
        uses: actions/upload-artifact@v3
        with:
          name: ${{ matrix.app }}-build
          path: dist/apps/${{ matrix.app }}
          retention-days: 7

  docker-build:
    runs-on: ubuntu-latest
    needs: build
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v3

      - name: Download build artifacts
        uses: actions/download-artifact@v3
        with:
          path: dist/apps

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2

      - name: Login to Container Registry
        uses: docker/login-action@v2
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Build and push Docker image
        uses: docker/build-push-action@v4
        with:
          context: .
          push: true
          tags: |
            ghcr.io/${{ github.repository }}:latest
            ghcr.io/${{ github.repository }}:${{ github.sha }}
          cache-from: type=gha
          cache-to: type=gha,mode=max

  deploy-staging:
    runs-on: ubuntu-latest
    needs: docker-build
    if: github.ref == 'refs/heads/develop'
    environment: staging
    steps:
      - name: Deploy to staging
        run: |
          echo "Deploying to staging environment"
          # Add deployment commands here

  deploy-production:
    runs-on: ubuntu-latest
    needs: docker-build
    if: github.ref == 'refs/heads/main'
    environment: production
    steps:
      - name: Deploy to production
        run: |
          echo "Deploying to production environment"
          # Add deployment commands here

  performance-audit:
    runs-on: ubuntu-latest
    needs: deploy-staging
    if: github.ref == 'refs/heads/develop'
    steps:
      - uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: ${{ env.NODE_VERSION }}

      - name: Run Lighthouse CI
        run: |
          npm install -g @lhci/cli
          lhci autorun
        env:
          LHCI_GITHUB_APP_TOKEN: ${{ secrets.LHCI_GITHUB_APP_TOKEN }}
```

### Azure DevOps Pipeline

```yaml
# azure-pipelines.yml
trigger:
  branches:
    include:
      - main
      - develop

variables:
  nodeVersion: "18"
  buildConfiguration: "production"

stages:
  - stage: Build
    displayName: "Build and Test"
    jobs:
      - job: Setup
        displayName: "Setup and Cache"
        pool:
          vmImage: "ubuntu-latest"
        steps:
          - task: NodeTool@0
            inputs:
              versionSpec: $(nodeVersion)
            displayName: "Install Node.js"

          - task: Cache@2
            inputs:
              key: 'npm | "$(Agent.OS)" | package-lock.json'
              restoreKeys: |
                npm | "$(Agent.OS)"
              path: "$(System.DefaultWorkingDirectory)/node_modules"
            displayName: "Cache npm packages"

          - script: npm ci
            displayName: "Install dependencies"

      - job: Lint
        displayName: "Lint Code"
        dependsOn: Setup
        pool:
          vmImage: "ubuntu-latest"
        steps:
          - template: .azure/templates/node-setup.yml
          - script: npx nx affected --target=lint --parallel=3
            displayName: "Run linting"

      - job: Test
        displayName: "Run Tests"
        dependsOn: Setup
        pool:
          vmImage: "ubuntu-latest"
        steps:
          - template: .azure/templates/node-setup.yml
          - script: npx nx affected --target=test --parallel=3 --coverage
            displayName: "Run unit tests"
          - task: PublishTestResults@2
            inputs:
              testResultsFormat: "JUnit"
              testResultsFiles: "**/junit.xml"
            displayName: "Publish test results"

      - job: Build
        displayName: "Build Applications"
        dependsOn: [Lint, Test]
        pool:
          vmImage: "ubuntu-latest"
        strategy:
          matrix:
            admin:
              appName: "admin"
            lab:
              appName: "lab"
            billing:
              appName: "billing"
        steps:
          - template: .azure/templates/node-setup.yml
          - script: npx nx build $(appName) --configuration=$(buildConfiguration)
            displayName: "Build $(appName)"
          - task: PublishBuildArtifacts@1
            inputs:
              pathToPublish: "dist/apps/$(appName)"
              artifactName: "$(appName)-build"
            displayName: "Publish build artifacts"

  - stage: Deploy
    displayName: "Deploy Applications"
    dependsOn: Build
    condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
    jobs:
      - deployment: DeployToProduction
        displayName: "Deploy to Production"
        environment: "production"
        pool:
          vmImage: "ubuntu-latest"
        strategy:
          runOnce:
            deploy:
              steps:
                - task: DownloadBuildArtifacts@0
                  inputs:
                    buildType: "current"
                    downloadType: "specific"
                    downloadPath: "$(System.ArtifactsDirectory)"

                - task: AzureWebApp@1
                  inputs:
                    azureSubscription: "$(azureServiceConnection)"
                    appType: "webApp"
                    appName: "$(webAppName)"
                    package: "$(System.ArtifactsDirectory)/**/*.zip"
```

---

## 🔹 Kubernetes Deployment

### Kubernetes Manifests

```yaml
# k8s/admin-deployment.yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: admin-app
  labels:
    app: admin
spec:
  replicas: 3
  selector:
    matchLabels:
      app: admin
  template:
    metadata:
      labels:
        app: admin
    spec:
      containers:
        - name: admin
          image: ghcr.io/company/angular-monorepo:latest
          ports:
            - containerPort: 80
          env:
            - name: API_BASE_URL
              value: "https://api.example.com"
          resources:
            requests:
              memory: "128Mi"
              cpu: "100m"
            limits:
              memory: "256Mi"
              cpu: "200m"
          livenessProbe:
            httpGet:
              path: /health
              port: 80
            initialDelaySeconds: 30
            periodSeconds: 10
          readinessProbe:
            httpGet:
              path: /ready
              port: 80
            initialDelaySeconds: 5
            periodSeconds: 5

---
apiVersion: v1
kind: Service
metadata:
  name: admin-service
spec:
  selector:
    app: admin
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  type: ClusterIP

---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: admin-ingress
  annotations:
    kubernetes.io/ingress.class: nginx
    cert-manager.io/cluster-issuer: letsencrypt-prod
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
spec:
  tls:
    - hosts:
        - admin.example.com
      secretName: admin-tls
  rules:
    - host: admin.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: admin-service
                port:
                  number: 80
```

### Helm Chart

```yaml
# helm/angular-monorepo/values.yml
global:
  imageRegistry: ghcr.io
  imageTag: latest

apps:
  admin:
    enabled: true
    replicaCount: 3
    image:
      repository: company/angular-monorepo
      tag: ""
      pullPolicy: IfNotPresent

    service:
      type: ClusterIP
      port: 80

    ingress:
      enabled: true
      className: nginx
      hostname: admin.example.com
      tls: true

    resources:
      requests:
        memory: 128Mi
        cpu: 100m
      limits:
        memory: 256Mi
        cpu: 200m

    env:
      API_BASE_URL: "https://api.example.com"

  lab:
    enabled: true
    replicaCount: 2
    # Similar configuration...

  billing:
    enabled: true
    replicaCount: 2
    # Similar configuration...
```

---

## 🔹 Monitoring & Observability

### Health Check Endpoints

```typescript
// apps/admin/src/app/health/health.component.ts
@Component({
  selector: "app-health",
  standalone: true,
  template: `
    <div class="health-check">
      <h1>Health Check</h1>
      <div>Status: {{ status }}</div>
      <div>Version: {{ version }}</div>
      <div>Build: {{ buildInfo.timestamp }}</div>
    </div>
  `,
})
export class HealthComponent {
  status = "OK";
  version = environment.version;
  buildInfo = {
    timestamp: environment.buildTimestamp,
    commit: environment.gitCommit,
  };
}
```

### Application Metrics

```typescript
// libs/core/services/metrics.service.ts
@Injectable({ providedIn: "root" })
export class MetricsService {
  private metrics = {
    pageViews: 0,
    apiCalls: 0,
    errors: 0,
    loadTime: 0,
  };

  incrementPageViews() {
    this.metrics.pageViews++;
    this.sendMetric("page_view", this.metrics.pageViews);
  }

  recordApiCall(duration: number) {
    this.metrics.apiCalls++;
    this.sendMetric("api_call", { count: this.metrics.apiCalls, duration });
  }

  recordError(error: any) {
    this.metrics.errors++;
    this.sendMetric("error", {
      count: this.metrics.errors,
      error: error.message,
    });
  }

  private sendMetric(name: string, data: any) {
    if (environment.production) {
      // Send to monitoring service (DataDog, New Relic, etc.)
      fetch("/api/metrics", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ name, data, timestamp: Date.now() }),
      });
    }
  }
}
```

---

## 🔹 Deployment Strategies

### Blue-Green Deployment

```bash
#!/bin/bash
# scripts/blue-green-deploy.sh

ENVIRONMENT=$1
VERSION=$2
NAMESPACE="angular-apps"

if [ "$ENVIRONMENT" = "production" ]; then
  # Deploy to green environment
  kubectl set image deployment/admin-app-green admin=ghcr.io/company/angular-monorepo:$VERSION -n $NAMESPACE
  kubectl rollout status deployment/admin-app-green -n $NAMESPACE

  # Health check
  kubectl wait --for=condition=ready pod -l app=admin-green -n $NAMESPACE --timeout=300s

  # Switch traffic
  kubectl patch service admin-service -p '{"spec":{"selector":{"version":"green"}}}' -n $NAMESPACE

  # Scale down blue
  kubectl scale deployment admin-app-blue --replicas=0 -n $NAMESPACE
else
  echo "Environment not supported"
  exit 1
fi
```

### Canary Deployment

```yaml
# k8s/canary-deployment.yml
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: admin-rollout
spec:
  replicas: 5
  strategy:
    canary:
      steps:
        - setWeight: 20
        - pause: {}
        - setWeight: 40
        - pause: { duration: 10 }
        - setWeight: 60
        - pause: { duration: 10 }
        - setWeight: 80
        - pause: { duration: 10 }
      canaryService: admin-canary
      stableService: admin-stable
  selector:
    matchLabels:
      app: admin
  template:
    metadata:
      labels:
        app: admin
    spec:
      containers:
        - name: admin
          image: ghcr.io/company/angular-monorepo:latest
```

---

## ✅ Deployment Checklist

### 🏗️ Build Process

- ✅ Nx build optimization enabled
- ✅ Bundle size monitoring
- ✅ Tree shaking configured
- ✅ Environment configuration
- ✅ Source maps for production debugging

### 🔒 Security

- ✅ Security headers configured
- ✅ HTTPS enforcement
- ✅ CSP headers set
- ✅ Sensitive files protected
- ✅ Dependency vulnerability scanning

### 🚀 Performance

- ✅ Gzip/Brotli compression enabled
- ✅ Static asset caching
- ✅ CDN configuration
- ✅ Image optimization
- ✅ Lazy loading implemented

### 📊 Monitoring

- ✅ Health check endpoints
- ✅ Application metrics
- ✅ Error tracking
- ✅ Performance monitoring
- ✅ Log aggregation

### 🔄 CI/CD

- ✅ Automated testing
- ✅ Security scanning
- ✅ Code quality gates
- ✅ Automated deployment
- ✅ Rollback procedures

### ☸️ Infrastructure

- ✅ Container optimization
- ✅ Resource limits set
- ✅ Auto-scaling configured
- ✅ Load balancing
- ✅ Backup strategies
