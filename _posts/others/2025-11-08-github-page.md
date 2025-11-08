---
title: 깃허브 페이지 만들기
description: 개인 페이지와 프로젝트 페이지를 만들어보자
author: melonhong
date: "2025-11-08 23:58:35 +0900"
categories: [기타]
tags: []
---

## 개요

깃허브에는 자신의 이름을 도메인으로 하여 사이트를 하나 만들 수 있다.

두 가지 방법이 존재한다.  
첫 번째 방법은 계정 하나 당 만들 수 있는 사용자 페이지이고,
두 번째 방법은 프로젝트 당 하나씩 만들 수 있는 페이지이다.

## 사용자 페이지 (Personal Page)

개인 페이지는 GitHub 계정을 대표하는 사이트로 만든다.  
URL 형식은 `https://<사용자명>.github.io` 이다.

### 만드는 방법

1. **저장소 생성**

   - GitHub에서 `New repository`를 클릭한다.
   - 저장소 이름을 `<사용자명>.github.io`로 지정한다.
   - `Public`으로 설정하고 `Create repository`를 클릭한다.

2. **페이지 파일 추가**

   - 저장소 루트에 `index.html` 파일을 추가한다.
   - 예시:
     ```html
     <!DOCTYPE html>
     <html>
       <head>
         <meta charset="utf-8" />
         <title>My GitHub Page</title>
       </head>
       <body>
         <h1>Hello, world!</h1>
       </body>
     </html>
     ```

3. **배포 설정**
   - 저장소의 `Settings > Pages`로 이동한다.
   - `Deploy from a branch`를 선택한다.
   - `main` 브랜치의 `/ (root)`를 선택한다.
   - 저장 후 배포가 완료되면 `https://<사용자명>.github.io`에서 페이지를 확인한다.

---

## 프로젝트 페이지 (Project Page)

프로젝트 페이지는 특정 프로젝트용 사이트를 만든다.  
URL 형식은 `https://<사용자명>.github.io/<저장소이름>` 이다.

### 만드는 방법

1. **프로젝트 저장소 생성**

   - 프로젝트 이름으로 새 저장소를 만든다.
   - 예: `my-project`

2. **페이지 파일 추가**

   - 저장소에 `index.html` 파일을 추가한다.
   - 예시:
     ```html
     <!DOCTYPE html>
     <html>
       <head>
         <meta charset="utf-8" />
         <title>My Project</title>
       </head>
       <body>
         <h1>Project Page</h1>
       </body>
     </html>
     ```

3. **배포 브랜치 설정**
   - 저장소의 `Settings > Pages`로 이동한다.
   - `Deploy from a branch`를 선택한다.
   - `main` 브랜치 또는 `docs` 폴더를 선택한다.
   - 저장 후 `https://<사용자명>.github.io/<저장소이름>`에서 페이지를 확인한다.

## 요약

- 사용자 페이지 (User Page)

  - 리포지토리 이름이 반드시 username.github.io 여야 함.
  - GitHub 계정당 한 개만 존재.
  - `https://<사용자명>.github.io` 로 접근 가능.

- 프로젝트 페이지 (Project Page)
  - 일반 리포지토리(blog, portfolio, nowbid 등)에서도 생성 가능.
  - `https://<사용자명>.github.io/<저장소이름>` 으로 접근 가능.
  - 여러 개 만들 수 있음.
