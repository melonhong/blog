---
title: "[카카오 로그인] 쿠키 ResponseEntity vs ApiResponse"
description: Spring Boot로 OAuth 로그인을 구현할 때, JWT를 SPA 프론트엔드로 안전하게 전달하려면 `ResponseEntity`와
  `ApiResponse` 중 어떤 방식을 쓰는 것이 좋을지 비교합니다.
author: melonhong
date: '2025-11-22 23:21:03 +0900'
categories:
- rooton
tags: []
---
## ApiResponse

`ApiResponse`는 REST API 응답을 표준화하기 위해 만든 커스텀 래퍼 클래스입니다. (스프링 부트 기본 프로젝트 코드)

```java
@Getter
@AllArgsConstructor
@JsonPropertyOrder({"isSuccess", "code", "message", "result"})
public class ApiResponse<T> {
    private final Boolean isSuccess;
    private final String code;
    private final String message;
    @JsonInclude(JsonInclude.Include.NON_NULL)
    private T result;

    public static <T> ApiResponse<T> onSuccess(T result){
        return new ApiResponse<>(true, "200", "OK", result);
    }
}
```

### 장점

  * JSON 구조가 항상 동일 (`isSuccess`, `code`, `message`, `result`)
  * 에러 메시지, 코드 표준화 가능
  * 프론트에서 응답 처리 일관성 확보

### 단점

  * HTTP 상태 코드 3xx, 302 리다이렉트 처리 어려움
  * 쿠키, 인증 헤더 등 `ResponseEntity` 기능 활용 불가

## ApiResponse로 구현한 코드

```java
@GetMapping("/oauth")
    public ApiResponse<SocialLoginResponse> kakaoCallback(
        @RequestParam String code,
        HttpServletResponse response) throws Exception {

        // ... (인가 코드 확인, 액세스 토큰 요청, 카카오 로그인 처리)

        // 4. 쿠키 생성 (HttpServletResponse 사용)
        Cookie cookie = new Cookie("access_token", loginResponse.getAccessToken());
        cookie.setHttpOnly(true);   // JS 접근 차단
        cookie.setSecure(false);    // 로컬(http) 개발 시 false, 배포(https) 시 true
        cookie.setPath("/");
        cookie.setMaxAge(60 * 60);  // 1시간
        response.addCookie(cookie);

        // 5. 프론트엔드 페이지로 리다이렉트 (HttpServletResponse 사용)
        response.sendRedirect("http://localhost:3000/");

        // 6. JWT 포함 응답
        return ApiResponse.onSuccess(loginResponse);
    }
```

| 클래스 | 설명 |
|---|---|
| `Cookie` | HTTP 응답에 심을 쿠키를 생성하는 표준 서블릿 API |
| `HttpServletResponse` | 서버 응답을 직접 제어 (쿠키 추가, 리다이렉트, 헤더 설정 등) |
| `ApiResponse` | API 응답 구조 통일을 위한 JSON DTO |

-----

## ResponseEntity

`ResponseEntity`는 HTTP 상태 코드, 헤더, 쿠키, 리다이렉트를 직접 제어할 수 있는 스프링 클래스입니다.

```java
return ResponseEntity.status(HttpStatus.FOUND)
        .location(URI.create("http://localhost:3000"))
        .build();
```

### 장점

  * 쿠키(`SET_COOKIE`), 헤더, 상태 코드, 리다이렉트 처리 가능
  * SPA + OAuth + JWT 인증 패턴과 잘 맞음
  * 테스트 작성이 쉽고 Security 필터와 통합 용이

### 단점

  * JSON 응답 구조 통일 필요 시 별도 구현 필요
  * 단순 REST API에서는 약간 장황할 수 있음

## ResponseEntity로 구현한 코드

```java
@GetMapping("/oauth")
public ResponseEntity<?> kakaoCallback(@RequestParam String code) throws Exception {

    // ... (인가 코드 확인, 액세스 토큰 요청, 카카오 로그인 처리)

    // 4. 쿠키 생성 (HttpOnly, Secure, SameSite 설정 용이)
    ResponseCookie cookie = ResponseCookie.from("access_token", loginResponse.getAccessToken())
            .httpOnly(true)
            .secure(false)
            .path("/")
            .maxAge(60 * 60)
            .sameSite("Lax")
            .build();

    // 5. HTTP 헤더 설정: 쿠키 + 리다이렉트
    HttpHeaders headers = new HttpHeaders();
    headers.add(HttpHeaders.SET_COOKIE, cookie.toString());
    headers.add(HttpHeaders.LOCATION, "http://localhost:3000/"); // 프론트 주소

    // 6. 302 Redirect 응답 반환
    return ResponseEntity.status(HttpStatus.FOUND)
            .headers(headers)
            .build();
}
```

| 클래스 | 설명 |
|---|---|
| `ResponseEntity` | HTTP 응답 상태, 헤더, 바디를 한번에 구성할 수 있는 스프링 클래스 |
| `ResponseCookie` | HttpOnly, Secure, SameSite 등 쿠키 속성을 쉽게 설정할 수 있는 스프링 클래스 |

-----

## OAuth 로그인 + JWT 쿠키 패턴 비교

| 항목 | ApiResponse | ResponseEntity |
|---|---|---|
| JSON 구조 | 표준화 가능 | 별도 구현 필요 |
| 리다이렉트(302) | 어렵다 | 바로 가능 |
| 쿠키 설정 | 서블릿 API(`HttpServletResponse`) 필요 | 바로 가능 (`ResponseCookie`) |
| SPA 인증 패턴 적합성 | 낮음 | 높음 |
| 실무 사용 예시 | 순수 REST API | OAuth, JWT, 리다이렉트 |

-----

## 결론

카카오 로그인을 완료하고 JWT를 프론트엔드에 줄 때, 백엔드에서 쿠키와 함께 리다이렉션 시키는 것이므로 `ApiResponse`보단 **`ResponseEntity`가 더 적절합니다.**

  * **순수 API 응답**: `ApiResponse` (사용자 정보 조회, 게시글 목록 API 등)
  * **OAuth 로그인 + JWT 전달 + SPA 리다이렉트**: `ResponseEntity` (쿠키, HTTP 상태 코드, 리다이렉트를 한 번에 처리 가능)

-----

## 원글

[[카카오 로그인] 쿠키 ResponseEntity vs ApiResponse](https://readinging.tistory.com/7)
