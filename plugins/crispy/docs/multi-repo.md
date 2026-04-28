# Working Across Multiple Repos

When a feature spans multiple repositories, create a single parent folder with all the related repos inside. Start crispy from that parent folder.

```
projects/          ← run crispy here
  backend/              ← git repo
  frontend/             ← git repo
```

Because `projects/` is not itself a git repo, crispy writes artifacts flat to `<base_dir>/projects/`. All sessions — planning and implementation — share the same intent, design, and plan regardless of which repo you're in.

## Setup

Run `/crispy:init` once and choose **No** when asked about grouping by git repository.

## Workflow

```bash
# Start from the parent folder for planning
cd projects
FEATURE=auth-overhaul claude
```
