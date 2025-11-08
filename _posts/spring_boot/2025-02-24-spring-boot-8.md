---
title: 스프링 부트3 제 8장
description: 흑역사는 지울게요!
author: melonhong
date: '2025-02-24 13:36:05 +0900'
categories:
- 스프링 부트3
tags: []
---
## 데이터 삭제 과정
1. 클라이언트가 HTTP 메서드로 삭제 요청
2. 컨트롤러가 리파지터리를 통해 DB에 저장된 데이터를 찾아 삭제
3. 삭제가 완료됐다면 클라이언트를 결과 페이지로 리다이렉트

> 결과 페이지로 리다이렉트 할 때 클라이언트에 삭제 완료 메시지를 띄워주기 위해 플래시를 사용
{: .prompt-info }

## 코드
### ArticleController
```java
// ... 생략
@GetMapping("/articles/{id}/delete")
    public String delete(@PathVariable Long id, RedirectAttributes rttr) { // 리다이렉트 페이지에서 사용할 데이터
        // 1. 삭제할 대상 가져오기
        Article target = articleRepository.findById(id).orElse(null);
        log.info(target.toString());
        
        // 2. 대상 엔티티 삭제하기
        if (target != null) {
            articleRepository.delete(target);
            rttr.addFlashAttribute("msg", "삭제가 완료되었습니다."); // 플래시 등록(넘겨 주려는 키 문자열과 객체를 인자로 받음)
            // 목록 페이지에서 삭제 메시지 사용, 실제로는 헤더에 적어놓음
        }
        
        // 3. 결과 페이지로 리다이렉트 하기
        return "redirect:/articles";
    }
```
`RedirectAttributes` 객체의 `addFlashAttribute()` 메서드를 사용하면 **리다이렉트 시점에 플래시를 남길 수 있다.** 더 자세한 내용은 [여기](https://www.baeldung.com/spring-web-flash-attributes#3-flashmap-data-structure)를 참조하자.

### header.mustache
```html
<!-- ... 생략 -->
{% raw %}
{{#msg}}
<div class="alert alert-primary alert-dismissible">
    {{msg}}
    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
</div>
{{/msg}}
{% endraw %}
```


## 요약
삭제 요청이 들어오면, `ArticleController`의 `delete()` 메서드에서 `@GetMapping`으로 받는다. 삭제 대상을 찾기 위해 URL의 값을 `@PathVariable`을 활용하여 매개변수로 가져온다.  
그리고 리파지터리로 해당 `id`를 가진 게시글을 삭제하고, 사용자를 결과 페이지로 리다이렉트한다.  
이때, 삭제 됐다는 메시지도 출력하기 위해 `RedirectAttributes` 객체의 `addFlashAttribute()` 메서드를 이용한다.