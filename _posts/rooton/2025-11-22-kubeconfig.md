---
title: "[k8s] kubeconfig 기본 설정"
description: kubeconfig를 환경변수로 등록하는 법
author: melonhong
date: '2025-11-22 23:39:45 +0900'
categories:
- rooton
tags: []
---
## 개요

**`kubeconfig`** 파일을 사용하지 않으면 다음과 같은 오류가 발생합니다.

> `E1030 10:00:18.602092 432197 memcache.go:265] "Unhandled Error" err="couldn't get current server API group list: "`

**NKS 클러스터**를 사용하기 위해서는 `kubeconfig` 파일이 필요합니다. 이 글에서는 `kubeconfig` 파일을 **환경 변수로 등록**하는 과정을 설명합니다.

-----

## 1\. kubeconfig 파일 생성

NKS에서 받은 `kubeconfig` 파일을 생성하고 해당 파일의 **절대 경로**를 복사합니다.

-----

## 2\. 환경변수로 등록

재부팅 후에도 환경 변수가 유지될 수 있도록 **`.bashrc`** 파일에 다음 명령어를 등록해 줍니다.

```bash
echo 'export KUBECONFIG=' >> ~/.bashrc
source ~/.bashrc
```

이제부터는 자유롭게 **Kubernetes (k8s)** 명령어를 사용할 수 있습니다.

-----

## 원글

[[k8s] kubeconfig 기본 설정](https://readinging.tistory.com/14)