---
title: "[게이트웨이] Spring Cloud Gateway로 게이트웨이 구현하기"
description: Spring Cloud Gateway를 사용하여 JWT 토큰을 검증하는 API 게이트웨이를 구현해봅시다.
author: melonhong
date: '2025-11-22 23:30:53 +0900'
categories:
- rooton
tags: []
---
## 개요

이 글은 

> Spring Cloud Gateway와 Spring Security에 대한 이론은 다음 글에서 다룰 예정입니다.

-----

## 프로젝트 초기 설정

### Spring Initializr

[https://start.spring.io/](https://start.spring.io/)에서 다음 의존성을 추가하여 프로젝트를 생성합니다.

  * **Gateway**
  * **Spring Web**
  * **Spring Security**

### JJWT 의존성 추가

JWT 해석을 위해 `gradle` 파일에 JJWT 관련 패키지를 추가합니다.

```groovy
// JJWT
implementation 'io.jsonwebtoken:jjwt-api:0.11.5'
runtimeOnly 'io.jsonwebtoken:jjwt-impl:0.11.5'
runtimeOnly 'io.jsonwebtoken:jjwt-jackson:0.11.5'
```

-----

## JWT 유틸리티 (JwtUtil)

JWT 토큰을 검증하는 메서드를 가진 클래스입니다. 게이트웨이의 주 역할이 토큰 검증이므로 `validateToken()` 메서드를 중점적으로 사용합니다.

```java
@Component
public class JwtUtil {
    public boolean validateToken(String token) {
        try {
            Jwts.parserBuilder()
                    .setSigningKey(secretKey.getBytes(StandardCharsets.UTF_8))
                    .build()
                    .parseClaimsJws(token);
            return true;
        } catch (JwtException | IllegalArgumentException e) {
            return false;
        }
    }
}
```

-----

## JWT 인증 필터 (JwtAuthenticationFilter)

실제 JWT를 검증하는 필터이며, Spring Security에 적용할 **GlobalFilter**입니다. 클라이언트 요청이 왔을 때, **로그인 경로가 아니라면** 헤더의 토큰을 검사합니다.

```java
@Component
public class JwtAuthenticationFilter implements GlobalFilter, Ordered {

    private final JwtUtil jwtUtil;
    // 예외할 경로 설정 (로그인 경로)
    private static final List<String> EXCLUDE_PATHS = List.of("/api/auth/login/kakao", "/oauth");
    // ... (생성자)

    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        ServerHttpRequest request = exchange.getRequest();
        String path = request.getPath().toString();

        // 1. 경로가 예외할 경로에 해당하면 패스 (인증 불필요)
        if (EXCLUDE_PATHS.stream().anyMatch(path::startsWith)) {
            return chain.filter(exchange);
        }

        String token = resolveToken(exchange);

        // 2. 토큰이 없거나 (401)
        if (token == null) {
            exchange.getResponse().setStatusCode(HttpStatus.UNAUTHORIZED);
            return exchange.getResponse().setComplete();
        }

        // 3. 토큰이 유효하지 않은 경우 (401)
        if (!jwtUtil.validateToken(token)) {
            exchange.getResponse().setStatusCode(HttpStatus.UNAUTHORIZED);
            return exchange.getResponse().setComplete();
        }

        // 4. 토큰이 유효한 경우 해당 도메인 서비스로 요청을 전달
        return chain.filter(exchange);
    }
    
    // ... (resolveToken, getOrder 메서드)
}
```

-----

## 보안 설정 (SecurityConfig)

위에서 만든 `JwtAuthenticationFilter`를 적용하고 CORS 설정을 추가합니다. \*\*`@EnableWebFluxSecurity`\*\*를 사용하여 Spring Cloud Gateway 환경에 맞는 설정을 구성합니다.

```java
@Configuration
@EnableWebFluxSecurity
public class SecurityConfig {

    @Bean
    public SecurityWebFilterChain securityWebFilterChain(ServerHttpSecurity http) {
        return http
                .csrf(ServerHttpSecurity.CsrfSpec::disable)
                .httpBasic(ServerHttpSecurity.HttpBasicSpec::disable)
                .formLogin(ServerHttpSecurity.FormLoginSpec::disable)
                
                // 401 에러 커스터마이징
                .exceptionHandling(spec ->
                        spec.authenticationEntryPoint((exchange, ex) -> {
                            exchange.getResponse().setStatusCode(HttpStatus.UNAUTHORIZED);
                            return exchange.getResponse().setComplete();
                        })
                )
                
                // CORS 허용 (프론트엔드 주소 설정)
                .cors(cors -> cors.configurationSource(request -> {
                    var corsConfig = new org.springframework.web.cors.CorsConfiguration();
                    corsConfig.setAllowedOrigins(List.of("http://localhost:3000"));
                    corsConfig.setAllowedMethods(List.of("GET","POST","PUT","DELETE","OPTIONS"));
                    corsConfig.setAllowedHeaders(List.of("*"));
                    corsConfig.setAllowCredentials(true);
                    return corsConfig;
                }))

                // 경로별 접근 제어 설정
                .authorizeExchange(exchange -> exchange
                        .pathMatchers("/api/auth/**","/oauth/**").permitAll() // public
                        .anyExchange().authenticated() // 나머지는 인증 필요
                )
                .build();
    }
    
    @Bean
    public JwtAuthenticationFilter jwtAuthenticationFilter(JwtUtil jwtUtil) {
        return new JwtAuthenticationFilter(jwtUtil);
    }
}
```

### ❗ 예외 경로를 Filter와 SecurityConfig에 모두 설정한 이유

  * **`JwtAuthenticationFilter`에서 설정:** 인증이 필요 없는 경로도 이 필터를 통과하도록 허용하지 않으면 401 에러가 발생합니다.
  * **`SecurityConfig`에서 설정:** 필터 체인에서 JWT 검증 필터가 실행되기 전에 Spring Security가 인증을 시도합니다. 특정 경로를 `permitAll()`로 허용하지 않으면 Spring Security가 요청을 막아 500 에러가 발생합니다.

### ❗ CORS 설정을 Gateway에만 둔 이유

게이트웨이가 백엔드에 요청을 프록시할 때, 백엔드도 CORS 헤더를 추가해서 응답하면 응답 헤더에 CORS 관련 헤더가 **중복되거나 충돌**할 수 있습니다. 따라서 **CORS 허용은 Gateway에만 두는 것**이 권장됩니다.

-----

## 테스트 결과

1.  **카카오 로그인으로 JWT 토큰 가져오기**
      * 카카오 로그인 요청을 통해 `accessToken`을 응답으로 받습니다.
2.  **API Tester로 게이트웨이에 올바른 JWT 토큰을 보내기**
      * `Authorization: Bearer [복사한 토큰]` 형식으로 헤더에 전송 시, 정상적으로 다음 서비스로 요청이 전달됩니다 (200 OK 등).
3.  **유효하지 않은 JWT 토큰을 보내기**
      * 토큰이 없거나 유효하지 않은 문자열(예: `foo`)을 `Authorization` 헤더에 넣으면 **401 Unauthorized** 에러가 반환됩니다.

-----

## 원글

[[게이트웨이] Spring Cloud Gateway로 게이트웨이 구현하기](https://readinging.tistory.com/11)