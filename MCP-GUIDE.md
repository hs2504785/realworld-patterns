# 🤖 Complete MCP Server Guide

**Model Context Protocol (MCP) Server for Realworld Angular Patterns**

This guide explains how we created the MCP server and how to use it for real-time pattern enforcement in Cursor IDE.

---

## 🎯 What is MCP?

**MCP (Model Context Protocol)** is Anthropic's standard for connecting AI assistants to external data sources and tools. It allows:

- ✅ **Real-time code validation** against your patterns
- ✅ **Automatic template generation** following standards
- ✅ **Live pattern enforcement** in IDE
- ✅ **Custom tool integration** with AI assistants

---

## 🏗️ How We Created the MCP Server

### 1. Project Structure

```
mcp-server/
├── package.json          # NPM configuration
├── tsconfig.json         # TypeScript configuration
├── src/
│   └── index.ts          # Main MCP server implementation
├── dist/                 # Compiled JavaScript (auto-generated)
└── README.md             # MCP server documentation
```

### 2. Dependencies Used

```json
{
  "dependencies": {
    "@modelcontextprotocol/sdk": "^0.4.0"
  },
  "devDependencies": {
    "@types/node": "^20.0.0",
    "typescript": "^5.0.0"
  }
}
```

### 3. Key MCP Components Implemented

**Server Initialization:**

```typescript
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";

const server = new Server({
  name: "realworld-angular-patterns-mcp",
  version: "1.0.0",
  capabilities: {
    resources: {}, // Provides pattern data
    tools: {}, // Provides validation/generation tools
  },
});
```

**Resources (Pattern Data):**

- `patterns://angular/rules` - Complete enterprise patterns
- `patterns://angular/templates` - Code templates
- `patterns://angular/validation` - Validation rules

**Tools (AI Functions):**

- `validate-angular-code` - Validates code against patterns
- `generate-angular-template` - Generates pattern-compliant code

---

## 🚀 Installation & Setup

### Step 1: Build the MCP Server

```bash
# Navigate to MCP server directory
cd mcp-server

# Install dependencies
npm install

# Build TypeScript to JavaScript
npm run build

# Verify build
ls -la dist/
# Should show: index.js, index.d.ts, source maps
```

### Step 2: Choose Installation Method

#### Option A: Install from Source (Recommended)

```bash
# Clone repository
git clone https://github.com/hs2504785/realworld-patterns.git
cd realworld-patterns/mcp-server

# Install dependencies and build
npm install
npm run build

# Install globally from source
npm install -g .

# Verify installation
which realworld-angular-patterns-mcp
```

#### Option B: Local Path Installation

```bash
# Note the absolute path
pwd
# Use this path in Cursor configuration
```

### Step 3: Configure Cursor IDE

Create or edit `~/.cursor/mcp_servers.json`:

#### For Global Installation (from source):

```json
{
  "mcpServers": {
    "realworld-angular-patterns": {
      "command": "realworld-angular-patterns-mcp"
    }
  }
}
```

#### For Local Path Installation:

```json
{
  "mcpServers": {
    "realworld-angular-patterns": {
      "command": "node",
      "args": ["/FULL/PATH/TO/realworld-patterns/mcp-server/dist/index.js"]
    }
  }
}
```

#### For Development (if working on the MCP server):

```json
{
  "mcpServers": {
    "realworld-angular-patterns": {
      "command": "npm",
      "args": ["start"],
      "cwd": "/FULL/PATH/TO/realworld-patterns/mcp-server"
    }
  }
}
```

### Step 4: Restart Cursor

```bash
# Restart Cursor IDE to load the MCP server
```

---

## 🎯 How to Use the MCP Server

### Real-Time Code Validation

**1. Write Angular Code in Cursor:**

```typescript
@Component({
  selector: "app-user-list",
  standalone: true, // ✅ MCP validates this
  template: `
    <div class="container-fluid">
      <!-- ✅ Bootstrap validation -->
      @if (loading()) {
      <!-- ✅ Angular 18+ validation -->
      <div class="spinner-border"></div>
      }
    </div>
  `,
})
export class UserListComponent {
  loading = signal(false); // ✅ Signals validation
}
```

**2. Ask Cursor to Validate:**

```
"Please validate this component against realworld patterns"
```

**3. Get Real-Time Feedback:**

```
✅ Code follows all realworld patterns!

Or:

❌ Issues found:
- Component must be standalone
- Use signals for reactive state
- Use Bootstrap classes instead of custom CSS
```

### Template Generation

**1. Ask for Code Generation:**

```
"Generate a user service following realworld patterns"
```

**2. Get Pattern-Compliant Code:**

```typescript
@Injectable({ providedIn: "root" })
export class UserService {
  private http = inject(HttpClient);
  private _state = signal(initialState);
  state = this._state.asReadonly();
}
```

### Access Pattern Resources

**1. Ask for Pattern Information:**

```
"Show me the dependency boundary rules"
"What are the mandatory folder structure rules?"
"Generate a component template"
```

**2. Get Structured Responses:**

```json
{
  "allowed": {
    "apps/*": ["libs/*"],
    "libs/features/*": [
      "libs/shared/*",
      "libs/core/*",
      "libs/interfaces/*",
      "libs/utils/*"
    ]
  },
  "forbidden": {
    "libs/core/*": ["libs/features/*", "libs/shared/*"]
  }
}
```

---

## 🛠️ Development & Customization

### Add New Validation Rules

```typescript
// In src/index.ts, function validateAngularCode()
function validateAngularCode(code: string, type: string): string[] {
  const issues: string[] = [];

  // Add your custom validation
  if (type === "component") {
    if (!code.includes("ChangeDetectionStrategy.OnPush")) {
      issues.push("Use OnPush change detection strategy");
    }
  }

  return issues;
}
```

### Add New Templates

```typescript
// In ANGULAR_PATTERNS.code_templates
code_templates: {
  component: `...existing template...`,
  service: `...existing template...`,

  // Add new template
  pipe: `@Pipe({
    name: '{name}',
    standalone: true
  })
  export class {Name}Pipe implements PipeTransform {
    transform(value: any): any {
      return value;
    }
  }`
}
```

### Rebuild After Changes

```bash
cd mcp-server
npm run build

# If globally installed, reinstall from source
npm install -g .

# Note: .tgz files are excluded from git (this is correct)
# We install directly from source instead of using npm pack
```

---

## 🔧 Troubleshooting

### MCP Server Not Found

```bash
# Check if Cursor can find the server
which realworld-angular-patterns-mcp

# Check MCP configuration
cat ~/.cursor/mcp_servers.json

# Check Cursor logs (if available)
```

### Build Errors

```bash
# Clean and rebuild
cd mcp-server
rm -rf dist node_modules
npm install
npm run build
```

### TypeScript Errors

```bash
# Check TypeScript version
npx tsc --version

# Verify SDK compatibility
npm list @modelcontextprotocol/sdk
```

### Cursor Not Responding

```bash
# Restart Cursor IDE
# Check if MCP server process is running
ps aux | grep realworld-angular-patterns

# Test server manually (should start and wait for input)
node mcp-server/dist/index.js
```

---

## 📊 MCP vs Other Approaches

| Feature                  | Copy-Paste        | .mdc Files      | MCP Server            |
| ------------------------ | ----------------- | --------------- | --------------------- |
| **Real-time validation** | ❌ Manual         | ❌ No           | ✅ Yes                |
| **Template generation**  | ❌ Manual         | ⚠️ Limited      | ✅ Dynamic            |
| **Custom rules**         | ❌ No             | ⚠️ Static       | ✅ Programmable       |
| **Setup complexity**     | ✅ Simple         | ✅ Simple       | ⚠️ Moderate           |
| **Maintenance**          | ❌ Manual updates | ✅ Auto-inherit | ✅ Version controlled |

---

## 🌟 Benefits of Our MCP Server

✅ **Live Pattern Enforcement** - Real-time validation as you code  
✅ **Automatic Code Generation** - Templates following your exact patterns  
✅ **Extensible** - Easy to add new rules and templates  
✅ **Version Controlled** - Patterns versioned with your codebase  
✅ **Team Consistency** - Everyone gets the same validation  
✅ **IDE Integration** - Works directly in Cursor without context switching

---

## 🚀 Distribution Options

### Option 1: NPM Publishing (For Public Distribution)

```bash
cd mcp-server

# Update version
npm version patch

# Publish to NPM registry
npm publish

# Teams can then install globally
npm install -g realworld-angular-patterns-mcp
```

### Option 2: Source Distribution (Recommended for Teams)

```bash
# Teams clone and install from source (current approach)
git clone https://github.com/hs2504785/realworld-patterns.git
cd realworld-patterns/mcp-server
npm install && npm run build && npm install -g .
```

### Option 3: GitHub Releases (For .tgz Distribution)

```bash
# Create release package (not committed to git)
cd mcp-server
npm pack

# Upload realworld-angular-patterns-mcp-1.0.0.tgz to GitHub Releases
# Users download and install: npm install -g downloaded-file.tgz
```

**Note**: `.tgz` files are intentionally excluded from git via `.gitignore` - this is the correct practice.

---

## 📝 Future Enhancements

- **VS Code Extension** - When VS Code supports MCP
- **Additional Validators** - More sophisticated pattern checking
- **Custom Rules DSL** - Configuration-driven validation rules
- **Integration Tests** - Automated testing of MCP functionality
- **Performance Monitoring** - Track validation performance

---

**The MCP server transforms your static patterns into a live, intelligent coding assistant that enforces enterprise standards in real-time!** 🎉
