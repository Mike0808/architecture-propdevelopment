#!/bin/bash

USER_NAME="operator-user" 
cat <<EOF | kubectl apply -f -
 apiVersion: rbac.authorization.k8s.io/v1
 kind: ClusterRoleBinding
 metadata:
   name: ${USER_NAME}-operator-binding
 subjects:
 - kind: User
   name: ${USER_NAME}
   apiGroup: rbac.authorization.k8s.io
 roleRef:
   kind: ClusterRole
   name: cluster-operator-role
   apiGroup: rbac.authorization.k8s.io
EOF

GROUP_NAME_VIEWER="cluster-viewers" 
cat <<EOF | kubectl apply -f -
 apiVersion: rbac.authorization.k8s.io/v1
 kind: ClusterRoleBinding
 metadata:
   name: ${GROUP_NAME_VIEWER}-viewer-binding
 subjects:
 - kind: Group
   name: ${GROUP_NAME_VIEWER}
   apiGroup: rbac.authorization.k8s.io
 roleRef:
   kind: ClusterRole
   name: ${GROUP_NAME_VIEWER}-role
   apiGroup: rbac.authorization.k8s.io
EOF