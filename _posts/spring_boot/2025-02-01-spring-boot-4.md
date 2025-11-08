---
title: 스프링 부트3 제 4장
description: 코드가 너저분하군요 정리하고 가죠
author: melonhong
date: '2025-02-01 22:47:53 +0900'
categories:
- 스프링 부트3
tags: []
---
## 롬복(lombok)
코드를 간소화해주는 라이브러리. 롬복으로 코드를 리팩터링해보자.

> **리팩터링(refactoring)**이란 코드의 기능에는 변함이 없이 코드의 구조 또는 성능을 개선하는 작업을 뜻한다.
{: .prompt-tip }


## 롬복 설치하기
build.gradle 파일에 다음 코드를 작성하자.
```java
dependencies {
	compileOnly 'org.projectlombok:lombok'
	annotationProcessor 'org.projectlombok:lombok' 
    // ... 생략
}
```
그리고 코끼리 모양의 새로 고침 아이콘을 클릭하면 자동으로 롬복 라이브러리를 다운로드 한다.


## 코드 리팩터링
### 생성자와 toString 어노테이션
```java
// ... 생략
@AllArgsConstructor // lombok으로 생성자 자동 추가
@ToString // lombok으로 toString 자동 추가
public class ArticleForm {
    private String title;
    private String content;
// ... 생략
}
```
기존의 생성자와 toString을 삭제하고 어노테이션을 추가하면 된다.

### Slf4j 어노테이션
```java
@Slf4j // Simple Logging Facade for Java
public class ArticleController {
    // ... 생략
    public String createArticle(ArticleForm form) {
        Article article = form.toEntity();
        log.info(article.toString()); // 로그 추가
        Article saved = articleRepository.save(article);
        log.info(saved.toString()); // 로그 추가
        return "";
    }
}
```
**Slf4j**는 Simple Logging Facade for Java의 약자로, 이 어노테이션을 쓰면 로깅 기능을 추가할 수 있다.

> println() 문은 기록에 남지 않고 서버의 성능에도 악영향을 끼치니 로깅으로 대체하자.
{: .prompt-danger }