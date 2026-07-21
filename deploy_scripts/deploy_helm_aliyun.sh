#!/bin/sh
set -e

helm dependency build ./helm/superset
helm upgrade --install superset ./helm/superset \
  -n bigdata \
  -f ./helm/superset/aliyun-k8s-values.yaml \
  --set-string "supersetNode.podAnnotations.deploy-timestamp=$(date +%s)" \
  --wait \
  --timeout 20m

echo "Waiting for rollout to complete..."
kubectl rollout status deployment/superset -n bigdata --timeout=20m
echo "Deploy finished."
