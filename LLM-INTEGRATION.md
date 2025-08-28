# 🤖 LLM Integration Guide

This repository provides **simple reference files** that any LLM can use to understand and follow your enterprise Angular patterns. No complex tooling needed - just reference files!

## 🎯 Quick Start

### Universal Approach (Recommended)

**For ALL AI Tools (Cursor, ChatGPT, Claude, etc.):**

```bash
# One file works everywhere - copy and paste content
curl -s https://raw.githubusercontent.com/hs2504785/realworld-patterns/main/realworld-patterns.md
```

### Alternative Approaches (Optional)

**For Advanced Cursor Users (MCP Server):**

```bash
# Real-time validation & code generation
cd mcp-server
npm install && npm run build
# Configure in ~/.cursor/mcp_servers.json - see MCP-GUIDE.md
```

**For Cursor IDE Inheritance:**

```bash
# If you want .mdc file inheritance
curl -O https://raw.githubusercontent.com/hs2504785/realworld-patterns/main/angular-20.mdc
curl -O https://raw.githubusercontent.com/hs2504785/realworld-patterns/main/realworld-patterns.mdc
```

**For Quick Prompt:**

```bash
# Minimal version
curl -s https://raw.githubusercontent.com/hs2504785/realworld-patterns/main/prompt-reference.md
```

### For Teams

Just share this repository URL:

```
https://github.com/hs2504785/realworld-patterns
```

## 📁 Reference Files Available

| File                         | What It Does                                   | When to Use                    |
| ---------------------------- | ---------------------------------------------- | ------------------------------ |
| **`realworld-patterns.md`**  | **Universal comprehensive patterns**           | **ALL AI tools (recommended)** |
| **`mcp-server/`**            | **Real-time MCP server**                       | **Advanced Cursor users**      |
| **`MCP-GUIDE.md`**           | **Complete MCP setup documentation**           | **MCP server implementation**  |
| **`realworld-patterns.mdc`** | Modern Cursor rules (inherits from Angular 20) | Cursor IDE inheritance         |
| **`angular-20.mdc`**         | Official Angular 20 base patterns              | Required for .mdc inheritance  |
| **`prompt-reference.md`**    | Quick copy-paste prompt for any LLM            | Minimal prompt version         |
| **`llm-context-rules.md`**   | Focused LLM patterns and enforcement rules     | Alternative detailed reference |
| **`mcp-context.json`**       | Legacy structured JSON for MCP systems         | Static MCP integrations        |

## 🚀 Usage Examples

### Example 1: Universal Setup (Recommended)

```bash
# One command works for everything:
curl -s https://raw.githubusercontent.com/hs2504785/realworld-patterns/main/realworld-patterns.md

# Copy the content and paste it into:
# - Cursor AI chat
# - ChatGPT conversation start
# - Claude conversation start
# - Any AI tool
```

### Example 2: Team Onboarding

```markdown
👋 Welcome! For any AI assistance:

1. Copy this: https://raw.githubusercontent.com/hs2504785/realworld-patterns/main/realworld-patterns.md
2. Paste content at start of any AI conversation
3. Ask AI to generate Angular code
4. Patterns will be followed automatically!
```

### Example 3: MCP Server in Cursor (Advanced)

```bash
# After MCP server setup (see MCP-GUIDE.md)
# Just start coding in Cursor and ask:

"Validate this component against realworld patterns"
"Generate a user service following patterns"
"Check if this import violates dependency boundaries"

# Get real-time feedback:
✅ Code follows all realworld patterns!
❌ Issues found: Use signals for reactive state
```

### Example 4: ChatGPT/Claude Conversation

```
Paste this first:
---
[Content of realworld-patterns.md]
---

Then ask: "Generate a user management component following these patterns"
```

## 🎯 What LLMs Will Follow

When using these reference files, any LLM will:

✅ **Structure**: Use exact folder layout (`/apps`, `/libs/core`, `/libs/features`, etc.)  
✅ **Angular**: Generate standalone components with signals  
✅ **Bootstrap**: Use only Bootstrap 5 classes (no custom CSS)  
✅ **Dependencies**: Respect strict boundary rules  
✅ **Security**: Include auth guards and proper error handling  
✅ **Performance**: Implement lazy loading and optimization

## 🔄 Keeping Updated

1. **Watch this repository** for updates
2. **Re-download reference files** when patterns change
3. **Share updates** with your team
4. **Submit PRs** for improvements

## 🌟 Benefits

- **Zero Setup**: Just copy reference files
- **Universal**: Works with any LLM (ChatGPT, Claude, Cursor, etc.)
- **Consistent**: All team members get same patterns
- **Scalable**: Easy to maintain and update
- **Simple**: No complex tooling or dependencies

## 🆘 Troubleshooting

**Q: LLM not following patterns?**  
A: Make sure you paste the reference content at the **start** of conversation

**Q: Patterns seem outdated?**  
A: Re-download latest reference files from this repository

**Q: Need custom patterns?**  
A: Fork this repository and modify the reference files

**Q: Team adoption issues?**  
A: Share the simple team instruction from README.md

---

**That's it!** Simple reference files that ensure consistent Angular patterns across all AI-assisted development. 🎉
