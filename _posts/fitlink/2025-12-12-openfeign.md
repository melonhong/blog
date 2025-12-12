---
title: SpringBoot에서 OpenFeign 사용하기
description: 초기 설정과 구체적인 코드까지
author: melonhong
date: '2025-12-12 13:45:41 +0900'
categories:
- fitlink
tags: []
---
## 개요

국민체력 100 동영상 오픈 API를 사용하기 위해 RootOn에서 배웠던 OpenFeign을 또 적용하기로 했다.  

하지만 다 까먹어서 다시 정리하는 글을 작성하는 시간을 가졌다.


## OpenFeign이란?

Netflix에서 만든 **선언형 HTTP 호출 클라이언트**이다.  

REST API 호출을 인터페이스로 선언하면 구현체는 자동 생성된다.  

### 사용처
- 외부 API 호출
- MSA 통신

### 장점

OpenFeign을 사용하지 않고 외부 API를 호출하려면 다음과 같은 작업이 필요하다.

- URL 만들기
- Query param 조합
- 헤더 설정
- Object -> JSON 변환
- 응답 파싱
- 예외 처리  

```java
@RestController
@RequiredArgsConstructor
public class GithubController {

    private final RestTemplate restTemplate;

    @GetMapping("/github/{username}")
    public GitHubUser getGithubUser(@PathVariable String username) {

        // 1. URL 만들기
        String url = "https://api.github.com/users/" + username;

        // 2. 헤더 생성
        HttpHeaders headers = new HttpHeaders();
        headers.set("Accept", "application/json");

        // 3. 엔티티 wrapping
        HttpEntity<Void> entity = new HttpEntity<>(headers);

        // 4. HTTP 호출
        ResponseEntity<GitHubUser> response =
                restTemplate.exchange(
                    url,
                    HttpMethod.GET,
                    entity,
                    GitHubUser.class
                );

        // 5. 에러 체크
        if (!response.getStatusCode().is2xxSuccessful()) {
            throw new RuntimeException("API ERROR");
        }

        // 6. 바디 추출
        return response.getBody();
    }
}

```
따라서 위와 같이 코드가 매우 길어지는 단점이 있다.

하지만 OpenFeign은 위의 과정을 모두 자동화 해주고, 개발자는 인터페이스만 잘 작성하면 된다.

```java
// FeignClient Interface
@FeignClient(name = "githubClient", url = "https://api.github.com")
public interface GitHubClient {

    @GetMapping("/users/{username}")
    GitHubUser getUser(@PathVariable String username);
}

// Service
@Service
@RequiredArgsConstructor
public class GithubService {

    private final GitHubClient githubClient;

    public GitHubUser getGithubUser(String username) {
        return githubClient.getUser(username);
    }
}
```

RestTemplate의 코드와 비교했을 때 코드가 매우 간단하지 않은가? 이로써 유지보수도 간단해진다.


## 초기 설정

OpenFeign을 프로젝트에 적용하기 위해선 몇 가지 의존성과 코드를 추가해야 한다.

### 1. 의존성 추가

#### Maven
```xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-openfeign</artifactId>
</dependency>
```

#### Gradle
```
implementation 'org.springframework.cloud:spring-cloud-starter-openfeign'
```

`Spring Cloud`를 추가해줘야 한다. 프로젝트에 맞는 설정을 사용하면 된다.

### 2. 어노테이션 추가

`@EnableFeignClients` 어노테이션을 메인 애플리케이션 클래스 또는 설정 클래스에 추가해준다.

```java
@SpringBootApplication
@EnableFeignClients // 여기에 추가
public class FitlinkApplication {
    public static void main(String[] args) {
        SpringApplication.run(FitlinkApplication.class, args);
    }
}
```

### 3. FeignClient 인터페이스 작성

나는 국민체력 100 동영상 API를 사용해야 하므로, 다음과 같이 작성했다.  

참고로 `serviceKey`는 오픈 API 활용 신청 시 받을 수 있는 인증키이다.

```java
@FeignClient(
    name = "fitnessVideoClient",
    url = "https://api.kspo.or.kr",
)
public interface FitnessVideoFeignClient {

    @GetMapping("/video")
    FitnessVideoResponseDTO getVideo(@RequestParam("serviceKey") String serviceKey);
}
```

이후 API 맞는 DTO를 작성하고 서비스에서 사용하면 된다.


## 트러블 슈팅

### 문제

API 호출 시 다음과 같은 오류가 발생했다.

```
Could not extract response: no suitable HttpMessageConverter found
for response type [FitnessVideoResponseDTO]
and content type [text/json;charset=utf-8]
```

### 원인

API 응답이 `text/json`으로 반환하고 있었다(공공 API는 이렇게 주는 경우가 많다).  

하지만 Spring MVC/Jackson은 이 타입을 JSON으로 인정하지 않기에 `Jackson MessageConverter`가 동작하지 않았다.

### 해결

커스텀 `MessageConverter`를 등록했다.

```java
@Configuration
public class FeignConfig {

    @Bean
    public Decoder feignDecoder() {
        MappingJackson2HttpMessageConverter converter =
                new MappingJackson2HttpMessageConverter();

        converter.setSupportedMediaTypes(List.of(
                MediaType.APPLICATION_JSON,
                new MediaType("text", "json"),
                MediaType.TEXT_PLAIN
        ));

        HttpMessageConverters converters =
                new HttpMessageConverters(converter);

        return new SpringDecoder(() -> converters);
    }
}
```

<br/>

이후 클라이언트에서 작성한 커스텀 컨버터를 적용해준다.

```java
@FeignClient(
    name = "fitnessVideoClient",
    url = "...",
    configuration = FeignConfig.class
)
```