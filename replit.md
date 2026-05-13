# MyProperty - Enterprise Property Management System

## Project Overview
Full-stack property management system with property-scoped authorization.

**Stack:**
- Backend: Java 25 + Spring Boot 4 + PostgreSQL (Neon) + Kafka (disabled in dev)
- Frontend: Angular 21 (source in `pm-frontend` submodule — private repo)
- Auth: Keycloak 26 (OAuth2/JWT)
- Messaging: Apache Kafka (KRaft mode, disabled in dev)

## Architecture
- `pm-backend/` — Spring Boot backend source (Java 25, Maven)
- `pm-frontend/` — Angular 21 frontend (git submodule, private)
- `frontend/` — Dev landing page / proxy served on port 5000
- `docker-compose.yml` — Full infrastructure (Postgres, Redis, Kafka, Keycloak)

## Running in Replit

### Frontend (port 5000 — webview)
Simple landing page / API proxy. Runs with: `cd frontend && node server.js`

### Backend (port 8081 — console)
Spring Boot API. Runs with: `bash start-backend.sh`
- API docs: `/api/swagger-ui.html`
- Health: `/api/actuator/health`
- Database: Neon PostgreSQL (cloud, pre-configured in dev profile)
- Kafka: disabled in dev profile

### Java 25
Installed at `/home/runner/jdk25`. The startup script sets `JAVA_HOME` automatically.

## User Preferences
- Java 25 + Maven for backend
- Angular 21 for frontend (pm-frontend submodule is private)
