# syntax=docker/dockerfile:1

# Stage 1: Build Angular frontend
FROM node:22-alpine AS frontend-build
WORKDIR /frontend

ARG API_BASE_URL=
ARG WS_BASE_URL=
ARG KEYCLOAK_URL=http://localhost:8083

COPY frontend/package*.json ./
RUN npm ci

COPY frontend/ ./
RUN sed -i "s|__API_BASE_URL__|${API_BASE_URL}|g" src/environments/environment.prod.ts && \
	sed -i "s|__WS_BASE_URL__|${WS_BASE_URL}|g" src/environments/environment.prod.ts && \
	sed -i "s|__KEYCLOAK_URL__|${KEYCLOAK_URL}|g" src/environments/environment.prod.ts
RUN npm run build -- --configuration production

# Stage 2: Build Spring Boot backend and bundle frontend assets
FROM eclipse-temurin:25-jdk AS backend-build
WORKDIR /backend

RUN apt-get update && apt-get install -y --no-install-recommends maven && rm -rf /var/lib/apt/lists/*

COPY backend/pom.xml ./
RUN mvn -B -DskipTests dependency:go-offline

COPY backend/src ./src
COPY --from=frontend-build /frontend/dist/myproperty-frontend/browser/ ./src/main/resources/static/
RUN mvn -B -DskipTests clean package

# Stage 3: Runtime image
FROM eclipse-temurin:25-jdk
WORKDIR /app

RUN groupadd --system --gid 1001 myproperty && useradd --system --uid 1001 --gid myproperty myproperty

COPY --from=backend-build /backend/target/property-management-*.jar ./app.jar

RUN mkdir -p /var/log/myproperty /app/uploads/property-images && \
	chown -R myproperty:myproperty /var/log/myproperty /app

ENV SPRING_PROFILES_ACTIVE=prod
ENV PORT=8081

EXPOSE 8081

USER myproperty

ENTRYPOINT ["java", "-XX:+UseContainerSupport", "-XX:MaxRAMPercentage=75.0", "-Djava.security.egd=file:/dev/./urandom", "-jar", "app.jar"]





