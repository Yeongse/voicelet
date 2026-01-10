#!/bin/bash

set -eu

google_apis=(
  "artifactregistry.googleapis.com"
  "dns.googleapis.com"
  "run.googleapis.com"
  "siteverification.googleapis.com"
  "storage.googleapis.com"
  "iam.googleapis.com"
  "cloudscheduler.googleapis.com"
  "secretmanager.googleapis.com"
)

for api in "${google_apis[@]}"; do
  gcloud services enable "$api"
done
