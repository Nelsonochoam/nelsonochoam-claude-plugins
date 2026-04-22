# Testing Commands Reference

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
