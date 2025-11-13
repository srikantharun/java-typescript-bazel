# Backstage Quick Start Demo (2-3 Hours)

## Goal
Run Backstage locally, import your existing GitHub repos, and understand the platform before your interview.

---

## Prerequisites

```bash
# Check you have Node.js 18+ and Yarn
node --version  # Should be v18 or higher
yarn --version  # Should be 1.22+

# If not installed:
# macOS
brew install node@18
npm install -g yarn
```

---

## Part 1: Create Backstage App (15 minutes)

### Step 1: Create app using official CLI

```bash
# Navigate to a workspace directory (not inside java-typescript-bazel)
cd ~/

# Create new Backstage app
npx @backstage/create-app@latest

# You'll be prompted:
# ? Enter a name for the app [required] → dwp-backstage-demo
# ? Select database for the backend [required] → SQLite
```

This creates:
```
dwp-backstage-demo/
├── app-config.yaml          # Main configuration
├── packages/
│   ├── app/                 # Frontend React app
│   └── backend/             # Backend Node.js API
├── plugins/                 # Custom plugins go here
└── package.json
```

### Step 2: Start Backstage

```bash
cd dwp-backstage-demo
yarn install
yarn dev
```

**Expected output:**
```
[0] webpack compiled successfully
[1] backstage backend has started on port 7007
```

Open browser: http://localhost:3000

You'll see:
- Empty software catalog
- "Welcome to Backstage" page

---

## Part 2: Connect to Your GitHub (30 minutes)

### Step 1: Create GitHub Personal Access Token

1. Go to https://github.com/settings/tokens
2. Click "Generate new token (classic)"
3. Scopes needed:
   - ✅ `repo` (all)
   - ✅ `workflow`
   - ✅ `read:org`
   - ✅ `read:user`
   - ✅ `user:email`
4. Generate and **copy the token**

### Step 2: Configure Backstage to use GitHub

Edit `app-config.yaml`:

```yaml
# app-config.yaml

app:
  title: DWP Backstage Demo
  baseUrl: http://localhost:3000

organization:
  name: DWP Demo

backend:
  baseUrl: http://localhost:7007
  listen:
    port: 7007
  csp:
    connect-src: ["'self'", 'http:', 'https:']
  cors:
    origin: http://localhost:3000
    methods: [GET, HEAD, PATCH, POST, PUT, DELETE]
    credentials: true
  database:
    client: better-sqlite3
    connection: ':memory:'

integrations:
  github:
    - host: github.com
      token: ${GITHUB_TOKEN}  # Read from environment variable

catalog:
  import:
    entityFilename: catalog-info.yaml
    pullRequestBranchName: backstage-integration
  rules:
    - allow: [Component, System, API, Resource, Location]
  locations:
    # Import your java-typescript-bazel repo
    - type: url
      target: https://github.com/srikantharun/java-typescript-bazel/blob/main/catalog-info.yaml
      rules:
        - allow: [Component]
```

### Step 3: Create catalog-info.yaml in your repo

We'll create a catalog file for your java-typescript-bazel project:

```bash
# Go to your java-typescript-bazel repo
cd ~/java-typescript-bazel
```

Create `catalog-info.yaml`:

```yaml
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: java-typescript-bazel
  description: Enterprise monorepo demonstrating Bazel build system with Java and TypeScript
  annotations:
    github.com/project-slug: srikantharun/java-typescript-bazel
    backstage.io/techdocs-ref: dir:.
  tags:
    - bazel
    - java
    - typescript
    - monorepo
    - build-system
  links:
    - url: https://github.com/srikantharun/java-typescript-bazel
      title: GitHub Repository
      icon: github
    - url: https://github.com/srikantharun/java-typescript-bazel/actions
      title: CI/CD Pipelines
      icon: dashboard
spec:
  type: library
  lifecycle: production
  owner: platform-team
  system: build-infrastructure
```

Commit and push:

```bash
git add catalog-info.yaml
git commit -m "Add Backstage catalog metadata"
git push
```

### Step 4: Start Backstage with GitHub token

```bash
cd ~/dwp-backstage-demo

# Set GitHub token as environment variable
export GITHUB_TOKEN=ghp_YOUR_TOKEN_HERE

# Start Backstage
yarn dev
```

### Step 5: Verify integration

1. Open http://localhost:3000/catalog
2. You should see your `java-typescript-bazel` component!
3. Click on it to see details

---

## Part 3: Explore GitHub Actions Plugin (45 minutes)

Backstage has a **built-in GitHub Actions plugin** - let's enable it!

### Step 1: Install GitHub Actions plugin

```bash
cd ~/dwp-backstage-demo

# Install frontend plugin
yarn --cwd packages/app add @backstage/plugin-github-actions
```

### Step 2: Add plugin to Entity Page

Edit `packages/app/src/components/catalog/EntityPage.tsx`:

```typescript
// Add imports at the top
import {
  EntityGithubActionsContent,
  isGithubActionsAvailable,
} from '@backstage/plugin-github-actions';

// Find the `serviceEntityPage` constant and add CI/CD tab:

const serviceEntityPage = (
  <EntityLayout>
    <EntityLayout.Route path="/" title="Overview">
      <Grid container spacing={3} alignItems="stretch">
        <Grid item md={6}>
          <EntityAboutCard variant="gridItem" />
        </Grid>
        {/* ... other overview components ... */}
      </Grid>
    </EntityLayout.Route>

    {/* ADD THIS NEW ROUTE */}
    <EntityLayout.Route
      path="/ci-cd"
      title="CI/CD"
      if={isGithubActionsAvailable}
    >
      <EntityGithubActionsContent />
    </EntityLayout.Route>

    {/* ... other existing routes ... */}
  </EntityLayout>
);
```

### Step 3: Restart Backstage

```bash
# Stop with Ctrl+C
# Restart
yarn dev
```

### Step 4: View GitHub Actions in Backstage

1. Go to http://localhost:3000/catalog
2. Click on `java-typescript-bazel` component
3. You should now see a **CI/CD tab**!
4. It shows your GitHub Actions workflows

---

## Part 4: Add More Components (30 minutes)

Let's make it more impressive by adding multiple components.

### Create catalog-info.yaml for DWP documents project

```bash
cd ~/java-typescript-bazel

# Create another catalog entry for your DWP application work
cat > dwp-application-catalog-info.yaml << 'EOF'
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: dwp-developer-experience-application
  description: Application materials for DWP Developer Experience Engineer role
  tags:
    - documentation
    - interview-prep
    - developer-experience
spec:
  type: documentation
  lifecycle: active
  owner: platform-team
  system: career-development
EOF
```

### Update app-config.yaml to import multiple files

```yaml
# app-config.yaml

catalog:
  locations:
    - type: url
      target: https://github.com/srikantharun/java-typescript-bazel/blob/main/catalog-info.yaml

    - type: url
      target: https://github.com/srikantharun/java-typescript-bazel/blob/main/dwp-application-catalog-info.yaml
```

---

## Part 5: Explore Key Features (30 minutes)

Now that you have Backstage running, explore:

### 1. Software Catalog
- http://localhost:3000/catalog
- Filter by tags, owners, types
- Search functionality

### 2. API Documentation
- Click on your component
- Navigate through tabs
- See how metadata is displayed

### 3. Create > Templates (Software Templates)
- http://localhost:3000/create
- Pre-built templates for scaffolding new projects
- This is what you'd use to standardize new services

### 4. Docs (TechDocs)
- Backstage can render README.md files
- Docs-as-code approach

### 5. Settings
- http://localhost:3000/settings
- User profile, theme preferences

---

## What You've Achieved

✅ **Running Backstage locally**
✅ **Integrated with GitHub**
✅ **Imported your own repositories**
✅ **Enabled GitHub Actions plugin**
✅ **Understand Backstage architecture**

---

## For Your Interview Tomorrow

You can now confidently say:

> "After learning about the role yesterday, I spun up a local Backstage instance last night to familiarize myself with the platform. I integrated it with my GitHub repositories, enabled the GitHub Actions plugin, and can see how the catalog-info.yaml metadata drives the entire portal.
>
> I explored the plugin architecture and understand how the GitLab CI integration would follow a similar pattern - a backend plugin calling the GitLab API with caching, and a frontend plugin displaying pipelines in the service catalog. The annotation-based approach is elegant because it keeps metadata with the code.
>
> While I did this in a few hours, I can see the power of Backstage for DWP - it would provide a unified portal for thousands of services, standardize onboarding with templates, and give engineers a single place to discover services, view CI/CD status, and access documentation."

This shows:
- 🔥 **Initiative** - You didn't wait to be asked
- 🔥 **Fast learner** - Backstage in one evening
- 🔥 **Hands-on** - You actually built something
- 🔥 **Connected to role** - Understood how it applies to DWP

---

## Troubleshooting

### Port conflicts
```bash
# If port 3000 or 7007 are in use
lsof -ti:3000 | xargs kill -9
lsof -ti:7007 | xargs kill -9
```

### GitHub token issues
```bash
# Verify token is set
echo $GITHUB_TOKEN

# Try re-exporting
export GITHUB_TOKEN=ghp_your_token_here
```

### Dependencies issues
```bash
# Clean install
rm -rf node_modules
yarn install
```

### Can't see GitHub Actions tab
- Make sure you have workflows in your repo (you do!)
- Check that annotation exists in catalog-info.yaml
- Verify GitHub token has `workflow` scope

---

## Next Steps After Interview

If you want to build a full GitLab CI plugin (great portfolio piece):

### Phase 1: Backend Plugin
```bash
cd ~/dwp-backstage-demo
yarn new --select backend-plugin
# Plugin ID: gitlab-ci
```

Implement:
- GitLabClient.ts (API wrapper)
- Cache layer (Redis or in-memory)
- REST endpoints

### Phase 2: Frontend Plugin
```bash
yarn new --select plugin
# Plugin ID: gitlab-ci
```

Implement:
- React components (PipelineList, PipelineDetails)
- API client
- Integration with entity page

### Phase 3: Demo with GitLab.com
- Create free GitLab.com account
- Create sample project with CI/CD
- Connect Backstage to GitLab
- Show pipeline status in portal

**Estimated time: 1-2 days for full implementation**

---

## Quick Reference Commands

```bash
# Start Backstage
cd ~/dwp-backstage-demo
export GITHUB_TOKEN=ghp_xxx
yarn dev

# View logs
# Frontend: localhost:3000
# Backend API: localhost:7007
# Backend health: http://localhost:7007/healthcheck

# Add new plugin
yarn new

# Install dependencies
yarn install

# Clean rebuild
yarn clean && yarn install && yarn dev
```

---

## Architecture Reference

```
┌─────────────────────────────────────────────────────────┐
│  Browser (localhost:3000)                               │
│  ┌───────────────────────────────────────────────────┐ │
│  │  React Frontend (packages/app/)                   │ │
│  │  - Software Catalog UI                            │ │
│  │  - Plugin UIs (GitHub Actions, etc.)              │ │
│  └───────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
                         │
                         │ HTTP API Calls
                         ▼
┌─────────────────────────────────────────────────────────┐
│  Backend (localhost:7007)                               │
│  ┌───────────────────────────────────────────────────┐ │
│  │  Node.js/Express (packages/backend/)              │ │
│  │  - Catalog API                                    │ │
│  │  - Plugin backends (GitHub integration)           │ │
│  │  - Authentication                                 │ │
│  └───────────────────────────────────────────────────┘ │
│  ┌───────────────────────────────────────────────────┐ │
│  │  SQLite Database                                  │ │
│  │  - Component metadata                             │ │
│  │  - User data                                      │ │
│  └───────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
                         │
                         │ GitHub API Calls
                         ▼
┌─────────────────────────────────────────────────────────┐
│  GitHub.com                                             │
│  - Repository metadata                                  │
│  - GitHub Actions workflows                             │
│  - Source code                                          │
└─────────────────────────────────────────────────────────┘
```

---

Good luck! This is achievable tonight and will make a huge impression in your interview. 🚀
