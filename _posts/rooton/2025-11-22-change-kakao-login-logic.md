---
title: "[카카오 로그인] 로직 변경"
description: 카카오 로그인 구현 방법이 조금 달라졌습니다.
author: melonhong
date: '2025-11-22 23:25:00 +0900'
categories:
- rooton
tags: []
---

## 개요

원래는 카카오 API의 리다이렉트 URI를 **백엔드**로 설정하여 인가 코드도 백엔드에서 받고 클라이언트를 프론트엔드로 리다이렉션 시킬 예정이었습니다.

하지만 이 방식으로는 토큰을 HTTP **바디(body)로 주지 못한다**는 점을 확인하고, 결국 일반적인 RESTful 서버 방식에 더 적합하다고 판단되는 방식으로 로직을 변경했습니다.


## 자세한 과정

원래는 백엔드에서 인가 코드를 받아 토큰 발급 및 리다이렉션을 모두 처리할 계획이었으나, 프론트엔드에서 API 요청을 백엔드로 보내는 방식이 **RESTful한 서버 방식에 더 적합**하다고 판단하여 로직을 아래 그림과 같이 변경했습니다.

**변경 후 로직 (일반적인 소셜 로그인 방식):**

1.  **카카오 인증:** 클라이언트가 카카오 서버에서 인증을 받고 **인가 코드**를 받습니다.
2.  **리다이렉션:** 카카오 서버가 프론트엔드의 특정 리다이렉션 페이지(예: `/oauth/redirect`)로 인가 코드를 전달합니다.
3.  **클라이언트 POST 요청:** 프론트엔드가 이 인가 코드를 가지고 **백엔드 API**로 POST 요청을 보냅니다.
4.  **백엔드 토큰 처리:** 백엔드는 인가 코드를 사용해 카카오로부터 \*\*액세스 토큰(AT)\*\*을 받고, 자체적인 JWT를 생성합니다.
5.  **응답:** 백엔드는 응답 헤더의 **쿠키**로 \*\*리프레시 토큰(RT)\*\*을, 응답 바디의 **JSON**으로 \*\*액세스 토큰(AT)\*\*을 클라이언트에 전달합니다.


## 프론트엔드가 해야할 일

프론트엔드(SPA)가 변경된 로직을 위해 수행해야 할 주요 작업은 다음과 같습니다.

1.  **리다이렉트 페이지에서 인가 코드 받기**
    `/oauth/redirect`와 같은 페이지를 만들고 카카오 API로부터 URL 파라미터로 전송된 **인가 코드**를 받습니다.

    ```javascript
    const urlParams = new URLSearchParams(window.location.search);
    const code = urlParams.get("code");
    ```

2.  **백엔드로 인가 코드와 함께 POST 요청 보내기**
    인가 코드를 포함하여 백엔드의 로그인 처리 API (예: `/api/auth/oauth`)로 POST 요청을 보냅니다.

    ```javascript
    // 예시 코드
    const res = await fetch(
                "http://localhost:8080/api/auth/login/kakao",
                {
                  method: "POST",
                  headers: { "Content-Type": "application/json" },
                  credentials: "include",
                  body: JSON.stringify({ provider: "kakao", accessToken: code }),
                }
              );
    ```

3.  **토큰 처리**

      * **Access Token (AT):** 백엔드로부터 **JSON 응답**으로 받아 이후 요청 시마다 `Authorization` 헤더에 포함시켜 보냅니다.
      * **Refresh Token (RT):** 백엔드로부터 **쿠키**로 받아 브라우저가 자동으로 저장 및 전송하므로 별도의 프론트엔드 작업은 필요 없습니다.


## 원글

[[카카오 로그인] 로직 변경](https://readinging.tistory.com/9)