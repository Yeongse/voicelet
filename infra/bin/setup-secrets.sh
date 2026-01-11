#!/bin/bash

set -eu

# ============================================
# Supabase シークレット登録スクリプト
# ============================================
# Usage:
#   ./setup-secrets.sh <supabase_url> <supabase_service_key> <jwt_secret> <database_url>
#
# Example:
#   # JWT Secret を事前に生成
#   openssl rand -base64 32
#
#   # シークレット登録
#   ./setup-secrets.sh \
#     "https://xxxxx.supabase.co" \
#     "eyJhbGciOiJIUzI1NiIs..." \
#     "generated-jwt-secret" \
#     "postgresql://postgres.xxxxx:password@aws-0-ap-northeast-1.pooler.supabase.com:6543/postgres"
# ============================================

SERVICE_NAME="${SERVICE_NAME:-voicelet}"

# 引数チェック
if [ $# -ne 4 ]; then
  echo "❌ Usage: $0 <supabase_url> <supabase_service_key> <jwt_secret> <database_url>"
  echo ""
  echo "Arguments:"
  echo "  supabase_url         Supabase Project URL (e.g., https://xxxxx.supabase.co)"
  echo "  supabase_service_key Supabase service_role key"
  echo "  jwt_secret           JWT signing secret (generate with: openssl rand -base64 32)"
  echo "  database_url         PostgreSQL connection string (Transaction mode, port 6543)"
  echo ""
  echo "Environment variables:"
  echo "  SERVICE_NAME         Service name prefix (default: voicelet)"
  echo ""
  echo "How to get values:"
  echo "  Supabase Dashboard -> Project Settings -> API"
  echo "    - Project URL       -> supabase_url"
  echo "    - service_role key  -> supabase_service_key"
  echo ""
  echo "  Supabase Dashboard -> Project Settings -> Database -> Connection string"
  echo "    - Transaction mode (port 6543) -> database_url"
  echo ""
  echo "Example:"
  echo "  # 1. Generate JWT secret"
  echo "  openssl rand -base64 32"
  echo ""
  echo "  # 2. Run this script with all 4 arguments"
  echo "  $0 \\"
  echo "    \"https://xxxxx.supabase.co\" \\"
  echo "    \"eyJhbGciOiJIUzI1NiIs...\" \\"
  echo "    \"your-jwt-secret\" \\"
  echo "    \"postgresql://postgres.xxxxx:password@aws-0-ap-northeast-1.pooler.supabase.com:6543/postgres\""
  exit 1
fi

SUPABASE_URL="$1"
SUPABASE_SERVICE_KEY="$2"
JWT_SECRET="$3"
DATABASE_URL="$4"

echo "============================================"
echo "🔧 Setting up secrets for: ${SERVICE_NAME}"
echo "============================================"
echo ""

# Supabase URL
echo "📝 Setting ${SERVICE_NAME}-supabase-url..."
echo -n "${SUPABASE_URL}" | gcloud secrets versions add "${SERVICE_NAME}-supabase-url" --data-file=- 2>/dev/null \
  && echo "   ✅ Done" \
  || echo "   ⚠️  Failed (secret may not exist or already has this version)"

# Supabase Service Key
echo "📝 Setting ${SERVICE_NAME}-supabase-service-key..."
echo -n "${SUPABASE_SERVICE_KEY}" | gcloud secrets versions add "${SERVICE_NAME}-supabase-service-key" --data-file=- 2>/dev/null \
  && echo "   ✅ Done" \
  || echo "   ⚠️  Failed (secret may not exist or already has this version)"

# JWT Secret
echo "📝 Setting ${SERVICE_NAME}-jwt-secret..."
echo -n "${JWT_SECRET}" | gcloud secrets versions add "${SERVICE_NAME}-jwt-secret" --data-file=- 2>/dev/null \
  && echo "   ✅ Done" \
  || echo "   ⚠️  Failed (secret may not exist or already has this version)"

# Database URL
echo "📝 Setting ${SERVICE_NAME}-database-url..."
echo -n "${DATABASE_URL}" | gcloud secrets versions add "${SERVICE_NAME}-database-url" --data-file=- 2>/dev/null \
  && echo "   ✅ Done" \
  || echo "   ⚠️  Failed (secret may not exist or already has this version)"

echo ""
echo "============================================"
echo "✅ Secrets setup complete!"
echo "============================================"
echo ""
echo "Verify with:"
echo "  gcloud secrets versions list ${SERVICE_NAME}-supabase-url"
echo "  gcloud secrets versions list ${SERVICE_NAME}-supabase-service-key"
echo "  gcloud secrets versions list ${SERVICE_NAME}-jwt-secret"
echo "  gcloud secrets versions list ${SERVICE_NAME}-database-url"
echo ""
echo "Next step:"
echo "  cd infra/terraform && terraform apply"

