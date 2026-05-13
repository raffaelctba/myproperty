# MyProperty - Multi-Environment Configuration

## Quick Start Guide

This project is configured to run in three different environments: **Development**, **Test**, and **Production**.

---

## 🚀 Running the Application

### Development Environment

**Option 1: Using Scripts (Recommended)**

Windows:
```bash
cd backend
start-dev.bat
```

Linux/Mac:
```bash
cd backend
chmod +x start-dev.sh
./start-dev.sh
```

**Option 2: Using Maven**
```bash
cd backend
mvn spring-boot:run -Dspring-boot.run.profiles=dev
```

**Option 3: Using JAR**
```bash
cd backend
mvn clean package -DskipTests
java -jar -Dspring.profiles.active=dev target/property-management-1.0.0.jar
```

**Option 4: Using Docker Compose**
```bash
docker-compose -f docker-compose-env.yml --profile dev up
```

**Access Points:**
- API: http://localhost:8081/api
- Swagger UI: http://localhost:8081/api/swagger-ui.html
- Health: http://localhost:8081/api/actuator/health

---

### Test Environment

**Using Scripts:**

Windows:
```bash
cd backend
# First, create .env.test from template
copy .env.test.template .env.test
# Edit .env.test with your test configuration
start-test.bat
```

Linux/Mac:
```bash
cd backend
# First, create .env.test from template
cp .env.test.template .env.test
# Edit .env.test with your test configuration
chmod +x start-test.sh
./start-test.sh
```

**Using Docker Compose:**
```bash
docker-compose -f docker-compose-env.yml --profile test up
```

---

### Production Environment

**Using Scripts:**

Windows:
```bash
cd backend
# First, create .env.prod from template
copy .env.prod.template .env.prod
# Edit .env.prod with your production credentials
start-prod.bat
```

Linux/Mac:
```bash
cd backend
# First, create .env.prod from template
cp .env.prod.template .env.prod
# Edit .env.prod with your production credentials
chmod +x start-prod.sh
./start-prod.sh
```

**Using Docker:**
```bash
cd backend
docker build -t myproperty:1.0.0 .
docker run -d \
  --name myproperty-app \
  --env-file .env.prod \
  -e SPRING_PROFILES_ACTIVE=prod \
  -p 8081:8081 \
  myproperty:1.0.0
```

---

## 📁 Configuration Files

### Main Configuration Files

| File | Purpose |
|------|---------|
| `application.yml` | Common configuration for all environments |
| `application-dev.yml` | Development-specific settings |
| `application-test.yml` | Test-specific settings |
| `application-prod.yml` | Production-specific settings |

### Environment Variable Templates

| File | Purpose |
|------|---------|
| `.env.dev.template` | Development environment variables template |
| `.env.test.template` | Test environment variables template |
| `.env.prod.template` | Production environment variables template |

### Startup Scripts

| File | Purpose |
|------|---------|
| `start-dev.sh` / `start-dev.bat` | Start development environment |
| `start-test.sh` / `start-test.bat` | Start test environment |
| `start-prod.sh` / `start-prod.bat` | Start production environment |

---

## 🔧 Environment-Specific Features

### Development (dev)
- ✅ SQL logging enabled
- ✅ Swagger UI enabled
- ✅ Debug logging
- ✅ Detailed error messages
- ✅ Local PostgreSQL (localhost:5432)
- ✅ Local Kafka (localhost:9092)
- ✅ Local Keycloak (localhost:8080)

### Test (test)
- ✅ Swagger UI enabled
- ✅ INFO level logging
- ⚠️ Limited error details
- 🔒 Separate test database
- 🔒 Test-specific Kafka topics
- 🔒 Test Keycloak server

### Production (prod)
- ❌ Swagger UI disabled
- ❌ No error details exposed
- ❌ Minimal logging (WARN level)
- 🔒 Production database with connection pooling
- 🔒 Production Kafka cluster
- 🔒 Secure Keycloak with HTTPS
- ⚡ Performance optimizations enabled
- ⚡ Compression enabled
- ⚡ Batch processing enabled

---

## 🔐 Security Notes

### Environment Files
- **NEVER commit `.env` files to git**
- Keep production secrets secure
- Use a secrets manager in production (AWS Secrets Manager, HashiCorp Vault, etc.)
- Rotate credentials regularly

### Production Checklist
- [ ] Use HTTPS for all connections
- [ ] Enable database SSL
- [ ] Enable Kafka SSL/SASL
- [ ] Use strong passwords
- [ ] Enable firewall rules
- [ ] Set up monitoring and alerts
- [ ] Configure backup strategy
- [ ] Review security groups/network policies

---

## 🛠️ Building the Application

### Development Build
```bash
cd backend
mvn clean package -DskipTests
```

### Production Build
```bash
cd backend
mvn clean package -Pprod
```

### Docker Build
```bash
cd backend
docker build -t myproperty:1.0.0 .
```

---

## 📊 Monitoring & Health Checks

### Health Endpoints

| Endpoint | Description |
|----------|-------------|
| `/api/actuator/health` | Overall health status |
| `/api/actuator/health/liveness` | Liveness probe (K8s) |
| `/api/actuator/health/readiness` | Readiness probe (K8s) |
| `/api/actuator/metrics` | Application metrics |
| `/api/actuator/prometheus` | Prometheus metrics (prod) |

### Checking Application Status

```bash
# Health check
curl http://localhost:8081/api/actuator/health

# Detailed health (dev/test only)
curl http://localhost:8081/api/actuator/health?details=true

# Metrics
curl http://localhost:8081/api/actuator/metrics
```

---

## 🐳 Docker Commands

### Development
```bash
# Start all services
docker-compose -f docker-compose-env.yml --profile dev up -d

# View logs
docker-compose -f docker-compose-env.yml logs -f app-dev

# Stop services
docker-compose -f docker-compose-env.yml --profile dev down
```

### Test
```bash
# Start all services
docker-compose -f docker-compose-env.yml --profile test up -d

# View logs
docker-compose -f docker-compose-env.yml logs -f app-test

# Stop services
docker-compose -f docker-compose-env.yml --profile test down
```

---

## 🗄️ Database Management

### Create Databases

Development:
```sql
CREATE DATABASE myproperty_dev;
```

Test:
```sql
CREATE DATABASE myproperty_test;
CREATE USER myproperty_test_user WITH PASSWORD 'test_password';
GRANT ALL PRIVILEGES ON DATABASE myproperty_test TO myproperty_test_user;
```

Production:
```sql
CREATE DATABASE myproperty_prod;
CREATE USER myproperty_prod_user WITH PASSWORD 'strong_secure_password';
GRANT ALL PRIVILEGES ON DATABASE myproperty_prod TO myproperty_prod_user;
```

### Flyway Migrations

Migrations run automatically on startup. To run manually:

```bash
# Development
mvn flyway:migrate -Dflyway.url=jdbc:postgresql://localhost:5432/myproperty_dev

# Test
mvn flyway:migrate -Dflyway.url=jdbc:postgresql://test-host:5432/myproperty_test

# Production
mvn flyway:migrate -Dflyway.url=jdbc:postgresql://prod-host:5432/myproperty_prod
```

---

## 🔍 Troubleshooting

### Application won't start

1. **Check active profile:**
   ```bash
   echo $SPRING_PROFILES_ACTIVE
   ```

2. **Check logs:**
   - Dev: `logs/myproperty-dev.log`
   - Test: `logs/myproperty-test.log`
   - Prod: `/var/log/myproperty/application.log`

3. **Verify database connection:**
   ```bash
   psql -h localhost -U postgres -d myproperty_dev
   ```

4. **Check if port is available:**
   ```bash
   # Windows
   netstat -ano | findstr :8081
   
   # Linux/Mac
   netstat -an | grep 8081
   ```

### Database connection issues

1. Check PostgreSQL is running
2. Verify credentials in environment file
3. Check firewall rules
4. Verify database exists

### Keycloak authentication issues

1. Verify Keycloak is accessible
2. Check realm configuration
3. Verify client secret matches
4. Check JWT issuer URI

---

## 📚 Additional Documentation

- [ENVIRONMENT_SETUP.md](ENVIRONMENT_SETUP.md) - Detailed setup guide
- [DEPLOYMENT.md](DEPLOYMENT.md) - Deployment strategies
- [README.md](README.md) - Main project documentation

---

## 🤝 Support

For issues or questions:
1. Check the logs
2. Review the troubleshooting section
3. Contact the development team
4. Create an issue in the project repository

---

## 📝 Version Information

- **Spring Boot**: 4.0.3
- **Java**: 21
- **PostgreSQL**: 16
- **Kafka**: 3.9.1
- **Keycloak**: 23.0

---

Last Updated: February 2026

