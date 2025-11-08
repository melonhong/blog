---
title: 스프링 부트3 제 3장
description: DTO와 리파지토리를 통해 DB에 게시글을 저장해보자
author: melonhong
date: '2025-01-30 21:47:52 +0900'
categories:
- 스프링 부트3
tags: []
---
## 폼 데이터(form data)
HTML 요소인 <form> 태그에 실려 전송되는 데이터를 의미한다.  
**폼 데이터는 서버의 컨트롤러가 객체에 담아 받는데, 이 객체를 DTO(Data Transfer Object)**라고 한다. DTO로 받은 데이터는 최종적으로 DB(Data Base)에 저장된다.


## DTO를 DB에 저장하기
JPA(Java Persistence API)로 DB에 SQL 명령을 내리면 된다. JPA의 핵심 도구로 엔티티와 리파지토리를 꼽을 수 있다.

- 엔티티(entity): 자바 객체를 DB가 이해할 수 있도록 만든 것
- 리파지토리(repository): 엔티티가 DB 테이블에 저장 및 관리될 수 있게 하는 인터페이스

즉, DTO를 DB에 저장하기 위해선 **DTO를 엔티티로 변환한 후, 리파지토리를 사용하여 DB에 저장해야 한다**는 뜻이다.  

참고로 리파지토리는 미리 생성된 `CrudRepository<T, T>`를 상속하여 만들면 된다.

## H2 DB
서버의 메모리 주소에 데이터베이스를 만든다. `src/main/resources/application.properties`{: .filepath} 파일에 `spring.h2.console.enabled=true` 코드를 추가하면 웹 콘솔로 H2 DB에 접속할 수 있다.  

브라우저로 `[SERVER_ADDRESS]/h2-console`로 접속하면 콘솔이 뜨는데, 이때 JDBC URL에 서버가 동작할 때 나온 URL을 붙여넣어주면 접속이 된다. (서버 시작 로그에서 Ctrl+F로 jdbc를 검색하면 `jdbc:h2:mem:...`이라고 나온다.)


## 코드
### 뷰
```html
<form class="container" action="/articles/create" method="post">
    <div class="mb-3">
        <label class="form-label">제목</label>
        <input type="text" class="form-control" name="title">
    </div>
    <div class="mb-3">
        <label class="form-label">내용</label>
        <textarea class="form-control" rows="3" name="content"></textarea>
    </div>
    <button type="submit" class="btn btn-primary">Submit</button>
</form>
```
- `<form>` 태그의 속성
    - action: 해당 URL로 폼 데이터를 보낸다는 의미
    - method: HTTP 메서드, POST 요청을 보낸다는 의미
- `<input>`과 `<textarea>` 태그의 속성
    - name: **DTO 필드명과 동일한 이름을 name의 속성 값**으로 써 주면, 입력 폼에서 작성한 두 데이터가 DTO의 해당 필드와 연결됨

### ArticleForm(DTO) 클래스
```java
package com.example.firstproject.dto;
import com.example.firstproject.entity.Article;

public class ArticleForm {
    private String title;
    private String content;

    public ArticleForm(String title, String content) {
        this.title = title;
        this.content = content;
    }

    @Override
    public String toString() {
        return "ArticleForm{" +
                "title='" + title + '\'' +
                ", content='" + content + '\'' +
                '}';
    }

    public Article toEntity() {
        return new Article(null, this.title, this.content);
    }
}
```
- toEntity() 메서드: 현재 ArticleForm(DTO)를 새로운 Article(entity)로 변환해 줌

### Article 컨트롤러 클래스
```java
// ... 생략

@Controller
public class ArticleController {
    @Autowired // 인터페이스를 구현하지 않아도 스프링 부트가 미리 생성해 놓은 리파지토리 객체 주입
    private ArticleRepository articleRepository;

    @GetMapping("/articles/new")
    public String newArticleForm() {
        return "articles/new";
    }

    @PostMapping("/articles/create") // 해당 URL로 POST 요청이 온 경우
    public String createArticle(ArticleForm form) {
        Article article = form.toEntity(); // 1. DTO를 엔티티로 변환
        Article saved = articleRepository.save(article); // 2. 리파지터리로 엔티티를 DB에 저장
        return "";
    }
}
```

### ArticleRepository 인터페이스
```java
public interface ArticleRepository extends CrudRepository<Article, Long> {
    // CrudRepository를 상속했기 때문에 기본적인 CRUD 기능은 사용할 수 있음
}
```

### 과정
1. 폼에서 `/articles/new`{: .filepath}로 `POST` 요청을 보낸다.
2. Article 컨트롤러에서 폼 데이터를 ArticleForm의 객체(DTO)로 받는다.
3. Article 컨트롤러에서 ArticleForm의 객체를 Article 객체(entity)로 변환한다.
4. Article 컨트롤러에서 ArticleRepository로 Article 객체(entity)를 DB에 저장한다.

![DTO](https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQv_i_Cxj-LYP-auWTjZb_LmDXYTWZ6iTzjfA&s)_DTO가 DB에 저장되는 과정_


## 트러블 슈팅
### Cannot resolve parameter names for constructor ISSUE
스프링 부트가 업데이트 되면서 `LocalVariableTableParameterNameDiscoverer` 기능이 사라지며 발생된 문제이다. 해당 블로그를 참조하여 해결했다.  
[[오류를 잡아보자] 생성자 바인딩 이슈 (Cannot resolve parameter names for constructor)](https://ppusda.tistory.com/78)


## 잡담
node.js의 sequelize와 살짝 다른데 하면서도 비슷해보인다. 다음 장에 코드를 정리하는 방법을 가르쳐주니 꼭 참고해야겠다. 그리고 H2 데이터베이스를 써서 좀 안 익숙하다. 나중에 MySQL로 바꾸든가 해야겠다. 또 인텔리제이에서 우클릭 후 생성을 누르면 생성자나 toString()을 알아서 작성해준다! 역시 요즘께 편하다.