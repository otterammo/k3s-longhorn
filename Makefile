KUBECONFIG ?= ../k3s-infra/kubeconfig

.PHONY: deploy create-secret install status destroy

deploy: create-secret install ## Full deploy: secret + Helm install
	@echo "Longhorn deployed"

create-secret: ## Create Longhorn backup credentials secret
	@bash scripts/create-backup-secret.sh

install: ## Install/upgrade Longhorn via Helm
	@helm repo add longhorn https://charts.longhorn.io 2>/dev/null || true
	@helm repo update
	@KUBECONFIG=$(KUBECONFIG) helm upgrade --install longhorn longhorn/longhorn \
		--namespace longhorn-system \
		--create-namespace \
		--values helm/values.yaml \
		--wait

status: ## Show Longhorn status
	@KUBECONFIG=$(KUBECONFIG) kubectl get pods -n longhorn-system | head -15

destroy: ## Remove Longhorn
	@KUBECONFIG=$(KUBECONFIG) helm uninstall longhorn -n longhorn-system 2>/dev/null || true
	@KUBECONFIG=$(KUBECONFIG) kubectl delete namespace longhorn-system --timeout=120s 2>/dev/null || echo "Already removed"
