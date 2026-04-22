# Browser Tool: Playwright

Load when: taking screenshots, recording video, navigating, or interacting with the browser during a demo.

There are two separate Playwright tools. Use the right one for the job:

- **`npx playwright screenshot`** — built-in, one-shot, no install beyond `playwright`. Good for a quick screenshot of a URL that doesn't require auth or interaction.
- **`playwright-cli`** (`@playwright/cli`) — a separate package designed for AI agents. Session-based like agent-browser: persistent Chrome, refs-based interaction, video recording. Use this when you need to navigate, interact, or record.

---

## Quick screenshots (no interaction needed)

Install: `npm install -g playwright && npx playwright install chromium`

```bash
# Basic screenshot — positional args: <url> <output-file>
npx playwright screenshot https://example.com /tmp/sb-<name>.png

# Full-page (entire scroll height)
npx playwright screenshot --full-page https://example.com /tmp/sb-<name>.png

# Set viewport size
npx playwright screenshot --viewport-size="1280, 720" https://example.com /tmp/sb-<name>.png

# Wait for a selector to appear before capturing
npx playwright screenshot --wait-for-selector=".content-loaded" https://example.com /tmp/sb-<name>.png

# Wait N milliseconds before capturing
npx playwright screenshot --wait-for-timeout=2000 https://example.com /tmp/sb-<name>.png

# Use a specific browser
npx playwright screenshot -b firefox https://example.com /tmp/sb-<name>.png
```

Pass to showboat:

```bash
npx playwright screenshot --full-page https://example.com /tmp/sb-<name>.png
showboat image "$DEMO_FILE" /tmp/sb-<name>.png
```

**Limitation:** no auth, no interaction before the screenshot. For anything that requires login or clicking first, use `playwright-cli` below.

---

## Full sessions: interaction + screenshots + video (playwright-cli)

Install: `npm install -g @playwright/cli`  
Binary: `playwright-cli`

`playwright-cli` maintains browser state between commands via named sessions (`-s=<name>`). Interactions use refs from a snapshot, same pattern as agent-browser.

### Start session

```bash
playwright-cli open <url>                  # default session
playwright-cli -s=demo open <url>          # named session (isolated state)
```

### Navigate

```bash
playwright-cli goto <url>
playwright-cli go-back
playwright-cli go-forward
playwright-cli reload
```

### Take a screenshot

```bash
playwright-cli screenshot --filename=/tmp/sb-<name>.png
playwright-cli screenshot <element-ref> --filename=/tmp/sb-<name>.png   # element only
```

Pass to showboat:

```bash
playwright-cli screenshot --filename=/tmp/sb-<name>.png
showboat image "$DEMO_FILE" /tmp/sb-<name>.png
```

### Record video

```bash
playwright-cli video-start /tmp/sb-<feature>.mp4

# ... all interactions while recording ...

playwright-cli video-stop
showboat image "$DEMO_FILE" /tmp/sb-<feature>.mp4
```

### Interact

Get refs from a snapshot first:

```bash
playwright-cli snapshot           # dump full accessibility snapshot with refs
playwright-cli snapshot -i        # interactive elements only (faster)
```

Then act on refs:

```bash
playwright-cli click <ref>
playwright-cli dblclick <ref>
playwright-cli fill <ref> "text"   # clear then type
playwright-cli type "text"         # type at current focus
playwright-cli press Enter
playwright-cli press Control+a
playwright-cli select <ref> "value"
playwright-cli check <ref>
playwright-cli hover <ref>
playwright-cli scroll down 500
```

### Wait for stability

```bash
playwright-cli wait --load networkidle      # network idle — best for SPAs
playwright-cli wait --load domcontentloaded
playwright-cli wait <selector>              # wait for CSS selector to appear
```

Or add a fixed wait:

```bash
playwright-cli press Tab   # no native wait-ms command; use a small interaction as a pause trigger
```

### Assert

```bash
playwright-cli eval "document.title"        # evaluate JS, print result
playwright-cli eval "<js-expression>" <ref> # evaluate in element context
playwright-cli console                       # print console messages
```

### Stop session

```bash
playwright-cli close              # close current session
playwright-cli close-all          # close all sessions
```
