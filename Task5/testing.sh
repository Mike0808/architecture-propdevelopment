#!/bin/bash

NAMESPACE="tenant-services-ns"

echo "=== Testing Network Policies ==="

# Test 1: front-end pod trying to reach back-end-api (should WORK)
echo "Test 1: front-end → back-end-api (should 403 error)"
kubectl run test-front-to-back-$RANDOM --rm -i -t --image=alpine --namespace=$NAMESPACE --labels="role=front-end" -- sh -c "apk add --no-cache curl && curl -m 5 http://back-end-api-app-svc:80" || echo "FAILED or BLOCKED"

# Test 2: front-end pod trying to reach back-end-api to wrong port(should FAIL)
echo "Test 2: front-end → back-end-api (should curle(28))"
kubectl run test-front-to-back-$RANDOM --rm -i -t --image=alpine --namespace=$NAMESPACE --labels="role=front-end" -- sh -c "apk add --no-cache curl && curl -m 5 http://back-end-api-app-svc:81" || echo "FAILED or BLOCKED"

# Test 3: back-end-api pod trying to reach front-end (should WORK)
echo -e "\nTest 3: back-end-api → front-end (should 403 error)"
kubectl run test-back-to-front-$RANDOM --rm -i -t --image=alpine --namespace=$NAMESPACE --labels="role=back-end-api" -- sh -c "apk add --no-cache curl && curl -m 5 http://front-end-app-svc:80" || echo "FAILED or BLOCKED"

# Test 4: back-end-api pod trying to reach front-end to wrong port (should FAIL)
echo -e "\nTest 4: back-end-api → front-end (should curle(28))"
kubectl run test-back-to-front-$RANDOM --rm -i -t --image=alpine --namespace=$NAMESPACE --labels="role=back-end-api" -- sh -c "apk add --no-cache curl && curl -m 5 http://front-end-app-svc:81" || echo "FAILED or BLOCKED"

# Test 5: front-end pod trying to reach admin-back-end-api (should FAIL)
echo -e "\nTest 5: front-end → admin-back-end-api (should curle(28))"
kubectl run test-front-to-admin-api-$RANDOM --rm -i -t --image=alpine --namespace=$NAMESPACE --labels="role=front-end" -- sh -c "apk add --no-cache curl && curl -m 5 http://admin-back-end-api-app-svc:80" || echo "EXPECTED: FAILED or BLOCKED"

# Test 6: admin-front-end pod trying to reach admin-back-end-api (should WORK)
echo -e "\nTest 6: admin-front-end → admin-back-end-api (should SUCCEED)"
kubectl run test-admin-front-to-admin-back-$RANDOM --rm -i -t --image=alpine --namespace=$NAMESPACE --labels="role=admin-front-end" -- sh -c "apk add --no-cache curl && curl -m 5 http://admin-back-end-api-app-svc:80" || echo "FAILED or BLOCKED"

# Test 7: Random pod trying to reach back-end-api (should FAIL)
echo -e "\nTest 7: random pod → back-end-api (should curle(28))"
kubectl run test-random-to-back-$RANDOM --rm -i -t --image=alpine --namespace=$NAMESPACE -- sh -c "apk add --no-cache curl && curl -m 5 http://back-end-api-app-svc:80" || echo "EXPECTED: FAILED or BLOCKED"

echo -e "\n=== Testing completed ==="