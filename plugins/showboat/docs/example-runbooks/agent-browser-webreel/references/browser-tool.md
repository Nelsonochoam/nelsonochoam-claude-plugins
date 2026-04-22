# Browser Tool: agent-browser + webreel

Load when: taking screenshots, recording video, navigating, or interacting with the browser during a demo.

This project uses two tools for two different jobs:

- **agent-browser** — drives the browser dynamically: navigate, interact, read state, assert, take screenshots. Use this for all live testing during the demo.
- **webreel** — produces polished demo videos from a pre-scripted config. Run this after the demo flow is verified to produce an MP4/GIF for sharing.

**They cannot share a browser session.** Each runs its own Chrome instance. Use agent-browser first for the interactive demo, then run webreel separately to produce the video.

---

## agent-browser — screenshots and interaction

Install: `npm install -g agent-browser && agent-browser install`

### Start session

```bash
agent-browser open <url>     # daemon auto-starts on first command
```

### Navigate

```bash
agent-browser open <url>
agent-browser back
agent-browser reload
```

### Take a screenshot

```bash
agent-browser screenshot /tmp/sb-<name>.png
showboat image "$DEMO_FILE" /tmp/sb-<name>.png
```

### Interact

Get refs first, then act:

```bash
agent-browser snapshot -i    # list interactive elements, each gets a ref like @e1
agent-browser click @e1
agent-browser fill @e2 "text"
agent-browser press Enter
agent-browser select @e1 "value"
```

Semantic locators (no snapshot needed):

```bash
agent-browser find text "Sign In" click
agent-browser find label "Email" fill "user@test.com"
agent-browser find testid "submit-btn" click
```

### Wait for stability

```bash
agent-browser wait --load networkidle     # best for SPAs
agent-browser wait --text "Success"       # wait for text to appear
agent-browser wait @e1                    # wait for element ref
agent-browser wait 2000                   # fixed ms (last resort)
```

### Assert

```bash
agent-browser is visible @e1
agent-browser get text @e1
agent-browser get url
agent-browser eval "document.title"
```

### Stop session

```bash
agent-browser close
```

---

## webreel — polished video recording

Install: `npm install -g webreel`

webreel is **config-driven**, not interactive. You write a JSON script of the full flow, then run `webreel record` once to produce the video. It spins up its own Chrome and runs the script in full before outputting the video.

### Workflow

**Step 1 — scaffold a config:**

```bash
webreel init --name demo-flow --url http://localhost:3000
# creates webreel.config.json
```

**Step 2 — write the script** (`webreel.config.json`):

```json
{
  "$schema": "https://webreel.dev/schema/v1.json",
  "videos": {
    "demo-flow": {
      "url": "http://localhost:3000",
      "output": "/tmp/sb-demo-flow.mp4",
      "viewport": { "width": 1280, "height": 720 },
      "fps": 60,
      "defaultDelay": 500,
      "waitFor": ".app-loaded",
      "steps": [
        { "action": "pause", "ms": 800 },
        { "action": "find", "text": "Sign In", "click": true },
        { "action": "type", "selector": "input[name=email]", "text": "demo@example.com" },
        { "action": "type", "selector": "input[name=password]", "text": "password" },
        { "action": "find", "text": "Submit", "click": true },
        { "action": "wait", "selector": ".dashboard" },
        { "action": "screenshot", "output": "/tmp/sb-dashboard.png" },
        { "action": "pause", "ms": 1000 }
      ]
    }
  }
}
```

**All available actions:**

| Action | Key fields | Notes |
|---|---|---|
| `navigate` | `url` | navigate to a new URL mid-recording |
| `click` | `text` or `selector`, optional `within` | click by visible text or CSS selector |
| `type` | `text`, optional `selector`, `charDelay` (default 80ms) | simulates keystrokes |
| `key` | `key` (e.g. `"mod+a"`) | keyboard shortcut; `mod+` = Cmd on macOS, Ctrl on Windows/Linux |
| `pause` | `ms` | hold on current state for N milliseconds |
| `wait` | `selector` or `text`, optional `timeout` (default 30000ms) | wait for element or text to appear |
| `scroll` | optional `x`, `y`, `selector` | scroll the page |
| `hover` | `text` or `selector` | move mouse over element |
| `drag` | `from` and `to` (each with `text` or `selector`) | drag and drop |
| `select` | `selector`, `value` | pick a dropdown option |
| `screenshot` | `output` | save a PNG at this point in the recording |

`delay` on any step overrides `defaultDelay` for that step only.

Output format is set by the file extension in `output`: `.mp4`, `.gif`, or `.webm`.

**Step 3 — record:**

```bash
webreel record                     # record all videos in webreel.config.json
webreel record demo-flow           # record a specific video by name
webreel record --verbose           # log each step as it executes
webreel record --dry-run           # validate config without recording
```

**Attach the video to the demo:**

```bash
webreel record demo-flow
showboat image "$DEMO_FILE" /tmp/sb-demo-flow.mp4
```

### Notes on combining the two tools

The typical pattern in a showboat demo:

1. Use agent-browser to drive the live test (interact, assert, take screenshots for the demo doc).
2. Once the flow is confirmed working, write a matching webreel config that scripts the same steps.
3. Run `webreel record` to produce a polished video for the demo doc.

The webreel config should mirror what you did with agent-browser — same URL, same flow, same key interactions. Because webreel has no assertions, the agent-browser run is what proves correctness; webreel just produces the shareable artifact.
