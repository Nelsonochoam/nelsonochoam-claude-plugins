# nelsonochoam Plugins

A directory of plugins for Claude Code by nelsonochoam.

> **Warning:** Make sure you trust a plugin before installing, updating, or using it. See each plugin's homepage for more information.

## Structure

- **`/plugins`** - Plugins developed and maintained by nelsonochoam

## Installation

Plugins can be installed directly from this marketplace via Claude Code's plugin system.

To install, run:

```
/plugin install {plugin-name}@nelsonochoam
```

Or browse for the plugin in `/plugin > Discover`.

## Available Plugins

| Plugin | Description |
|--------|-------------|
| [crispy](./plugins/crispy) | A framework for agentic development |

## Plugin Structure

Each plugin follows a standard structure:

```
plugin-name/
├── .claude-plugin/
│   └── plugin.json      # Plugin metadata (required)
├── .mcp.json            # MCP server configuration (optional)
├── commands/            # Slash commands (optional)
├── agents/              # Agent definitions (optional)
├── skills/              # Skill definitions (optional)
└── README.md            # Documentation
```

## Documentation

For more information on developing Claude Code plugins, see the [official documentation](https://code.claude.com/docs/en/plugins).
