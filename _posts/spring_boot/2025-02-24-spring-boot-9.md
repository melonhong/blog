---
title: 스프링 부트3 제 9장
description: 보이지 않는 DB에서 무슨 일이 일어난 거죠?
author: melonhong
date: '2025-02-24 14:43:57 +0900'
categories:
- 스프링 부트3
tags: []
---
## JPA 로깅 설정하기
서버에 CRUD 요청을 하면 JPA 리파지터리가 DB에 해당 요청을 전달한다.  
DB는 SQL로 쿼리를 작성해 요청을 처리한다.  
서버에서 DB가 무엇을 하는지 알 수 있도록 JPA 로깅 설정을 해주자.

### application.properties
```
# ... 생략

# JPA 로깅 설정
# 디버그 레벨로 쿼리 출력
logging.level.org.hibernate.SQL=DEBUG
# 퀴리 줄바꿈하기
spring.jpa.properties.hibernate.format_sql=true
# 매개변수 값 보여주기
logging.level.org.hibernate.type.descriptor.sql.BasicBinder=TRACE

# DB URL 설정
# 유니크 URL 생성하지 않기
spring.datasource.generate-unique-name=false
# 고정 URL 설정하기
spring.datasource.url=jdbc:h2:mem:testdb
```
로깅 레벨에는 7단계가 있다.
1. **TRACE**: DEBUG 레벨보다 더 상세한 정보
2. **DEBUG**: 앱을 디버깅하는 데 필요한 세부 정보
3. **INFO**: 앱의 순조로운 진행 정보
4. **WARN**: 잠재적으로 유해한 상황 정보
5. **ERROR**: 앱이 수행할 수 있는 정도의 오류 정보
6. **FATAL**: 앱이 중단될 만한 심각한 오류 정보
7. **OFF**: 로깅 기능 해제

쿼리를 줄바꿈하는 이유는 한눈에 보기 좋게 로그를 보기 위해서이다.  
매개변수 확인 코드를 넣은 이유는 종종 로그에 물음표를 볼 수 있는데, 그 값을 확인하기 위해서이다.

## id가 겹치는 에러
data.sql로 DB를 초기화 할 때, `id`를 1번부터 넣게 설정했다. 이렇게 하면 새 게시글을 작성할 때, `id`가 중복되어 에러가 발생한다.  
따라서 DB가 자동으로 `id`를 생성하도록 설정해주었다.

### Article.java
```java
// ... 생략
@Id // 엔티티의 대푯값 지정
@GeneratedValue(strategy = GenerationType.IDENTITY) // DB가 id 자동 생성
private Long id; // 아이디 필드
```
엔티티 파일 `id` 변수의 `@GeneratedValue` 어노테이션에 `strategy = GenerationType.IDENTITY`를 추가하면 DB가 알아서 `id`를 자동 생성하게 할 수 있다.

### data.sql
```
insert into article(title, content) values ('aaaa', '1111');
insert into article(title, content) values ('bbbb', '2222');
insert into article(title, content) values ('cccc', '3333');
```
`id`는 필요 없으니 없애주었다.


## CRUD 시 로그 확인
### insert
```
2025-02-24T14:27:32.713+09:00  INFO 6656 --- [firstproject] [nio-8080-exec-4] c.e.f.controller.ArticleController       : Article(id=null, title=제목제목, content=내용내용)
2025-02-24T14:27:32.730+09:00 DEBUG 6656 --- [firstproject] [nio-8080-exec-4] org.hibernate.SQL                        : 
    insert 
    into
        article
        (content, title, id) 
    values
        (?, ?, default)
2025-02-24T14:27:32.764+09:00  INFO 6656 --- [firstproject] [nio-8080-exec-4] c.e.f.controller.ArticleController       : Article(id=4, title=제목제목, content=내용내용)
```

### select
```
2025-02-24T14:27:37.050+09:00 DEBUG 6656 --- [firstproject] [nio-8080-exec-7] org.hibernate.SQL                        : 
    select
        a1_0.id,
        a1_0.content,
        a1_0.title 
    from
        article a1_0 
    where
        a1_0.id=?
```

### update
```
2025-02-24T14:34:45.911+09:00  INFO 7236 --- [firstproject] [nio-8080-exec-5] c.e.f.controller.ArticleController       : Article(id=2, title=제목제목제목, content=내용내용내용)
2025-02-24T14:34:45.911+09:00 DEBUG 7236 --- [firstproject] [nio-8080-exec-5] org.hibernate.SQL                        : 
    select
        a1_0.id,
        a1_0.content,
        a1_0.title 
    from
        article a1_0 
    where
        a1_0.id=?
2025-02-24T14:34:45.953+09:00 DEBUG 7236 --- [firstproject] [nio-8080-exec-5] org.hibernate.SQL                        : 
    update
        article 
    set
        content=?,
        title=? 
    where
        id=?
```

### delete
```
2025-02-24T14:35:48.405+09:00  INFO 7236 --- [firstproject] [nio-8080-exec-9] c.e.f.controller.ArticleController       : Article(id=2, title=제목제목제목, content=내용내용내용)
2025-02-24T14:35:48.409+09:00 DEBUG 7236 --- [firstproject] [nio-8080-exec-9] org.hibernate.SQL                        : 
    delete 
    from
        article 
    where
        id=?
```