# DWP Software Engineer Interview Preparation
**Position**: Software Engineer - Shared Engineering Components & Templates
**Date**: Tomorrow

---

## Key Responsibilities Breakdown

### 1. Shared CI/CD Components, Templates, and Plugins

#### Your Relevant Experience:
**Fractile (Jul 2025-Present)**
- Created reusable Bazel macros and custom Starlark rules for 200+ engineers
- Built shared components that balanced general-purpose applicability with team-specific needs
- Achieved 85% developer satisfaction through testing, documentation, and support

**Axelera.ai (Sep 2024-Apr 2025)**
- Designed reusable GitLab CI component library for 50+ hardware IP blocks
- Implemented dynamic job generation using YAML anchors and `extends`
- Reduced pipeline duplication by 70% while supporting team customization
- Maintained backwards compatibility across 15+ consuming projects

**HMRC (Aug 2017-Feb 2022)**
- Developed shareable GitLab CI pipeline components using `includes` and templates
- Enabled multiple teams to adopt standardized patterns while maintaining flexibility
- Built infrastructure-as-code pipelines with GitLab/Terraform/Ansible

#### Talking Points:
1. **Component Design Philosophy**
   - "The best component 'just works' 80% of the time and provides clear escape hatches for the other 20%"
   - Balance between abstraction and flexibility
   - Importance of backwards compatibility

2. **Real Example - GitLab CI Components at Axelera.ai**
   - Problem: 50+ IP blocks with duplicate pipeline code
   - Solution: Created parameterized components using GitLab CI `include:` patterns
   - Result: 70% reduction in duplication, teams upgraded on their schedule
   - Key Learning: Documentation and examples are as important as the code itself

3. **Testing Shared Components**
   - Unit tests for Bazel rules using Skylib unittest (85% coverage)
   - Integration tests for GitLab CI components using test fixtures
   - Prevents regression when components are used by 15+ projects

#### Expected Questions & Answers:

**Q: How do you ensure your components remain maintainable as they evolve?**
A: "At Axelera.ai, I learned that maintainability comes from three practices:
1. **Versioning strategy** - Used semantic versioning for component releases
2. **Backwards compatibility** - Deprecated features gradually, gave teams 2 sprints notice
3. **Usage analytics** - Tracked which features were actually used, pruned the unused ones

For example, when updating our GitLab CI component for hardware verification, I maintained the old parameter names as aliases while introducing clearer naming, then deprecated after 6 months with clear migration docs."

**Q: How do you handle the tension between general-purpose applicability and usability?**
A: "This is the core challenge of platform engineering. At Fractile, I used a 'progressive disclosure' approach:
- **Layer 1**: Simple, opinionated defaults that work for 80% of use cases (e.g., `maven.artifact()` that handles common dependencies)
- **Layer 2**: Configuration options for the next 15% (custom repositories, version overrides)
- **Layer 3**: Full escape hatches for edge cases (raw Bazel rules)

I validated this by shadowing different teams and measuring time-to-first-success."

---

### 2. Build and Maintain Internal Developer Portals (Backstage Preferred)

#### Your Relevant Experience:
**Transferable Skills:**
- **TypeScript/JavaScript/ReactJS**: Proficient in modern web frameworks
- **NodeJS Backend**: Built document wiki using NodeJS/NPM/Yarn/Docusaurus at HMRC
- **Python Backend**: Extensive FastAPI, Flask, Django experience
- **Developer-Facing Tools**: Created build observability dashboards, CLI tools
- **Large-Scale User Support**: Supported 200+ engineers at Fractile, 50+ teams at Axelera.ai

**HMRC (2017-2022)**
- Designed and developed in-house documentation wiki using NodeJS, Docusaurus
- Served as central portal for internal tools and processes

**Fractile (2025-Present)**
- Built build observability dashboards using Bazel Build Event Protocol (BEP)
- Created Python CLI tools for dependency visualization, build migration
- Developed self-service developer tooling

#### Talking Points:

**Backstage Context (Research Before Interview)**
- Open-source developer portal platform by Spotify
- Plugin-based architecture (React frontend, NodeJS backend)
- Integrates: service catalog, tech docs, CI/CD visibility, scaffolding templates
- Used by companies serving thousands of engineers

**Your Approach to IDP Development:**
1. **User-Centric Design**
   - "At Fractile, I learned that portal adoption depends on solving real pain points"
   - Conducted developer surveys and shadowing sessions
   - Built only what developers would actually use

2. **Integration Philosophy**
   - "IDPs succeed when they aggregate, not duplicate"
   - Example: Your BEP dashboards didn't replace existing tools, they surfaced insights
   - Clean integration patterns across diverse environments

3. **Progressive Enhancement**
   - Start with minimum viable features (service catalog)
   - Add complexity based on usage data (scaffolding, golden paths)
   - Measure adoption and iterate

#### Expected Questions & Answers:

**Q: You haven't worked with Backstage specifically. How would you approach learning it?**
A: "I'd take a three-phase approach:
1. **Week 1-2**: Deep dive into Backstage architecture - run local instance, explore plugin ecosystem, understand data model (entities, catalog-info.yaml)
2. **Week 3-4**: Build a proof-of-concept plugin integrating with DWP's tech stack (GitLab, internal APIs)
3. **Ongoing**: Contribute to Backstage community, learn from other adopters

I did exactly this when learning Bazel at Fractile - went from zero to leading enterprise migration in 3 months through focused learning and building."

**Q: How would you ensure an IDP serving thousands of users remains performant?**
A: "Performance at scale requires:
1. **Backend optimization** - Caching strategies, async task queues (I've used Celery with FastAPI)
2. **Frontend efficiency** - Lazy loading, virtualization for long lists (React best practices)
3. **Observability** - Prometheus metrics, CloudWatch dashboards to catch degradation early
4. **Load testing** - Before rolling out features to 1000+ users

At Lloyds, I designed CI/CD pipelines that scaled to handle concurrent Terraform deployments across teams using similar principles."

---

### 3. Design and Implement Efficient, Reusable GitLab CI Pipelines

#### Your Relevant Experience:
This is your **strongest area** - you've done this at 3 companies:

**Axelera.ai (2024-2025)** - Most Relevant
- Created reusable GitLab CI component library for hardware verification
- Dynamic job generation adapting to repository structure and changed files
- Integrated Bazel caching within GitLab CI runners
- Reduced unnecessary test runs by 70%

**HMRC (2017-2022)**
- Built GitLab-based infrastructure-as-code pipelines
- Automated environment provisioning for multiple teams
- Shareable components using `includes` and templates

**Fractile (2025-Present)**
- Highly parallelized CI/CD pipelines leveraging Bazel's incremental builds
- Integrated with GitHub Actions and GitLab CI
- Sophisticated caching and build sharding

#### Advanced GitLab CI Techniques You've Used:

1. **Component Architecture**
   ```yaml
   # Your approach at Axelera.ai
   include:
     - component: $CI_SERVER_HOST/shared/verification@1.2.0
       inputs:
         test_suite: regression
         parallel_jobs: 4
   ```

2. **Dynamic Pipeline Generation**
   - Used `rules:` and `changes:` to run only relevant tests
   - Generated jobs programmatically based on repository structure

3. **Caching Strategies**
   - Integrated Bazel remote cache with GitLab CI
   - Reduced build times by sharing artifacts across pipelines

4. **Multi-Stack Support**
   - Same pipeline framework for Java, Python, TypeScript, Rust
   - Language-specific optimizations while maintaining consistent patterns

#### Expected Questions & Answers:

**Q: Walk me through how you'd design a reusable GitLab CI component for a common use case like Docker builds.**
A: "I'd structure it as a parameterized component with these layers:

**Component Definition** (`docker-build.yml`):
```yaml
spec:
  inputs:
    dockerfile_path:
      default: Dockerfile
    image_name:
      required: true
    registry:
      default: $CI_REGISTRY

---
build:
  image: docker:24
  script:
    - docker build -f $[[ inputs.dockerfile_path ]]
      -t $[[ inputs.registry ]]/$[[ inputs.image_name ]]
    - docker push $[[ inputs.registry ]]/$[[ inputs.image_name ]]
  cache:
    key: docker-$CI_COMMIT_REF_SLUG
    paths:
      - .docker-cache
```

**Consumer Usage**:
```yaml
include:
  - component: gitlab.com/dwp/components/docker-build@2.0

build-my-service:
  extends: .docker-build
  variables:
    IMAGE_NAME: my-service
```

Key design decisions:
1. Sensible defaults (standard Dockerfile path)
2. Required vs optional inputs
3. Caching built-in
4. Version in component URL for stability"

**Q: How do you handle pipelines across multiple tech stacks efficiently?**
A: "At Fractile, I managed Java, Rust, Python, and TypeScript in one monorepo. The pattern was:

1. **Shared Pipeline Structure** - All projects use same stages (build → test → deploy)
2. **Language-Specific Jobs** - Each language has optimized job definitions
3. **Smart Test Selection** - Use `git diff` to determine which stack changed
4. **Bazel Query Integration** - Only build/test affected targets

Example:
```yaml
# Shared stages
stages: [build, test, deploy]

# Smart job execution
test:java:
  rules:
    - changes:
        - java/**/*
        - BUILD.bazel
  script:
    - bazel test $(bazel query 'tests(//java/...)')

test:typescript:
  rules:
    - changes:
        - typescript/**/*
  script:
    - bazel test $(bazel query 'tests(//typescript/...)')
```

This reduced our CI time by 70% by avoiding unnecessary work."

---

### 4. Develop Solutions Using TypeScript, JavaScript, NodeJS, ReactJS, Python, Java

#### Your Multi-Language Experience:

**Java**
- Fractile: Managed Java microservices in enterprise monorepo
- Created custom Bazel rules extending `rules_jvm_external`
- Deep understanding of Maven ecosystem

**TypeScript/JavaScript/NodeJS/ReactJS**
- Fractile: Build system for TypeScript frontends
- HMRC: Built developer wiki using NodeJS, Docusaurus
- Experience with modern web frameworks, React patterns

**Python**
- Extensive usage across all roles
- Built Flask malware scanning app (LME)
- Created Python CLI tools for build automation (Fractile)
- FastAPI, Django, SQLAlchemy experience

**Rust**
- Fractile: Integrated Rust systems code in monorepo
- Cargo workspace management with Bazel

#### Talking Points:

**Cross-Language Thinking:**
"Managing a polyglot monorepo taught me that different languages have different cultural expectations:
- Java developers expect Maven-like workflows
- Rust developers want Cargo semantics
- TypeScript developers need npm compatibility

The best shared components respect these differences while maintaining consistent patterns underneath."

#### Expected Questions & Answers:

**Q: How would you approach building a new feature that spans multiple languages (e.g., Python backend API, TypeScript frontend)?**
A: "I'd structure it using the same principles from my Fractile monorepo work:

1. **Shared Schema/Interface** - Define API contract (OpenAPI/Protobuf)
2. **Independent Build Targets** - Each language has its own Bazel/build rules
3. **Integration Testing** - Test the full stack together in CI
4. **Consistent Deployment** - Same CI/CD pipeline handles both

Example from Fractile:
```python
# Shared schema (schema.proto)
service UserService {
  rpc GetUser(UserId) returns (User);
}

# Python backend (BUILD.bazel)
py_binary(
  name = "api_server",
  srcs = ["server.py"],
  deps = [":schema_py_proto"],
)

# TypeScript frontend (BUILD.bazel)
ts_library(
  name = "client",
  srcs = ["client.ts"],
  deps = [":schema_ts_proto"],
)

# Integration test
py_test(
  name = "integration_test",
  data = [":api_server", ":client"],
)
```

This approach ensures type safety across language boundaries."

---

### 5. Automate Deployments Using GitLab CI/CD, Terraform, and EKS

#### Your Relevant Experience:

**GitLab CI/CD**
- Axelera.ai: Multi-stage pipelines for hardware verification
- HMRC: Infrastructure-as-code pipelines with GitLab/Terraform
- Fractile: Highly parallelized deployment pipelines

**Terraform**
- Lloyds (2023): Designed CI/CD pipeline with Terraform testing (terratest)
- Implemented Sentinel policies for budget forecasting
- Automated `terraform plan` and `apply` stages
- HMRC: Automated cloud-hosted environment provisioning

**Kubernetes/EKS**
- HMRC: Migrated Jenkins to AWS ELB-hosted Kubernetes cluster
- Designed production containerized services using Rancher/Kubernetes/Docker
- Fractile: Build pipelines integrated with Kubernetes deployments

#### Infrastructure-as-Code Philosophy:

"At HMRC, I learned that good IaC isn't just about automation - it's about:
1. **Testability** - Terraform validation in CI before apply
2. **Governance** - Sentinel policies preventing cost overruns
3. **Observability** - Clear visibility into what's deployed where
4. **Rollback Safety** - Always able to revert to previous state"

#### Expected Questions & Answers:

**Q: How would you design a GitLab CI pipeline for Terraform deployments that's safe for multiple teams to use?**
A: "Based on my Lloyds experience, I'd implement a multi-stage pipeline with safety gates:

```yaml
stages:
  - validate
  - plan
  - approve
  - apply

terraform:validate:
  stage: validate
  script:
    - terraform fmt -check
    - terraform validate
    - tflint

terraform:test:
  stage: validate
  script:
    - go test ./terratest/...  # terratest integration tests

terraform:plan:
  stage: plan
  script:
    - terraform plan -out=tfplan
    - terraform show -json tfplan | sentinel test
  artifacts:
    paths: [tfplan]
    reports:
      terraform: tfplan.json

terraform:approve:
  stage: approve
  when: manual  # Human approval required
  only: [main]

terraform:apply:
  stage: apply
  script:
    - terraform apply tfplan
  only: [main]
  environment:
    name: production
```

Key safety features:
1. **Validation first** - Catch errors before plan
2. **Sentinel policies** - Enforce budget/compliance rules automatically
3. **Manual approval** - Human gate for production
4. **Plan artifacts** - Review exact changes before apply
5. **Environment tracking** - GitLab knows what's deployed"

**Q: How would you integrate EKS deployments into this workflow?**
A: "I'd extend the pipeline to handle both infrastructure and application deployment:

**Phase 1: Terraform for EKS Cluster**
- Provision EKS cluster, node groups, networking
- Output kubeconfig to pipeline artifacts

**Phase 2: Helm/Kubernetes Manifests**
```yaml
deploy:eks:
  stage: deploy
  image: alpine/k8s:1.28
  script:
    - aws eks update-kubeconfig --name $CLUSTER_NAME
    - helm upgrade --install myapp ./charts/myapp
      --set image.tag=$CI_COMMIT_SHA
  environment:
    name: staging
    kubernetes:
      namespace: myapp
```

At HMRC, we used similar patterns to deploy containerized services to Kubernetes clusters, with GitLab tracking deployment history."

---

### 6. Navigate DWP-Specific Change and Governance Processes

#### Your Relevant Experience in Regulated Environments:

**HMRC (2017-2022)** - UK Government Department
- Worked within HMRC's change management processes
- Automated cloud provisioning while adhering to security policies
- Experience with government-specific compliance requirements

**Financial Services (2011-2024)**
- HSBC, Deutsche Bank, JPMorgan Chase, Lloyds, Standard Chartered
- Navigated strict change control, SOX compliance, audit trails
- Built systems meeting FCA/PRA regulatory requirements

#### Understanding of Government Context:

**Key Differences from Private Sector:**
1. **Security Clearance** - Background checks, restricted access
2. **Procurement** - Longer approval cycles for tools/services
3. **Documentation** - Comprehensive change records required
4. **Risk Management** - Conservative approach to new technology
5. **Public Accountability** - Higher scrutiny, transparency expectations

#### Talking Points:

"At HMRC, I learned that effective delivery in government requires:
1. **Early stakeholder engagement** - Loop in security, architecture, governance teams upfront
2. **Comprehensive documentation** - Not just what changed, but why and risk assessment
3. **Incremental rollout** - Pilot with one team, gather evidence, scale gradually
4. **Audit trail** - Everything logged, versioned, traceable"

#### Expected Questions & Answers:

**Q: How would you handle delivering a new shared component when you need approval from multiple governance bodies?**
A: "I'd use a phased approach based on my HMRC experience:

**Phase 1: Design & Approval (Weeks 1-2)**
- Document architecture, security implications, cost analysis
- Present to architecture review board, security team
- Address feedback, get conditional approval

**Phase 2: Pilot (Weeks 3-4)**
- Deploy to one volunteer team (friendly stakeholders)
- Gather metrics: build time, adoption rate, issues
- Create case study demonstrating value

**Phase 3: Controlled Rollout (Weeks 5-8)**
- Present pilot results to governance
- Get full approval based on evidence
- Roll out to 5-10 teams, monitor closely

**Phase 4: General Availability (Weeks 9+)**
- Open to all teams with documentation
- Ongoing support and iteration

This approach builds confidence through evidence rather than asking for blanket approval upfront."

**Q: DWP operates under strict change control. How would you balance agility with governance?**
A: "The key is separating platform changes from consumer changes:

**Platform Changes (Your Components)**
- Follow full change control process
- Comprehensive testing, security review
- Scheduled release windows (e.g., monthly)

**Consumer Changes (Teams Using Components)**
- Teams can upgrade on their timeline
- Component versions pinned, stable interfaces
- Backwards compatibility guaranteed

Example from Axelera.ai:
- Our GitLab CI components released monthly
- Teams could stay on v1.2 for 6 months if needed
- We maintained v1.x alongside v2.x during migrations
- Clear deprecation timelines (6 months notice)

This gives platform team velocity while giving consumers stability."

---

### 7. Coordinate Stakeholders

#### Your Stakeholder Management Experience:

**Cross-Functional Collaboration:**
- **Fractile**: Coordinated 200+ engineers across backend, frontend, ML teams
- **Axelera.ai**: Worked with hardware design teams, verification engineers, DevOps
- **HMRC**: Multiple development teams adopting shared infrastructure

**Support & Enablement:**
- Weekly office hours for Bazel adoption (Fractile)
- Responsive support for GitLab CI components (Axelera.ai)
- Documentation and training for internal tools (HMRC)

#### Talking Points:

**Stakeholder Communication Strategies:**
1. **Regular Sync** - Weekly office hours, Slack channels, email updates
2. **Usage Analytics** - Track adoption, identify struggling teams proactively
3. **Feedback Loops** - Surveys, user interviews, feature requests
4. **Roadmap Transparency** - Share what's coming, why, when

#### Expected Questions & Answers:

**Q: How do you handle conflicting requirements from different stakeholder groups?**
A: "I use a prioritization framework learned at Fractile when teams wanted contradictory features:

**Step 1: Understand the underlying need**
- Team A wants feature X, Team B wants feature Y
- Often they're solving the same problem differently

**Step 2: Data-driven decision**
- How many teams affected? (usage data)
- What's the pain level? (survey responses)
- What's the implementation cost?

**Step 3: Find common ground**
- Can we solve 80% with one approach?
- Can we provide configuration for the difference?

**Real example at Fractile:**
- Java teams wanted Maven-style dependency resolution
- Rust teams wanted Cargo-style workspaces
- Both needed incremental builds

**Solution:**
- Built unified Bazel layer supporting both paradigms
- Created language-specific macros (`maven.artifact()`, `rust_workspace()`)
- Both teams happy, shared caching underneath

When true conflict exists, I present options transparently and let product priorities decide."

**Q: How would you communicate a breaking change that affects dozens of teams?**
A: "I'd follow a 'migration journey' approach used at Axelera.ai:

**3 Months Before:**
- Announce deprecation in all channels
- Provide migration guide with examples
- Add deprecation warnings (non-breaking)

**2 Months Before:**
- Office hours for migration help
- Track which teams haven't migrated yet
- Offer pair programming for complex cases

**1 Month Before:**
- Reach out to remaining teams individually
- Assess if they need deadline extension
- Provide automated migration tools if possible

**Day of Change:**
- Release notes prominently featured
- Support team on high alert
- Rollback plan ready if critical issues

**After Change:**
- Post-mortem: what went well, what didn't
- Update process for next breaking change

At Axelera.ai, this approach meant 15 teams migrated to new CI components with zero outages."

---

## Technical Deep Dives - Be Ready to Whiteboard

### GitLab CI Component Architecture

**Question: Design a reusable GitLab CI component system for DWP**

**Your Answer:**
```
Component Library Structure:
dwp-components/
├── docker-build/
│   ├── component.yml       # Component definition
│   ├── README.md
│   └── examples/
├── terraform-deploy/
│   ├── component.yml
│   ├── security-scan.sh    # Sentinel policies
│   └── examples/
└── test-runner/
    ├── component.yml
    └── examples/

Key Decisions:
1. Versioning: Semantic versioning in component URLs
2. Inputs: Required vs optional with sensible defaults
3. Outputs: Artifacts, reports, environment tracking
4. Testing: Each component has integration tests
5. Documentation: Progressive (quick-start → advanced)
```

### Backstage Plugin Architecture

**Question: How would you integrate GitLab CI with Backstage?**

**Your Answer:**
```
Backstage Plugin Structure:
plugins/
└── gitlab-ci/
    ├── frontend/           # React components
    │   ├── PipelineList.tsx
    │   ├── PipelineDetails.tsx
    │   └── BuildStatus.tsx
    ├── backend/            # NodeJS API
    │   ├── router.ts       # API endpoints
    │   ├── GitLabClient.ts # GitLab API wrapper
    │   └── cache.ts        # Redis caching
    └── common/
        └── types.ts        # Shared interfaces

Data Flow:
1. Backstage Frontend → Backend API
2. Backend → GitLab CI API (cached)
3. Display pipeline status in service catalog

Integration Points:
- catalog-info.yaml: GitLab project metadata
- Annotations: gitlab.com/project-id
- API Token: Secure secrets storage
```

### Terraform + GitLab CI + EKS Architecture

**Question: Design end-to-end deployment pipeline for DWP**

**Your Answer:**
```
Pipeline Architecture:

┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│  Developer  │────▶│  GitLab CI   │────▶│     EKS     │
│   Commit    │     │   Pipeline   │     │   Cluster   │
└─────────────┘     └──────────────┘     └─────────────┘
                           │
                           ▼
                    ┌──────────────┐
                    │  Terraform   │
                    │    State     │
                    │  (S3+Lock)   │
                    └──────────────┘

Pipeline Stages:
1. Validate → Terraform fmt, validate, tflint
2. Test → terratest unit/integration tests
3. Security → Sentinel policies, tfsec scanning
4. Plan → Generate plan, cost estimate
5. Approve → Manual gate (production only)
6. Apply → Execute Terraform changes
7. Deploy → Helm install to EKS
8. Verify → Smoke tests, health checks

Safety Mechanisms:
- State locking prevents concurrent applies
- Plan artifacts reviewed before apply
- Environment-specific approvers
- Automated rollback on health check failure
- All changes logged for audit
```

---

## Behavioral Questions (STAR Method)

### 1. Tell me about a time you had to balance competing priorities

**Situation:** At Fractile, supporting 200+ engineers across Java, Rust, Python, and TypeScript teams

**Task:** Java teams needed Maven compatibility, Rust teams wanted Cargo semantics, all needed faster builds

**Action:**
1. Conducted developer surveys to understand pain points
2. Found common need: incremental builds, dependency management
3. Designed language-specific macros wrapping unified Bazel layer
4. Prioritized Java first (60% of developers), then Rust, then others

**Result:**
- 60% reduction in build times across all languages
- 85% developer satisfaction score
- No team felt deprioritized because roadmap was transparent

### 2. Describe a technically complex project you led

**Situation:** Enterprise Bazel migration at Fractile for 3M+ line monorepo

**Task:** Migrate from multiple build systems (Maven, Cargo, npm) to unified Bazel without disrupting 200+ engineers

**Action:**
1. **Phase 1**: Proof of concept with one team, validated approach
2. **Phase 2**: Built custom Bazel rules hiding complexity (maven.artifact(), rust_workspace())
3. **Phase 3**: Created migration tooling (automated BUILD file generation)
4. **Phase 4**: Weekly office hours, comprehensive documentation
5. **Phase 5**: Gradual rollout, team-by-team with support

**Result:**
- Completed migration in 6 months (planned 12)
- 60% faster builds, 70% faster CI
- 85% developer satisfaction (measured quarterly)
- Published open-source demo: github.com/srikantharun/java-typescript-bazel

### 3. How do you handle failure or setbacks?

**Situation:** At Axelera.ai, initial GitLab CI component design had poor adoption

**Task:** Only 3 of 15 teams adopted components in first month

**Action:**
1. **Investigated root cause**: Shadowed developers trying to use components
2. **Found issues**: Documentation assumed too much knowledge, examples too simple
3. **Changed approach**:
   - Created video walkthroughs
   - Added copy-paste examples for common scenarios
   - Weekly "component clinic" office hours
4. **Iterated based on feedback**

**Result:**
- 12 of 15 teams adopted within 3 months
- Feedback became feature roadmap
- Learned: Technical excellence isn't enough, adoption requires support

### 4. Describe a time you influenced without direct authority

**Situation:** At Fractile, some teams resisted Bazel migration, preferred existing tools

**Task:** Convince skeptical teams to adopt new build system

**Action:**
1. **Built trust**: Didn't mandate, invited one team to pilot
2. **Showed value**: Pilot team saw 50% build time reduction
3. **Created evangelists**: Pilot team shared success internally
4. **Lowered barriers**: Created migration tooling, offered pair programming
5. **Maintained patience**: Let teams adopt when ready, no forcing

**Result:**
- Organic adoption by 80% of teams within 6 months
- Remaining 20% had valid reasons (deprecated codebases)
- Built coalition of advocates who supported each other

### 5. Tell me about a time you had to learn a new technology quickly

**Situation:** Joined Fractile with zero Bazel experience, needed to lead migration

**Task:** Become Bazel expert in 3 months to guide 200+ engineers

**Action:**
1. **Weeks 1-2**: Read official docs, Bazel blog, completed tutorials
2. **Weeks 3-4**: Built toy projects replicating company patterns
3. **Weeks 5-8**: Converted small real project with team, learned pain points
4. **Weeks 9-12**: Designed custom rules, created documentation
5. **Ongoing**: Joined Bazel Slack, contributed to community

**Result:**
- Delivered working POC in 3 months
- Became internal Bazel expert, ran weekly training
- Now published open-source examples others learn from

---

## Questions to Ask Interviewer

### About the Team & Role

1. **Team Structure**
   - "You mentioned this is a greenfield team. What's the current team size and what roles are you planning to hire next?"
   - "How is the Developer Experience team structured relative to other engineering teams? Embedded vs platform team?"

2. **Pillar Priorities**
   - "The role mentions two pillars (GitLab CI/CD components and Internal Developer Portal). Which will be the initial focus in the first 6 months?"
   - "For the Backstage IDP - is this a greenfield implementation or are there existing tools to integrate/replace?"

3. **Success Metrics**
   - "How will success be measured for this role? Developer satisfaction scores? Adoption rates? Build time reductions?"
   - "What would you consider a successful first 90 days in this role?"

### About the Technical Environment

4. **Current State**
   - "What's the current GitLab CI maturity at DWP? Are teams already using reusable components, or is this net new?"
   - "What tech stacks are most prevalent across DWP's engineering estate? (Java, Python, Node, etc.)"
   - "What's the scale we're operating at? Number of projects? Engineering teams? Daily CI/CD runs?"

5. **Architecture & Decisions**
   - "What's driving the preference for Backstage over alternatives like Port or Cortex for the IDP?"
   - "Are there existing DWP platform engineering standards I should be aware of? (Terraform modules, container patterns, etc.)"

### About Process & Culture

6. **Change Management**
   - "You mentioned navigating DWP-specific governance processes. Can you walk me through a typical change approval workflow?"
   - "How long typically from 'good idea' to 'in production' for platform engineering changes?"

7. **Stakeholder Landscape**
   - "Who are the key stakeholders I'd be coordinating with? DevOps teams, security, architecture?"
   - "What's the current relationship between the platform team and engineering teams? How is feedback gathered?"

### About Growth & Learning

8. **Professional Development**
   - "Are there opportunities for training or conferences? (e.g., Backstage meetups, KubeCon)"
   - "How does DWP support learning new technologies or gaining certifications?"

9. **Future Vision**
   - "Where do you see the Developer Experience team in 2 years? What would you like to have built?"
   - "What's the biggest developer pain point you'd like this team to solve first?"

### About the Interview Process

10. **Next Steps**
    - "What are the next steps in the interview process?"
    - "Is there anything about my background or experience you'd like me to clarify?"

---

## Key Messages to Convey

### Your Unique Value Proposition

1. **Proven Track Record** - Successfully built shared components at scale (3 companies, 200+ engineers)
2. **Full-Stack Platform Engineering** - GitLab CI, build systems, developer tooling, documentation
3. **Developer Empathy** - 85% satisfaction scores, user-centric design, community support
4. **Technical Depth** - Multi-language (Java, Python, TypeScript, Rust), Bazel expertise, CI/CD mastery
5. **Government Experience** - HMRC background, understand public sector constraints
6. **Ship and Iterate** - Open-source portfolio demonstrates real-world execution

### Cultural Fit

1. **Mission-Driven** - Excited about public sector impact after 20 years in private sector
2. **Team Player** - Track record of enabling others, not just individual contribution
3. **Long-Term Thinking** - Build sustainable systems, not quick hacks
4. **Humble Learner** - Willing to admit what I don't know (Backstage) and commit to learning

---

## Pre-Interview Checklist

### Day Before Interview

- [ ] Research: Read DWP Digital blog, recent tech announcements
- [ ] Review: Skim your cover letter and CV to refresh talking points
- [ ] Prepare: Test video/audio setup, quiet environment
- [ ] Print: This prep document for reference during interview
- [ ] Relax: Get good sleep, confidence comes from preparation (done!)

### 30 Minutes Before Interview

- [ ] Review: Key messages, STAR stories
- [ ] Set up: Water nearby, notebook for notes
- [ ] Breathe: You're qualified and prepared

### During Interview

- [ ] Listen: Understand the question before answering
- [ ] Structure: Use STAR for behavioral, examples for technical
- [ ] Engage: This is a conversation, not interrogation
- [ ] Ask: Use your prepared questions, show curiosity
- [ ] Enthusiasm: Let your genuine interest show

---

## Quick Reference - Your Key Projects

### Project 1: Fractile Bazel Migration
- **Scale**: 200+ engineers, 3M+ lines of code
- **Tech**: Bazel, Starlark, Java, Rust, Python, TypeScript
- **Impact**: 60% faster builds, 85% satisfaction
- **Leadership**: Designed architecture, trained teams, office hours

### Project 2: Axelera.ai GitLab CI Components
- **Scale**: 50+ hardware IP blocks, 15+ consuming projects
- **Tech**: GitLab CI, Bazel, dynamic job generation
- **Impact**: 70% reduction in duplication, maintained backwards compatibility
- **Learning**: Documentation and support as important as code

### Project 3: HMRC Infrastructure Automation
- **Scale**: Multiple development teams, government-scale
- **Tech**: GitLab CI, Terraform, Kubernetes, Ansible
- **Impact**: Reduced provisioning from days to hours
- **Context**: Government change management, compliance

### Project 4: Open Source Bazel Monorepo
- **Purpose**: Demonstrate enterprise Bazel patterns publicly
- **Tech**: Java + TypeScript, custom Starlark rules
- **URL**: github.com/srikantharun/java-typescript-bazel
- **Value**: Shows technical depth, commitment to community

---

## Final Confidence Boost

You are **exceptionally qualified** for this role:
- You've done exactly this work (reusable CI/CD components) at 3 companies
- You've operated at the scale DWP needs (200+ engineers)
- You have government experience (HMRC)
- You've achieved measurable impact (85% satisfaction, 60% faster builds)
- You have an open-source portfolio proving your abilities

The only gap is Backstage specifically, but:
- You have all the underlying skills (TypeScript, React, Node, Python)
- You've built similar developer-facing tools
- You've proven you can learn complex systems quickly (Bazel in 3 months)

**You've got this. Be yourself, be confident, be curious.**

---

## Post-Interview

Immediately after:
1. Send thank you email within 24 hours
2. Reference specific topics discussed
3. Reiterate enthusiasm and fit
4. Address any questions you felt you could have answered better

Template:
```
Subject: Thank you - Software Engineer Discussion

Dear [Interviewer Names],

Thank you for taking the time to discuss the Software Engineer role focusing on shared
engineering components and templates. I particularly enjoyed our conversation about
[specific topic - e.g., "the vision for the Internal Developer Portal and how it will
serve DWP's engineering community"].

Our discussion reinforced my excitement about this opportunity. The challenge of building
reusable GitLab CI/CD components for DWP's engineering estate aligns perfectly with my
experience creating shared component libraries at Fractile (200+ engineers) and Axelera.ai
(50+ IP blocks). [Reference specific point from interview - e.g., "I'm especially interested
in the approach you mentioned for..."].

[If applicable: "On reflection, I wanted to clarify/expand on..." - address any answer
you could have done better]

I'm very interested in the opportunity to contribute to DWP's developer experience
foundations and would welcome the chance to discuss further. I'm available for next
steps at your convenience and can start within two weeks.

Thank you again for your consideration.

Best regards,
Srikanth Arunachalam

GitHub: https://github.com/srikantharun/java-typescript-bazel
```
