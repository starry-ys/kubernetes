#!/usr/bin/env bash
#
# author: liuchao
# email: mirs_chao@163.com


cfssl gencert -initca etcd-ca-csr.json | cfssljson -bare /etc/etcd/ssl/etcd-ca

cfssl gencert \
  -ca=/etc/etcd/ssl/etcd-ca.pem \
  -ca-key=/etc/etcd/ssl/etcd-ca-key.pem \
  -config=ca-config.json \
  -hostname=127.0.0.1,${M1HOSTNAME},${M2HOSTNAME},${M3HOSTNAME},${LOADBALANCER},${MASTER1},${MASTER2},${MASTER3} \
  -profile=kubernetes \
  etcd-csr.json | cfssljson -bare /etc/etcd/ssl/etcd

#>>> 创建k8s证书目录
mkdir -p /etc/kubernetes/pki/etcd/

#>>> 生成k8s通用ca证书
cfssl gencert -initca ca-csr.json | cfssljson -bare /etc/kubernetes/pki/ca
cfssl gencert \
  -ca=/etc/kubernetes/pki/ca.pem \
  -ca-key=/etc/kubernetes/pki/ca-key.pem \
  -config=ca-config.json \
  -hostname=10.96.0.1,127.0.0.1,kubernetes,kubernetes.detault,kubernetes.default.svc,kubernetes.default.svc.cluster,kubernetes.default.svc.cluster.local,${LOADBALANCER},${MASTER1},${MASTER2},${MASTER3} \
  -profile=kubernetes \
  apiserver-csr.json | cfssljson -bare /etc/kubernetes/pki/apiserver

cfssl gencert -initca front-proxy-ca-csr.json | cfssljson -bare /etc/kubernetes/pki/front-proxy-ca

cfssl gencert \
  -ca=/etc/kubernetes/pki/front-proxy-ca.pem \
  -ca-key=/etc/kubernetes/pki/front-proxy-ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  front-proxy-client-csr.json | cfssljson -bare /etc/kubernetes/pki/front-proxy-client

#>>> controller-manager
cfssl gencert \
  -ca=/etc/kubernetes/pki/ca.pem \
  -ca-key=/etc/kubernetes/pki/ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  manager-csr.json | cfssljson -bare /etc/kubernetes/pki/controller-manager

kubectl config set-cluster kubernetes \
  --certificate-authority=/etc/kubernetes/pki/ca.pem \
  --embed-certs=true \
  --server=https://${LOADBALANCER}:8443 \
  --kubeconfig=/etc/kubernetes/controller-manager.kubeconfig

kubectl config set-credentials system:kube-controller-manager \
  --client-certificate=/etc/kubernetes/pki/controller-manager.pem \
  --client-key=/etc/kubernetes/pki/controller-manager-key.pem \
  --embed-certs=true \
  --kubeconfig=/etc/kubernetes/controller-manager.kubeconfig

kubectl config set-context system:kube-controller-manager@kubernetes \
  --cluster=kubernetes \
  --user=system:kube-controller-manager \
  --kubeconfig=/etc/kubernetes/controller-manager.kubeconfig

kubectl config use-context system:kube-controller-manager@kubernetes \
  --kubeconfig=/etc/kubernetes/controller-manager.kubeconfig

#>>> scheduler
cfssl gencert \
  -ca=/etc/kubernetes/pki/ca.pem \
  -ca-key=/etc/kubernetes/pki/ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  scheduler-csr.json | cfssljson -bare /etc/kubernetes/pki/scheduler

kubectl config set-cluster kubernetes \
  --certificate-authority=/etc/kubernetes/pki/ca.pem \
  --embed-certs=true \
  --server=https://${LOADBALANCER}:8443 \
  --kubeconfig=/etc/kubernetes/scheduler.kubeconfig

kubectl config set-credentials system:kube-scheduler \
  --client-certificate=/etc/kubernetes/pki/scheduler.pem \
  --client-key=/etc/kubernetes/pki/scheduler-key.pem \
  --embed-certs=true \
  --kubeconfig=/etc/kubernetes/scheduler.kubeconfig

kubectl config set-context system:kube-scheduler@kubernetes \
  --cluster=kubernetes \
  --user=system:kube-scheduler \
  --kubeconfig=/etc/kubernetes/scheduler.kubeconfig

kubectl config use-context system:kube-scheduler@kubernetes \
  --kubeconfig=/etc/kubernetes/scheduler.kubeconfig

#>>> admin
cfssl gencert \
  -ca=/etc/kubernetes/pki/ca.pem \
  -ca-key=/etc/kubernetes/pki/ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  admin-csr.json | cfssljson -bare /etc/kubernetes/pki/admin

kubectl config set-cluster kubernetes \
  --certificate-authority=/etc/kubernetes/pki/ca.pem \
  --embed-certs=true \
  --server=https://${LOADBALANCER}:8443 \
  --kubeconfig=/etc/kubernetes/admin.kubeconfig

kubectl config set-credentials kubernetes-admin \
  --client-certificate=/etc/kubernetes/pki/admin.pem \
  --client-key=/etc/kubernetes/pki/admin-key.pem \
  --embed-certs=true \
  --kubeconfig=/etc/kubernetes/admin.kubeconfig

kubectl config set-context kubernetes-admin@kubernetes \
  --cluster=kubernetes \
  --user=kubernetes-admin \
  --kubeconfig=/etc/kubernetes/admin.kubeconfig

kubectl config use-context kubernetes-admin@kubernetes \
  --kubeconfig=/etc/kubernetes/admin.kubeconfig

#>>> serviceaccount
openssl genrsa -out /etc/kubernetes/pki/sa.key 2048
openssl rsa -in /etc/kubernetes/pki/sa.key -pubout -out /etc/kubernetes/pki/sa.pub
