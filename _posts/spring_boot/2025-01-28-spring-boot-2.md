---
layout: post
title: 스프링 부트3 제 2장
description: >-
    MVC 패턴을 배우고 스프링 부트에 적용하자
date: 2025-01-28 01:42 +0900
category: [스프링 부트3]
---
## MVC 패턴이란
- View: 웹 페이지를 화면에 보여줌
- Controller: 클라이언트의 요청을 받아 처리함
- Model: 데이터를 관리함

### 생성 위치
- 뷰 템플릿: `src/main/resources/templates`{: .filepath}
- 컨트롤러: `src/main/java/your_package`{: .filepath}


## 코드 예시
### 모델을 통해 변수를 등록하는 방법
`model.addAttribute("varName", var);`

### 컨트롤러 예시
```java
// ... 생략

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller // 이 클래스가 컨트롤러임을 선언하는 어노테이션
public class FirstController {
    @GetMapping("/hi") // URL 매핑
    public String niceToMeetYou(Model model) { // Model 객체 받아오기
        model.addAttribute("username", "neko"); // model에 변수 등록록
        return "greetings"; // 페이지 이름만 적어주면 templates에서 해당 뷰를 반환
    }
}
```

### 뷰에서의 변수 사용 예시
{% raw %}
```html
{{>layouts/header}}
<div class="bg-dark text-white p-5">
    <h1>{{ username }}님 반갑습니다</h1>
</div>
{{>layouts/footer}}
```
{% endraw %}


## 레이아웃
화면에 요소를 배치하는 일. 뷰를 구조적으로 관리할 수 있다. 뷰에서 {% raw %}`{{>file_path}}`{% endraw %}으로 가져올 수 있다.

### 생성 위치
- 레이아웃 템플릿: `src/main/resources/templates/layouts`{: .filepath} (편하게 하기 위해 layouts이라는 디렉토리 생성)

