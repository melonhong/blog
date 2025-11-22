---
title: "[게이트웨이] Spring Security와 Spring Cloud Gateway 이론"
description: 스프링에서 자주 사용되는 두 패키지인 Spring Security와 Spring Cloud Gateway의 개념과 작동 원리를
  알아봅시다.
author: melonhong
date: '2025-11-22 23:32:55 +0900'
categories:
- rooton
tags: []
---
## Spring Security

**인증(Authentication), 인가(Authorization), 보안** 등을 제공하는 프레임워크입니다. \*\*Servlet 기반 (Spring MVC)\*\*과 **Reactive 기반 (Spring WebFlux)** 모두 사용 가능합니다.

### Filter의 기본 개념과 역할

**Filter**는 웹 애플리케이션에서 클라이언트의 **요청(Request)과 응답(Response)을 가로채는 역할**을 합니다.

클라이언트 요청이 오면 스프링 컨테이너가 **FilterChain**을 만드는데, 이 체인에는 여러 **Filter** 인스턴스와 최종 목적지인 **Servlet**이 포함됩니다. 필터는 한 방향으로만 순서대로 실행됩니다.

### FilterChainProxy

Spring Security가 제공하는 특수한 필터로, 다른 **SecurityFilterChain**에 요청을 위임하여 **어떤 보안 정책을 사용할지 결정**하는 역할을 합니다.

> **DelegatingFilterProxy:** Servlet 컨테이너가 스프링 Bean을 알지 못하므로, 스프링 Bean으로 선언된 `FilterChainProxy`와 Servlet 컨테이너를 연결해주는 역할을 합니다.

### SecurityFilterChain

`FilterChainProxy`가 요청을 위임하는 대상입니다. **하나의 보안 정책 집합**이며, 특정 요청 패턴에 대해 어떤 보안 필터들이 적용될지를 정의합니다. SecurityFilterChain 내에는 여러 **Security Filters**가 순서대로 배치됩니다.
**예시 코드의 필터:**

```java
// ...
            .csrf(Customizer.withDefaults())
            .httpBasic(Customizer.withDefaults())
            .formLogin(Customizer.withDefaults())
            .authorizeHttpRequests(authorize -> authorize
                .anyRequest().authenticated()
            );
// ...
```

| Filter | Added by |
| :--- | :--- |
| `CsrfFilter` | `HttpSecurity#csrf` |
| `BasicAuthenticationFilter` | `HttpSecurity#httpBasic` |
| `UsernamePasswordAuthenticationFilter` | `HttpSecurity#formLogin` |
| `AuthorizationFilter` | `HttpSecurity#authorizeHttpRequests` |

### ExceptionTranslationFilter

어떤 필터가 \*\*인증 실패(`AuthenticationException`)\*\*나 **접근 거부(`AccessDeniedException`)** 예외를 던진 경우, 이 필터가 해당 예외들을 가로채어 적절한 예외 처리(응답 반환 또는 인증 흐름 시작)를 수행합니다.

### 요청 저장 & 재요청 처리

클라이언트가 보호된 리소스에 접근하려다 인증에 실패했을 때, Spring Security는 그 요청 정보를 **RequestCache**에 저장해 둡니다. 인증 성공 시 저장해 둔 요청으로 자동으로 리다이렉트되도록 처리합니다.

-----

## Spring Cloud Gateway

Spring에서 제공하는 게이트웨이 서비스입니다. Servlet 기반이 아닌 **Reactive 기반**, 즉 **Netty**를 사용하는 **비동기(Non-blocking) 처리**를 합니다.

### Spring MVC vs Spring WebFlux (Reactive Stack) 비교

| 항목 | Spring MVC (Servlet 기반) | Spring WebFlux (Reactive 기반) |
| :--- | :--- | :--- |
| **동작 방식** | **Blocking I/O** (요청당 스레드 1개) | **Non-blocking I/O** (Event-driven) |
| **처리 모델** | 스레드가 입출력 시 대기 | 입출력 중에도 다른 요청 처리 가능 |
| **내부 엔진** | Tomcat, Jetty 등 (Servlet Container) | **Netty**, Undertow (Reactive Server) |
| **리턴 타입** | String, `ResponseEntity` 등 | **`Mono<T>`, `Flux<T>`** (Reactive Stream) |

### 작동 원리

1.  클라이언트 요청이 Spring Cloud Gateway에 들어옵니다.
2.  **Gateway Handler Mapping**에서 요청이 경로와 일치하는지 판단합니다.
3.  **Gateway Web Handler**로 요청이 전달됩니다.
4.  핸들러는 해당 요청에 맞는 **필터 체인**을 통해 요청을 실행합니다.

필터 체인은 **pre (사전) 로직**과 **post (사후) 로직**으로 구성됩니다.

  * **pre 필터:** 요청이 Gateway에 들어왔을 때 실행 (헤더 검사, 인증 토큰 체크, 요청 로그 기록).
  * **post 필터:** 요청이 라우팅되어 downstream 서버에서 **응답이 돌아왔을 때** 실행 (응답 로그 기록, 응답 데이터 수정, 에러 처리).

### GlobalFilter

**모든 경로에 조건부로 적용**되는 특수 필터 인터페이스입니다. 어떤 경로로 요청이 오든 이 필터의 전/후 과정을 거칩니다.

Gateway의 필터 레벨:

  * **GlobalFilter:** 전체 요청에 적용.
  * **GatewayFilter:** 특정 라우트에만 적용.

**주요 GlobalFilter 종류:**

| 필터 | 역할 |
| :--- | :--- |
| **Netty Routing Filter** | 요청을 실제로 downstream 서비스로 라우팅하는 필터 (실제 호출). |
| **Netty Write Response Filter** | 응답이 돌아올 때, 클라이언트로 응답을 쓰는 필터 (응답 직후 후처리). |
| **RouteToRequestUrl Filter** | 라우트에 정의한 URL대로 요청의 URL을 수정하여 반영. |

-----

## 원글

[[게이트웨이] Spring Security와 Spring Cloud Gateway 이론](https://readinging.tistory.com/12)