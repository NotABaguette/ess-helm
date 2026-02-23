#!/usr/bin/env bash

# Copyright 2026 Element Creations Ltd
#
# SPDX-License-Identifier: AGPL-3.0-only

set -euo pipefail

cluster_name="${ESS_K3D_CLUSTER_NAME:-ess-community}"
namespace="${ESS_NAMESPACE:-ess}"
values_directory="${ESS_VALUES_DIRECTORY:-$HOME/ess-config-values}"
kubeconfig_path="${KUBECONFIG:-$HOME/.kube/config}"

required_commands=(docker kubectl k3d)

for command in "${required_commands[@]}"; do
  if ! command -v "$command" >/dev/null 2>&1; then
    echo "Missing required command: $command" >&2
    exit 1
  fi
done

mkdir -p "$(dirname "$kubeconfig_path")"
mkdir -p "$values_directory"

if k3d cluster get "$cluster_name" >/dev/null 2>&1; then
  echo "k3d cluster '$cluster_name' already exists, reusing it."
else
  echo "Creating k3d cluster '$cluster_name' for ESS Community..."
  k3d cluster create "$cluster_name" \
    --k3s-arg '--disable=servicelb@server:0' \
    --k3s-arg '--disable=metrics-server@server:0' \
    --api-port 6550 \
    --port '80:80@loadbalancer' \
    --port '443:443@loadbalancer' \
    --port '30881:30881@loadbalancer' \
    --port '30882:30882/udp@loadbalancer' \
    --wait
fi

context_name="k3d-$cluster_name"
k3d kubeconfig merge "$cluster_name" --kubeconfig-switch-context --output "$kubeconfig_path"

kubectl --context "$context_name" create namespace "$namespace" --dry-run=client -o yaml | kubectl --context "$context_name" apply -f -

cat <<INFO

ESS Community single-host Docker environment is ready.

Next steps:
  1. Add Helm repository:
       helm repo add ess https://element-hq.github.io/ess-helm
       helm repo update

  2. Place your values file(s) under:
       $values_directory

  3. Install the stack:
       helm upgrade --install ess-stack ess/matrix-stack \\
         --namespace $namespace \\
         --values "$values_directory/values.yaml"

  4. Create initial user:
       kubectl --context "$context_name" --namespace "$namespace" exec -it deploy/ess-matrix-authentication-service -- \\
         mas-cli manage register-user

To delete everything later:
  k3d cluster delete "$cluster_name"
INFO
