# Testing Excellence Skill

## Overview

This skill provides comprehensive guidance for testing practices across unit testing, integration testing, end-to-end testing, and test-driven development.

## Testing Philosophy

### Testing Pyramid

```
        /\
       /  \     E2E Tests (Few)
      /____\    - Slow
     /      \   - Expensive
    / Integr \  - Brittle
   /  ation   \
  /____________\
 /              \  Unit Tests (Many)
/________________\ - Fast
                   - Cheap
                   - Stable
```

**Guidelines:**
- **70% Unit Tests** - Fast, isolated, test single units
- **20% Integration Tests** - Test component interactions
- **10% E2E Tests** - Test complete user workflows

### Test Characteristics (F.I.R.S.T.)

- **Fast** - Tests should run quickly
- **Independent** - Tests don't depend on each other
- **Repeatable** - Same result every time
- **Self-Validating** - Pass/fail, no manual checking
- **Timely** - Written at the right time (TDD: before code)

## Unit Testing

### Jest (JavaScript/TypeScript)

```typescript
// user.test.ts
import { User } from './user';
import { UserService } from './userService';

describe('User', () => {
    describe('constructor', () => {
        it('should create user with valid data', () => {
            const user = new User('Alice', 'alice@example.com');
            
            expect(user.name).toBe('Alice');
            expect(user.email).toBe('alice@example.com');
            expect(user.createdAt).toBeInstanceOf(Date);
        });
        
        it('should throw error for invalid email', () => {
            expect(() => new User('Bob', 'invalid-email'))
                .toThrow('Invalid email format');
        });
        
        it('should normalize name to title case', () => {
            const user = new User('alice smith', 'alice@example.com');
            expect(user.name).toBe('Alice Smith');
        });
    });
    
    describe('updateEmail', () => {
        let user: User;
        
        beforeEach(() => {
            user = new User('Alice', 'alice@example.com');
        });
        
        it('should update email with valid input', () => {
            user.updateEmail('newemail@example.com');
            expect(user.email).toBe('newemail@example.com');
        });
        
        it('should not update with invalid email', () => {
            expect(() => user.updateEmail('invalid'))
                .toThrow('Invalid email format');
            expect(user.email).toBe('alice@example.com');
        });
    });
});

// Mocking
describe('UserService', () => {
    let service: UserService;
    let mockRepository: jest.Mocked<UserRepository>;
    
    beforeEach(() => {
        mockRepository = {
            findById: jest.fn(),
            save: jest.fn(),
            delete: jest.fn(),
        } as any;
        
        service = new UserService(mockRepository);
    });
    
    afterEach(() => {
        jest.clearAllMocks();
    });
    
    describe('getUser', () => {
        it('should return user when found', async () => {
            const mockUser = { id: 1, name: 'Alice', email: 'alice@example.com' };
            mockRepository.findById.mockResolvedValue(mockUser);
            
            const result = await service.getUser(1);
            
            expect(result).toEqual(mockUser);
            expect(mockRepository.findById).toHaveBeenCalledWith(1);
            expect(mockRepository.findById).toHaveBeenCalledTimes(1);
        });
        
        it('should return null when user not found', async () => {
            mockRepository.findById.mockResolvedValue(null);
            
            const result = await service.getUser(999);
            
            expect(result).toBeNull();
        });
        
        it('should handle repository errors', async () => {
            mockRepository.findById.mockRejectedValue(
                new Error('Database connection failed')
            );
            
            await expect(service.getUser(1))
                .rejects.toThrow('Database connection failed');
        });
    });
});

// Async testing
describe('async operations', () => {
    it('should fetch user data', async () => {
        const user = await fetchUser(1);
        expect(user.name).toBe('Alice');
    });
    
    it('should handle fetch errors', async () => {
        await expect(fetchUser(999))
            .rejects.toThrow('User not found');
    });
});

// Snapshot testing
describe('UserCard component', () => {
    it('should match snapshot', () => {
        const user = { id: 1, name: 'Alice', email: 'alice@example.com' };
        const tree = renderer.create(<UserCard user={user} />).toJSON();
        expect(tree).toMatchSnapshot();
    });
});
```

### pytest (Python)

```python
# test_user.py
import pytest
from datetime import datetime
from user import User, UserService, UserNotFoundError

class TestUser:
    """Test User model."""
    
    def test_create_user_with_valid_data(self):
        """Should create user with valid data."""
        user = User(name="Alice", email="alice@example.com")
        
        assert user.name == "Alice"
        assert user.email == "alice@example.com"
        assert isinstance(user.created_at, datetime)
    
    def test_invalid_email_raises_error(self):
        """Should raise ValueError for invalid email."""
        with pytest.raises(ValueError, match="Invalid email"):
            User(name="Bob", email="invalid-email")
    
    def test_name_normalized_to_title_case(self):
        """Should normalize name to title case."""
        user = User(name="alice smith", email="alice@example.com")
        assert user.name == "Alice Smith"


class TestUserService:
    """Test UserService."""
    
    @pytest.fixture
    def mock_repository(self, mocker):
        """Create mock repository."""
        return mocker.Mock()
    
    @pytest.fixture
    def service(self, mock_repository):
        """Create service with mock repository."""
        return UserService(mock_repository)
    
    def test_get_user_when_found(self, service, mock_repository):
        """Should return user when found."""
        mock_user = User(id=1, name="Alice", email="alice@example.com")
        mock_repository.find_by_id.return_value = mock_user
        
        result = service.get_user(1)
        
        assert result == mock_user
        mock_repository.find_by_id.assert_called_once_with(1)
    
    def test_get_user_when_not_found(self, service, mock_repository):
        """Should raise UserNotFoundError when user not found."""
        mock_repository.find_by_id.return_value = None
        
        with pytest.raises(UserNotFoundError):
            service.get_user(999)
    
    @pytest.mark.asyncio
    async def test_async_operation(self, service):
        """Should handle async operations."""
        result = await service.fetch_user_async(1)
        assert result is not None


# Parametrized tests
@pytest.mark.parametrize("input,expected", [
    ("alice@example.com", True),
    ("bob@test.co.uk", True),
    ("invalid", False),
    ("@example.com", False),
    ("user@", False),
])
def test_email_validation(input, expected):
    """Should validate email addresses correctly."""
    assert is_valid_email(input) == expected


# Fixtures with scope
@pytest.fixture(scope="session")
def database():
    """Create database for entire test session."""
    db = create_test_database()
    yield db
    db.cleanup()


@pytest.fixture(scope="function")
def user(database):
    """Create user for each test."""
    user = database.create_user("Alice", "alice@example.com")
    yield user
    database.delete_user(user.id)


# Property-based testing with Hypothesis
from hypothesis import given, strategies as st

@given(st.lists(st.integers()))
def test_sort_idempotent(lst):
    """Sorting should be idempotent."""
    sorted_once = sorted(lst)
    sorted_twice = sorted(sorted_once)
    assert sorted_once == sorted_twice

@given(
    st.integers(min_value=0, max_value=100),
    st.integers(min_value=0, max_value=100)
)
def test_addition_commutative(a, b):
    """Addition should be commutative."""
    assert a + b == b + a
```

## Integration Testing

### Database Integration

```python
# test_user_repository.py
import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from models import Base, User
from repositories import UserRepository

@pytest.fixture(scope="module")
def engine():
    """Create test database engine."""
    engine = create_engine("postgresql://test:test@localhost/test_db")
    Base.metadata.create_all(engine)
    yield engine
    Base.metadata.drop_all(engine)

@pytest.fixture(scope="function")
def db_session(engine):
    """Create database session for each test."""
    Session = sessionmaker(bind=engine)
    session = Session()
    yield session
    session.rollback()
    session.close()

@pytest.fixture
def repository(db_session):
    """Create repository instance."""
    return UserRepository(db_session)

class TestUserRepository:
    """Integration tests for UserRepository."""
    
    def test_save_and_retrieve_user(self, repository):
        """Should save and retrieve user from database."""
        user = User(name="Alice", email="alice@example.com")
        
        # Save
        saved_user = repository.save(user)
        assert saved_user.id is not None
        
        # Retrieve
        retrieved = repository.find_by_id(saved_user.id)
        assert retrieved is not None
        assert retrieved.name == "Alice"
        assert retrieved.email == "alice@example.com"
    
    def test_update_user(self, repository):
        """Should update existing user."""
        user = repository.save(User(name="Alice", email="alice@example.com"))
        
        user.email = "newemail@example.com"
        updated = repository.save(user)
        
        retrieved = repository.find_by_id(user.id)
        assert retrieved.email == "newemail@example.com"
    
    def test_delete_user(self, repository):
        """Should delete user from database."""
        user = repository.save(User(name="Alice", email="alice@example.com"))
        user_id = user.id
        
        repository.delete(user_id)
        
        retrieved = repository.find_by_id(user_id)
        assert retrieved is None
    
    def test_find_by_email(self, repository):
        """Should find user by email."""
        repository.save(User(name="Alice", email="alice@example.com"))
        
        user = repository.find_by_email("alice@example.com")
        
        assert user is not None
        assert user.name == "Alice"
```

### API Integration Testing

```typescript
// user.integration.test.ts
import request from 'supertest';
import { app } from '../app';
import { connectDatabase, clearDatabase, closeDatabase } from './testDb';

describe('User API Integration Tests', () => {
    beforeAll(async () => {
        await connectDatabase();
    });
    
    afterAll(async () => {
        await closeDatabase();
    });
    
    beforeEach(async () => {
        await clearDatabase();
    });
    
    describe('POST /api/users', () => {
        it('should create new user', async () => {
            const userData = {
                name: 'Alice',
                email: 'alice@example.com',
                password: 'SecurePassword123!'
            };
            
            const response = await request(app)
                .post('/api/users')
                .send(userData)
                .expect(201);
            
            expect(response.body).toMatchObject({
                id: expect.any(Number),
                name: 'Alice',
                email: 'alice@example.com'
            });
            expect(response.body).not.toHaveProperty('password');
        });
        
        it('should reject invalid email', async () => {
            const response = await request(app)
                .post('/api/users')
                .send({
                    name: 'Bob',
                    email: 'invalid-email',
                    password: 'Password123!'
                })
                .expect(400);
            
            expect(response.body).toHaveProperty('error');
            expect(response.body.error).toContain('email');
        });
        
        it('should reject duplicate email', async () => {
            const userData = {
                name: 'Alice',
                email: 'alice@example.com',
                password: 'Password123!'
            };
            
            await request(app).post('/api/users').send(userData);
            
            const response = await request(app)
                .post('/api/users')
                .send(userData)
                .expect(409);
            
            expect(response.body.error).toContain('already exists');
        });
    });
    
    describe('GET /api/users/:id', () => {
        it('should retrieve user by id', async () => {
            const createResponse = await request(app)
                .post('/api/users')
                .send({
                    name: 'Alice',
                    email: 'alice@example.com',
                    password: 'Password123!'
                });
            
            const userId = createResponse.body.id;
            
            const response = await request(app)
                .get(`/api/users/${userId}`)
                .expect(200);
            
            expect(response.body).toMatchObject({
                id: userId,
                name: 'Alice',
                email: 'alice@example.com'
            });
        });
        
        it('should return 404 for non-existent user', async () => {
            await request(app)
                .get('/api/users/999999')
                .expect(404);
        });
    });
    
    describe('Authentication', () => {
        let authToken: string;
        
        beforeEach(async () => {
            // Create user
            await request(app)
                .post('/api/users')
                .send({
                    name: 'Alice',
                    email: 'alice@example.com',
                    password: 'Password123!'
                });
            
            // Login to get token
            const loginResponse = await request(app)
                .post('/api/auth/login')
                .send({
                    email: 'alice@example.com',
                    password: 'Password123!'
                });
            
            authToken = loginResponse.body.token;
        });
        
        it('should access protected route with valid token', async () => {
            await request(app)
                .get('/api/protected')
                .set('Authorization', `Bearer ${authToken}`)
                .expect(200);
        });
        
        it('should reject access without token', async () => {
            await request(app)
                .get('/api/protected')
                .expect(401);
        });
        
        it('should reject access with invalid token', async () => {
            await request(app)
                .get('/api/protected')
                .set('Authorization', 'Bearer invalid-token')
                .expect(401);
        });
    });
});
```

## End-to-End Testing

### Playwright

```typescript
// user-flow.e2e.test.ts
import { test, expect } from '@playwright/test';

test.describe('User Registration and Login Flow', () => {
    test.beforeEach(async ({ page }) => {
        await page.goto('http://localhost:3000');
    });
    
    test('should complete full user journey', async ({ page }) => {
        // Registration
        await page.click('text=Sign Up');
        await page.fill('input[name="name"]', 'Alice Smith');
        await page.fill('input[name="email"]', 'alice@example.com');
        await page.fill('input[name="password"]', 'SecurePassword123!');
        await page.click('button[type="submit"]');
        
        // Wait for redirect and success message
        await expect(page).toHaveURL('/dashboard');
        await expect(page.locator('text=Welcome, Alice')).toBeVisible();
        
        // Logout
        await page.click('button:has-text("Logout")');
        await expect(page).toHaveURL('/');
        
        // Login
        await page.click('text=Login');
        await page.fill('input[name="email"]', 'alice@example.com');
        await page.fill('input[name="password"]', 'SecurePassword123!');
        await page.click('button[type="submit"]');
        
        // Verify dashboard access
        await expect(page).toHaveURL('/dashboard');
        await expect(page.locator('text=Welcome, Alice')).toBeVisible();
    });
    
    test('should show validation errors', async ({ page }) => {
        await page.click('text=Sign Up');
        await page.click('button[type="submit"]');
        
        await expect(page.locator('text=Name is required')).toBeVisible();
        await expect(page.locator('text=Email is required')).toBeVisible();
        await expect(page.locator('text=Password is required')).toBeVisible();
    });
    
    test('should handle network errors gracefully', async ({ page }) => {
        // Simulate offline
        await page.context().setOffline(true);
        
        await page.click('text=Sign Up');
        await page.fill('input[name="name"]', 'Alice');
        await page.fill('input[name="email"]', 'alice@example.com');
        await page.fill('input[name="password"]', 'Password123!');
        await page.click('button[type="submit"]');
        
        await expect(page.locator('text=Network error')).toBeVisible();
    });
});

// Visual regression testing
test('should match visual snapshot', async ({ page }) => {
    await page.goto('http://localhost:3000');
    await expect(page).toHaveScreenshot('homepage.png');
});

// Mobile testing
test.use({ viewport: { width: 375, height: 667 } });

test('should work on mobile', async ({ page }) => {
    await page.goto('http://localhost:3000');
    
    // Click mobile menu
    await page.click('[aria-label="Menu"]');
    await expect(page.locator('nav')).toBeVisible();
});

// Performance testing
test('should load within performance budget', async ({ page }) => {
    const startTime = Date.now();
    await page.goto('http://localhost:3000');
    await page.waitForLoadState('networkidle');
    const loadTime = Date.now() - startTime;
    
    expect(loadTime).toBeLessThan(3000); // 3 second budget
});
```

### Cypress

```typescript
// cypress/e2e/user-flow.cy.ts
describe('User Flow', () => {
    beforeEach(() => {
        cy.visit('/');
    });
    
    it('should complete registration and login', () => {
        // Register
        cy.contains('Sign Up').click();
        cy.get('input[name="name"]').type('Alice Smith');
        cy.get('input[name="email"]').type('alice@example.com');
        cy.get('input[name="password"]').type('SecurePassword123!');
        cy.get('button[type="submit"]').click();
        
        // Verify dashboard
        cy.url().should('include', '/dashboard');
        cy.contains('Welcome, Alice').should('be.visible');
        
        // Logout
        cy.contains('Logout').click();
        cy.url().should('eq', Cypress.config().baseUrl + '/');
        
        // Login
        cy.contains('Login').click();
        cy.get('input[name="email"]').type('alice@example.com');
        cy.get('input[name="password"]').type('SecurePassword123!');
        cy.get('button[type="submit"]').click();
        
        // Verify dashboard
        cy.url().should('include', '/dashboard');
    });
    
    it('should handle API errors', () => {
        // Intercept and mock error
        cy.intercept('POST', '/api/users', {
            statusCode: 500,
            body: { error: 'Server error' }
        });
        
        cy.contains('Sign Up').click();
        cy.get('input[name="name"]').type('Alice');
        cy.get('input[name="email"]').type('alice@example.com');
        cy.get('input[name="password"]').type('Password123!');
        cy.get('button[type="submit"]').click();
        
        cy.contains('Server error').should('be.visible');
    });
    
    // Custom commands
    Cypress.Commands.add('login', (email: string, password: string) => {
        cy.visit('/login');
        cy.get('input[name="email"]').type(email);
        cy.get('input[name="password"]').type(password);
        cy.get('button[type="submit"]').click();
        cy.url().should('include', '/dashboard');
    });
    
    it('should use custom login command', () => {
        cy.login('alice@example.com', 'Password123!');
        cy.contains('Welcome').should('be.visible');
    });
});
```

## Test-Driven Development (TDD)

### Red-Green-Refactor Cycle

```typescript
// 1. RED - Write failing test first
describe('Calculator', () => {
    it('should add two numbers', () => {
        const calc = new Calculator();
        expect(calc.add(2, 3)).toBe(5);
    });
});

// 2. GREEN - Write minimum code to pass
class Calculator {
    add(a: number, b: number): number {
        return a + b;
    }
}

// 3. REFACTOR - Improve code while keeping tests green
class Calculator {
    add(...numbers: number[]): number {
        return numbers.reduce((sum, num) => sum + num, 0);
    }
}

// Add more tests
describe('Calculator', () => {
    let calc: Calculator;
    
    beforeEach(() => {
        calc = new Calculator();
    });
    
    describe('add', () => {
        it('should add two numbers', () => {
            expect(calc.add(2, 3)).toBe(5);
        });
        
        it('should add multiple numbers', () => {
            expect(calc.add(1, 2, 3, 4)).toBe(10);
        });
        
        it('should return 0 for no arguments', () => {
            expect(calc.add()).toBe(0);
        });
        
        it('should handle negative numbers', () => {
            expect(calc.add(-5, 3)).toBe(-2);
        });
    });
});
```

## Test Doubles

### Mocks, Stubs, Spies

```typescript
// Stub - Provides canned answers
const stubUserRepository = {
    findById: () => Promise.resolve({
        id: 1,
        name: 'Alice',
        email: 'alice@example.com'
    })
};

// Mock - Pre-programmed with expectations
const mockUserRepository = {
    findById: jest.fn().mockResolvedValue({
        id: 1,
        name: 'Alice',
        email: 'alice@example.com'
    }),
    save: jest.fn().mockResolvedValue(true)
};

// Verify interactions
expect(mockUserRepository.findById).toHaveBeenCalledWith(1);
expect(mockUserRepository.save).toHaveBeenCalledTimes(1);

// Spy - Wraps real object, records interactions
const service = new UserService(realRepository);
const spy = jest.spyOn(service, 'getUser');

await service.getUser(1);

expect(spy).toHaveBeenCalledWith(1);
spy.mockRestore();

// Fake - Working implementation, but simplified
class FakeUserRepository {
    private users = new Map<number, User>();
    private nextId = 1;
    
    async save(user: User): Promise<User> {
        if (!user.id) {
            user.id = this.nextId++;
        }
        this.users.set(user.id, user);
        return user;
    }
    
    async findById(id: number): Promise<User | null> {
        return this.users.get(id) || null;
    }
}
```

## Code Coverage

### Coverage Configuration

```json
// jest.config.js
module.exports = {
  collectCoverage: true,
  coverageDirectory: 'coverage',
  coverageReporters: ['text', 'lcov', 'html'],
  collectCoverageFrom: [
    'src/**/*.{js,ts}',
    '!src/**/*.test.{js,ts}',
    '!src/**/*.spec.{js,ts}',
    '!src/index.ts',
    '!src/**/*.d.ts'
  ],
  coverageThresholds: {
    global: {
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80
    }
  }
};
```

### Coverage Goals

- **Statements**: 80%+ (every statement executed)
- **Branches**: 80%+ (every conditional path)
- **Functions**: 80%+ (every function called)
- **Lines**: 80%+ (every line executed)

**Focus on meaningful coverage, not just numbers:**
- Test business logic thoroughly
- Test error paths and edge cases
- Don't test trivial code
- Don't test third-party libraries

## Testing Best Practices

### Test Structure (AAA Pattern)

```typescript
test('should update user email', async () => {
    // Arrange - Set up test data and dependencies
    const user = new User('Alice', 'alice@example.com');
    const newEmail = 'newemail@example.com';
    
    // Act - Perform the action being tested
    await user.updateEmail(newEmail);
    
    // Assert - Verify the expected outcome
    expect(user.email).toBe(newEmail);
});
```

### Test Naming

```typescript
// ✅ GOOD - Describes what and why
test('should reject login with invalid password', () => {});
test('should create user with valid data', () => {});
test('should return 404 when user not found', () => {});

// ❌ BAD - Vague or implementation-focused
test('test1', () => {});
test('it works', () => {});
test('testUserCreation', () => {});
```

### One Assertion Per Test (Generally)

```typescript
// ✅ GOOD - Focused test
test('should set user name', () => {
    const user = new User('Alice', 'alice@example.com');
    expect(user.name).toBe('Alice');
});

test('should set user email', () => {
    const user = new User('Alice', 'alice@example.com');
    expect(user.email).toBe('alice@example.com');
});

// ⚠️ ACCEPTABLE - Related assertions
test('should create user with valid data', () => {
    const user = new User('Alice', 'alice@example.com');
    expect(user.name).toBe('Alice');
    expect(user.email).toBe('alice@example.com');
    expect(user.createdAt).toBeInstanceOf(Date);
});

// ❌ BAD - Testing multiple behaviors
test('user operations', () => {
    const user = new User('Alice', 'alice@example.com');
    expect(user.name).toBe('Alice');
    
    user.updateEmail('new@example.com');
    expect(user.email).toBe('new@example.com');
    
    user.delete();
    expect(user.isDeleted).toBe(true);
});
```

### Test Independence

```typescript
// ❌ BAD - Tests depend on each other
let user: User;

test('create user', () => {
    user = new User('Alice', 'alice@example.com');
    expect(user).toBeDefined();
});

test('update user', () => {
    user.updateEmail('new@example.com');  // Depends on previous test
    expect(user.email).toBe('new@example.com');
});

// ✅ GOOD - Independent tests
test('should create user', () => {
    const user = new User('Alice', 'alice@example.com');
    expect(user).toBeDefined();
});

test('should update user email', () => {
    const user = new User('Alice', 'alice@example.com');
    user.updateEmail('new@example.com');
    expect(user.email).toBe('new@example.com');
});
```

### Avoid Test Logic

```typescript
// ❌ BAD - Conditional logic in test
test('should validate users', () => {
    const users = getUsers();
    
    if (users.length > 0) {
        expect(users[0].name).toBeDefined();
    }
});

// ✅ GOOD - Clear, unconditional assertions
test('should return users with names', () => {
    const users = getUsers();
    
    expect(users.length).toBeGreaterThan(0);
    expect(users[0].name).toBeDefined();
});
```

### Test Data Builders

```typescript
// Test data builder pattern
class UserBuilder {
    private name = 'Test User';
    private email = 'test@example.com';
    private age = 30;
    private role = 'user';
    
    withName(name: string): this {
        this.name = name;
        return this;
    }
    
    withEmail(email: string): this {
        this.email = email;
        return this;
    }
    
    withAge(age: number): this {
        this.age = age;
        return this;
    }
    
    asAdmin(): this {
        this.role = 'admin';
        return this;
    }
    
    build(): User {
        return new User({
            name: this.name,
            email: this.email,
            age: this.age,
            role: this.role
        });
    }
}

// Usage
test('should process admin users', () => {
    const admin = new UserBuilder()
        .withName('Alice')
        .asAdmin()
        .build();
    
    expect(processUser(admin)).toBe('admin-processed');
});
```

## Performance Testing

### Load Testing with k6

```javascript
// load-test.js
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
    stages: [
        { duration: '1m', target: 50 },  // Ramp up to 50 users
        { duration: '3m', target: 50 },  // Stay at 50 users
        { duration: '1m', target: 100 }, // Ramp up to 100 users
        { duration: '3m', target: 100 }, // Stay at 100 users
        { duration: '1m', target: 0 },   // Ramp down
    ],
    thresholds: {
        http_req_duration: ['p(95)<500'], // 95% of requests under 500ms
        http_req_failed: ['rate<0.01'],   // Error rate under 1%
    },
};

export default function () {
    const res = http.get('https://api.example.com/users');
    
    check(res, {
        'status is 200': (r) => r.status === 200,
        'response time < 500ms': (r) => r.timings.duration < 500,
    });
    
    sleep(1);
}
```

## Conclusion

Testing excellence requires:
- Comprehensive test coverage (unit, integration, e2e)
- Test-driven development practices
- Fast, independent, repeatable tests
- Meaningful assertions and clear naming
- Proper use of test doubles
- Regular execution in CI/CD
- Performance and load testing
- Continuous improvement

**Remember:** Tests are documentation. Write them for humans to read and understand.
