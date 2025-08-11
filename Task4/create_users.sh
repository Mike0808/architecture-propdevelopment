#!/bin/bash

# --- Создание пользователя analyst-user ---

USER_NAME="analyst-user"
GROUP_NAME="cluster-viewers"

# 1. Создание приватного ключа для пользователя
openssl genrsa -out ${USER_NAME}.key 2048

# 2. Создание Certificate Signing Request (CSR)
# CN - имя пользователя, O - группа(ы)
openssl req -new -key ${USER_NAME}.key -out ${USER_NAME}.csr -subj "/CN=${USER_NAME}/O=${GROUP_NAME}"

# 3. Подпись CSR с помощью CA кластера (требуются ca.crt и ca.key)
# (Этот шаг обычно выполняется администратором кластера)
# Создаем временный конфиг для подписи CSR
cat <<EOF > csr_config.conf
[req]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn
req_extensions = v3_req

[dn]
CN=analyst-user

[v3_req]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = clientAuth
subjectAltName = @alt_names

[alt_names]
DNS.1 = example.com
DNS.2 = www.example.com
IP.1 = 127.0.0.1
IP.2 = ::1

EOF

# Переподписываем CSR с нужными параметрами
openssl x509 -req -in ${USER_NAME}.csr -CA ~/.minikube/ca.crt -CAkey ~/.minikube/ca.key -CAcreateserial -out ${USER_NAME}.crt -days 365 -sha256 -extfile csr_config.conf -extensions v3_req

echo "Созданы файлы для пользователя ${USER_NAME}: ${USER_NAME}.key, ${USER_NAME}.csr, ${USER_NAME}.crt"
echo "CSR должен быть подписан администратором кластера. Пример команды выше (требуются ca.crt и ca.key)."

# --- Создание пользователя dev-user ---

USER_NAME_DEV="dev-user"
GROUP_NAME_DEV="app-developers"

# 1. Создание приватного ключа для пользователя
openssl genrsa -out ${USER_NAME_DEV}.key 2048

# 2. Создание Certificate Signing Request (CSR)
openssl req -new -key ${USER_NAME_DEV}.key -out ${USER_NAME_DEV}.csr -subj "/CN=${USER_NAME_DEV}/O=${GROUP_NAME_DEV}"

# 3. Подпись CSR (аналогично)
openssl x509 -req -in ${USER_NAME_DEV}.csr -CA ~/.minikube/ca.crt -CAkey ~/.minikube/ca.key -CAcreateserial -out ${USER_NAME_DEV}.crt -days 365 -sha256 -extfile csr_config.conf -extensions v3_req

echo "Созданы файлы для пользователя ${USER_NAME_DEV}: ${USER_NAME_DEV}.key, ${USER_NAME_DEV}.csr"
echo "CSR должен быть подписан администратором кластера."

# --- Создание пользователя user-operator ---

USER_NAME_OPER="user-operator"
GROUP_NAME_OPER="cluster-operators"

# 1. Создание приватного ключа для пользователя
openssl genrsa -out ${USER_NAME_OPER}.key 2048

# 2. Создание Certificate Signing Request (CSR)
openssl req -new -key ${USER_NAME_OPER}.key -out ${USER_NAME_OPER}.csr -subj "/CN=${USER_NAME_DEV}/O=${GROUP_NAME_OPER}"

# 3. Подпись CSR (аналогично)
openssl x509 -req -in ${USER_NAME_OPER}.csr -CA ~/.minikube/ca.crt -CAkey ~/.minikube/ca.key -CAcreateserial -out ${USER_NAME_OPER}.crt -days 365 -sha256 -extfile csr_config.conf -extensions v3_req

echo "Созданы файлы для пользователя ${USER_NAME_OPER}: ${USER_NAME_OPER}.key, ${USER_NAME_OPER}.csr"
echo "CSR должен быть подписан администратором кластера."
