#!/usr/bin/env node

import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListResourcesRequestSchema,
  ListToolsRequestSchema,
  ReadResourceRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";

const ANGULAR_PATTERNS = {
  name: "realworld-angular-patterns",
  version: "1.0.0",
  description: "Enterprise Angular 18+ patterns for consistent development",
  repository: "https://github.com/hs2504785/realworld-patterns",

  rules: {
    mandatory_structure: {
      apps: "Application entry points only",
      libs: {
        core: "Global singletons & infrastructure",
        shared: "Reusable UI components & utilities",
        auth: "Authentication & authorization",
        features: "Domain-driven feature modules",
        interfaces: "TypeScript type definitions",
        utils: "Pure utility functions",
        styles: "Design system & SCSS",
        state: "Global state management",
        i18n: "Internationalization",
      },
    },

    dependency_boundaries: {
      allowed: {
        "apps/*": ["libs/*"],
        "libs/features/*": [
          "libs/shared/*",
          "libs/core/*",
          "libs/interfaces/*",
          "libs/utils/*",
        ],
        "libs/shared/*": ["libs/core/*", "libs/interfaces/*", "libs/utils/*"],
        "libs/core/*": ["libs/interfaces/*", "libs/utils/*"],
      },
      forbidden: {
        "libs/core/*": ["libs/features/*", "libs/shared/*"],
        "libs/shared/*": ["libs/features/*"],
        cross_domain: "No imports between admin/lab/billing features",
      },
    },

    angular_patterns: {
      components: "ALWAYS standalone",
      state: "ALWAYS use signals",
      routing: "ALWAYS lazy loading",
      guards: "ALWAYS functional with inject()",
      services: "ALWAYS injectable with providedIn",
      modules: "NEVER use NgModules",
    },

    styling_patterns: {
      framework: "Bootstrap 5 ONLY",
      custom_css: "FORBIDDEN",
      utility_classes: "REQUIRED",
      components: "Use Bootstrap components",
    },

    security_patterns: {
      auth_guards: "REQUIRED for protected routes",
      interceptors: "REQUIRED for HTTP auth",
      error_handling: "REQUIRED with global handler",
      validation: "REQUIRED for all forms",
    },
  },

  code_templates: {
    component: `@Component({
  selector: 'app-{name}',
  standalone: true,
  imports: [CommonModule],
  template: \`<div class="container-fluid">...</div>\`
})
export class {Name}Component {
  loading = signal(false);
}`,

    service: `@Injectable({ providedIn: 'root' })
export class {Name}Service {
  private http = inject(HttpClient);
  private _state = signal(initialState);
  state = this._state.asReadonly();
}`,

    guard: `export const {name}Guard: CanActivateFn = (route, state) => {
  const service = inject(SomeService);
  return service.check();
};`,
  },

  validation_rules: [
    "Check dependency boundaries before imports",
    "Ensure standalone components only",
    "Verify Bootstrap classes usage",
    "Confirm signals for reactive state",
    "Validate proper file structure placement",
    "Ensure proper TypeScript interfaces",
    "Check auth guards on protected routes",
    "Verify lazy loading implementation",
  ],
};

const server = new Server({
  name: "realworld-angular-patterns-mcp",
  version: "1.0.0",
  capabilities: {
    resources: {},
    tools: {},
  },
});

// List available resources
server.setRequestHandler(ListResourcesRequestSchema, async () => {
  return {
    resources: [
      {
        uri: "patterns://angular/rules",
        mimeType: "application/json",
        name: "Angular Patterns Rules",
        description: "Complete set of enterprise Angular patterns and rules",
      },
      {
        uri: "patterns://angular/templates",
        mimeType: "text/plain",
        name: "Code Templates",
        description: "Reusable Angular code templates",
      },
      {
        uri: "patterns://angular/validation",
        mimeType: "application/json",
        name: "Validation Rules",
        description: "Rules for validating Angular code",
      },
    ],
  };
});

// Read specific resources
server.setRequestHandler(ReadResourceRequestSchema, async (request) => {
  const { uri } = request.params;

  switch (uri) {
    case "patterns://angular/rules":
      return {
        contents: [
          {
            uri,
            mimeType: "application/json",
            text: JSON.stringify(ANGULAR_PATTERNS.rules, null, 2),
          },
        ],
      };

    case "patterns://angular/templates":
      return {
        contents: [
          {
            uri,
            mimeType: "text/plain",
            text: Object.entries(ANGULAR_PATTERNS.code_templates)
              .map(
                ([name, template]) =>
                  `// ${name.toUpperCase()} TEMPLATE\n${template}`
              )
              .join("\n\n"),
          },
        ],
      };

    case "patterns://angular/validation":
      return {
        contents: [
          {
            uri,
            mimeType: "application/json",
            text: JSON.stringify(ANGULAR_PATTERNS.validation_rules, null, 2),
          },
        ],
      };

    default:
      throw new Error(`Resource not found: ${uri}`);
  }
});

// List available tools
server.setRequestHandler(ListToolsRequestSchema, async () => {
  return {
    tools: [
      {
        name: "validate-angular-code",
        description: "Validate Angular code against realworld patterns",
        inputSchema: {
          type: "object",
          properties: {
            code: {
              type: "string",
              description: "Angular code to validate",
            },
            type: {
              type: "string",
              enum: ["component", "service", "guard", "routing"],
              description: "Type of Angular code",
            },
          },
          required: ["code", "type"],
        },
      },
      {
        name: "generate-angular-template",
        description: "Generate Angular code template following patterns",
        inputSchema: {
          type: "object",
          properties: {
            type: {
              type: "string",
              enum: ["component", "service", "guard"],
              description: "Type of template to generate",
            },
            name: {
              type: "string",
              description: "Name for the generated code",
            },
          },
          required: ["type", "name"],
        },
      },
    ],
  };
});

// Handle tool calls
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;

  switch (name) {
    case "validate-angular-code":
      const { code, type } = args as { code: string; type: string };
      const issues = validateAngularCode(code, type);
      return {
        content: [
          {
            type: "text",
            text:
              issues.length === 0
                ? "✅ Code follows all realworld patterns!"
                : `❌ Issues found:\n${issues.map((i) => `- ${i}`).join("\n")}`,
          },
        ],
      };

    case "generate-angular-template":
      const { type: templateType, name: templateName } = args as {
        type: string;
        name: string;
      };
      const template = generateTemplate(templateType, templateName);
      return {
        content: [
          {
            type: "text",
            text: template,
          },
        ],
      };

    default:
      throw new Error(`Tool not found: ${name}`);
  }
});

function validateAngularCode(code: string, type: string): string[] {
  const issues: string[] = [];

  // Basic validation examples
  if (type === "component") {
    if (!code.includes("standalone: true")) {
      issues.push("Component must be standalone");
    }
    if (!code.includes("signal(")) {
      issues.push("Use signals for reactive state");
    }
    if (
      code.includes("class=") &&
      !code.includes("container-fluid") &&
      !code.includes("btn") &&
      !code.includes("card")
    ) {
      issues.push("Use Bootstrap classes instead of custom CSS");
    }
  }

  if (type === "service") {
    if (!code.includes("providedIn: 'root'")) {
      issues.push("Service must use providedIn: root");
    }
    if (!code.includes("inject(")) {
      issues.push("Use inject() function for dependency injection");
    }
  }

  return issues;
}

function generateTemplate(type: string, name: string): string {
  const templates = ANGULAR_PATTERNS.code_templates;
  const template = templates[type as keyof typeof templates];

  if (!template) {
    return `Template not found for type: ${type}`;
  }

  return template
    .replace(
      /\{name\}/g,
      name
        .toLowerCase()
        .replace(/([A-Z])/g, "-$1")
        .slice(1)
    )
    .replace(/\{Name\}/g, name.charAt(0).toUpperCase() + name.slice(1));
}

async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
}

main().catch((error) => {
  console.error("Server error:", error);
  process.exit(1);
});
