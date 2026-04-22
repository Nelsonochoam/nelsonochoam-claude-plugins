# Browser Tool: agent-browser

Load when: taking screenshots, recording video, navigating, or interacting with the browser during a demo.

`agent-browser` is a persistent headless Chrome daemon. Start one session, keep it running for all interactions, stop at the end.

Install: `npm install -g agent-browser && agent-browser install`

## Start session

```bash
agent-browser open <url>     # starts the daemon on first use and navigates to the URL
```

The daemon auto-starts when you issue any command. No explicit `start` is needed.

## Navigate

```bash
agent-browser open <url>     # aliases: goto, navigate
agent-browser back
agent-browser forward
agent-browser reload
```

## Take a screenshot

```bash
agent-browser screenshot /tmp/sb-<name>.png          # full-page screenshot
agent-browser screenshot --full /tmp/sb-<name>.png   # full scroll height
```

Pass to showboat:

```bash
agent-browser screenshot /tmp/sb-<name>.png
showboat image "$DEMO_FILE" /tmp/sb-<name>.png
```

## Record video

agent-browser records in WebM format. Start recording before any interaction, stop when done.

```bash
agent-browser record start /tmp/sb-<feature>.webm

# ... perform all interactions while recording ...

agent-browser record stop
showboat image "$DEMO_FILE" /tmp/sb-<feature>.webm
```

Take screenshots at key moments during a recording — both are captured:

```bash
agent-browser record start /tmp/sb-<feature>.webm
agent-browser open <url>
agent-browser screenshot /tmp/sb-<name>-before.png
# interact...
agent-browser screenshot /tmp/sb-<name>-after.png
agent-browser record stop
```

Always stop the recording on exit:

```bash
cleanup() { agent-browser record stop 2>/dev/null || true; agent-browser close 2>/dev/null || true; }
trap cleanup EXIT
```

## Interact

Interactions use **refs** from a snapshot. Get refs first, then act on them:

```bash
agent-browser snapshot -i    # list interactive elements; each gets a ref like @e1, @e2
```

Then:

```bash
agent-browser click @e1                    # click by ref
agent-browser fill @e2 "text"              # clear field and type
agent-browser type @e2 "text"              # type without clearing
agent-browser press Enter
agent-browser press Control+a
agent-browser select @e1 "value"           # dropdown
agent-browser check @e1                    # checkbox
agent-browser scroll down 500
agent-browser hover @e1
```

**Semantic locators** (no snapshot needed):

```bash
agent-browser find text "Sign In" click
agent-browser find role button click --name "Submit"
agent-browser find label "Email" fill "user@test.com"
agent-browser find testid "submit-btn" click
agent-browser find placeholder "Search" type "query"
```

Raw CSS selectors also work: `agent-browser click "#submit-btn"`.

## Wait for stability

```bash
agent-browser wait --load networkidle     # network idle — best for SPAs
agent-browser wait --load domcontentloaded
agent-browser wait @e1                   # wait for a specific element ref to appear
agent-browser wait --text "Success"      # wait until text appears on page
agent-browser wait --url "**/dashboard"  # wait for URL glob pattern
agent-browser wait 2000                  # fixed wait ms (last resort)
```

## Assert

Exit code is non-zero on failure — safe inside `showboat exec`:

```bash
agent-browser is visible @e1             # assert element is visible
agent-browser is enabled @e1
agent-browser is checked @e1
```

Read page state:

```bash
agent-browser get text @e1              # print element text
agent-browser get value @e1             # print input value
agent-browser get attr @e1 href
agent-browser get title
agent-browser get url
agent-browser get count ".item"
agent-browser eval "document.title"     # evaluate JavaScript, print result
```

## Stop session

```bash
agent-browser close      # aliases: quit, exit
```
