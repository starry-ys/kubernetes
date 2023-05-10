#!/usr/bin/env bash
#
# coding: utf-8
# author: liuchao


DEST_WORKER=$1

ssh-copy-id root@${DEST_WORKER}

WORKER_HOSTNAME=$(ssh root@${DEST_WORKER} "hostname")

echo "${DEST_WORKER}        ${WORKER_HOSTNAME}" >>/etc/hosts

LINE=$(awk '{ print $1 }' /etc/hosts | wc -l)
IPLINE=$(echo ${LINE}-4|bc)
IPLIST=$(awk '{ print $1 }' /etc/hosts | tail -${IPLINE})

for HOST in ${IPLIST};do scp /etc/hosts ${HOST}:/etc/hosts;done

scp /usr/local/bin/kube{let,-proxy} ${DEST_WORKER}:/usr/local/bin/

scp initialenv.sh ${DEST_WORKER}:/opt/initialenv.sh

ssh root@${DEST_WORKER} "bash /opt/initialenv.sh"

scp /usr/lib/systemd/system/kubelet.service ${DEST_WORKER}:/usr/lib/systemd/system/kubelet.service

scp /etc/systemd/system/kubelet.service.d/10-kubelet.conf ${DEST_WORKER}:/etc/systemd/system/kubelet.service.d/10-kubelet.conf

scp /etc/kubernetes/kubelet-conf.yml ${DEST_WORKER}:/etc/kubernetes/kubelet-conf.yml

for FILE in etcd-ca.pem etcd.pem etcd-key.pem;do scp /etc/etcd/ssl/${FILE} ${DEST_WORKER}:/etc/etcd/ssl;done

for FILE in pki/ca.pem pki/ca-key.pem pki/front-proxy-ca.pem bootstrap-kubelet.kubeconfig;do scp /etc/kubernetes/${FILE} ${DEST_WORKER}:/etc/kubernetes/${FILE};done

scp /usr/lib/systemd/system/kube-proxy.service ${DEST_WORKER}:/usr/lib/systemd/system/kube-proxy.service

scp /etc/kubernetes/kube-proxy.conf ${DEST_WORKER}:/etc/kubernetes/kube-proxy.conf

scp /etc/kubernetes/kube-proxy.kubeconfig ${DEST_WORKER}:/etc/kubernetes/kube-proxy.kubeconfig

ssh root@${DEST_WORKER} "systemctl daemon-reload"
ssh root@${DEST_WORKER} "systemctl enable --now kubelet kube-proxy"