# Browser Tool: Rodney

Load when: taking screenshots, navigating, or interacting with the browser during a demo.

Rodney is a Go binary (distributed as a Python package) that controls a persistent Chrome process via CDP. Each CLI invocation is short-lived; Chrome stays running in the background between commands.

Install: `uv tool install rodney` (recommended) or `pip install rodney`

Requires Google Chrome or Chromium. Set `ROD_CHROME_BIN` to override the binary path.

## Start session

```bash
rodney start              # headless Chrome (default)
rodney start --show       # visible window (useful for debugging)
rodney start --insecure   # ignore TLS errors
rodney connect host:9222  # attach to an already-running Chrome debug port
rodney status             # show browser info and active page
```

Do NOT call `rodney stop` between screenshots in the same demo run. Keep the session open and navigate with `rodney open`.

Session state is stored in `~/.rodney/` by default. Use `--local` to scope state to `./.rodney/state.json` for per-project isolation.

## Navigate

```bash
rodney open <url>         # opens URL; http:// added automatically if omitted
rodney back
rodney forward
rodney reload
rodney reload --hard      # bypass cache
```

## Take a screenshot

```bash
rodney screenshot                             # saves as screenshot.png
rodney screenshot /tmp/sb-<name>.png          # custom path
rodney screenshot -w 1280 -h 720 /tmp/sb-<name>.png  # set viewport size
rodney screenshot-el '<css-selector>' /tmp/sb-<name>.png  # element only
```

Pass to showboat:

```bash
rodney screenshot /tmp/sb-<name>.png
showboat image "$DEMO_FILE" /tmp/sb-<name>.png
```

## Record video

Not supported. Rodney captures screenshots only.

## Interact

All selectors are **CSS selectors** — there is no element ref system.

```bash
rodney click '<selector>'              # click an element
rodney input '<selector>' '<text>'     # type into a field (clears first)
rodney clear '<selector>'              # clear a field
rodney select '<selector>' '<value>'   # pick dropdown option by value
rodney hover '<selector>'              # hover over element
rodney submit '<selector>'             # submit a form
```

**React controlled inputs:** `rodney input` may not fire the synthetic events that React-controlled inputs (react-hook-form, etc.) expect. Use `rodney js` with the native setter pattern instead:

```bash
rodney js "(function(){ var el = document.querySelector('<selector>'); var nativeSetter = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, 'value').set; nativeSetter.call(el, '<value>'); el.dispatchEvent(new Event('input', { bubbles: true })); })()"
```

**JavaScript evaluation:**

```bash
rodney js '<expression>'               # auto-wrapped in () => { return (expr); }
rodney js 'document.title'
rodney js 'document.querySelector("h1").textContent'
```

Use IIFE `(function(){ ... })()` for multi-statement code.

## Wait for stability

Prefer these over `rodney sleep`:

```bash
rodney waitload           # wait for page load event
rodney waitstable         # wait for DOM to stop changing — best for SPAs
rodney waitidle           # wait for network idle
rodney wait '<selector>'  # wait for element to appear in DOM
rodney sleep <seconds>    # fixed wait in seconds, e.g. rodney sleep 2.5 (last resort)
```

## Assert

Exit code 0 on pass, 1 on failure — safe inside `showboat exec`:

```bash
rodney exists '<selector>'                    # assert element exists
rodney visible '<selector>'                   # assert element is visible
rodney count '<selector>'                     # print count of matching elements
rodney assert '<js-expr>'                     # assert JS expression is truthy
rodney assert '<js-expr>' '<expected-value>'  # assert expression equals value
rodney assert '<js-expr>' '<value>' -m "message"  # with custom failure message
```

Read page state:

```bash
rodney text '<selector>'                      # print text content
rodney attr '<selector>' '<attribute>'        # print attribute value
rodney html ['<selector>']                    # print HTML (page or element)
rodney url                                    # print current URL
rodney title                                  # print page title
```

### Selector tips

- Prefer semantic: `button[type=submit]`, `input[name=email]`, `[data-testid=save]`
- When selectors are unclear, inspect with the accessibility tree:

```bash
rodney ax-tree                    # dump full accessibility tree
rodney ax-tree --depth 3          # limit depth
rodney ax-tree --json             # JSON output
rodney ax-find --role button      # find by ARIA role
rodney ax-find --name "Submit"    # find by accessible name
rodney ax-find --role link --name "Home"
rodney ax-node '#submit-btn'      # inspect a specific element's a11y properties
```

## Stop session

```bash
rodney stop     # shut down Chrome
```

## Environment variables

| Variable | Default | Purpose |
|---|---|---|
| `ROD_CHROME_BIN` | auto-detected | Path to Chrome/Chromium binary |
| `ROD_TIMEOUT` | `30` | Default timeout in seconds |
| `RODNEY_HOME` | `~/.rodney` | Data directory |
| `HTTPS_PROXY` / `HTTP_PROXY` | — | Proxy, auto-detected on start |
