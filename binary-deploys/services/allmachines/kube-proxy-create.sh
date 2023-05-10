#!/usr/bin/env bash
#
# author: liuchao
# email: mirs_chao@163.com


kubectl -n kube-system create serviceaccount kube-proxy
kubectl create clusterrolebinding system:kube-proxy \
  --clusterrole system:node-proxier \
  --serviceaccount kube-system:kube-proxy

SECRET=$(kubectl -n kube-system get sa/kube-proxy --output=jsonpath='{.secrets[0].name}')
JWT_TOKEN=$(kubectl -n kube-system get secret/$SECRET --output=jsonpath='{.data.token}' | base64 -d)

kubectl config set-cluster kubernetes \
  --certificate-authority=/etc/kubernetes/pki/ca.pem \
  --embed-certs=true \
  --server=https://LOADBALANCER:8443 \
  --kubeconfig=/etc/kubernetes/kube-proxy.kubeconfig

kubectl config set-credentials kubernetes \
  --token=${JWT_TOKEN} \
  --kubeconfig=/etc/kubernetes/kube-proxy.kubeconfig

kubectl config set-context kubernetes \
  --cluster=kubernetes \
  --user=kubernetes \
  --kubeconfig=/etc/kubernetes/kube-proxy.kubeconfig

kubectl config use-context kubernetes \
  --kubeconfig=/etc/kubernetes/kube-proxy.kubeconfig