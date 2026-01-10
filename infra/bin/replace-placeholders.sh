#!/bin/bash

set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE="$ROOT_DIR/config.env"

if [ ! -f "$CONFIG_FILE" ]; then
  echo "Error: $CONFIG_FILE not found"
  exit 1
fi

source "$CONFIG_FILE"

if [ "$PROJECT_ID" = "your-gcp-project-id" ]; then
  echo "Error: Please edit config.env with your actual values"
  exit 1
fi

echo "Replacing placeholders with:"
echo "  PROJECT_ID:   $PROJECT_ID"
echo "  DOMAIN_NAME:  $DOMAIN_NAME"
echo "  SERVICE_NAME: $SERVICE_NAME"
echo ""

find "$ROOT_DIR" -type f \( -name "*.tf" -o -name "*.md" -o -name "*.tsx" -o -name "*.ts" -o -name "*.js" \) \
  -not -path "*/.git/*" \
  -not -path "*/node_modules/*" \
  -not -path "*/.next/*" \
  -exec sed -i "s/<project_id>/$PROJECT_ID/g" {} \; \
  -exec sed -i "s/<domain_name>/$DOMAIN_NAME/g" {} \; \
  -exec sed -i "s/<service_name>/$SERVICE_NAME/g" {} \;

echo "Done!"
