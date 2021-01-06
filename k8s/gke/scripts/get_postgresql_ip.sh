PRIVATE_IP=$(kubectl get sqlinstance kidsloop-postgresql-99994 -n config-connector -o jsonpath="{.status .privateIpAddress}")
echo $PRIVATE_IP