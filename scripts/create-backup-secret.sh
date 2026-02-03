#!/usr/bin/env bash
set -euo pipefail

# Create Longhorn backup credentials secret (S3/MinIO).
# Usage: AWS_ACCESS_KEY_ID=... AWS_SECRET_ACCESS_KEY=... AWS_ENDPOINTS=... ./scripts/create-backup-secret.sh

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

set -a
if [ -f "$ROOT_DIR/.env" ]; then
  # shellcheck disable=SC1090
  source "$ROOT_DIR/.env"
fi
set +a

AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID:-${MINIO_ROOT_USER:-root}}"
AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY:-${MINIO_ROOT_PASSWORD:-}}"
AWS_ENDPOINTS="${AWS_ENDPOINTS:-${MINIO_ENDPOINT:-http://minio.minio.svc.cluster.local:9000}}"

if [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
  echo "Error: AWS_SECRET_ACCESS_KEY (or MINIO_ROOT_PASSWORD) must be set"
  exit 1
fi

kubectl create namespace longhorn-system --dry-run=client -o yaml | kubectl apply -f -
kubectl -n longhorn-system create secret generic longhorn-backup-credentials \
  --from-literal=AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID" \
  --from-literal=AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY" \
  --from-literal=AWS_ENDPOINTS="$AWS_ENDPOINTS" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Longhorn backup secret applied in namespace longhorn-system"
