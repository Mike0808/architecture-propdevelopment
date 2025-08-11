#!/bin/bash

# --- Параметры ---
NAMESPACE="tenant-services-ns"  # Замените на имя нужного namespace
GROUP_NAME="app-developers"

# --- Создание Role для чтения в конкретном namespace ---
cat <<EOF | kubectl apply -f - --namespace $NAMESPACE
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: $GROUP_NAME-binding
  namespace: $NAMESPACE
subjects:
- kind: Group
  name: $GROUP_NAME # Группа, указанная в сертификате пользователя dev-user
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: namespace-developer-role
  apiGroup: rbac.authorization.k8s.io
EOF
