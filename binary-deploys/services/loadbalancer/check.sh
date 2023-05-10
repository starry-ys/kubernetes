#!/usr/bin/env bash

err=0
check_code=$(pgrep haproxy)
if [[ $check_code == "" ]];then
	err=$(expr $err + 1)
fi

if [[ $err != "0" ]];then
	/usr/bin/systemctl stop keepalived
	exit 1
else
  exit 0
fi