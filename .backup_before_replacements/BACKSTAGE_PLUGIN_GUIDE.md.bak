# Building a GitLab CI Integration Plugin for Backstage

## What is Backstage?

Backstage is an open-source **Internal Developer Portal (IDP)** created by Spotify. It's a platform for building developer portals that unify all your infrastructure tooling, services, and documentation in one place.

### Core Concepts

1. **Software Catalog** - Central registry of all software components (services, libraries, websites)
2. **Software Templates** - Scaffolding tools to create new projects with best practices built-in
3. **TechDocs** - Documentation as code, rendered in Backstage
4. **Plugins** - Extensibility mechanism to integrate with any tool (GitLab, Jenkins, Kubernetes, etc.)

### Why Companies Use Backstage

- **Discoverability**: Engineers can find services, APIs, owners
- **Self-Service**: Create new projects from templates
- **Unified View**: See CI/CD status, deployments, docs in one place
- **Onboarding**: New engineers have a single portal to discover everything

---

## GitLab CI Plugin Architecture

### High-Level Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    Backstage Frontend (React)               │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Service Catalog Page                                 │  │
│  │  ┌────────────────────────────────────────────────┐  │  │
│  │  │  Service: payment-api                          │  │  │
│  │  │  Owner: team-payments                          │  │  │
│  │  │                                                 │  │  │
│  │  │  Tabs: [Overview] [CI/CD] [Kubernetes] [Docs]  │  │  │
│  │  │                                                 │  │  │
│  │  │  ┌──────────────────────────────────────────┐  │  │  │
│  │  │  │  GitLab CI Tab                           │  │  │  │
│  │  │  │  ──────────────────────────────────────  │  │  │  │
│  │  │  │  Pipeline #1234: ✅ Passed               │  │  │  │
│  │  │  │  - Build: ✅ 2m 30s                      │  │  │  │
│  │  │  │  - Test: ✅ 5m 15s                       │  │  │  │
│  │  │  │  - Deploy: ✅ 1m 45s                     │  │  │  │
│  │  │  │                                           │  │  │  │
│  │  │  │  Pipeline #1233: ❌ Failed               │  │  │  │
│  │  │  │  - Build: ✅ 2m 20s                      │  │  │  │
│  │  │  │  - Test: ❌ 4m 50s                       │  │  │  │
│  │  │  └──────────────────────────────────────────┘  │  │  │
│  │  └────────────────────────────────────────────────┘  │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                          │
                          │ HTTP Request
                          ▼
┌─────────────────────────────────────────────────────────────┐
│              Backstage Backend (Node.js/Express)            │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  GitLab CI Plugin Backend                            │  │
│  │                                                       │  │
│  │  GET /api/gitlab-ci/pipelines/:projectId             │  │
│  │  ──────────────────────────────────────────────────  │  │
│  │  1. Read service metadata from catalog               │  │
│  │  2. Extract GitLab project ID from annotations       │  │
│  │  3. Call GitLab API (with caching)                   │  │
│  │  4. Transform response to plugin format              │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                          │
                          │ HTTPS + GitLab Token
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                      GitLab API                             │
│                                                             │
│  GET /api/v4/projects/:id/pipelines                         │
│  GET /api/v4/projects/:id/pipelines/:pipeline_id/jobs       │
│  GET /api/v4/projects/:id/pipelines/:pipeline_id            │
└─────────────────────────────────────────────────────────────┘
```

---

## Step-by-Step Implementation

### Step 1: Define Service Metadata (catalog-info.yaml)

Each service in Backstage has a `catalog-info.yaml` file defining its metadata:

```yaml
# repos/payment-api/catalog-info.yaml
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: payment-api
  description: Payment processing service
  annotations:
    # GitLab plugin annotations
    gitlab.com/project-slug: dwp/payments/payment-api
    gitlab.com/project-id: '12345'
  tags:
    - java
    - spring-boot
  links:
    - url: https://gitlab.dwp.gov.uk/dwp/payments/payment-api
      title: GitLab Repository
      icon: gitlab
spec:
  type: service
  lifecycle: production
  owner: team-payments
  system: payment-system
```

The plugin reads these annotations to know which GitLab project to query.

---

### Step 2: Backend Plugin Implementation

#### File Structure

```
plugins/gitlab-ci-backend/
├── package.json
├── src/
│   ├── plugin.ts           # Plugin registration
│   ├── router.ts           # API routes
│   ├── service/
│   │   ├── GitLabClient.ts # GitLab API wrapper
│   │   └── cache.ts        # Caching layer
│   └── types.ts            # TypeScript interfaces
└── README.md
```

#### GitLabClient.ts - API Wrapper

```typescript
// plugins/gitlab-ci-backend/src/service/GitLabClient.ts

import { Config } from '@backstage/config';
import axios, { AxiosInstance } from 'axios';

export interface Pipeline {
  id: number;
  status: 'running' | 'pending' | 'success' | 'failed' | 'canceled';
  ref: string;
  sha: string;
  web_url: string;
  created_at: string;
  updated_at: string;
}

export interface Job {
  id: number;
  name: string;
  stage: string;
  status: string;
  duration: number;
  web_url: string;
}

export class GitLabClient {
  private client: AxiosInstance;
  private baseUrl: string;
  private token: string;

  constructor(config: Config) {
    // Read config from app-config.yaml
    this.baseUrl = config.getString('gitlab.baseUrl');
    this.token = config.getString('gitlab.token');

    this.client = axios.create({
      baseURL: this.baseUrl,
      headers: {
        'PRIVATE-TOKEN': this.token,
      },
    });
  }

  /**
   * Get recent pipelines for a GitLab project
   */
  async getPipelines(projectId: string, limit: number = 10): Promise<Pipeline[]> {
    const response = await this.client.get(
      `/api/v4/projects/${projectId}/pipelines`,
      {
        params: {
          per_page: limit,
          order_by: 'updated_at',
        },
      }
    );
    return response.data;
  }

  /**
   * Get jobs for a specific pipeline
   */
  async getPipelineJobs(projectId: string, pipelineId: number): Promise<Job[]> {
    const response = await this.client.get(
      `/api/v4/projects/${projectId}/pipelines/${pipelineId}/jobs`
    );
    return response.data;
  }

  /**
   * Get detailed pipeline information
   */
  async getPipeline(projectId: string, pipelineId: number): Promise<Pipeline> {
    const response = await this.client.get(
      `/api/v4/projects/${projectId}/pipelines/${pipelineId}`
    );
    return response.data;
  }

  /**
   * Get project information
   */
  async getProject(projectId: string) {
    const response = await this.client.get(`/api/v4/projects/${projectId}`);
    return response.data;
  }
}
```

#### cache.ts - Redis Caching Layer

```typescript
// plugins/gitlab-ci-backend/src/service/cache.ts

import { CacheClient } from '@backstage/backend-common';

export class GitLabCache {
  private cache: CacheClient;
  private ttl: number; // Time to live in seconds

  constructor(cache: CacheClient, ttl: number = 300) {
    this.cache = cache;
    this.ttl = ttl;
  }

  /**
   * Get cached pipelines or fetch from GitLab
   */
  async getPipelines(
    projectId: string,
    fetcher: () => Promise<any>
  ): Promise<any> {
    const cacheKey = `gitlab-pipelines-${projectId}`;

    // Try to get from cache
    const cached = await this.cache.get(cacheKey);
    if (cached) {
      return JSON.parse(cached);
    }

    // Cache miss - fetch from GitLab
    const data = await fetcher();

    // Store in cache
    await this.cache.set(cacheKey, JSON.stringify(data), {
      ttl: this.ttl,
    });

    return data;
  }

  /**
   * Invalidate cache for a project (e.g., when webhook received)
   */
  async invalidate(projectId: string): Promise<void> {
    const cacheKey = `gitlab-pipelines-${projectId}`;
    await this.cache.delete(cacheKey);
  }
}
```

#### router.ts - API Endpoints

```typescript
// plugins/gitlab-ci-backend/src/router.ts

import { errorHandler } from '@backstage/backend-common';
import express from 'express';
import Router from 'express-promise-router';
import { Logger } from 'winston';
import { Config } from '@backstage/config';
import { GitLabClient } from './service/GitLabClient';
import { GitLabCache } from './service/cache';

export interface RouterOptions {
  logger: Logger;
  config: Config;
  cache: any;
}

export async function createRouter(
  options: RouterOptions,
): Promise<express.Router> {
  const { logger, config, cache } = options;

  const gitlabClient = new GitLabClient(config);
  const gitlabCache = new GitLabCache(cache);

  const router = Router();
  router.use(express.json());

  /**
   * GET /pipelines/:projectId
   * Get recent pipelines for a project
   */
  router.get('/pipelines/:projectId', async (req, res) => {
    const { projectId } = req.params;
    const limit = parseInt(req.query.limit as string) || 10;

    logger.info(`Fetching pipelines for project ${projectId}`);

    try {
      const pipelines = await gitlabCache.getPipelines(
        projectId,
        () => gitlabClient.getPipelines(projectId, limit)
      );

      res.json({ pipelines });
    } catch (error) {
      logger.error(`Error fetching pipelines: ${error}`);
      res.status(500).json({ error: 'Failed to fetch pipelines' });
    }
  });

  /**
   * GET /pipelines/:projectId/:pipelineId/jobs
   * Get jobs for a specific pipeline
   */
  router.get('/pipelines/:projectId/:pipelineId/jobs', async (req, res) => {
    const { projectId, pipelineId } = req.params;

    logger.info(`Fetching jobs for pipeline ${pipelineId}`);

    try {
      const jobs = await gitlabClient.getPipelineJobs(
        projectId,
        parseInt(pipelineId)
      );

      res.json({ jobs });
    } catch (error) {
      logger.error(`Error fetching pipeline jobs: ${error}`);
      res.status(500).json({ error: 'Failed to fetch pipeline jobs' });
    }
  });

  /**
   * GET /project/:projectId
   * Get project information
   */
  router.get('/project/:projectId', async (req, res) => {
    const { projectId } = req.params;

    try {
      const project = await gitlabClient.getProject(projectId);
      res.json({ project });
    } catch (error) {
      logger.error(`Error fetching project: ${error}`);
      res.status(500).json({ error: 'Failed to fetch project' });
    }
  });

  /**
   * POST /webhook
   * Receive webhooks from GitLab to invalidate cache
   */
  router.post('/webhook', async (req, res) => {
    const { project_id, object_kind } = req.body;

    // Validate webhook signature (important for security!)
    // Implementation depends on GitLab webhook secret configuration

    if (object_kind === 'pipeline') {
      logger.info(`Webhook received for project ${project_id}, invalidating cache`);
      await gitlabCache.invalidate(project_id.toString());
    }

    res.status(200).json({ status: 'ok' });
  });

  router.use(errorHandler());
  return router;
}
```

#### plugin.ts - Plugin Registration

```typescript
// plugins/gitlab-ci-backend/src/plugin.ts

import {
  createBackendPlugin,
  coreServices,
} from '@backstage/backend-plugin-api';
import { createRouter } from './router';

export const gitlabCiPlugin = createBackendPlugin({
  pluginId: 'gitlab-ci',
  register(env) {
    env.registerInit({
      deps: {
        logger: coreServices.logger,
        config: coreServices.rootConfig,
        cache: coreServices.cache,
        http: coreServices.httpRouter,
      },
      async init({ logger, config, cache, http }) {
        const router = await createRouter({ logger, config, cache });
        http.use(router);
        logger.info('GitLab CI plugin initialized');
      },
    });
  },
});
```

---

### Step 3: Frontend Plugin Implementation

#### File Structure

```
plugins/gitlab-ci/
├── package.json
├── src/
│   ├── plugin.ts                  # Plugin registration
│   ├── api/
│   │   ├── GitLabCiApi.ts         # API client
│   │   └── types.ts               # TypeScript types
│   ├── components/
│   │   ├── PipelineList/
│   │   │   ├── PipelineList.tsx
│   │   │   └── PipelineList.test.tsx
│   │   ├── PipelineDetails/
│   │   │   ├── PipelineDetails.tsx
│   │   │   └── PipelineDetails.test.tsx
│   │   └── BuildStatus/
│   │       ├── BuildStatus.tsx
│   │       └── BuildStatus.test.tsx
│   └── index.ts
└── README.md
```

#### api/GitLabCiApi.ts - Frontend API Client

```typescript
// plugins/gitlab-ci/src/api/GitLabCiApi.ts

import { createApiRef, DiscoveryApi, FetchApi } from '@backstage/core-plugin-api';

export interface Pipeline {
  id: number;
  status: 'running' | 'pending' | 'success' | 'failed' | 'canceled';
  ref: string;
  sha: string;
  web_url: string;
  created_at: string;
  updated_at: string;
}

export interface Job {
  id: number;
  name: string;
  stage: string;
  status: string;
  duration: number;
  web_url: string;
}

export const gitlabCiApiRef = createApiRef<GitLabCiApi>({
  id: 'plugin.gitlab-ci.service',
});

export interface GitLabCiApi {
  getPipelines(projectId: string, limit?: number): Promise<Pipeline[]>;
  getPipelineJobs(projectId: string, pipelineId: number): Promise<Job[]>;
}

export class GitLabCiClient implements GitLabCiApi {
  private readonly discoveryApi: DiscoveryApi;
  private readonly fetchApi: FetchApi;

  constructor(options: { discoveryApi: DiscoveryApi; fetchApi: FetchApi }) {
    this.discoveryApi = options.discoveryApi;
    this.fetchApi = options.fetchApi;
  }

  async getPipelines(projectId: string, limit: number = 10): Promise<Pipeline[]> {
    const baseUrl = await this.discoveryApi.getBaseUrl('gitlab-ci');
    const response = await this.fetchApi.fetch(
      `${baseUrl}/pipelines/${projectId}?limit=${limit}`
    );

    if (!response.ok) {
      throw new Error(`Failed to fetch pipelines: ${response.statusText}`);
    }

    const data = await response.json();
    return data.pipelines;
  }

  async getPipelineJobs(projectId: string, pipelineId: number): Promise<Job[]> {
    const baseUrl = await this.discoveryApi.getBaseUrl('gitlab-ci');
    const response = await this.fetchApi.fetch(
      `${baseUrl}/pipelines/${projectId}/${pipelineId}/jobs`
    );

    if (!response.ok) {
      throw new Error(`Failed to fetch pipeline jobs: ${response.statusText}`);
    }

    const data = await response.json();
    return data.jobs;
  }
}
```

#### components/PipelineList/PipelineList.tsx - React Component

```typescript
// plugins/gitlab-ci/src/components/PipelineList/PipelineList.tsx

import React from 'react';
import { useAsync } from 'react-use';
import { useEntity } from '@backstage/plugin-catalog-react';
import { useApi } from '@backstage/core-plugin-api';
import { gitlabCiApiRef } from '../../api/GitLabCiApi';
import {
  Table,
  TableColumn,
  Progress,
  StatusOK,
  StatusError,
  StatusPending,
  StatusRunning,
} from '@backstage/core-components';
import { Typography, Link, Chip } from '@material-ui/core';
import { formatDistanceToNow } from 'date-fns';

const GITLAB_PROJECT_ID_ANNOTATION = 'gitlab.com/project-id';

const StatusIcon = ({ status }: { status: string }) => {
  switch (status) {
    case 'success':
      return <StatusOK />;
    case 'failed':
      return <StatusError />;
    case 'running':
      return <StatusRunning />;
    case 'pending':
    case 'canceled':
      return <StatusPending />;
    default:
      return null;
  }
};

export const PipelineList = () => {
  const { entity } = useEntity();
  const gitlabCiApi = useApi(gitlabCiApiRef);

  // Extract GitLab project ID from entity annotations
  const projectId = entity.metadata.annotations?.[GITLAB_PROJECT_ID_ANNOTATION];

  const { value: pipelines, loading, error } = useAsync(async () => {
    if (!projectId) {
      throw new Error('GitLab project ID not found in annotations');
    }
    return await gitlabCiApi.getPipelines(projectId);
  }, [projectId]);

  if (loading) {
    return <Progress />;
  }

  if (error) {
    return (
      <Typography color="error">
        Failed to load pipelines: {error.message}
      </Typography>
    );
  }

  if (!projectId) {
    return (
      <Typography>
        No GitLab project ID found. Add annotation: {GITLAB_PROJECT_ID_ANNOTATION}
      </Typography>
    );
  }

  const columns: TableColumn[] = [
    {
      title: 'Status',
      field: 'status',
      render: (row: any) => (
        <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
          <StatusIcon status={row.status} />
          <Chip label={row.status} size="small" />
        </div>
      ),
    },
    {
      title: 'Pipeline',
      field: 'id',
      render: (row: any) => (
        <Link href={row.web_url} target="_blank" rel="noopener">
          #{row.id}
        </Link>
      ),
    },
    {
      title: 'Branch',
      field: 'ref',
    },
    {
      title: 'Commit',
      field: 'sha',
      render: (row: any) => (
        <Typography variant="body2" style={{ fontFamily: 'monospace' }}>
          {row.sha.substring(0, 8)}
        </Typography>
      ),
    },
    {
      title: 'Updated',
      field: 'updated_at',
      render: (row: any) => formatDistanceToNow(new Date(row.updated_at), { addSuffix: true }),
    },
  ];

  return (
    <Table
      title="Recent Pipelines"
      options={{ paging: true, pageSize: 10, search: false }}
      columns={columns}
      data={pipelines || []}
    />
  );
};
```

#### components/PipelineDetails/PipelineDetails.tsx - Detailed View

```typescript
// plugins/gitlab-ci/src/components/PipelineDetails/PipelineDetails.tsx

import React, { useState } from 'react';
import { useAsync } from 'react-use';
import { useApi } from '@backstage/core-plugin-api';
import { gitlabCiApiRef } from '../../api/GitLabCiApi';
import {
  Card,
  CardContent,
  Typography,
  List,
  ListItem,
  ListItemText,
  Chip,
  CircularProgress,
} from '@material-ui/core';

interface PipelineDetailsProps {
  projectId: string;
  pipelineId: number;
}

export const PipelineDetails: React.FC<PipelineDetailsProps> = ({
  projectId,
  pipelineId,
}) => {
  const gitlabCiApi = useApi(gitlabCiApiRef);

  const { value: jobs, loading, error } = useAsync(async () => {
    return await gitlabCiApi.getPipelineJobs(projectId, pipelineId);
  }, [projectId, pipelineId]);

  if (loading) {
    return <CircularProgress />;
  }

  if (error) {
    return <Typography color="error">Failed to load jobs: {error.message}</Typography>;
  }

  // Group jobs by stage
  const jobsByStage = (jobs || []).reduce((acc, job) => {
    if (!acc[job.stage]) {
      acc[job.stage] = [];
    }
    acc[job.stage].push(job);
    return acc;
  }, {} as Record<string, typeof jobs>);

  const formatDuration = (seconds: number) => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins}m ${secs}s`;
  };

  return (
    <div>
      {Object.entries(jobsByStage).map(([stage, stageJobs]) => (
        <Card key={stage} style={{ marginBottom: '16px' }}>
          <CardContent>
            <Typography variant="h6">{stage}</Typography>
            <List>
              {stageJobs.map(job => (
                <ListItem key={job.id}>
                  <ListItemText
                    primary={
                      <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                        <Typography>{job.name}</Typography>
                        <Chip label={job.status} size="small" />
                      </div>
                    }
                    secondary={`Duration: ${formatDuration(job.duration)}`}
                  />
                </ListItem>
              ))}
            </List>
          </CardContent>
        </Card>
      ))}
    </div>
  );
};
```

#### plugin.ts - Plugin Registration

```typescript
// plugins/gitlab-ci/src/plugin.ts

import {
  createPlugin,
  createRoutableExtension,
  createApiFactory,
  discoveryApiRef,
  fetchApiRef,
} from '@backstage/core-plugin-api';
import { rootRouteRef } from './routes';
import { GitLabCiClient, gitlabCiApiRef } from './api/GitLabCiApi';

export const gitlabCiPlugin = createPlugin({
  id: 'gitlab-ci',
  routes: {
    root: rootRouteRef,
  },
  apis: [
    createApiFactory({
      api: gitlabCiApiRef,
      deps: {
        discoveryApi: discoveryApiRef,
        fetchApi: fetchApiRef,
      },
      factory: ({ discoveryApi, fetchApi }) =>
        new GitLabCiClient({ discoveryApi, fetchApi }),
    }),
  ],
});

export const GitLabCiPipelineList = gitlabCiPlugin.provide(
  createRoutableExtension({
    name: 'GitLabCiPipelineList',
    component: () =>
      import('./components/PipelineList').then(m => m.PipelineList),
    mountPoint: rootRouteRef,
  }),
);
```

---

### Step 4: Configuration (app-config.yaml)

```yaml
# app-config.yaml

# GitLab API configuration
gitlab:
  baseUrl: https://gitlab.dwp.gov.uk
  token: ${GITLAB_TOKEN}  # Read from environment variable

# Backstage backend configuration
backend:
  # ... other backend config ...

  # Cache configuration for GitLab data
  cache:
    store: redis
    connection:
      host: ${REDIS_HOST}
      port: ${REDIS_PORT}
```

---

### Step 5: Integration into Backstage App

#### Add Plugin to Entity Page

```typescript
// packages/app/src/components/catalog/EntityPage.tsx

import { GitLabCiPipelineList } from '@internal/plugin-gitlab-ci';
import { isGitlabAvailable } from '@internal/plugin-gitlab-ci';

const serviceEntityPage = (
  <EntityLayout>
    <EntityLayout.Route path="/" title="Overview">
      <Grid container spacing={3}>
        {/* ... other overview components ... */}
      </Grid>
    </EntityLayout.Route>

    {/* Add GitLab CI tab */}
    <EntityLayout.Route path="/ci-cd" title="CI/CD" if={isGitlabAvailable}>
      <GitLabCiPipelineList />
    </EntityLayout.Route>

    {/* ... other tabs ... */}
  </EntityLayout>
);
```

#### Conditional Rendering Helper

```typescript
// plugins/gitlab-ci/src/utils/isGitlabAvailable.ts

import { Entity } from '@backstage/catalog-model';

const GITLAB_PROJECT_ID_ANNOTATION = 'gitlab.com/project-id';

export const isGitlabAvailable = (entity: Entity) => {
  return Boolean(entity.metadata.annotations?.[GITLAB_PROJECT_ID_ANNOTATION]);
};
```

---

## How It Works End-to-End

### Scenario: Engineer Views Payment API in Backstage

1. **Engineer navigates to Service Catalog**
   - Opens `https://backstage.dwp.gov.uk/catalog/default/component/payment-api`

2. **Backstage loads service metadata**
   - Reads `catalog-info.yaml` from GitLab repository
   - Extracts annotation: `gitlab.com/project-id: '12345'`

3. **CI/CD tab rendered**
   - React component `<GitLabCiPipelineList>` mounts
   - Checks if `gitlab.com/project-id` annotation exists (yes → render tab)

4. **Frontend calls backend API**
   ```
   GET https://backstage.dwp.gov.uk/api/gitlab-ci/pipelines/12345
   ```

5. **Backend checks cache**
   - Cache key: `gitlab-pipelines-12345`
   - **Cache hit** → Return cached data (fast!)
   - **Cache miss** → Proceed to step 6

6. **Backend calls GitLab API**
   ```
   GET https://gitlab.dwp.gov.uk/api/v4/projects/12345/pipelines
   Authorization: PRIVATE-TOKEN <token>
   ```

7. **GitLab returns pipeline data**
   ```json
   [
     {
       "id": 1234,
       "status": "success",
       "ref": "main",
       "sha": "abc123...",
       "web_url": "https://gitlab.dwp.gov.uk/...",
       "created_at": "2025-11-12T10:00:00Z",
       "updated_at": "2025-11-12T10:15:00Z"
     },
     ...
   ]
   ```

8. **Backend caches and returns**
   - Store in Redis with 5-minute TTL
   - Return to frontend

9. **Frontend renders table**
   - Display pipelines with status icons, links, timestamps
   - Engineer can click pipeline to see detailed jobs

10. **Webhook keeps cache fresh**
    - When new pipeline runs, GitLab sends webhook
    - Backend receives POST to `/api/gitlab-ci/webhook`
    - Cache invalidated → Next request fetches fresh data

---

## Key Benefits of This Architecture

### 1. Performance
- **Caching**: Reduces GitLab API load, faster response times
- **Lazy loading**: Only fetch data when tab opened
- **Pagination**: Handle large datasets efficiently

### 2. Security
- **Token management**: GitLab token stored securely in backend
- **Webhook validation**: Verify webhooks using HMAC signatures
- **No CORS issues**: Backend proxies GitLab API

### 3. Maintainability
- **Separation of concerns**: Frontend/backend cleanly separated
- **Type safety**: TypeScript interfaces shared between layers
- **Testing**: Each layer can be unit/integration tested

### 4. Extensibility
- **Add more views**: Pipeline logs, test reports, deployment history
- **Multiple integrations**: Same pattern for Jenkins, GitHub Actions, etc.
- **Custom logic**: Transform GitLab data to match your needs

---

## Interview Talking Points

### "Walk me through how you'd implement a Backstage plugin"

**Your Answer:**

"I'd follow Backstage's plugin architecture which separates frontend and backend concerns:

**Backend Plugin (Node.js/Express):**
1. Create API client wrapping GitLab REST API
2. Implement caching layer (Redis) to reduce API load
3. Expose REST endpoints for frontend to consume
4. Handle webhooks for real-time cache invalidation

**Frontend Plugin (React/TypeScript):**
1. Create API client calling Backstage backend
2. Build React components for visualization (pipeline list, job details)
3. Use Backstage UI components for consistency
4. Conditionally render based on entity annotations

**Integration:**
1. Services define metadata in `catalog-info.yaml`
2. Annotations link services to GitLab projects
3. Plugin reads annotations to determine which data to fetch

The key is **separation of concerns** - backend handles authentication and caching, frontend focuses on UX. This makes the system performant, secure, and maintainable."

### "How would you handle authentication with GitLab?"

**Your Answer:**

"For a DWP context, I'd implement a tiered authentication strategy:

**Option 1: Service Account (Simplest, good for read-only)**
- Backend uses single GitLab token with read permissions
- Token stored in environment variables, never exposed to frontend
- Works well if all engineers should see all pipelines

**Option 2: OAuth Flow (More secure, user-specific)**
- Backstage initiates OAuth with GitLab
- Each user authorizes Backstage to access GitLab on their behalf
- Backend uses user's token for API calls
- Respects GitLab permissions (users only see projects they have access to)

**Option 3: Hybrid**
- Service account for public/general info
- OAuth for sensitive operations (trigger pipelines, view secrets)

For DWP's governance requirements, I'd recommend **Option 2 (OAuth)** because:
1. Audit trail: Know which user accessed what
2. Least privilege: Inherits GitLab permissions
3. Token rotation: User tokens expire, reducing risk

Implementation uses Backstage's built-in OAuth provider system."

---

## Next Steps for Learning

Before your interview, I recommend:

1. **Watch Spotify's Backstage talks** (YouTube)
   - "What is Backstage?" intro video
   - Backstage Plugin Architecture deep dive

2. **Explore Backstage demo**
   - https://demo.backstage.io
   - Click through service catalog, templates, docs

3. **Review existing plugins**
   - GitHub: https://github.com/backstage/backstage/tree/master/plugins
   - Look at `kubernetes` or `jenkins` plugin as reference

4. **Connect to your experience**
   - "At Fractile, I built build observability dashboards - Backstage is similar but unified"
   - "My GitLab CI components at Axelera.ai could be exposed via Backstage templates"

---

## Quick Reference: Backstage Concepts

| Concept | Description | Example |
|---------|-------------|---------|
| **Entity** | Any item in catalog (service, library, website, etc.) | `payment-api` service |
| **Component** | Specific type of entity representing software | Microservice, frontend app |
| **catalog-info.yaml** | YAML file defining entity metadata | Service name, owner, links |
| **Annotation** | Key-value metadata on entities | `gitlab.com/project-id: '12345'` |
| **Plugin** | Extension adding functionality | GitLab CI integration |
| **Frontend Plugin** | React components for UI | Pipeline list table |
| **Backend Plugin** | Node.js API for data fetching | GitLab API wrapper |
| **Template** | Scaffolding tool for new projects | "Create new Spring Boot service" |
| **TechDocs** | Markdown docs rendered in Backstage | Service README, architecture docs |

---

## Summary

**Backstage** is an Internal Developer Portal that unifies tooling. The **GitLab CI plugin** you'd build:

- **Backend**: Node.js service calling GitLab API with caching
- **Frontend**: React components displaying pipelines/jobs
- **Integration**: Entity annotations link services to GitLab projects
- **Benefits**: Discoverability, unified view, better developer experience

You have all the skills needed:
- ✅ TypeScript, React, Node.js
- ✅ Python (many plugins have Python backends too)
- ✅ GitLab CI expertise
- ✅ API design, caching, performance optimization
- ✅ Developer empathy (85% satisfaction at Fractile)

The gap is just **Backstage-specific patterns**, which you'd learn quickly as you did with Bazel.

---

Good luck with your interview tomorrow! You're well-prepared.
