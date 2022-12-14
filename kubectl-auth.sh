#!/bin/sh

# Configure kubectl to use service account secret
# https://www.ibm.com/docs/en/cloud-paks/cp-management/2.0.0?topic=kubectl-using-service-account-tokens-connect-api-server

kubectl config set-cluster cfc --server=https://kubernetes.default --certificate-authority=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
kubectl config set-context cfc --cluster=cfc
kubectl config set-credentials user --token=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
kubectl config set-context cfc --user=user
kubectl config use-context cfc