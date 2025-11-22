---
title: "[k8s] 쿠버네티스를 공부해보자"
description: 컨테이너와 쿠버네티스의 개념을 작성한 글입니다.
author: melonhong
date: '2025-11-22 23:43:37 +0900'
categories:
- rooton
tags: []
---
## 개요

서비스 개발이 마무리됨에 따라, **MSA(Microservices Architecture)** 로 구성된 각 서비스들을 효과적으로 관리하고 컨트롤하기 위해 **Kubernetes (줄여서 k8s)** 를 사용하게 되었습니다. k8s를 이해하기 위해 먼저 **컨테이너** 개념을 살펴봅니다.

---

## 컨테이너와 가상 머신(VM)

### 가상 머신 (Virtual Machine, VM)

서비스를 자신의 컴퓨터(호스트 OS)가 아닌, 그 위에 또 다른 컴퓨터(게스트 OS)를 올려 실행시키는 방식입니다. 호스트 OS와 게스트 OS 사이에는 **하이퍼바이저**가 있어 자원을 분리하고 관리합니다.

* **호스트 OS (Host OS):** 자신의 컴퓨터 운영체제.
* **게스트 OS (Guest OS):** VM 내의 운영체제.

**단점:** VM은 게스트 OS 전체를 포함하므로 **무겁습니다**.

### 컨테이너 (Container)

VM의 단점을 해결하기 위해 등장했으며, **가벼운 격리 환경**을 제공합니다. 

* **VM:** 호스트 OS, 하이퍼바이저, 게스트 OS, 바이너리/라이브러리, 앱을 모두 포함.
* **컨테이너:** 호스트 OS 커널을 공유하고 그 위에 바이너리/라이브러리, 앱만 포함하여 훨씬 가볍습니다.

컨테이너를 만들려면 **이미지**가 필요합니다. 기업이나 프레임워크가 제공하는 기본 이미지(예: Ubuntu, Node.js) 위에 개발자가 만든 애플리케이션을 올려 빌드하고, 이 이미지를 컨테이너로 실행시키면 서비스가 **도커(Docker)** 상에서 돌아갑니다.

이미지 빌드 시 **Dockerfile**을 사용하여 복사할 파일, 실행 명령어 등을 사전에 정의합니다.

![VM and Container](https://img1.daumcdn.net/thumb/R1280x0/?scode=mtistory2&fname=https%3A%2F%2Fblog.kakaocdn.net%2Fdna%2FnRs2Y%2FdJMcah3LMdd%2FAAAAAAAAAAAAAAAAAAAAAECuNYxH6PpQu9JYw6M-aXuceF7BnembzhlDg9PKI2nQ%2Fimg.jpg%3Fcredential%3DyqXZFxpELC7KVnFOS48ylbz2pIh7yKj8%26expires%3D1764514799%26allow_ip%3D%26allow_referer%3D%26signature%3Dx3Q8Q%252FuegJLOGNaHfcPAQTnk15Y%253D)_가상머신과 컨테이너 비교_


## 쿠버네티스 (Kubernetes)

컨테이너를 실행시키고 이미지를 빌드하는 것이 **도커의 역할**이라면, **쿠버네티스**는 수많은 컨테이너들을 관리하는 시스템입니다. 마치 지휘자처럼 오케스트라를 지휘하기 때문에 **컨테이너 오케스트레이션(Container Orchestration)**이라고 불립니다.

쿠버네티스는 기본적으로 **파드(Pod)** 단위로 관리하며, 파드 안에는 한 개 이상의 컨테이너가 들어갑니다 (일반적으로 하나).

k8s에는 이 파드들을 관리하기 위한 여러 **오브젝트(Objects)**가 존재하며, 그중 **컨트롤러**와 **서비스**를 간략하게 살펴봅니다.

### 1. 컨트롤러 (Controller)

* **역할:** 쿠버네티스 리소스의 **'원하는 상태'**를 **'실제 상태'**와 맞추는 관리자 역할을 합니다. Pod 개수, 순서, 스케줄 등 **상태 유지 자동화**를 담당합니다.

| 종류 | 역할 |
| :--- | :--- |
| **Deployment** | Pod 개수 유지 + **롤링 업데이트/롤백** 관리 |
| **ReplicaSet** | Pod 개수를 **정확히 유지** |
| **StatefulSet** | **순서, 고정 이름, 스토리지**가 필요한 경우 Pod 관리 |
| **DaemonSet** | **모든 노드**에 하나씩 Pod를 배치 |
| **Job** | **한 번 실행하고 끝나는** 작업 관리 |
| **CronJob** | **정해진 주기**에 `Job`을 자동 실행 |

### 2. 서비스 (Service)

* **역할:** Pod에 **안정적인 네트워크 접근 경로(IP/포트)**를 제공하여, Pod가 죽거나 변경되어도 클라이언트에게 **일관된 연결**을 보장합니다.

| 종류 | 역할 |
| :--- | :--- |
| **ClusterIP** | **클러스터 내부**에서만 접근 가능함 (기본) |
| **NodePort** | **노드 포트를 열어서** 외부 접근 가능함 |
| **LoadBalancer** | 클라우드 **로드밸런서**를 생성해 외부 노출함 |
| **Headless Service** | 로드밸런싱 없이 **각 Pod의 IP를 직접 반환**함 |
| **ExternalName** | 서비스 이름을 **외부 DNS로 매핑**함 |

이러한 오브젝트들은 명령어로 생성할 수도 있지만, 보통은 **YAML 파일**로 정의한 후 `kubectl apply` 명령어를 사용하는 것이 일반적입니다.

이 외에도 시크릿(Secret), 네임스페이스(Namespace), 컨피그맵(ConfigMap), 볼륨(Volume), 인그레스(Ingress) 등 수많은 오브젝트들이 존재합니다.


## 참조

### 쿠버네티스 (Kubernetes)
* **Kubernetes 공식 문서:** [https://kubernetes.io/ko/docs/home/](https://kubernetes.io/ko/docs/home/)
* **Kubectl 치트 시트:** [https://kubernetes.io/ko/docs/reference/kubectl/cheatsheet/](https://kubernetes.io/ko/docs/reference/kubectl/cheatsheet/)

### 컨테이너 및 도커 (Container & Docker)
* **Docker 공식 문서:** [https://docs.docker.com/](https://docs.docker.com/)


## 원글
[[k8s] 쿠버네티스를 공부해보자](https://readinging.tistory.com/15)