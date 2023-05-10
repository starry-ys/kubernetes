# coding: utf-8
# @author: liuchao
# @email: mirs_chao@163.com
# @github: https://github.com/mirschao
# @usage: check kubernetes error.


from kubernetes import client, config


config.load_kube_config()
clientV1 = client.CoreV1Api()

def check_namespaces():
    namespaces = []
    results = clientV1.list_namespace()
    for rets in results.items:
        if rets not in ('default', 'kube-system', 'kube-node-lease', 'kube-public'):
            namespaces.append(rets.metadata.name)
    return namespaces

def check_pending():
    for ns in check_namespaces():
        results = clientV1.list_namespaced_pod(namespace=ns)
        for rets in results.items:
            if rets.status.phase != "Running":
                print(ns, rets.metadata.name, rets.status.phase)
