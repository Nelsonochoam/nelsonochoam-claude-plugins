# Testing Commands Reference

## Rodney — Browser Automation

Rodney controls a persistent Chrome session. Start once, keep it running across all interactions, stop at the end.

### Session

```bash
rodney start              # launch Chrome headless
rodney start --show       # launch with visible window
rodney stop               # shut down Chrome
rodney status             # check if browser is running
```

### Navigation

```bash
rodney open <url>         # navigate to URL
rodney reload             # reload current page
rodney back / forward     # history navigation
```

### Waiting (prefer over sleep)

```bash
rodney waitload           # wait for page load event
rodney waitstable         # wait for DOM to stop changing — best for SPAs
rodney waitidle           # wait for network to go idle
rodney wait <selector>    # wait for element to appear in DOM
rodney sleep <seconds>    # fixed wait (last resort)
```

### Interaction

```bash
rodney click <selector>              # click an element
rodney input <selector> <text>       # type into a field
rodney clear <selector>              # clear a field
rodney select <selector> <value>     # pick dropdown option by value
rodney hover <selector>              # hover over element
rodney submit <selector>             # submit a form
rodney js '<expression>'             # evaluate JavaScript and print result
```

### Reading Page State

```bash
rodney text <selector>               # print text content
rodney attr <selector> <name>        # print attribute value
rodney html [selector]               # print HTML (page or element)
rodney url                           # print current URL
rodney title                         # print page title
```

### Assertions (exit 1 on failure — safe inside showboat exec)

```bash
rodney exists <selector>             # assert element exists
rodney visible <selector>            # assert element is visible
rodney count <selector>              # print count of matching elements
rodney assert '<js-expr>'            # assert JS expression is truthy
rodney assert '<js-expr>' '<value>'  # assert expression equals value
```

### Screenshots

```bash
rodney screenshot [file]             # full-page screenshot
rodney screenshot-el <sel> [file]   # screenshot a specific element
```

Pass the output to showboat image:

```bash
rodney screenshot /tmp/sb-<name>.png
showboat image "$DEMO_FILE" /tmp/sb-<name>.png
```

### Accessibility (when selectors are unclear)

```bash
rodney ax-tree               # dump accessibility tree
rodney ax-tree --depth 3     # limit depth
rodney ax-find --name "Save" # find node by accessible name
rodney ax-find --role button # find nodes by ARIA role
```

### Selector Tips

- Prefer semantic selectors: `button[type=submit]`, `input[name=email]`, `[data-testid=save]`
- When selectors are unclear, use `rodney ax-tree` or `rodney html` to inspect first
- For text-based matching: `rodney js 'Array.from(document.querySelectorAll("button")).find(b => b.textContent.trim() === "Save")'`

---

## Curl — API Verification

Use inside `showboat exec` to capture API calls as proof. Prove specific behavior — not just a 200 status, but that the response contains the right data.

### Basic requests

```bash
# GET
showboat exec "$DEMO_FILE" bash "curl -s '<url>' | jq ."

# GET with auth
showboat exec "$DEMO_FILE" bash "curl -s '<url>' -H 'Authorization: Bearer <token>' | jq ."

# POST
showboat exec "$DEMO_FILE" bash "curl -s -X POST '<url>' \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer <token>' \
  -d '{\"key\": \"value\"}' | jq ."

# PATCH / PUT
showboat exec "$DEMO_FILE" bash "curl -s -X PATCH '<url>/<id>' \
  -H 'Content-Type: application/json' \
  -d '{\"field\": \"new-value\"}' | jq ."

# DELETE — show status code
showboat exec "$DEMO_FILE" bash "curl -s -X DELETE '<url>/<id>' \
  -o /dev/null -w 'HTTP %{http_code}'"
```

### Assert specific fields

```bash
# Extract a single field
showboat exec "$DEMO_FILE" bash "curl -s '<url>' | jq '.<field>'"

# Show only relevant fields
showboat exec "$DEMO_FILE" bash "curl -s '<url>' | jq '{id, status, name}'"
```

### End-to-end flow (create then retrieve)

```bash
showboat note "$DEMO_FILE" "Create a record, then retrieve it to confirm persistence:"
showboat exec "$DEMO_FILE" bash "curl -s -X POST '<create-url>' \
  -H 'Content-Type: application/json' \
  -d '{\"name\": \"test\"}' | jq ."
showboat exec "$DEMO_FILE" bash "curl -s '<list-url>' | jq '.[] | select(.name == \"test\")'"
```

### Other useful patterns

```bash
# Check status code only
showboat exec "$DEMO_FILE" bash "curl -s -o /dev/null -w 'HTTP %{http_code}' '<url>'"

# Paginated: show count and sample
showboat exec "$DEMO_FILE" bash "curl -s '<url>' | jq '{count: (.data | length), sample: .data[0]}'"

# Cookie-based auth (login first, reuse cookies)
showboat exec "$DEMO_FILE" bash "curl -s -X POST '<login-url>' \
  -c /tmp/demo-cookies.txt \
  -d 'email=<email>&password=<pass>'"
showboat exec "$DEMO_FILE" bash "curl -s '<url>' -b /tmp/demo-cookies.txt | jq ."
```
