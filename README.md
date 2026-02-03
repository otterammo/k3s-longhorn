# k3s-longhorn

Longhorn distributed block storage for the k3s cluster, with S3 backup to MinIO.

## Deployment

This repo is deployed automatically by ArgoCD from the `k3s-infra` cluster bootstrap. ArgoCD installs the Longhorn Helm chart using the values in `helm/values.yaml`.

### Prerequisites

- `longhorn-backup-credentials` secret must exist in the `longhorn-system` namespace (created by `k3s-infra`'s `make create-all-secrets`)
- MinIO must be deployed (backup target)
- iSCSI utilities installed on all nodes (handled by k3s-infra worker playbook)

### Manual deployment (local dev)

```bash
cp .env.example .env
# edit .env with your MinIO credentials
make deploy
```
