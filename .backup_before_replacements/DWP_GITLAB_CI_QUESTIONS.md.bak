# DWP Interview - GitLab CI Specific Questions & Answers

Based on your europa-main project experience and the DWP role requirements.

---

## Part 1: TypeScript/Node.js in Backstage

### Q: What is TypeScript and Node.js doing in the Backstage repo?

**Answer:**

"Backstage is built with TypeScript and Node.js for both frontend and backend:

**Frontend (TypeScript + React):**
- `/packages/app/` - React application written in TypeScript
- Plugin UIs (like the GitLab CI plugin) are React components
- Type safety ensures plugin APIs are consistent
- Example: When displaying pipeline data, TypeScript ensures the data shape matches expectations

**Backend (Node.js + Express):**
- `/packages/backend/` - Node.js API server
- Handles authentication, proxies external APIs (GitLab, GitHub)
- Implements caching, database access
- Example: GitLab CI plugin backend would:
  ```typescript
  // Backend plugin calling GitLab API
  router.get('/pipelines/:projectId', async (req, res) => {
    const pipelines = await gitlabClient.getPipelines(projectId);
    res.json(pipelines);
  });
  ```

**Why TypeScript/Node.js?**
- Full-stack JavaScript ecosystem
- Excellent for building web APIs and UIs
- Large plugin ecosystem
- Fast development iteration"

---

## Part 2: GitLab CI Development Requirements at DWP

### Q: If GitLab CI requires changes, what development work would be needed?

**Answer based on your experience:**

"At DWP, there are three levels of GitLab CI work:

**Level 1: Modifying Shared CI/CD Components (Most Common)**

Based on my experience at Axelera building reusable GitLab CI components:

```yaml
# Example: Updating a shared component template
# .gitlab/ci/templates/docker-build.yml

.docker_build_template:
  stage: build
  image: docker:24
  script:
    - docker build -t $IMAGE_NAME .
    - docker push $IMAGE_NAME
  cache:
    key: docker-$CI_COMMIT_REF_SLUG
    paths:
      - .docker-cache
  rules:
    - if: '$CI_PIPELINE_SOURCE == "merge_request_event"'
      when: manual
    - if: '$CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH'
      when: always
```

**Changes might include:**
- Adding new parameters (e.g., `DOCKER_REGISTRY` variable)
- Improving caching strategies
- Adding security scanning stages
- Optimizing for DWP's infrastructure

**Languages used:** YAML (pipeline definitions) + Bash (scripts)

**Level 2: Building Backstage GitLab CI Plugin (Your Role)**

This is where TypeScript/Node.js comes in:

**Backend Plugin (Node.js/TypeScript):**
```typescript
// packages/gitlab-ci-backend/src/GitLabClient.ts
export class GitLabClient {
  private client: AxiosInstance;

  async getPipelines(projectId: string): Promise<Pipeline[]> {
    const response = await this.client.get(
      `/api/v4/projects/${projectId}/pipelines`
    );
    return response.data;
  }

  async triggerPipeline(projectId: string, ref: string) {
    return await this.client.post(
      `/api/v4/projects/${projectId}/pipeline`,
      { ref }
    );
  }
}
```

**Frontend Plugin (TypeScript/React):**
```typescript
// packages/gitlab-ci/src/components/PipelineList.tsx
export const PipelineList = () => {
  const { entity } = useEntity();
  const gitlabApi = useApi(gitlabCiApiRef);

  const { value: pipelines } = useAsync(async () => {
    const projectId = entity.metadata.annotations?.['gitlab.com/project-id'];
    return await gitlabApi.getPipelines(projectId);
  });

  return (
    <Table
      data={pipelines}
      columns={[
        { title: 'Pipeline', field: 'id' },
        { title: 'Status', field: 'status' },
        { title: 'Branch', field: 'ref' }
      ]}
    />
  );
};
```

**Level 3: Advanced Pipeline Automation (Python/Bash)**

For dynamic job generation (like your europa-main project):

```python
# scripts/generate_pipeline.py
import yaml
import os

def generate_jobs_for_components(components):
    jobs = {}
    for component in components:
        jobs[f'build_{component}'] = {
            'stage': 'build',
            'script': [f'bazel build //components/{component}/...'],
            'rules': [{'changes': [f'components/{component}/**/*']}]
        }
    return jobs

# Generate dynamic pipeline YAML
components = os.listdir('components/')
pipeline = generate_jobs_for_components(components)
with open('.gitlab-ci-generated.yml', 'w') as f:
    yaml.dump(pipeline, f)
```

---

## Part 3: GitLab CI Questions Based on Europa-Main

### Q1: Explain the Europa pipeline structure

**Your Answer:**

"In europa-main, I see a **modular GitLab CI architecture**:

**Main Pipeline Structure:**
```
.gitlab-ci.yml (top level)
  ├── includes: .gitlab/ci/config.gitlab-ci.yml (global config)
  └── includes: .gitlab/ci/pipelines/static/* (static jobs)
      └── includes: dynamic/*.gitlab-ci.yml (per-component pipelines)
```

**Key Components:**

1. **config.gitlab-ci.yml** - Global settings:
   - Default configurations (interruptible jobs)
   - Jacamar authentication for HPC clusters
   - Variables (CMAKE_GENERATOR, versions)
   - Stages: dynamic → validate → build → test → release → publish

2. **Dynamic Pipelines** - Per-component CI:
   - `dwm.gitlab-ci.yml`, `l1.gitlab-ci.yml`, `l2.gitlab-ci.yml`
   - Each hardware IP block has its own pipeline
   - Generated based on repository structure

3. **Slurm Integration:**
   - `SCHEDULER_PARAMETERS: '-N1 --cpus-per-task 1'`
   - Jobs run on HPC clusters via Jacamar (GitLab executor for Slurm)

**This architecture is similar to what DWP needs:**
- Reusable components (templates)
- Dynamic job generation (only test what changed)
- Modular organization (scales to many teams)"

### Q2: How would you adapt europa-main patterns to DWP?

**Your Answer:**

"DWP likely has similar requirements - multiple services/components needing CI/CD. Here's how I'd adapt:

**Pattern 1: Reusable Templates (Already in europa-main)**

```yaml
# DWP version
# .gitlab/ci/templates/terraform-deploy.yml

.terraform_deploy_template:
  stage: deploy
  image: hashicorp/terraform:1.5
  script:
    - terraform init
    - terraform plan -out=tfplan
    - terraform apply tfplan
  rules:
    - if: '$CI_COMMIT_BRANCH == "main"'
      when: manual
  artifacts:
    paths:
      - tfplan
```

**Pattern 2: Dynamic Job Generation**

From europa-main's approach with multiple IP blocks → DWP with multiple microservices:

```python
# scripts/generate_service_pipelines.py
import os
import yaml

services = [d for d in os.listdir('services/') if os.path.isdir(f'services/{d}')]

pipeline = {'include': []}
for service in services:
    pipeline['include'].append({
        'local': f'.gitlab/ci/services/{service}.gitlab-ci.yml',
        'rules': [{'changes': [f'services/{service}/**/*']}]
    })

with open('.gitlab-ci-generated.yml', 'w') as f:
    yaml.dump(pipeline, f)
```

**Pattern 3: Staged Rollout**

```yaml
# Based on europa's stages: build → test → release
stages:
  - validate      # Linting, security scans
  - build         # Docker images, artifacts
  - test          # Unit, integration tests
  - deploy-dev    # Automatic to dev
  - deploy-stage  # Manual to staging
  - deploy-prod   # Manual to production (with approval)
```

**Pattern 4: Caching Strategy**

Europa uses: `XDG_CACHE_HOME: '/local/workspace/gitlab-runner/cache'`

DWP equivalent:
```yaml
cache:
  key: ${CI_COMMIT_REF_SLUG}
  paths:
    - node_modules/
    - .terraform/
    - target/  # Maven/Gradle
```

### Q3: How would you integrate GitLab CI with Backstage at DWP?

**Your Answer:**

"Based on europa-main's structure and my Backstage demo:

**Step 1: Catalog Integration**

Each service in europa-main (dwm, l1, l2) would have:

```yaml
# services/payment-api/catalog-info.yaml
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: payment-api
  annotations:
    gitlab.com/project-slug: dwp/payments/payment-api
    gitlab.com/project-id: '12345'
spec:
  type: service
  owner: team-payments
```

**Step 2: Backend Plugin Queries GitLab**

```typescript
// Backstage backend
async getPipelines(projectId: string) {
  // Query GitLab API
  const response = await fetch(
    `https://gitlab.dwp.gov.uk/api/v4/projects/${projectId}/pipelines`,
    { headers: { 'PRIVATE-TOKEN': this.token } }
  );
  return response.json();
}
```

**Step 3: Frontend Displays Status**

```
┌──────────────────────────────────────────┐
│  payment-api → CI/CD                     │
│                                          │
│  Pipeline #456  ✅ Passed (4m 30s)      │
│  ├─ validate    ✅  0m 45s              │
│  ├─ build       ✅  2m 10s              │
│  ├─ test        ✅  1m 20s              │
│  └─ deploy-dev  ✅  0m 15s              │
│                                          │
│  [View in GitLab] [Trigger New Build]   │
└──────────────────────────────────────────┘
```

**Step 4: Dynamic Pipeline Visibility**

For europa-main's dynamic pipelines, Backstage would:
- Show per-component build status (dwm, l1, l2)
- Display which IP blocks are building
- Link to Slurm job logs
- Show test results by component

**Benefits:**
- Engineers see build status without leaving Backstage
- Service owners get notifications on failures
- Historical trends (build time improvements)
- Dependency-aware CI (show what triggered rebuild)"

---

## Part 4: Specific Technical Questions You Might Get

### Q4: How do you handle secrets in GitLab CI?

**Your Answer:**

"Based on best practices and DWP's security requirements:

**1. GitLab CI/CD Variables (Preferred at DWP):**
```yaml
# Settings → CI/CD → Variables
# Mark as: Protected, Masked
variables:
  DEPLOY_TOKEN: $GITLAB_DEPLOY_TOKEN  # Injected securely

deploy:
  script:
    - kubectl apply -f deployment.yaml
      --token=$DEPLOY_TOKEN  # Never in code
```

**2. HashiCorp Vault Integration (for sensitive secrets):**
```yaml
secrets:
  DATABASE_PASSWORD:
    vault: production/db/password@secrets
    file: false

deploy:
  id_tokens:
    VAULT_ID_TOKEN:
      aud: https://vault.dwp.gov.uk
  script:
    - export DB_PASS=$(cat $DATABASE_PASSWORD)
```

**3. What NOT to do:**
- ❌ Never commit secrets to `.gitlab-ci.yml`
- ❌ Never echo secrets in logs
- ❌ Never use unmasked variables for sensitive data

**At Axelera, I used:**
- Jacamar's `id_tokens` for HPC authentication (similar to europa-main)
- GitLab protected variables for deployment tokens
- Vault for database credentials"

### Q5: How do you optimize GitLab CI pipeline performance?

**Your Answer:**

"At Axelera, I reduced CI time by 70% using these strategies (applicable to DWP):

**1. Caching Dependencies**
```yaml
build:
  cache:
    key: ${CI_COMMIT_REF_SLUG}
    paths:
      - node_modules/
      - .m2/repository/  # Maven
  script:
    - npm install  # Uses cache
    - mvn package  # Uses cache
```

**2. Parallel Execution**
```yaml
test:
  parallel:
    matrix:
      - SERVICE: [auth, payment, user]
  script:
    - bazel test //services/${SERVICE}/...
```

**3. Smart Job Execution (Only run what changed)**
```yaml
build-service-a:
  rules:
    - changes:
        - services/service-a/**/*
  script:
    - bazel build //services/service-a/...
```

**4. Docker Layer Caching**
```yaml
build:
  image: docker:24
  services:
    - docker:24-dind
  variables:
    DOCKER_BUILDKIT: 1
  script:
    - docker build --cache-from $CI_REGISTRY_IMAGE:latest .
```

**5. Artifacts for Downstream Jobs**
```yaml
build:
  artifacts:
    paths:
      - target/*.jar
    expire_in: 1 hour

test:
  needs: [build]  # Don't re-build, use artifact
  script:
    - java -jar target/app.jar --test
```

**Results at Axelera:**
- Pipeline time: 25 min → 7 min
- Only affected tests run (70% reduction)
- Caching saved 2-3 min per build"

### Q6: How do you ensure GitLab CI components are maintainable?

**Your Answer:**

"Based on my experience maintaining components for 15+ projects at Axelera:

**1. Versioning Strategy**
```yaml
# Consumers pin to versions
include:
  - project: 'dwp/ci-templates'
    file: '/templates/terraform-deploy.yml'
    ref: 'v1.2.0'  # Semantic versioning
```

**2. Backwards Compatibility**
```yaml
# Old parameter still works (deprecated)
.deploy_template:
  script:
    - |
      if [ -n "$DEPLOY_ENV" ]; then
        echo "WARN: DEPLOY_ENV is deprecated, use ENVIRONMENT"
        ENVIRONMENT=${DEPLOY_ENV}
      fi
    - terraform apply -var="env=${ENVIRONMENT}"
```

**3. Testing CI Components**
```yaml
# Test pipeline changes before merging
test-component:
  stage: test
  script:
    - |
      # Simulate using the template
      gitlab-ci-local --file .gitlab-ci.yml
```

**4. Documentation**
```yaml
# .gitlab/ci/templates/docker-build.yml
#
# Docker Build Template
# Version: v1.2.0
#
# Usage:
#   include:
#     - local: '.gitlab/ci/templates/docker-build.yml'
#
#   build:
#     extends: .docker_build_template
#     variables:
#       IMAGE_NAME: my-app
#
# Parameters:
#   IMAGE_NAME (required): Docker image name
#   DOCKERFILE_PATH (optional): Path to Dockerfile (default: Dockerfile)
```

**5. Migration Support**
- Announce deprecations 6 months ahead
- Provide migration scripts
- Run office hours for teams upgrading
- Track adoption (who's on old versions)"

---

## Part 5: Challenging Scenario Questions

### Q7: A team complains your shared GitLab CI component is too slow. How do you investigate?

**Your Answer:**

"I'd use a systematic approach:

**Step 1: Data Collection**
```yaml
# Add timing instrumentation
.build_template:
  before_script:
    - echo \"BUILD_START=$(date +%s)\" >> timings.txt
  script:
    - time npm install  # Measure each step
    - time npm run build
  after_script:
    - echo \"BUILD_END=$(date +%s)\" >> timings.txt
    - cat timings.txt
```

**Step 2: Identify Bottleneck**

Common culprits:
1. **No caching** → Downloads dependencies every time
2. **Sequential jobs** → Could run in parallel
3. **Large Docker images** → Use multi-stage builds
4. **Unnecessary steps** → Running on every branch

**Step 3: Optimize**

Example fix:
```yaml
# Before: 5 minutes
build:
  script:
    - apt-get update && apt-get install -y nodejs npm  # 2 min
    - npm install  # 2 min (no cache)
    - npm run build  # 1 min

# After: 1.5 minutes
build:
  image: node:20-alpine  # Pre-installed Node (saves 2 min)
  cache:
    key: ${CI_COMMIT_REF_SLUG}
    paths:
      - node_modules/  # Reuse (saves 1.5 min)
  script:
    - npm install  # 30s (cached)
    - npm run build  # 1 min
```

**Step 4: Measure & Communicate**
- Before: 5 min
- After: 1.5 min
- 70% improvement
- Document optimization in changelog"

### Q8: How would you roll out a breaking change to a GitLab CI component used by 50 teams?

**Your Answer:**

"This happened at Axelera when we needed to upgrade our CI runner image. Here's my approach:

**Phase 1: Communication (Week 1-2)**
```
Subject: [Action Required] CI Component Upgrade - v2.0

Timeline:
- Now: v2.0 released (opt-in)
- Week 4: v1.x deprecated (warnings added)
- Week 12: v1.x removed

What's Changing:
- Runner image: ubuntu:20.04 → ubuntu:22.04
- Python: 3.8 → 3.10
- Node: 14 → 18

Migration Guide:
https://wiki.dwp.gov.uk/ci-migration-v2

Support:
- Office hours: Tuesdays 10-11am
- Slack: #ci-cd-support
```

**Phase 2: Parallel Versions (Week 3-12)**
```yaml
# Both versions available
include:
  # Old (deprecated)
  - project: 'ci-templates'
    file: '/templates/build.yml'
    ref: 'v1.5.0'  # Still works

  # New (recommended)
  - project: 'ci-templates'
    file: '/templates/build.yml'
    ref: 'v2.0.0'
```

**Phase 3: Migration Tracking**
```sql
-- Track adoption
SELECT
  team,
  component_version,
  last_used
FROM pipeline_usage
WHERE component = 'build-template'
GROUP BY team
ORDER BY component_version;

-- Result:
-- team-payments: v1.5.0 (migrate!)
-- team-users: v2.0.0 ✓
-- team-auth: v2.0.0 ✓
```

**Phase 4: Targeted Outreach**
- Week 8: Email teams still on v1.x
- Week 10: Direct Slack messages
- Week 11: Offer pair programming sessions

**Phase 5: Sunset (Week 12)**
```yaml
# v1.x template now shows error
.build_template_v1:
  script:
    - |
      echo "ERROR: v1.x is deprecated. Upgrade to v2.0"
      echo "Migration guide: https://wiki.dwp.gov.uk/ci-migration-v2"
      exit 1
```

**Result at Axelera:**
- 15 teams migrated
- Zero outages
- 2 teams needed 1-on-1 support
- Completed in 10 weeks (planned 12)"

---

## Part 6: DWP-Specific Context

### Q9: How do GitLab CI components support DWP's governance requirements?

**Your Answer:**

"DWP operates under strict change control. GitLab CI components help by:

**1. Standardized, Auditable Pipelines**
```yaml
# Every deployment uses same template
include:
  - project: 'dwp-standards/ci-templates'
    file: '/secure-deploy.yml'
    ref: 'approved-v1.5.0'  # Approved version

deploy:
  extends: .secure_deploy_template
  # Automatically includes:
  # - Security scanning
  # - Approval gates
  # - Audit logging
```

**2. Immutable Audit Trail**
```yaml
deploy-production:
  script:
    - |
      # Log who, what, when
      echo \"Deployed by: $GITLAB_USER_LOGIN\" >> audit.log
      echo \"Pipeline: $CI_PIPELINE_ID\" >> audit.log
      echo \"Commit: $CI_COMMIT_SHA\" >> audit.log
      echo \"Timestamp: $(date --iso-8601=seconds)\" >> audit.log
  artifacts:
    reports:
      audit: audit.log  # Sent to compliance system
```

**3. Mandatory Security Scans**
```yaml
.secure_deploy_template:
  before_script:
    - trivy image $DOCKER_IMAGE  # Container scan
    - semgrep --config=auto .    # SAST
    - dependency-check.sh        # SCA
  rules:
    - if: $SECURITY_SCAN_PASSED != "true"
      when: never  # Block if scans fail
```

**4. Separation of Duties**
```yaml
build:
  stage: build
  # Any developer can trigger

deploy-production:
  stage: deploy
  rules:
    - if: $CI_COMMIT_BRANCH == \"main\"
      when: manual  # Requires approval
  environment:
    name: production
    deployment_tier: production
  # Only specific roles can approve
```

**Benefits for DWP:**
- Every pipeline change reviewed (template versioning)
- Audit logs for compliance
- Consistent security posture
- Reduces \"shadow IT\" (teams can't skip controls)"

---

## Summary: Key Messages for Interview

### TypeScript/Node.js in Backstage
- **Frontend**: React components (TypeScript) for UI
- **Backend**: Node.js API for calling GitLab, caching, auth
- **Plugin development**: You'd write TypeScript for GitLab CI integration

### GitLab CI Development at DWP
1. **Component development** (YAML + Bash) - Reusable pipeline templates
2. **Plugin development** (TypeScript + Node.js) - Backstage integration
3. **Automation scripts** (Python/Bash) - Dynamic job generation

### Your Unique Value
- ✅ Built reusable GitLab CI components (Axelera - 50+ IP blocks)
- ✅ Experience with modular CI architecture (europa-main structure)
- ✅ Understand DWP-scale requirements (200+ engineers at Fractile)
- ✅ Proven track record (70% CI reduction, 85% satisfaction)
- ✅ Government experience (HMRC - 5 years)

### Confidence Builders
You've already done this work:
- Reusable components ✅ (Axelera GitLab CI templates)
- Large-scale support ✅ (200+ engineers at Fractile)
- Government context ✅ (HMRC infrastructure)
- Developer satisfaction ✅ (85% score)

**You're exceptionally qualified for this role!**
