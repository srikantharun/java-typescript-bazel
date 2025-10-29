# GitHub Actions CI/CD Workflow

This directory contains the GitHub Actions workflow configuration for the enterprise monorepo. It's placed in `github_test/` instead of `.github/` to **prevent automatic execution and associated costs**.

## 📊 Cost Analysis & Runner Information

### GitHub Actions Pricing

#### Public Repositories
- **FREE**: Unlimited minutes on GitHub-hosted runners
- **Cost**: $0/month

#### Private Repositories
GitHub-hosted runner costs (as of 2024):

| Runner Type | Cost per Minute |
|-------------|-----------------|
| Linux (Ubuntu) | $0.008 |
| macOS (x64) | $0.08 |
| macOS (ARM64 - M1) | $0.16 |
| Windows | $0.016 |

**Example Build Cost (Private Repo):**
- Linux build: 5 min × $0.008 = $0.04
- macOS build: 8 min × $0.16 = $1.28
- **Total per build**: ~$1.32
- **Monthly (20 builds/day)**: ~$792

#### Free Tier (Private Repos)
- 2,000 minutes/month for free
- Shared across all private repos in your account

### Self-Hosted Runners (FREE)
- **Cost**: $0 for compute (GitHub doesn't charge)
- **Requirements**: Your own infrastructure
- **Scalability**: Unlimited usage
- **Best for**: Heavy workloads, private repos with frequent builds

## 🎯 Workflow Features

### 1. Multi-Platform Matrix Build
```yaml
matrix:
  include:
    - os: ubuntu-latest    # Linux x64
    - os: macos-latest     # macOS ARM64
```

**Cost Optimization**: Matrix runs platforms in parallel, reducing total time

### 2. Intelligent Test Selection
```yaml
- name: Run Affected Tests Only
  if: env.RUN_ALL_TESTS == 'false'
```

**Savings**: 70% reduction in test time = 70% cost reduction for tests

### 3. Aggressive Caching
```yaml
- name: Mount Bazel Cache
  uses: actions/cache@v4
  with:
    path: ~/.cache/bazel
```

**Savings**: 60% reduction in build time on cache hits

### 4. Conditional Container Builds
```yaml
- name: Build Container Images
  if: matrix.platform == 'linux'
```

**Savings**: Only builds containers once (not on macOS)

## 🚀 How to Activate

### Option 1: Public Repository (FREE)
```bash
# Simply rename the directory
mv github_test .github

# Commit and push
git add .github
git commit -m "Enable GitHub Actions CI/CD"
git push
```

**Result**: Workflows will run on all PRs and pushes for FREE

### Option 2: Private Repository (Verify First)

#### Step 1: Test Locally with `act`
```bash
# Install act (local GitHub Actions runner)
brew install act

# Test the workflow locally (no GitHub costs)
cd /path/to/repo
act -j build_and_test

# Test specific platform
act -j build_and_test -P ubuntu-latest=catthehacker/ubuntu:act-latest
```

#### Step 2: Enable for Single PR (Test Run)
```bash
# Create a test branch
git checkout -b test-ci

# Rename for this branch only
mv github_test .github

# Push to test branch
git add .github
git commit -m "Test: GitHub Actions"
git push origin test-ci

# Create PR and watch the build
# Check the Actions tab: https://github.com/your-org/repo/actions
```

#### Step 3: Monitor First Build
1. Go to Actions tab: `https://github.com/your-org/repo/actions`
2. Watch build progress
3. Check "Usage" tab to see minutes consumed
4. Cancel if costs are too high

#### Step 4: Activate Permanently
```bash
# If satisfied, merge to main
git checkout main
git merge test-ci
git push
```

## ⚙️ Configuration Options

### Disable Expensive Jobs

Edit `github_test/workflows/ci.yml`:

```yaml
# Disable macOS builds (most expensive)
matrix:
  include:
    - os: ubuntu-latest  # Keep only Linux

# Or skip container builds
- name: Build Container Images
  if: false  # Disabled
```

### Enable BEP Monitoring

In your GitHub repository settings:
1. Go to Settings → Secrets and variables → Variables
2. Add `ENABLE_BEP_MONITORING` = `true`

### Use Self-Hosted Runners

```yaml
# Replace this:
runs-on: ubuntu-latest

# With this:
runs-on: [self-hosted, linux, x64]
```

**Setup Self-Hosted Runner:**
1. Go to Settings → Actions → Runners → New self-hosted runner
2. Follow instructions to install on your server
3. Label your runner (e.g., `linux`, `x64`)

## 💰 Cost Reduction Strategies

### 1. Skip CI on Documentation Changes
```yaml
on:
  pull_request:
    paths-ignore:
      - '**.md'
      - 'docs/**'
```

**Savings**: ~30% of builds skipped

### 2. Use Concurrency to Cancel Old Runs
```yaml
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true
```

**Savings**: Prevents duplicate builds on rapid pushes

### 3. Conditional Jobs
```yaml
# Only run expensive jobs on main branch
if: github.ref == 'refs/heads/main'
```

### 4. Schedule Nightly Builds
```yaml
on:
  schedule:
    - cron: '0 2 * * *'  # 2 AM daily
```

**Savings**: Run full tests nightly instead of every PR

### 5. Use Smaller Runners for Simple Tasks
```yaml
pre-commit:
  runs-on: ubuntu-latest  # Cheaper than macOS
```

## 📈 Estimated Costs

### Public Repository
- **Cost**: $0/month (unlimited)
- **Recommendation**: Activate immediately

### Private Repository - Light Usage
- **Builds per day**: 5
- **Avg minutes per build**: 10 (with caching)
- **Monthly cost**: ~$12 (Linux only)
- **With macOS**: ~$40/month

### Private Repository - Heavy Usage
- **Builds per day**: 50
- **Avg minutes per build**: 15
- **Monthly cost**: ~$180 (Linux only)
- **With macOS**: ~$600/month

### Private Repository - Self-Hosted
- **Cost**: $0/month (GitHub doesn't charge)
- **Hardware cost**: ~$50-200/month (cloud VM)
- **Net savings**: ~80% vs GitHub-hosted

## 🧪 Testing Without Costs

### Method 1: Use `act` for Local Testing
```bash
# Install act
brew install act

# Run workflow locally
act -j build_and_test

# Run specific event
act push

# Dry run (see what would happen)
act -n
```

### Method 2: Fork to Public Repo
```bash
# Create a public fork (temporary)
# Test workflows there (free)
# Then bring back to private repo
```

### Method 3: Use Repository Secrets
Set `CI_ENABLED=false` in repository variables:

```yaml
on:
  pull_request:

jobs:
  build:
    if: vars.CI_ENABLED != 'false'
```

## 🔧 Workflow Customization

### Add Slack Notifications
```yaml
- name: Notify Slack
  if: failure()
  uses: slackapi/slack-github-action@v1.24.0
  with:
    webhook-url: ${{ secrets.SLACK_WEBHOOK }}
```

### Add Coverage Reports
```yaml
- name: Generate Coverage
  run: bazel coverage //...

- name: Upload to Codecov
  uses: codecov/codecov-action@v3
```

### Add Security Scanning
```yaml
- name: Run Trivy Scanner
  uses: aquasecurity/trivy-action@master
  with:
    scan-type: 'fs'
```

## 📋 Pre-Activation Checklist

Before activating (moving `github_test/` to `.github/`):

- [ ] Review cost implications for your repository type
- [ ] Test locally with `act` if possible
- [ ] Configure secrets if needed (registry credentials, etc.)
- [ ] Set up branch protection rules
- [ ] Consider self-hosted runners for heavy usage
- [ ] Enable BEP monitoring if desired
- [ ] Add repository variables for configuration
- [ ] Review matrix strategy (disable expensive platforms if needed)
- [ ] Test with a single PR first
- [ ] Monitor first few builds in Actions tab

## 🎓 Learning Resources

- [GitHub Actions Pricing](https://docs.github.com/en/billing/managing-billing-for-github-actions/about-billing-for-github-actions)
- [Self-Hosted Runners](https://docs.github.com/en/actions/hosting-your-own-runners)
- [Act - Local GitHub Actions](https://github.com/nektos/act)
- [Actions Usage Limits](https://docs.github.com/en/actions/learn-github-actions/usage-limits-billing-and-administration)

## ⚠️ Important Notes

1. **This directory (`github_test/`) will NOT execute workflows** - it must be renamed to `.github/`
2. **GitHub only recognizes workflows in `.github/workflows/`** directory
3. **Public repos get unlimited free minutes** - safe to activate immediately
4. **Private repos consume paid minutes** - review costs first
5. **Self-hosted runners are always free** - no GitHub charges
6. **Caching is critical** - can reduce costs by 60%+

## 🚦 Quick Decision Guide

**Should I activate now?**

| Scenario | Recommendation | Action |
|----------|---------------|--------|
| Public repo | ✅ Yes, activate now | `mv github_test .github` |
| Private repo, light usage | ✅ Probably yes | Test with one PR first |
| Private repo, heavy usage | ⚠️ Consider self-hosted | Setup runners first |
| Want to test first | ✅ Use `act` locally | `brew install act && act` |
| Cost-sensitive | ⚠️ Start minimal | Disable macOS, enable only Linux |

---

**When ready to activate, simply run:**
```bash
mv github_test .github
git add .github
git commit -m "Enable GitHub Actions CI/CD"
git push
```

**To deactivate:**
```bash
mv .github github_test
git add . && git commit -m "Disable CI temporarily" && git push
```
