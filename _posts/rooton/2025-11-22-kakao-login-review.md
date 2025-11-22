---
title: "[카카오 로그인] 설계부터 구현까지의 회고록"
description: >- 
    이 글은 우리 서비스의 카카오 로그인 설계부터 구현까지 진행한 경험을 바탕으로 작성하는 보고서이자 회고록입니다.
author: melonhong
date: '2025-11-22 23:15:18 +0900'
categories: [rooton]
tags: []
---

## 설계

### 기존 코드 분석

설계를 하기 전, 어떤 코드가 있는지 먼저 분석할 필요가 있었습니다. 카카오 로그인과 관련 있는 코드만 설명합니다.

* **Client**
    * `KakaoFeignClient`: 카카오 API로 사용자 정보를 가져오게 하는 클라이언트
* **Service**
    * `KakaoAuthService`: 소셜 로그인을 위해 `KakaoFeignClient`를 사용하는 서비스
    * `AuthService`: 소셜 로그인과 다양한 메서드들이 있는 서비스
* **Controller**
    * `AuthController`: 계정 관련 엔드포인트를 다루는 컨트롤러

### 기존 설계 로직

대략 다음과 같은 로직으로 로그인을 했을 것으로 예상합니다.

> 카카오 인증 > 리다이렉션 페이지로 이동 > 인가 코드로 액세스 토큰 가져오기 > 로그인 페이지에서 액세스 토큰으로 카카오 로그인 > DB 처리를 하고 JWT를 생성해 프론트엔드로 이동

**문제 제기 및 결정:**
* 프론트엔드에 리다이렉션 페이지를 두면 인가 코드가 유출될 가능성과 로직이 복잡해지는 단점이 생김.
* **결정:** 리다이렉션 페이지를 백엔드에 두는 것으로 결정.
* 참고 블로그: [Redirect URI는 프론트엔드여야 할까? 백엔드여야 할까? (OAuth 2.0에 대해서 알아보기)](https://dogfood.tistory.com/entry/Redirect-URI%EB%8A%94-%ED%94%84%EB%A1%A0%ED%8A%B8%EC%97%94%EB%93%9C%EC%97%AC%EC%95%BC-%ED%95%A0%EA%B9%8C-%EB%B0%B1%EC%97%94%EB%93%9C%EC%97%AC%EC%95%BC-%ED%95%A0%EA%B9%8C-OAuth-20%EC%97%90-%EB%8C%80%ED%95%B4%EC%84%9C-%EC%95%8C%EC%95%84%EB%B3%B4%EA%B8%B0)

### 새로운 설계 로직

기존 로직에서 리다이렉션 페이지 > 로그인 페이지로 이동하는 과정에서 **쓸데없는 네트워크 요청** (오버헤드)이 발생할 수 있다는 문제 발견.

**새로운 설계:** 로그인 페이지가 하던 일(카카오 로그인)을 리다이렉션 페이지가 맡도록 변경.

> 카카오 인증 > 리다이렉션 페이지로 이동 > 인가 코드로 액세스 토큰 가져오기 > 액세스 토큰으로 카카오 로그인 > DB 처리를 하고 JWT를 생성해 프론트엔드로 이동


## 구현

구현과 관련된 상세 내용은 아래 벨로그에 정리되어 있습니다.

* [[카카오 로그인] KakaoAuthService와 OpenFeign](https://velog.io/@melonhong/%EC%B9%B4%EC%B9%B4%EC%98%A4-%EB%A1%9C%EA%B7%B8%EC%9D%B8-KakaoAuthService%EC%99%80-FeignClient)
* [[카카오 로그인] AuthService의 socialLogin 메서드](https://velog.io/@melonhong/%EC%B9%B4%EC%B9%B4%EC%98%A4-%EB%A1%9C%EA%B7%B8%EC%9D%B8-AuthService%EC%9D%98-socialLogin-%EB%A9%94%EC%84%9C%EB%93%9C)
* [[카카오 로그인] AuthController](https://velog.io/@melonhong/%EC%B9%B4%EC%B9%B4%EC%98%A4-%EB%A1%9C%EA%B7%B8%EC%9D%B8-AuthController)

깃허브 커밋 히스토리: [https://github.com/CloudNativeSC/auth/commits/feature/%233-kakao-login/](https://github.com/CloudNativeSC/auth/commits/feature/%233-kakao-login/)

---

## 마무리

프론트엔드로 JWT를 쿠키로 주는 일만 남았습니다. (이후 Task 관련 업무 예정)


**추가 참고 자료:**

* [Spring Boot OAuth2, JWT 적용해보리기](https://velog.io/@jkijki12/Spring-Boot-OAuth2-JWT-%EC%A0%81%EC%9A%A9%ED%95%B4%EB%B3%B4%EB%A6%AC%EA%B8%B0)


## 원글
[클라우드 네이티브](https://readinging.tistory.com/5)