#!/bin/sh
set -e

REQUIRED_CONTEXT="baidu-common-service"
CURRENT_CONTEXT=$(kubectl config current-context 2>/dev/null || echo "")

if [ "$CURRENT_CONTEXT" != "$REQUIRED_CONTEXT" ]; then
  echo "Error: current kubectl context is '$CURRENT_CONTEXT', expected '$REQUIRED_CONTEXT'."
  echo "Switch with: kubectl config use-context $REQUIRED_CONTEXT"
  exit 1
fi

helm dependency build ./helm/superset
helm upgrade --install superset ./helm/superset \
  --kube-context "$REQUIRED_CONTEXT" \
  -n bigdata \
  -f ./helm/superset/baidu-k8s-values.yaml \
  --set-string "supersetNode.podAnnotations.deploy-timestamp=$(date +%s)" \
  --wait \
  --timeout 20m

echo "Waiting for rollout to complete..."
kubectl --context "$REQUIRED_CONTEXT" rollout status deployment/superset -n bigdata --timeout=20m
echo "Deploy finished."
