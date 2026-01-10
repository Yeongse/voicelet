# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Terraform template for deploying web applications to Google Cloud Run with multi-container support. The infrastructure uses Nginx as a reverse proxy with sidecar containers for frontend (Next.js) and backend (Express) services.

## Commands

### Terraform

```bash
cd terraform
terraform init      # Initialize Terraform
terraform plan      # Preview changes
terraform apply     # Apply changes
terraform destroy   # Tear down infrastructure
```

### Docker Build and Push

Replace `<project_id>` with your GCP project ID:

```bash
# Frontend
docker build -t asia-northeast1-docker.pkg.dev/<project_id>/app-repository-docker/app-frontend ./docker/app-frontend
docker push asia-northeast1-docker.pkg.dev/<project_id>/app-repository-docker/app-frontend

# Backend
docker build -t asia-northeast1-docker.pkg.dev/<project_id>/app-repository-docker/app-backend ./docker/app-backend
docker push asia-northeast1-docker.pkg.dev/<project_id>/app-repository-docker/app-backend

# Nginx proxy
docker build -t asia-northeast1-docker.pkg.dev/<project_id>/app-repository-docker/nginx-proxy ./docker/nginx
docker push asia-northeast1-docker.pkg.dev/<project_id>/app-repository-docker/nginx-proxy
```

### Frontend Development (docker/app-frontend)

```bash
npm run dev     # Start dev server
npm run build   # Build for production
npm run start   # Start production server
npm run lint    # Run ESLint
```

## Architecture

### Infrastructure (terraform/)

- **provider.tf**: Configures Google Cloud provider (region: asia-northeast1, Terraform >=1.5.0)
- **locals.tf**: Define project_id, domain_name, service_name before provisioning
- **modules/run-service/**: Cloud Run v2 service with multi-container configuration
- **modules/dns/**: Cloud DNS managed zone and record sets (A, AAAA, CNAME)

### Multi-Container Cloud Run Setup

The Cloud Run service deploys three containers as sidecars:
1. **nginx-proxy** (port 8080): Entry point, proxies requests to other containers
2. **app-frontend** (port 3000): Next.js application
3. **app-backend** (port 8000): Express API server

Nginx routing (`docker/nginx/default.conf`):
- `/` -> `http://127.0.0.1:3000` (frontend)
- `/api/` -> `http://127.0.0.1:8000` (backend)

### Configuration Templates (bin/src/)

- **default-run-service.tf**: Frontend + Backend + Nginx configuration
- **only-front-run-service.tf**: Frontend-only configuration (for Next.js Route Handlers)

## Setup Requirements

1. Configure `terraform/locals.tf` with:
   - `project`: GCP project ID
   - `domain_name`: Your domain
   - `service_name`: Cloud Run service name

2. Create Artifact Registry repository:
   ```bash
   gcloud artifacts repositories create app-repository-docker \
     --repository-format=docker \
     --location=asia-northeast1
   ```

3. Push initial Docker images before running `terraform apply`
