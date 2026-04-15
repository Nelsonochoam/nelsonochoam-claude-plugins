# Testing Context Template

Use this template when writing `testing-context.md`. Fill in every section that applies based on the `app_type`. Delete sections that don't apply (e.g., no "Pages & Routes" for a library).

---

```markdown
---
app_name: <Application Name>
app_type: <web-app | api | cli | library | hybrid>
repo: <repo-name>
created: <YYYY-MM-DD>
updated: <YYYY-MM-DD>
tags:
  - showboat/context
---

# Testing Context: <Application Name>

## Environment Setup

### Prerequisites

<!-- List required tools, runtimes, services -->
- Node.js XX+
- PostgreSQL XX (if applicable)
- Redis (if applicable)

### Install Dependencies

```bash
<install command, e.g., npm install>
```

### Dev Server

```bash
<start command, e.g., npm run dev>
```

- **Ready signal**: `<stdout text that means the server is ready, e.g., "Local: http://localhost:3000">`
- **URL**: <http://localhost:PORT>
- **Shutdown**: Ctrl+C / kill process

### Build

```bash
<build command, e.g., npm run build>
```

### Database Setup (if applicable)

```bash
<migration command, e.g., npm run db:migrate>
<seed command, e.g., npm run db:seed>
```

### Environment Variables (if applicable)

<!-- List required env vars WITHOUT secret values -->
- `DATABASE_URL` — connection string
- `API_KEY` — external service key

## Test Suites

### Unit Tests

```bash
<command, e.g., npm test>
```

### Integration Tests

```bash
<command, e.g., npm run test:integration>
```

### End-to-End Tests

```bash
<command, e.g., npm run test:e2e>
```

### Linting & Type Checking

```bash
<lint command, e.g., npm run lint>
<type check command, e.g., npm run typecheck>
```

## Pages & Routes

<!-- For web-app and hybrid types. One subsection per significant page. -->

### / (Home)

- **Description**: <what the page shows>
- **Key elements**: <important UI elements to verify>
- **Verification**: <how to confirm the page works>

### /dashboard

- **Description**: <what the page shows>
- **Key elements**: <important UI elements>
- **Auth required**: yes/no
- **Verification**: <how to confirm>

<!-- Add more pages as discovered -->

## API Endpoints

<!-- For api and hybrid types. One subsection per endpoint or group. -->

### GET /api/health

- **Description**: Health check endpoint
- **Example**: `curl -s http://localhost:<PORT>/api/health`
- **Expected**: `200 OK`, `{"status": "ok"}`

### GET /api/<resource>

- **Description**: <what it returns>
- **Example**: `curl -s http://localhost:<PORT>/api/<resource>?page=1&limit=10`
- **Expected**: `200 OK`, JSON array

### POST /api/<resource>

- **Description**: <what it creates>
- **Example**: `curl -X POST http://localhost:<PORT>/api/<resource> -H 'Content-Type: application/json' -d '{"field": "value"}'`
- **Expected**: `201 Created`, JSON object with id

<!-- Add more endpoints as discovered -->

## CLI Commands

<!-- For cli and hybrid types. One subsection per command. -->

### <tool> <command>

- **Description**: <what it does>
- **Example**: `<tool> <command> --flag value`
- **Expected output**: <what stdout should show>
- **Expected exit code**: 0

<!-- Add more commands as discovered -->

## Common Verification Patterns

<!-- Reusable verification steps that apply across features -->

### Health Check

```bash
curl -s http://localhost:<PORT>/api/health | jq .status
```
Expected: `"ok"`

### Database Seeded

```bash
<seed command> && curl -s http://localhost:<PORT>/api/<resource> | jq length
```
Expected: number > 0

<!-- Add more patterns as discovered -->

## Feature-Specific Testing

<!-- This section grows over time as /showboat-demo creates demos.
     Each entry links back to its demo for traceability.
     Do not modify existing entries when updating the context. -->
```
