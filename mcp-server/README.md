# Realworld Angular Patterns - MCP Server

MCP (Model Context Protocol) server that provides enterprise Angular patterns to AI assistants.

## 🚀 Quick Setup

### 1. Install Dependencies

```bash
cd mcp-server
npm install
npm run build
```

### 2. Configure Cursor MCP

Add this to your Cursor settings (`~/.cursor/mcp_servers.json`):

```json
{
  "mcpServers": {
    "realworld-angular-patterns": {
      "command": "node",
      "args": ["/path/to/realworld-patterns/mcp-server/dist/index.js"]
    }
  }
}
```

**Or install globally:**

```bash
# Install globally
npm install -g realworld-angular-patterns-mcp

# Then configure Cursor
{
  "mcpServers": {
    "realworld-angular-patterns": {
      "command": "realworld-angular-patterns-mcp"
    }
  }
}
```

### 3. Use in Cursor

Once configured, Cursor can:

- **Validate Angular code** against enterprise patterns
- **Generate code templates** following patterns
- **Access pattern rules** for suggestions
- **Enforce dependency boundaries** automatically

## 🎯 Available Resources

The MCP server provides:

| Resource                        | Description                          |
| ------------------------------- | ------------------------------------ |
| `patterns://angular/rules`      | Complete enterprise Angular patterns |
| `patterns://angular/templates`  | Reusable code templates              |
| `patterns://angular/validation` | Validation rules                     |

## 🛠️ Available Tools

| Tool                        | Description                           |
| --------------------------- | ------------------------------------- |
| `validate-angular-code`     | Validates code against patterns       |
| `generate-angular-template` | Generates pattern-compliant templates |

## 📝 Usage Examples

### Validation

```typescript
// Cursor will automatically validate this component:
@Component({
  selector: "app-user-list",
  standalone: true, // ✅ Required pattern
  imports: [CommonModule],
  template: `
    <div class="container-fluid">
      <!-- ✅ Bootstrap pattern -->
      @if (loading()) {
      <!-- ✅ Angular 18+ pattern -->
      <div class="spinner-border"></div>
      }
    </div>
  `,
})
export class UserListComponent {
  loading = signal(false); // ✅ Signals pattern
}
```

### Code Generation

Ask Cursor: "Generate a user service following realworld patterns"

Result:

```typescript
@Injectable({ providedIn: "root" })
export class UserService {
  private http = inject(HttpClient);
  private _state = signal(initialState);
  state = this._state.asReadonly();
}
```

## 🔧 Development

```bash
# Development mode
npm run dev

# Build for production
npm run build

# Test the server
npm start
```

## 📦 Publishing

```bash
# Publish to NPM
npm run build
npm publish
```

## 🎯 Integration with Other Tools

### Claude Desktop

```json
{
  "mcpServers": {
    "realworld-patterns": {
      "command": "realworld-angular-patterns-mcp"
    }
  }
}
```

### VS Code (when MCP support is added)

```json
{
  "mcp.servers": [
    {
      "name": "realworld-patterns",
      "command": "realworld-angular-patterns-mcp"
    }
  ]
}
```

## 🌟 Benefits

✅ **Real-time validation** of Angular code  
✅ **Automatic pattern enforcement**  
✅ **Template generation** following enterprise standards  
✅ **Dependency boundary checking**  
✅ **Bootstrap-only CSS validation**  
✅ **Signals-based state management guidance**

Your AI assistant now understands and enforces your enterprise Angular patterns automatically! 🎉

# npm deploy

```
cd mcp-server
npm pack
npm install -g realworld-angular-patterns-mcp-1.0.0.tgz
```
