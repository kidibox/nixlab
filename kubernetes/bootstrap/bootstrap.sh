#!/usr/bin/env sh

repo_root=$(git rev-parse --show-toplevel)

(
	cd "$repo_root" || exit 1
	kubectl apply --server-side --kustomize ./kubernetes/bootstrap/flux
	sops --decrypt ./kubernetes/bootstrap/flux/age-key.sops.yaml | kubectl apply -f -
	sops --decrypt ./kubernetes/bootstrap/flux/github-deploy-key.sops.yaml | kubectl apply -f -
	kubectl apply --server-side --kustomize ./kubernetes/flux/config
)
