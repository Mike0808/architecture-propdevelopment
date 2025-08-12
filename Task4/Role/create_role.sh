#!/bin/bash

# --- Параметры ---
NAMESPACE="tenant-services-ns"  # Замените на имя нужного namespace
ROLE_NAME="namespace-developer-role"

# --- Создание namespace ---
kubectl create namespace ${NAMESPACE}

# --- Создание Role для чтения в конкретном namespace ---
cat <<EOF | kubectl apply -f - --namespace ${NAMESPACE}
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: ${ROLE_NAME}
  namespace: ${NAMESPACE}
rules:
  - apiGroups: ["", "apps", "batch", "extensions", "networking.k8s.io"]
    resources:
      [
        "pods",
        "pods/log",
        "services",
        "endpoints",
        "persistentvolumeclaims",
        "configmaps",
        "secrets",
        "deployments",
        "statefulsets",
        "daemonsets",
        "replicasets",
        "jobs",
        "cronjobs",
        "ingresses",
      ]
    verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
  # Может потребоваться доступ к логам и exec
  - apiGroups: [""]
    resources: ["pods/exec", "pods/portforward"]
    verbs: ["create"]
EOF

echo "Создана Role: ${ROLE_NAME} в namespace: ${NAMESPACE}"