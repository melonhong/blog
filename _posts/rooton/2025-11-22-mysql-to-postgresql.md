---
title: "[데이터베이스] MySQL에서 PostgreSQL로"
description: '스프링부트에서 PostgreSQL을 설정하는 법'
author: melonhong
date: '2025-11-22 23:07:18 +0900'
categories:
- rooton
tags: [데이터베이스]
---
## 개요

원래 스프링부트의 데이터베이스는 Mysql로 설정되어 있었다.
하지만 요구사항 변화에 따라 Postgresql로 변환하기로 했다.

-----

## 변경해야할 코드

### env 파일

```
DB_URL=jdbc:postgresql://IP_ADDR:PORT/DB
DB_USERNAME=USERNAME
DB_PASSWORD=PW
```

데이터베이스의 url, 사용자 이름, 비밀번호 등을 적어주면 된다.

### application.yml

```yaml
  datasource:
    url: ${DB_URL}
    username: ${DB_USERNAME}
    password: ${DB_PASSWORD}
    driver-class-name: org.postgresql.Driver # postgresql driver
  sql:
    init:
      mode: never
  jpa:
    properties:
      hibernate:
        dialect: org.hibernate.dialect.PostgreSQLDialect # postgresql dialect
        show_sql: true
        format_sql: true
        use_sql_comments: true
        hbm2ddl:
          auto: update
        default_batch_fetch_size: 1000
```

`datasource` 부분에서 env 파일에 설정한 환경변수를 써준다.
그리고 **driver와 dialect를 위와 같이 Postgresql로 설정**해주어야 한다.

### gradle

```groovy
runtimeOnly 'org.postgresql:postgresql:42.7.3'
// runtimeOnly 'com.mysql:mysql-connector-j'
```

의존성에서 Mysql을 제거하고 Postgresql로 바꾸어준다.

## 원글
[클라우드 네이티브](https://readinging.tistory.com/6)