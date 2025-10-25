# Create System Architecture Document

You are being asked to create a comprehensive System Architecture document.

## Your Task - Architect Agent Role

Act as the Architect agent to design the complete system architecture.

### 1. Check Prerequisites

**Required:**
- `docs/prd.md` MUST exist - read it completely
- Understand all FRs and NFRs before designing

**If PRD doesn't exist:**
- Inform user: "Cannot create architecture without PRD"
- Offer to help create PRD first (`/bmad-prd`)

### 2. Read and Analyze PRD

Extract from PRD:
- All Functional Requirements (FR-XXX)
- All Non-Functional Requirements (NFR-XXX)
- Performance, security, scalability targets
- User personas and use cases
- Constraints and dependencies

### 3. Design System

Have a design conversation with user about:

**Technology Stack:**
- Programming language(s) and justification
- Framework choices (backend, frontend if applicable)
- Database technology (SQL vs NoSQL, which one, why)
- Infrastructure approach (containers, serverless, VMs)
- Third-party services needed

**Architecture Pattern:**
- Monolith vs Microservices vs Hybrid
- Layered architecture (API, business logic, data access)
- Design patterns to use

**Data Design:**
- Entity-relationship models
- Database schemas
- Data flow patterns
- Caching strategy

**API Design:**
- RESTful, GraphQL, gRPC, or other
- Endpoint structure
- Authentication/authorization approach
- API versioning strategy

### 4. Create Architecture Document

Create `docs/architecture.md` with comprehensive design:

```markdown
# System Architecture Document

> **Product:** [Product Name]
> **Created by:** Architect Agent
> **Date:** [Today's date]
> **Status:** Draft
> **Version:** 1.0

## Overview

### Purpose
[What this architecture document describes]

### Architectural Goals
1. [Goal mapped to NFR-XXX]
2. [Goal mapped to NFR-YYY]

## Technology Stack

### Backend
- **Language:** Python 3.11+
- **Framework:** FastAPI 0.104+
- **Rationale:** [Why these choices, referencing NFRs]

### Frontend (if applicable)
- **Language:** TypeScript
- **Framework:** React 18
- **Rationale:** [Why these choices]

### Infrastructure
- **Container:** Docker
- **Orchestration:** Kubernetes
- **Cloud:** AWS
- **Rationale:** [Why, addressing NFR-XXX scalability]

### Data Storage
- **Primary DB:** PostgreSQL 15
  - **Why:** ACID compliance for NFR-XXX reliability
- **Cache:** Redis 7
  - **Why:** Sub-200ms response time (NFR-001)
- **Object Storage:** S3
  - **Why:** File uploads from FR-XXX

### Third-Party Services
| Service | Purpose | Justification |
|---------|---------|---------------|
| Auth0 | Authentication | Meets NFR-002 security, faster than building |

## System Architecture

### High-Level Architecture
[ASCII diagram or description]

```
┌──────────────────────────────────┐
│       Load Balancer              │
└────────────┬─────────────────────┘
             │
    ┌────────┴────────┐
    ↓                 ↓
┌─────────┐      ┌─────────┐
│ API     │      │ API     │
│ Server  │      │ Server  │
└────┬────┘      └────┬────┘
     │                │
     └────────┬───────┘
              ↓
     ┌────────────────┐
     │   PostgreSQL   │
     └────────────────┘
```

### Architecture Patterns
- **Pattern:** Layered Architecture (API → Service → Data Access)
- **Rationale:** Separation of concerns, testability, maintainability

## Component Architecture

### Component: API Layer
**Purpose:** Handle HTTP requests, route to services
**Responsibilities:**
- Request validation
- Authentication/authorization
- Response formatting
**Technology:** FastAPI with Pydantic models
**Location:** `src/api/`
**Related Requirements:** FR-001, FR-005, NFR-002

---

### Component: Business Logic Layer
**Purpose:** Core business rules and processing
**Responsibilities:**
- [Specific responsibilities mapped to FRs]
**Technology:** Python classes and services
**Location:** `src/services/`
**Related Requirements:** [FR-XXX, FR-YYY]

---

### Component: Data Access Layer
**Purpose:** Database operations and data persistence
**Responsibilities:**
- CRUD operations
- Query optimization
- Transaction management
**Technology:** SQLAlchemy ORM
**Location:** `src/repositories/`
**Related Requirements:** [FR-XXX, NFR-XXX]

[Continue for all major components]

## Data Architecture

### Entity-Relationship Diagram
[ASCII or description]

### Entity: User
**Purpose:** Represents system users (from FR-001)
**Attributes:**
| Attribute | Type | Constraints | Purpose |
|-----------|------|-------------|---------|
| id | UUID | PK, NOT NULL | Unique identifier |
| email | VARCHAR(255) | UNIQUE, NOT NULL | Login credential |
| password_hash | VARCHAR(255) | NOT NULL | Secure password storage |
| created_at | TIMESTAMP | NOT NULL | Audit trail |

**Relationships:**
- **Has Many:** Sessions (1:N)
**Indexes:**
- Primary: id
- Unique: email (for fast login lookups)
**Related Requirements:** FR-001, FR-002, NFR-002

---

[Continue for all entities]

### Database Schema
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- More tables...
```

## API Design

### RESTful API Endpoints

#### POST /api/v1/users/register
**Purpose:** User registration (FR-001)
**Authentication:** None
**Request:**
```json
{
  "email": "user@example.com",
  "password": "SecurePass123!"
}
```
**Response (201 Created):**
```json
{
  "id": "uuid",
  "email": "user@example.com",
  "created_at": "2025-10-24T12:00:00Z"
}
```
**Errors:**
- 400: Invalid email/password
- 409: Email already exists
**Related Requirements:** FR-001, NFR-002

---

[Continue for all major endpoints]

### API Conventions
- Versioning: URL path (/v1/, /v2/)
- Authentication: JWT Bearer tokens
- Rate Limiting: 100 req/min per user (NFR-001)
- Error Format: RFC 7807 Problem Details

## Security Architecture

### Authentication
**Method:** JWT (JSON Web Tokens)
**Flow:**
1. User submits credentials
2. Server validates, issues JWT (exp: 1 hour)
3. Client includes JWT in Authorization header
4. Server validates JWT on each request

**Implementation:** `src/auth/jwt_handler.py`
**Related Requirements:** NFR-002

### Authorization
**Method:** Role-Based Access Control (RBAC)
**Roles:** Admin, User, Guest
**Implementation:** Decorator-based on endpoints
**Related Requirements:** NFR-002

### Data Protection
- **At Rest:** AES-256 encryption for sensitive fields
- **In Transit:** TLS 1.3 (HTTPS only)
- **Passwords:** bcrypt hashing (cost factor: 12)
**Related Requirements:** NFR-002

## Scalability & Performance

### Performance Targets (from NFR-001)
- API Response: < 200ms (95th percentile)
- DB Queries: < 50ms
- Cache Hit Rate: > 80%

### Scalability Strategy
**Horizontal Scaling:**
- API servers: Auto-scale 2-10 pods
- Trigger: CPU > 70% for 2 minutes

**Caching:**
- Cache: User sessions, frequently accessed data
- TTL: 15 minutes
- Invalidation: On data updates

**Database:**
- Read replicas: 2 replicas for read-heavy operations
- Connection pooling: Max 20 connections per pod
**Related Requirements:** NFR-001, NFR-003

## Deployment Architecture

### Environments
1. **Development:** Local Docker Compose
2. **Staging:** Kubernetes cluster (mirror of prod)
3. **Production:** Kubernetes on AWS EKS

### CI/CD Pipeline
```
Code Push → GitHub Actions →
  Build & Test → Docker Build →
  Push to ECR → Deploy to Staging →
  Manual Approval → Deploy to Production
```

### Infrastructure as Code
**Tool:** Terraform
**Location:** `infrastructure/terraform/`
**Resources:** VPC, EKS cluster, RDS, ElastiCache

## Monitoring & Observability

### Metrics
- **Application:** Prometheus + Grafana
- **Infrastructure:** CloudWatch
- **Key Metrics:**
  - Request rate, error rate, latency (RED metrics)
  - CPU, memory, disk, network

### Logging
- **Tool:** ELK Stack (Elasticsearch, Logstash, Kibana)
- **Levels:** DEBUG, INFO, WARN, ERROR, CRITICAL
- **Retention:** 30 days

### Alerting
- **Critical:** Page on-call (response time > 1s, error rate > 1%)
- **Warning:** Slack notification (response time > 500ms)

## Development Guidelines

### Code Structure
```
project-root/
├── src/
│   ├── api/              # API endpoints (FastAPI routers)
│   ├── services/         # Business logic
│   ├── repositories/     # Data access
│   ├── models/           # SQLAlchemy models
│   ├── schemas/          # Pydantic schemas
│   ├── auth/             # Authentication/authorization
│   └── utils/            # Utilities
├── tests/
│   ├── unit/
│   ├── integration/
│   └── e2e/
├── infrastructure/
│   └── terraform/
└── docs/
```

### Coding Standards
- **Python:** PEP 8, Black formatter, mypy type checking
- **Testing:** pytest, 80%+ coverage
- **Documentation:** Docstrings for all public functions

## Architectural Decisions

### Decision: FastAPI over Flask
**Context:** Need high-performance async API framework
**Options:**
1. Flask - Traditional, synchronous
2. FastAPI - Modern, async, automatic OpenAPI docs
**Decision:** FastAPI
**Rationale:**
- Native async support (NFR-001 performance)
- Automatic API documentation
- Pydantic validation built-in
- Type hints enforced

---

[Document other major decisions]

## Trade-offs

### PostgreSQL vs MongoDB
**Choice:** PostgreSQL
**Trade-offs:**
- ✓ ACID compliance (critical for NFR-004 reliability)
- ✓ Complex queries with JOINs
- ✗ Slightly slower for simple reads vs MongoDB
- ✗ Less flexible schema vs NoSQL
**Justification:** Data integrity more important than flexibility for this use case

## Future Considerations

### Potential Enhancements
- Microservices migration if team grows beyond 10 engineers
- GraphQL layer for complex client queries
- Event-driven architecture for async processing

### Known Limitations
- Monolithic architecture limits independent scaling
- Mitigation: Modular design allows future extraction

## Appendix

### Glossary
- **JWT:** JSON Web Token
- **RBAC:** Role-Based Access Control

### References
- PRD: `docs/prd.md`
- FastAPI Docs: https://fastapi.tiangolo.com
- [Other references]
```

### 5. Apply Best Practices

- Reference specific PRD requirements (FR-XXX, NFR-YYY) throughout
- Justify every major technology decision
- Provide diagrams (ASCII art is fine)
- Include code examples and schemas
- Address ALL NFRs explicitly
- Make architecture implementable - specific, not vague

### 6. Create Memory Entities

Store architecture decisions in Knowledge Graph:
- Create entity for each major technology choice
- Link to NFRs they address
- Create entities for major components
- Store relationships between components
- Link data models to FRs

### 7. Create Todos

Use TodoWrite for next steps:
- "Create stories from Epics (Scrum Master role)"
- "Set up project structure per architecture"

### 8. Confirm Completion

```
✓ Architecture created: docs/architecture.md

Summary:
- Technology Stack: [Languages, frameworks]
- Pattern: [Architecture pattern]
- Components: X major components
- Data Models: Y entities
- API Endpoints: Z endpoints

All NFRs addressed:
- NFR-001 Performance: ✓ Caching + async design
- NFR-002 Security: ✓ JWT auth + encryption
- NFR-003 Scalability: ✓ Horizontal scaling design
[... more ...]

Next Steps:
1. Scrum Master role: Create detailed stories (`/bmad-story`)
2. Set up project structure matching this architecture

Ready to create stories?
```

## Important

- This architecture is THE source of truth for ALL technical decisions
- Never implement code that contradicts this architecture
- When creating stories, reference specific sections
- When implementing, follow patterns defined here
- Architecture should be detailed enough that any developer can implement consistently
- Every decision should trace back to a PRD requirement
