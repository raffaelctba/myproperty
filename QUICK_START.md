you mean I should send again the one from the first week of this month? because it is showing approved # Guia Rápido - MyProperty System

## Sistema Completo de Gerenciamento de Propriedades

Este sistema foi desenvolvido com:
- **Backend**: Java 25 + Spring Boot 3.4+ + PostgreSQL + Kafka + Keycloak
- **Frontend**: Angular 21 + Tailwind CSS
- **Autenticação**: Keycloak com roles por propriedade
- **Mensageria**: Apache Kafka para eventos assíncronos
- **Chat**: WebSocket para comunicação em tempo real

## ⚡ Início Rápido

### 1. Pré-requisitos

Instale em sua máquina:
- Java 25 (JDK)
- Node.js 20+
- PostgreSQL 15+
- Apache Kafka + Zookeeper
- Keycloak 26+
- Maven 3.9+

### 2. Configuração do Banco de Dados

```sql
CREATE DATABASE myproperty;
CREATE USER postgres WITH PASSWORD 'postgres';
GRANT ALL PRIVILEGES ON DATABASE myproperty TO postgres;
```

### 3. Iniciar Kafka

**Windows:**
```bash
# Terminal 1 - Zookeeper
bin\windows\zookeeper-server-start.bat config\zookeeper.properties

# Terminal 2 - Kafka
bin\windows\kafka-server-start.bat config\server.properties
```

**Linux/Mac:**
```bash
# Terminal 1
bin/zookeeper-server-start.sh config/zookeeper.properties

# Terminal 2
bin/kafka-server-start.sh config/server.properties
```

### 4. Configurar Keycloak

```bash
# Iniciar Keycloak
cd keycloak-26.0.7
bin/kc.bat start-dev  # Windows
bin/kc.sh start-dev   # Linux/Mac
```

**Acesse:** http://localhost:8080

**Configure:**
1. Login: admin / admin
2. Criar Realm: `myproperty`
3. Criar Client Backend: `property-backend` (confidential)
4. Criar Client Frontend: `property-frontend` (public)
5. Criar Roles:
   - PROPERTY_OWNER
   - PROPERTY_TENANT
   - PROPERTY_LANDLORD
   - PROPERTY_ADMIN
   - BUILDING_MANAGER
6. Criar usuário de teste e atribuir roles

**Veja detalhes completos em:** `KEYCLOAK_SETUP.md`

### 5. Iniciar Backend

```bash
cd backend
mvn clean install
mvn spring-boot:run
```

**URL**: http://localhost:8081/api
**Swagger**: http://localhost:8081/api/swagger-ui.html

### 6. Iniciar Frontend

```bash
cd frontend
npm install
npm start
```

**URL**: http://localhost:4200

## 📋 Estrutura do Projeto

```
MyProperty/
├── backend/                    # Spring Boot Application
│   ├── src/main/java/
│   │   └── com/myproperty/
│   │       ├── config/        # Configurações
│   │       ├── controller/    # REST Controllers
│   │       ├── dto/           # DTOs
│   │       ├── kafka/         # Kafka Events/Producers/Consumers
│   │       ├── model/         # Entidades JPA
│   │       ├── repository/    # Repositórios
│   │       └── service/       # Serviços
│   └── src/main/resources/
│       ├── application.yml    # Configurações
│       └── db/migration/      # Flyway Migrations
│
├── frontend/                   # Angular Application
│   ├── src/app/
│   │   ├── guards/           # Route Guards
│   │   ├── models/           # TypeScript Models
│   │   ├── pages/            # Components
│   │   │   ├── dashboard/
│   │   │   ├── properties/
│   │   │   ├── invoices/
│   │   │   └── chat/
│   │   └── services/         # Angular Services
│   └── tailwind.config.js
│
├── README.md                  # Documentação Principal
├── KEYCLOAK_SETUP.md         # Setup do Keycloak
├── DEPLOYMENT.md             # Guia de Deploy
└── docker-compose.yml        # Docker Compose
```

## 🎯 Funcionalidades Principais

### 1. Gerenciamento de Propriedades
- ✅ CRUD completo de propriedades
- ✅ Tipos: Apartamento, Casa, Prédio, Comercial, Terreno
- ✅ Configuração de taxas para prédios
- ✅ Listagem com paginação

### 2. Sistema de Faturas
- ✅ Geração automática mensal para prédios
- ✅ Criação manual de cobranças
- ✅ Cálculo de multas e juros
- ✅ Status: Pendente, Pago, Atrasado
- ✅ Notificações via Kafka

### 3. Chat em Tempo Real
- ✅ WebSocket
- ✅ Salas por propriedade
- ✅ Histórico de mensagens
- ✅ Interface moderna

### 4. Sistema de Roles
Roles por propriedade (não globais):
- **PROPERTY_OWNER**: Controle total
- **PROPERTY_ADMIN**: Administração
- **PROPERTY_LANDLORD**: Gerenciamento
- **PROPERTY_TENANT**: Acesso de inquilino
- **BUILDING_MANAGER**: Síndico

## 📡 API Endpoints

### Properties
```
GET    /api/properties                 Lista todas
GET    /api/properties/{id}            Busca por ID
GET    /api/properties/my-properties   Propriedades do usuário
POST   /api/properties                 Cria nova
PUT    /api/properties/{id}            Atualiza
DELETE /api/properties/{id}            Remove
```

### Invoices
```
GET    /api/invoices                   Lista todas
GET    /api/invoices/{id}              Busca por ID
GET    /api/invoices/property/{id}     Por propriedade
POST   /api/invoices                   Cria nova
PATCH  /api/invoices/{id}/pay          Marca como paga
```

### Chat
```
GET    /api/chat/rooms                 Salas do usuário
GET    /api/chat/rooms/{id}/messages   Mensagens
POST   /api/chat/messages              Envia mensagem

WebSocket:
CONNECT   /ws
SUBSCRIBE /topic/room/{roomId}
```

## 🔄 Eventos Kafka

Tópicos configurados:
- `property-events` - Eventos de propriedades
- `invoice-events` - Eventos de faturas
- `notification-events` - Notificações
- `audit-events` - Auditoria

## ⚙️ Configurações Importantes

### Backend (application.yml)
```yaml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/myproperty
    username: postgres
    password: postgres

  kafka:
    bootstrap-servers: localhost:9092

keycloak:
  auth-server-url: http://localhost:8080
  realm: myproperty
  resource: property-backend
  credentials:
    secret: <SEU-CLIENT-SECRET>
```

### Frontend (app.config.ts)
```typescript
config: {
  url: 'http://localhost:8080',
  realm: 'myproperty',
  clientId: 'property-frontend'
}
```

## 🔍 Testando o Sistema

### 1. Obter Token JWT

```bash
curl -X POST http://localhost:8080/realms/myproperty/protocol/openid-connect/token \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=password" \
  -d "client_id=property-backend" \
  -d "client_secret=<SEU-SECRET>" \
  -d "username=owner" \
  -d "password=password123"
```

### 2. Testar API

```bash
# Listar propriedades
curl -H "Authorization: Bearer <TOKEN>" \
  http://localhost:8081/api/properties/my-properties

# Criar propriedade
curl -X POST http://localhost:8081/api/properties \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Meu Apartamento",
    "propertyType": "APARTMENT",
    "status": "ACTIVE",
    "addressCity": "São Paulo"
  }'
```

### 3. Testar Frontend

1. Acesse http://localhost:4200
2. Você será redirecionado para o Keycloak
3. Faça login com o usuário criado
4. Explore o dashboard
5. Cadastre uma propriedade
6. Crie uma fatura
7. Teste o chat

## 🐛 Solução de Problemas

### Erro de conexão PostgreSQL
```bash
# Verifique se está rodando
psql -U postgres -d myproperty
```

### Erro de conexão Kafka
```bash
# Liste tópicos
bin/kafka-topics.sh --list --bootstrap-server localhost:9092
```

### Erro no Keycloak
- Verifique o realm `myproperty`
- Confirme os client IDs
- Valide o client secret no application.yml

### Frontend não autentica
- Verifique redirect URIs no Keycloak
- Confirme a URL do Keycloak no app.config.ts
- Limpe o cache do navegador

## 📊 Jobs Agendados

O sistema executa automaticamente:
- **01:00** - Verifica faturas atrasadas
- **00:00 (dia 1)** - Gera faturas mensais para prédios

## 🎓 Próximos Passos

1. **Explore a documentação completa** em `README.md`
2. **Configure o Keycloak detalhadamente** seguindo `KEYCLOAK_SETUP.md`
3. **Prepare para deploy** consultando `DEPLOYMENT.md`
4. **Teste todos os endpoints** via Swagger UI
5. **Personalize o sistema** conforme suas necessidades

## 📞 Suporte

- GitHub Issues: [Criar Issue]
- Email: contact@myproperty.com
- Documentação: Ver arquivos `.md` na raiz do projeto

---

**MyProperty System** - Desenvolvido com Java 25, Spring Boot, Angular 21 e muito ☕
