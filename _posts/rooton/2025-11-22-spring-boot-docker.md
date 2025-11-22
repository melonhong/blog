---
title:
description: ''
author: melonhong
date: '2025-11-22 23:36:13 +0900'
categories:
- rooton
tags: []
---

## 1. [로컬] Dockerfile과 .dockerignore 파일을 루트 디렉토리에 추가한다.
본인 서비스에 맞는 버전의 JDK를 사용해주세요.

```dockerfile

# Dockerfile

# 1. JDK 21 기반 이미지 사용
FROM eclipse-temurin:21-jdk-jammy

# 2. 컨테이너 내부 작업 디렉토리 설정
WORKDIR /app

# 3. Gradle 빌드 결과 JAR 파일을 컨테이너로 복사
COPY build/libs/*.jar app.jar

# 4. 환경변수 설정 (docker-compose.yml에서 주입 가능)
ENV SERVER_PORT=8080

# 5. 컨테이너에서 노출할 포트 (컨테이너 내부 포트 통일)
EXPOSE ${SERVER_PORT}

# 6. 컨테이너 실행 시 JAR 실행

ENTRYPOINT ["sh", "-c", "java -jar app.jar --server.port=${SERVER_PORT}"]
```

```dockerfile
# .dockerignore

# IDE 파일 제외
.idea/
*.iml

# Git 파일 제외
.git/
.gitignore

# 로그 파일 제외
*.log

# 환경 변수 파일 제외 (docker-compose에서 주입)
src/main/resources/.env
```
 
## 2. [로컬] 프로젝트 루트 디렉토리에서 다음과 같은 명령어를 입력하여 JAR 파일을 만든다.
주의: 환경변수는 본인의 서비스에 맞는 환경변수를 작성해주세요

```bash
VARIABLE= \
./gradlew clean build --no-build-cache
```

## 3. [로컬] wsl이나 인텔리제이 도커를 사용해서 자신의 도커 허브에 이미지를 배포한다.
 
## 4. [NKS] 다음 명령어를 사용하여 도커 이미지를 클라우드에 배포한다.
주의: 환경변수는 자신의 서비스에 맞는 걸 써주세요

```bash
sudo docker run -d \
  --name backend \
  -p 8080:8080 \
  -e VARIABLE="" \
  your-image-name:latest
  ```
