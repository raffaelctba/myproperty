# MyProperty - Enterprise Property Management System

A complete, production-ready, full-stack Property Management System designed for long-term scalability and enterprise adoption with property-scoped authorization.

## 🏗️ Architecture Overview

### Technology Stack

**Backend:**
- Spring Boot 4 + Java 25
- PostgreSQL (primary database)
- Redis (caching)
- Apache Kafka (event-driven messaging)
- WebSockets (real-time communication)
- OAuth2/OpenID Connect with Keycloak
- REST + GraphQL APIs 

**Frontend:**
- Angular 21 with standalone components
- TailwindCSS for styling
- Angular Signals for state management
- WebSocket integration for real-time features

**Infrastructure:**
- Docker & Docker Compose
- Kubernetes-ready architecture
- Gradle with Kotlin DSL

### Core Architecture Decisions

#### 1. Modular Monolith vs Microservices
**Decision: Modular Monolith**

**Justification:**
- Faster initial development and deployment
- Simplified data consistency and transactions
- Easier debugging and monitoring
- Lower operational complexity
- Can be decomposed into microservices later as the system grows

#### 2. Multi-tenancy Strategy
**Decision: Single Schema with Property-Scoped Authorization**

**Justification:**
- Simpler database management and migrations
- Better resource utilization
- Easier backup and maintenance
- Property-scoped roles provide sufficient isolation
- Cost-effective for medium-scale deployments

#### 3. Property-Scoped Authorization Model

The system implements a sophisticated authorization model where:
- Users can have different roles per property (not global roles)
- Roles are enforced at both backend and frontend levels
- Any authenticated user can register a property and becomes its owner/admin
- Fine-grained permissions control access to features

**Roles:**
- `PROPERTY_OWNER`: Full ownership rights
- `PROPERTY_LANDLORD`: Day-to-day operations management
- `PROPERTY_MANAGER`: Professional property management
- `PROPERTY_TENANT`: Tenant access to lease and maintenance
- `PROPERTY_MAINTENANCE`: Maintenance staff access

## 🚀 Quick Start

### Prerequisites
- Docker and Docker Compose
- Node.js 18+ (for local development)
- Java 25+ (for local development)

### Running the System

1. **Clone the repository:**
```bash
git clone <repository-url>
cd MyProperty
```

2. **Start all services:**
```bash
docker-compose up -d
```

3. **Start with development tools:**
```bash
docker-compose --profile dev up -d
```

### Service URLs

- **Frontend:** http://localhost:4200
- **Backend API:** http://localhost:8080
- **Keycloak Admin:** http://localhost:8090 (admin/admin_password)
- **Kafka UI:** http://localhost:8081 (dev profile)
- **pgAdmin:** http://localhost:8082 (dev profile)
- **Redis Commander:** http://localhost:8083 (dev profile)

## 📁 Project Structure

```
MyProperty/
├── myproperty-backend/          # Spring Boot backend
│   ├── src/main/kotlin/com/myproperty/
│   │   ├── domain/              # Domain entities and models
│   │   │   ├── authorization/   # Property-scoped roles and permissions
│   │   │   ├── property/        # Property and unit management
│   │   │   ├── lease/           # Lease management
│   │   │   ├── maintenance/     # Maintenance requests
│   │   │   └── user/            # User management
│   │   ├── controller/          # REST controllers
│   │   ├── service/             # Business logic services
│   │   ├── repository/          # Data access layer
│   │   ├── security/            # Security and authorization
│   │   ├── event/               # Kafka event producers/consumers
│   │   ├── websocket/           # WebSocket controllers
│   │   └── config/              # Configuration classes
│   ├── src/main/resources/
│   │   └── db/migration/        # Flyway database migrations
│   ├── build.gradle.kts         # Gradle build configuration
│   └── Dockerfile               # Backend container configuration
├── myproperty-frontend/         # Angular frontend
│   ├── src/app/
│   │   ├── core/                # Core services and models
│   │   │   ├── services/        # Angular services
│   │   │   └── models/          # TypeScript models
│   │   ├── features/            # Feature modules
│   │   │   ├── properties/      # Property management
│   │   │   ├── leases/          # Lease management
│   │   │   ├── maintenance/     # Maintenance requests
│   │   │   ├── chat/            # Real-time chat
│   │   │   └── dashboard/       # Dashboard views
│   │   └── shared/              # Shared components
│   ├── package.json             # NPM dependencies
│   ├── angular.json             # Angular configuration
│   ├── nginx.conf               # Nginx configuration
│   └── Dockerfile               # Frontend container configuration
└── docker-compose.yml          # Multi-service orchestration
```

## 🔐 Authorization System

### Property-Scoped Roles

The system's core innovation is property-scoped authorization:

```kotlin
// Backend: Property-scoped permission check
@GetMapping("/{propertyId}")
fun getProperty(@PathVariable propertyId: UUID, @AuthenticationPrincipal jwt: Jwt) {
    val userId = UUID.fromString(jwt.subject)
    propertyScopedSecurity.requirePermission(userId, propertyId, Permission.PROPERTY_VIEW)
    // ... rest of the method
}
```

```html
<!-- Frontend: Role-aware UI rendering -->
@if (hasPermission('PROPERTY_EDIT')) {
  <button (click)="editProperty()">Edit Property</button>
}
```

### Permission Matrix

| Role | Property View | Property Edit | User Management | Lease Management | Maintenance | Financial |
|------|---------------|---------------|-----------------|------------------|-------------|-----------|
| OWNER | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| MANAGER | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| LANDLORD | ✅ | ✅ | ❌ | ✅ | ✅ | View Only |
| TENANT | ✅ | ❌ | ❌ | View Only | Request Only | Submit Only |
| MAINTENANCE | ✅ | ❌ | ❌ | ❌ | ✅ | ❌ |

## 🔄 Event-Driven Architecture

The system uses Kafka for event-driven workflows:

### Event Topics
- `property-created` - New property registration
- `lease-created` - New lease agreements
- `lease-signed` - Lease execution
- `maintenance-request-created` - New maintenance requests
- `maintenance-request-completed` - Completed maintenance
- `payment-received` - Payment processing
- `user-role-assigned` - Role assignments
- `chat-message-sent` - Real-time messaging
- `notification-requested` - Notification delivery

### Event Flow Example
```
Property Created → Kafka Event → Notification Service → Email/SMS → User
                              → Audit Service → Audit Log
                              → Analytics Service → Metrics
```

## 🌐 Real-Time Features

### WebSocket Endpoints
- `/ws/property/{propertyId}/chat` - Property-scoped chat
- `/ws/property/{propertyId}/maintenance` - Maintenance updates
- `/ws/property/{propertyId}/notifications` - Live notifications

### Frontend Integration
```typescript
// Angular service with Signals
export class WebSocketService {
  private chatMessages = signal<ChatMessage[]>([]);

  subscribeToPropertyChat(propertyId: string) {
    this.stompClient.subscribe(`/topic/property/${propertyId}/chat`, 
      message => this.chatMessages.update(msgs => [...msgs, JSON.parse(message.body)])
    );
  }
}
```

## 🗄️ Database Schema

### Core Tables
- **users** - User profiles and authentication
- **properties** - Property information
- **user_property_roles** - Property-scoped authorization (CORE)
- **units** - Individual rental units
- **leases** - Lease agreements
- **maintenance_requests** - Maintenance workflow
- **payments** - Payment tracking
- **chat_messages** - Real-time messaging
- **notifications** - Notification system

### Key Relationships
```sql
-- Property-scoped authorization
CREATE TABLE user_property_roles (
    user_id UUID REFERENCES users(id),
    property_id UUID REFERENCES properties(id),
    role VARCHAR(50) CHECK (role IN ('PROPERTY_OWNER', 'PROPERTY_LANDLORD', ...)),
    is_active BOOLEAN DEFAULT true,
    valid_from TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    valid_until TIMESTAMP,
    UNIQUE(user_id, property_id, role)
);
```

## 🚀 CI/CD Pipeline

### Pipeline Stages

#### 1. Build Stage
```yaml
build:
  stage: build
  script:
    - ./gradlew build -x test  # Backend build
    - npm ci && npm run build  # Frontend build
  artifacts:
    paths:
      - myproperty-backend/build/libs/*.jar
      - myproperty-frontend/dist/
```

#### 2. Test Stage
```yaml
test:
  stage: test
  parallel:
    matrix:
      - SERVICE: [backend, frontend]
  script:
    - if [ "$SERVICE" = "backend" ]; then ./gradlew test; fi
    - if [ "$SERVICE" = "frontend" ]; then npm run test:ci; fi
  coverage: '/Total.*?(\d+(?:\.\d+)?)%/'
```

#### 3. Security Scan
```yaml
security:
  stage: security
  script:
    - docker run --rm -v $(pwd):/app securecodewarrior/docker-security-scan
    - npm audit --audit-level moderate
    - ./gradlew dependencyCheckAnalyze
```

#### 4. Docker Build
```yaml
docker:
  stage: docker
  script:
    - docker build -t $CI_REGISTRY/myproperty-backend:$CI_COMMIT_SHA ./myproperty-backend
    - docker build -t $CI_REGISTRY/myproperty-frontend:$CI_COMMIT_SHA ./myproperty-frontend
    - docker push $CI_REGISTRY/myproperty-backend:$CI_COMMIT_SHA
    - docker push $CI_REGISTRY/myproperty-frontend:$CI_COMMIT_SHA
```

#### 5. Deploy Stage
```yaml
deploy:
  stage: deploy
  script:
    - kubectl set image deployment/backend backend=$CI_REGISTRY/myproperty-backend:$CI_COMMIT_SHA
    - kubectl set image deployment/frontend frontend=$CI_REGISTRY/myproperty-frontend:$CI_COMMIT_SHA
    - kubectl rollout status deployment/backend
    - kubectl rollout status deployment/frontend
```

### Kubernetes Deployment

#### Backend Deployment
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myproperty-backend
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myproperty-backend
  template:
    metadata:
      labels:
        app: myproperty-backend
    spec:
      containers:
      - name: backend
        image: myproperty-backend:latest
        ports:
        - containerPort: 8080
        env:
        - name: SPRING_PROFILES_ACTIVE
          value: "kubernetes"
        resources:
          requests:
            memory: "512Mi"
            cpu: "250m"
          limits:
            memory: "1Gi"
            cpu: "500m"
```

## 🔮 Future Enhancements

### Phase 1: Core Improvements (3-6 months)
- **Mobile Application**: React Native app for tenants and maintenance staff
- **Advanced Reporting**: Business intelligence dashboard with charts and analytics
- **Document Management**: Integrated document storage and e-signature capabilities
- **Payment Integration**: Stripe/PayPal integration for online rent payments
- **SMS Notifications**: Two-way SMS communication for urgent maintenance requests

### Phase 2: Advanced Features (6-12 months)
- **AI-Powered Insights**: Predictive maintenance and market analysis
- **IoT Integration**: Smart home device integration for utilities and security
- **Accounting Integration**: QuickBooks/Xero synchronization
- **Multi-language Support**: Internationalization for global markets
- **Advanced Workflow Engine**: Customizable business process automation

### Phase 3: Enterprise Scale (12-18 months)
- **Microservices Migration**: Decompose monolith based on domain boundaries
- **Multi-region Deployment**: Global CDN and database replication
- **Advanced Security**: Zero-trust architecture and advanced threat detection
- **API Marketplace**: Third-party integrations and developer ecosystem
- **White-label Solution**: Customizable branding for property management companies

### Phase 4: Innovation (18+ months)
- **Blockchain Integration**: Smart contracts for lease agreements
- **VR/AR Property Tours**: Virtual property viewing capabilities
- **Machine Learning**: Automated rent pricing and tenant screening
- **Voice Interface**: Alexa/Google Assistant integration
- **Sustainability Tracking**: Carbon footprint and energy efficiency monitoring

## 📊 Performance Targets

### Scalability Goals
- **Users**: Support 100,000+ concurrent users
- **Properties**: Handle 1M+ properties with 10M+ units
- **Transactions**: Process 10,000+ transactions per second
- **Storage**: Manage 100TB+ of documents and media

### Performance Metrics
- **API Response Time**: < 200ms for 95th percentile
- **Database Queries**: < 50ms average query time
- **WebSocket Latency**: < 100ms for real-time messages
- **Uptime**: 99.9% availability SLA

## 🛡️ Security Considerations

### Current Implementation
- OAuth2/OpenID Connect authentication
- Property-scoped authorization
- SQL injection prevention
- XSS protection
- CSRF protection
- Secure headers (HSTS, CSP, etc.)

### Future Security Enhancements
- Multi-factor authentication (MFA)
- Rate limiting and DDoS protection
- Advanced audit logging
- Encryption at rest and in transit
- Regular security assessments
- Compliance certifications (SOC 2, GDPR)

## 🤝 Contributing

### Development Setup
1. Install prerequisites (Java 25, Node.js 18+, Docker)
2. Clone repository and run `docker-compose --profile dev up -d`
3. Backend: `./gradlew bootRun`
4. Frontend: `npm start`

### Code Standards
- Backend: Kotlin coding conventions, comprehensive unit tests
- Frontend: Angular style guide, TypeScript strict mode
- Database: Flyway migrations for all schema changes
- Documentation: Update README for any architectural changes

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

For support and questions:
- Create an issue in the GitHub repository
- Email: support@myproperty.com
- Documentation: [Wiki](https://github.com/myproperty/wiki)

---

**MyProperty** - Building the future of property management, one property at a time. 🏠✨
