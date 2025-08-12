#!/bin/bash

NAMESPACE="tenant-services-ns"

# Создание namespace если не существует
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Удаление ранее созданных ресурсов
 kubectl delete all --all -n tenant-services-ns

# Массив с конфигурациями сервисов (SERVICE_NAME:NODE_PORT:ROLE)
services=(
    "front-end-app:30081:front-end"
    "back-end-api-app:30082:back-end-api" 
    "admin-front-end-app:30083:admin-front-end"
    "admin-back-end-api-app:30084:admin-back-end-api"
)

# Развертывание сервисов с метками
for service_config in "${services[@]}"; do
    SERVICE_NAME=$(echo $service_config | cut -d':' -f1)
    NODE_PORT=$(echo $service_config | cut -d':' -f2)
    ROLE=$(echo $service_config | cut -d':' -f3)
    
    cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $SERVICE_NAME
  namespace: $NAMESPACE
  labels:
    app: $SERVICE_NAME
    service-type: nginx
    role: $ROLE
spec:
  replicas: 1
  selector:
    matchLabels:
      app: $SERVICE_NAME
      role: $ROLE
  template:
    metadata:
      labels:
        app: $SERVICE_NAME
        service-type: nginx
        role: $ROLE
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
        env:
        - name: SERVICE_NAME
          value: "$SERVICE_NAME"
        - name: ROLE
          value: "$ROLE"
        volumeMounts:
        - name: nginx-config
          mountPath: /usr/share/nginx/html
      volumes:
      - name: nginx-config
        emptyDir: {}
---
apiVersion: v1
kind: Service
metadata:
  name: $SERVICE_NAME-svc
  namespace: $NAMESPACE
  labels:
    app: $SERVICE_NAME
    service-type: nginx-service
    role: $ROLE
spec:
  selector:
    app: $SERVICE_NAME
    role: $ROLE
  ports:
  - port: 80
    targetPort: 80
    nodePort: $NODE_PORT
  type: NodePort
EOF
    
    echo "Развернут $SERVICE_NAME (роль: $ROLE) с NodePort $NODE_PORT"
done

echo "Все 4 сервиса успешно развернуты в namespace $NAMESPACE!"