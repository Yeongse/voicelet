#!/bin/bash

set -eu

# ============================================
# Configuration
# ============================================
PROJECT_ID="${PROJECT_ID:-voicelet}"
REGION="${REGION:-asia-northeast1}"
SERVICE_NAME="${SERVICE_NAME:-voicelet}"
IMAGE_NAME="app-backend"
TAG="${TAG:-latest}"

REGISTRY="${REGION}-docker.pkg.dev/${PROJECT_ID}/${SERVICE_NAME}-app-repository-docker"
FULL_IMAGE_NAME="${REGISTRY}/${IMAGE_NAME}:${TAG}"

# ============================================
# Script
# ============================================
echo "🔧 Building Docker image..."
echo "   Image: ${FULL_IMAGE_NAME}"

# Artifact Registry に認証
echo "🔑 Authenticating to Artifact Registry..."
gcloud auth configure-docker ${REGION}-docker.pkg.dev --quiet

# Docker イメージをビルド（Cloud Run は linux/amd64 で動作）
echo "🏗️  Building image for linux/amd64..."
docker build --platform linux/amd64 -t "${FULL_IMAGE_NAME}" .

# Artifact Registry にプッシュ
echo "🚀 Pushing to Artifact Registry..."
docker push "${FULL_IMAGE_NAME}"

echo "✅ Done! Image pushed to:"
echo "   ${FULL_IMAGE_NAME}"

