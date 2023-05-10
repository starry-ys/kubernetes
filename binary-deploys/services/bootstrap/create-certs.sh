#!/usr/bin/env bash
#
# author: liuchao
# email: mirs_chao@163.com


kubectl config set-cluster kubernetes \
  --certificate-authority=/etc/kubernetes/pki/ca.pem \
  --embed-certs=true \
  --server=https://LOADBALANCER:8443 \
  --kubeconfig=/etc/kubernetes/bootstrap-kubelet.kubeconfig

kubectl config set-credentials tls-bootstrap-token-user \
  --token=c8ad9c.2e4d610cf3e7426e \
  --kubeconfig=/etc/kubernetes/bootstrap-kubelet.kubeconfig

kubectl config set-context tls-bootstrap-token-user@kubernetes \
  --cluster=kubernetes \
  --user=tls-bootstrap-token-user \
  --kubeconfig=/etc/kubernetes/bootstrap-kubelet.kubeconfig

kubectl config use-context tls-bootstrap-token-user@kubernetes \
  --kubeconfig=/etc/kubernetes/bootstrap-kubelet.kubeconfig

mkdir -p /root/.kube
cp /etc/kubernetes/admin.kubeconfig /root/.kube/config
kubectl create -f bootstrap.yaml