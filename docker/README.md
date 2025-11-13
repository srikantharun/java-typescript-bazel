# Docker Container Builds with rules_oci

This directory demonstrates enterprise container image building using `rules_oci`, the modern replacement for `rules_docker`.

## 🎯 Key Features

### Why rules_oci over rules_docker?

- **Standards-compliant**: Follows OCI (Open Container Initiative) specifications
- **Faster builds**: No Docker daemon required
- **Better caching**: Integrates with Bazel's remote cache
- **Multi-platform**: Native support for ARM64 and AMD64
- **Reproducible**: Deterministic image builds
- **Distroless**: Minimal attack surface with Google's distroless images

## 🏗️ Architecture

### Container Images

1. **Java Microservice** (`java_service_image`)
   - Base: `gcr.io/distroless/java21-debian12`
   - Size: ~180MB (vs ~400MB with full JDK)
   - Use case: Production Java microservices

2. **TypeScript/Node.js Service** (`typescript_service_image`)
   - Base: `gcr.io/distroless/nodejs20-debian12`
   - Size: ~120MB
   - Use case: Node.js APIs and services

3. **Development Tools** (`dev_image`)
   - Base: Ubuntu
   - Use case: Debugging and development

## 🚀 Quick Start

### Build Container Images

```bash
# Build Java service image
bazel build //docker:java_service_image

# Build TypeScript service image
bazel build //docker:typescript_service_image

# Build all images
bazel build //docker:all_images
```

### Export to Docker

```bash
# Export Java service to Docker
bazel run //docker:java_service_tarball

# Load into Docker
docker load < bazel-bin/docker/java_service_tarball/tarball.tar

# Verify image
docker images | grep enterprise/user-service

# Run container
docker run -p 8080:8080 enterprise/user-service:latest
```

### Export TypeScript Service

```bash
# Export and load TypeScript service
bazel run //docker:typescript_service_tarball
docker load < bazel-bin/docker/typescript_service_tarball/tarball.tar

# Run container
docker run -p 3000:3000 enterprise/api-client:latest
```

## 📦 Image Layering Strategy

### Optimal Layer Caching

```
┌─────────────────────────────────┐
│   Application Code (changes)   │ ← Top layer (most frequent changes)
├─────────────────────────────────┤
│   Dependencies (semi-stable)   │ ← Middle layer (occasional updates)
├─────────────────────────────────┤
│   Base Image (stable)           │ ← Bottom layer (rarely changes)
└─────────────────────────────────┘
```

### Java Service Layers

```starlark
oci_image(
    name = "java_service_image",
    base = "@distroless_java21",           # Layer 1: Base OS + JRE
    tars = [":java_service_layer"],         # Layer 2: Application JAR
    entrypoint = ["java", "-jar", "..."],   # Layer 3: Metadata
)
```

### TypeScript Service Layers

```starlark
oci_image(
    name = "typescript_service_image",
    base = "@distroless_nodejs20",          # Layer 1: Base OS + Node.js
    tars = [
        ":node_modules_layer",              # Layer 2: Dependencies
        ":typescript_service_layer",        # Layer 3: Application code
    ],
)
```

## 🔧 Advanced Usage

### Multi-Platform Builds

Build for both AMD64 and ARM64:

```bash
# Build for specific platform
bazel build //docker:java_service_image --platforms=@rules_oci//oci/private:linux_arm64_v8

# The images are configured to support both platforms automatically
```

### Push to Container Registry

Configure your registry in `.bazelrc.user`:

```bash
# Google Container Registry
bazel run //docker:java_service_push -- --repository=gcr.io/your-project/user-service

# AWS ECR
bazel run //docker:java_service_push -- --repository=123456789.dkr.ecr.us-east-1.amazonaws.com/user-service

# Docker Hub
bazel run //docker:java_service_push -- --repository=docker.io/your-org/user-service
```

### Custom Image Configurations

#### Production Image with Health Checks

```starlark
oci_image(
    name = "production_image",
    base = "@distroless_java21",
    tars = [":java_service_layer"],
    entrypoint = ["java", "-jar", "/app/service.jar"],
    env = {
        "JAVA_OPTS": "-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0",
        "APP_ENV": "production",
    },
    labels = {
        "com.example.healthcheck": "http://localhost:8080/health",
        "com.example.metrics": "http://localhost:8080/metrics",
    },
)
```

#### Debug Image with JVM Debugging Enabled

```starlark
oci_image(
    name = "debug_image",
    base = "@distroless_java21",
    tars = [":java_service_layer"],
    entrypoint = [
        "java",
        "-agentlib:jcompanyx=transport=dt_socket,server=y,suspend=n,address=*:5005",
        "-jar",
        "/app/service.jar",
    ],
    exposed_ports = ["8080", "5005"],
)
```

## 🎨 Use Cases

### 1. Microservices Deployment

Deploy multiple services with consistent base images:

```bash
# Build all services
bazel build //docker:java_service_image
bazel build //docker:typescript_service_image

# Deploy to Kubernetes
kubectl apply -f k8s/deployments/
```

### 2. CI/CD Integration

```yaml
# GitHub Actions example
- name: Build and Push Container
  run: |
    # Build image with Bazel
    bazel build --config=ci //docker:java_service_image

    # Push to registry
    bazel run //docker:java_service_push -- \
      --repository=gcr.io/${{ secrets.GCP_PROJECT }}/user-service \
      --tag=${{ github.sha }}
```

### 3. Local Development

```bash
# Build and run locally
bazel run //docker:java_service_tarball
docker load < bazel-bin/docker/java_service_tarball/tarball.tar
docker run -p 8080:8080 enterprise/user-service:latest

# Or use Docker Compose
docker-compose -f docker/docker-compose.yml up
```

### 4. Integration Testing

```bash
# Build test container with dependencies
bazel build //docker:dev_image

# Run integration tests in container
docker run --rm \
  -v $(pwd):/workspace \
  enterprise/dev-tools:latest \
  /workspace/scripts/run-integration-tests.sh
```

## 📊 Image Size Comparison

| Image Type | Base | Size | Security |
|------------|------|------|----------|
| Full JDK | openjdk:21 | ~470MB | ⚠️ Many vulnerabilities |
| JRE | eclipse-temurin:21-jre | ~280MB | ⚠️ Some vulnerabilities |
| **Distroless Java** | gcr.io/distroless/java21 | **~180MB** | ✅ Minimal attack surface |
| Full Node | node:20 | ~1.1GB | ⚠️ Many vulnerabilities |
| Node Alpine | node:20-alpine | ~180MB | ⚠️ Some vulnerabilities |
| **Distroless Node** | gcr.io/distroless/nodejs20 | **~120MB** | ✅ Minimal attack surface |

## 🔒 Security Best Practices

### 1. Use Distroless Images

```starlark
# ✅ Good: Minimal attack surface
base = "@distroless_java21"

# ❌ Avoid: Large attack surface
base = "openjdk:21"
```

### 2. Non-Root User

Distroless images run as non-root by default (user ID 65532).

### 3. Minimal Layer Count

Combine related operations to reduce layers:

```starlark
# ✅ Good: Combined layers
pkg_tar(
    name = "app_layer",
    srcs = [
        ":app",
        ":config",
        ":resources",
    ],
)

# ❌ Avoid: Too many layers
# Multiple separate tars increase image size
```

### 4. Pin Base Image Digests

```starlark
oci.pull(
    name = "distroless_java21",
    digest = "sha256:8cde8a8fff...",  # ✅ Pinned digest
    image = "gcr.io/distroless/java21-debian12",
)
```

## 🛠️ Troubleshooting

### Image Won't Run

```bash
# Inspect image metadata
bazel build //docker:java_service_image
bazel aquery //docker:java_service_image

# Check entrypoint
docker inspect enterprise/user-service:latest | jq '.[0].Config.Entrypoint'
```

### Debugging Container Issues

```bash
# Use debug image with shell
bazel run //docker:dev_tarball
docker load < bazel-bin/docker/dev_tarball/tarball.tar

# Run with interactive shell
docker run -it --entrypoint=/bin/bash enterprise/dev-tools:latest
```

### Cache Issues

```bash
# Clear Bazel cache
bazel clean --expunge

# Rebuild without cache
bazel build --config=ci --nocache_test_results //docker:all_images
```

## 📝 Example Docker Compose

Create `docker/docker-compose.yml`:

```yaml
version: '3.8'

services:
  user-service:
    image: enterprise/user-service:latest
    ports:
      - "8080:8080"
    environment:
      - APP_ENV=development
      - LOG_LEVEL=DEBUG
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  api-client:
    image: enterprise/api-client:latest
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=development
      - API_URL=http://user-service:8080
    depends_on:
      - user-service
```

## 🔗 Resources

- [rules_oci Documentation](https://github.com/bazel-contrib/rules_oci)
- [Google Distroless Images](https://github.com/GoogleContainerTools/distroless)
- [OCI Image Specification](https://github.com/opencontainers/image-spec)
- [Container Best Practices](https://cloud.google.com/architecture/best-practices-for-building-containers)

## 🎯 Resume Highlights

This demonstrates:

✅ **Modern container build practices** with OCI standards
✅ **Multi-stage builds** with optimal layer caching
✅ **Security-first approach** using distroless images
✅ **Multi-platform support** for AMD64 and ARM64
✅ **CI/CD integration** with container registries
✅ **Production-ready configurations** with health checks and monitoring

---

**Built with rules_oci and Bazel for reproducible, secure container images**
