---
title: 블로그 대업데이트
description: 2025년 11월 블로그를 개편하다
author: melonhong
date: '2025-11-09 04:37:53 +0900'
categories:
- 블로그
tags: []
---
## 개요
나의 포트폴리오 페이지를 추가하기 위해 개인 블로그를 프로젝트 페이지로 만들기로 했다.  

- 나의 포트폴리오 페이지: `https://melonhong.github.io`
- 개인 블로그: `https://melonhong.github.io/blog`

이렇게 깔끔하게 나누기 위해 개인 블로그 저장소를 삭제하고 새로 만들었다.  

원본 chirpy 저장소가 많이 업데이트 되었다보니 이참에 새로 병합하는 과정도 거쳤다.  
기존에 쓰던 폴더들(assets, includes, scss 등)을 가져오고 병합했다.  
내가 테마를 수정한게 꽤 있었기 때문이다. 자세한 건 커밋 히스토리를 참조.  

또 중요한 문제가 있었는데, 바로 Github Actions에서 자꾸 에러가 발생한다는 것이었다.  
원본 저장소 내용으로 갈아치우면 고쳐지지 않을까라고 기대했는데,  
그냥 내가 고쳤다...  

이번 글에선 이 트러블 슈팅과 기타 설정들을 모아보았다.



## Jekyll `sass-embedded` 설치 실패 / CI 빌드 오류 트러블슈팅

### 문제 증상

- GitHub Actions CI에서 Jekyll 빌드 실패

```
In Gemfile:
  jekyll-theme-chirpy was resolved to 7.4.1, which depends on
    jekyll-archives was resolved to 2.3.0, which depends on
      jekyll was resolved to 4.4.1, which depends on
        jekyll-sass-converter was resolved to 3.1.0, which depends on
          sass-embedded
Error: The process '/opt/hostedtoolcache/Ruby/3.1.6/x64/bin/bundle' failed with exit code 5
```

* `bundle install` 단계에서 `sass-embedded` 설치 실패

### 원인
Ruby 버전 3.1에서는 특정 `sass-embedded` 버전 호환성 문제가 있다.  
즉, 버전 호환성 이슈였다.

### 해결 방법

#### 1. CI 환경 설정 수정

```yaml
strategy:
  matrix:
    ruby: ["3.2", "3.3"] # ["3.1", "3.2", "3.3"]
```

- Ruby 3.2 이상에서는 설치가 안정적이므로, **3.1 빌드 단계는 아예 제외**했다.
- 3.1 버전 빌드를 제외시킨 이유는 이전 단계가 실패하면 다음 단계가 실행이 되지 않기 때문에, 3.1 버전 이상의 빌드가 실행되지 않았기 때문이다.

#### 2. Jekyll 루비 버전 수정
```yaml
with:
    ruby-version: "3.2" # Not needed with a .ruby-version file
    bundler-cache: true # runs 'bundle install' and caches installed gems automatically
    cache-version: 0 # Increment this number if you need to re-download cached gems
```

- jekyll.yml은 Jekyll 사이트 빌드 및 배포용 GitHub Actions 워크플로우를 담당한다.
- 따라서 Ruby 버전을 3.2로 변경해주었다.



## Chirpy를 사용 시 캐시 파일이 없는 문제

### 문제 증상
```bash
Error: Can't find stylesheet to import.
1 │ @use 'vendors/bootstrap';
```

Chirpy 테마를 사용하면 vendors 안에 있는 파일이 없거나,  
js가 작동하지 않는 문제가 발생한다.  

### 원인
캐시 파일들이 `.gitignore`에 등록되어 있기 때문에  
깃 저장소에 올라가지 않아 빌드할 때 에러가 발생하는 것이다.

### 해결 방법
`.gitignore`에 다음 항목들을 주석 처리 해준다.

```bash
# Misc
# _sass/vendors
# assets/js/dist
```

## 후기
깃허브 페이지는 정말 사람이 할 게 못 되는거 같다...  
하지만 한 번 만들면 진짜 뿌듯하고 진정한 개발자로 거듭난 거 같다.