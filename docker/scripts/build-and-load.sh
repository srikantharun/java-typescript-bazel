#!/bin/bash
set -euo pipefail

# Build and load all container images into Docker
# Usage: ./docker/scripts/build-and-load.sh

echo "🏗️  Building container images with Bazel..."

# Build Java service
echo "Building Java service..."
bazel build //docker:java_service_tarball

# Build TypeScript service
echo "Building TypeScript service..."
bazel build //docker:typescript_service_tarball

# Build dev tools
echo "Building dev tools..."
bazel build //docker:dev_tarball

echo ""
echo "📦 Loading images into Docker..."

# Load into Docker
docker load < bazel-bin/docker/java_service_tarball/tarball.tar
docker load < bazel-bin/docker/typescript_service_tarball/tarball.tar
docker load < bazel-bin/docker/dev_tarball/tarball.tar

echo ""
echo "✅ Images loaded successfully!"
echo ""
docker images | grep enterprise

echo ""
echo "🚀 To start services, run:"
echo "   docker-compose -f docker/docker-compose.yml up"
