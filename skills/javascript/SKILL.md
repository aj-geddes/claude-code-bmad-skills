# JavaScript/TypeScript Development Excellence Skill

## Overview

This skill provides comprehensive guidance for modern JavaScript (ES6+) and TypeScript development, covering best practices, patterns, and professional development standards.

## Modern JavaScript (ES6+)

### Variable Declarations

```javascript
// ❌ Avoid var - function-scoped and hoisted
var x = 10;

// ✅ Use const for values that won't be reassigned
const API_URL = 'https://api.example.com';
const user = { name: 'Alice' };  // Object itself is const, properties can change

// ✅ Use let for values that will be reassigned
let counter = 0;
counter += 1;

// Block scoping
{
    const blockScoped = 'only available here';
    let alsoBlockScoped = 'me too';
}
// console.log(blockScoped);  // ReferenceError
```

### Arrow Functions

```javascript
// Traditional function
function add(a, b) {
    return a + b;
}

// Arrow function
const add = (a, b) => a + b;

// Multiple lines
const processUser = (user) => {
    const validated = validate(user);
    return transform(validated);
};

// No parameters
const greet = () => console.log('Hello!');

// Single parameter (parentheses optional)
const square = x => x * x;

// Arrow functions don't bind their own 'this'
class Timer {
    constructor() {
        this.seconds = 0;
    }
    
    start() {
        // ✅ Arrow function preserves 'this'
        setInterval(() => {
            this.seconds++;
            console.log(this.seconds);
        }, 1000);
        
        // ❌ Regular function would lose 'this'
        // setInterval(function() {
        //     this.seconds++;  // 'this' is undefined
        // }, 1000);
    }
}
```

### Template Literals

```javascript
// String interpolation
const name = 'Alice';
const greeting = `Hello, ${name}!`;

// Multi-line strings
const html = `
    <div class="user">
        <h2>${user.name}</h2>
        <p>${user.email}</p>
    </div>
`;

// Expression evaluation
const price = 29.99;
const message = `Total: $${(price * 1.1).toFixed(2)}`;

// Tagged template literals
function sql(strings, ...values) {
    // Custom processing
    return {
        text: strings.reduce((acc, str, i) => 
            acc + str + (values[i] ? '$' + (i + 1) : ''), ''
        ),
        values
    };
}

const userId = 42;
const query = sql`SELECT * FROM users WHERE id = ${userId}`;
// { text: 'SELECT * FROM users WHERE id = $1', values: [42] }
```

### Destructuring

```javascript
// Array destructuring
const [first, second, ...rest] = [1, 2, 3, 4, 5];
// first = 1, second = 2, rest = [3, 4, 5]

// Skip elements
const [, , third] = [1, 2, 3];

// Default values
const [a = 10, b = 20] = [5];
// a = 5, b = 20

// Object destructuring
const user = { name: 'Alice', age: 30, email: 'alice@example.com' };
const { name, age } = user;

// Rename variables
const { name: userName, age: userAge } = user;

// Nested destructuring
const { address: { city, country } } = user;

// Default values
const { role = 'user' } = user;

// Function parameters
function greet({ name, age }) {
    console.log(`${name} is ${age} years old`);
}

greet({ name: 'Bob', age: 25 });

// Rest properties
const { name, ...otherProps } = user;
```

### Spread Operator

```javascript
// Array spreading
const arr1 = [1, 2, 3];
const arr2 = [4, 5, 6];
const combined = [...arr1, ...arr2];

// Copy array
const original = [1, 2, 3];
const copy = [...original];

// Object spreading
const defaults = { theme: 'dark', language: 'en' };
const userPrefs = { language: 'fr' };
const config = { ...defaults, ...userPrefs };
// { theme: 'dark', language: 'fr' }

// Clone object (shallow)
const obj = { a: 1, b: 2 };
const clone = { ...obj };

// Function arguments
function sum(a, b, c) {
    return a + b + c;
}

const numbers = [1, 2, 3];
sum(...numbers);  // 6
```

### Enhanced Object Literals

```javascript
const name = 'Alice';
const age = 30;

// Shorthand property names
const user = {
    name,     // Instead of name: name
    age,      // Instead of age: age
    
    // Method shorthand
    greet() {
        console.log(`Hello, I'm ${this.name}`);
    },
    
    // Computed property names
    [`role_${Date.now()}`]: 'admin',
    
    // Dynamic keys
    [Symbol.iterator]: function*() {
        yield this.name;
        yield this.age;
    }
};
```

### Classes

```javascript
class User {
    // Private fields (ES2022)
    #password;
    
    // Public fields
    role = 'user';
    
    // Static fields
    static instances = 0;
    
    constructor(name, email, password) {
        this.name = name;
        this.email = email;
        this.#password = password;
        User.instances++;
    }
    
    // Instance method
    greet() {
        console.log(`Hello, ${this.name}`);
    }
    
    // Getter
    get displayName() {
        return this.name.toUpperCase();
    }
    
    // Setter
    set displayName(value) {
        this.name = value;
    }
    
    // Private method
    #validatePassword(password) {
        return password.length >= 8;
    }
    
    // Static method
    static create(data) {
        return new User(data.name, data.email, data.password);
    }
}

// Inheritance
class Admin extends User {
    constructor(name, email, password) {
        super(name, email, password);
        this.role = 'admin';
    }
    
    // Override method
    greet() {
        console.log(`Hello, Admin ${this.name}`);
    }
}
```

### Async/Await

```javascript
// Promise-based
function fetchUser(id) {
    return fetch(`/api/users/${id}`)
        .then(response => response.json())
        .then(user => {
            console.log(user);
            return user;
        })
        .catch(error => {
            console.error('Error:', error);
            throw error;
        });
}

// Async/await
async function fetchUser(id) {
    try {
        const response = await fetch(`/api/users/${id}`);
        const user = await response.json();
        console.log(user);
        return user;
    } catch (error) {
        console.error('Error:', error);
        throw error;
    }
}

// Parallel execution
async function fetchMultipleUsers(ids) {
    // All requests happen in parallel
    const promises = ids.map(id => fetch(`/api/users/${id}`));
    const responses = await Promise.all(promises);
    const users = await Promise.all(responses.map(r => r.json()));
    return users;
}

// Sequential execution
async function processUsersSequentially(ids) {
    const users = [];
    for (const id of ids) {
        const user = await fetchUser(id);  // Waits for each
        users.push(user);
    }
    return users;
}

// Error handling with Promise.allSettled
async function fetchWithResults(urls) {
    const results = await Promise.allSettled(
        urls.map(url => fetch(url))
    );
    
    const successful = results.filter(r => r.status === 'fulfilled');
    const failed = results.filter(r => r.status === 'rejected');
    
    return { successful, failed };
}
```

### Modules

```javascript
// Export
// user.js
export class User {
    constructor(name) {
        this.name = name;
    }
}

export function createUser(name) {
    return new User(name);
}

export const DEFAULT_ROLE = 'user';

// Default export
export default class UserManager {
    // ...
}

// Import
// app.js
import UserManager, { User, createUser, DEFAULT_ROLE } from './user.js';

// Import all
import * as userModule from './user.js';
userModule.createUser('Alice');

// Dynamic import
async function loadModule() {
    const module = await import('./user.js');
    const user = module.createUser('Bob');
}

// Re-export
// index.js
export { User, createUser } from './user.js';
export { Admin } from './admin.js';
```

## TypeScript

### Type Annotations

```typescript
// Basic types
let name: string = 'Alice';
let age: number = 30;
let isActive: boolean = true;
let nothing: null = null;
let notDefined: undefined = undefined;

// Arrays
let numbers: number[] = [1, 2, 3];
let strings: Array<string> = ['a', 'b', 'c'];

// Tuples
let tuple: [string, number] = ['Alice', 30];

// Objects
let user: { name: string; age: number } = {
    name: 'Alice',
    age: 30
};

// Functions
function add(a: number, b: number): number {
    return a + b;
}

const multiply = (a: number, b: number): number => a * b;

// Optional parameters
function greet(name: string, title?: string): string {
    return title ? `Hello, ${title} ${name}` : `Hello, ${name}`;
}

// Default parameters
function createUser(name: string, role: string = 'user') {
    return { name, role };
}

// Rest parameters
function sum(...numbers: number[]): number {
    return numbers.reduce((acc, n) => acc + n, 0);
}

// Void return type
function logMessage(message: string): void {
    console.log(message);
}

// Never return type (functions that never return)
function throwError(message: string): never {
    throw new Error(message);
}
```

### Interfaces and Types

```typescript
// Interface
interface User {
    id: number;
    name: string;
    email: string;
    age?: number;  // Optional property
    readonly createdAt: Date;  // Read-only
}

// Extending interfaces
interface Admin extends User {
    permissions: string[];
}

// Type alias
type UserID = number | string;

type User = {
    id: UserID;
    name: string;
    email: string;
};

// Union types
type Status = 'pending' | 'approved' | 'rejected';
type Result = User | Error;

// Intersection types
type Timestamped = {
    createdAt: Date;
    updatedAt: Date;
};

type TimestampedUser = User & Timestamped;

// Function types
type Validator = (value: string) => boolean;
type AsyncFetcher<T> = (id: number) => Promise<T>;

// Generic types
type Response<T> = {
    data: T;
    error?: string;
};

interface Repository<T> {
    findById(id: number): Promise<T | null>;
    save(entity: T): Promise<T>;
    delete(id: number): Promise<void>;
}

class UserRepository implements Repository<User> {
    async findById(id: number): Promise<User | null> {
        // Implementation
        return null;
    }
    
    async save(user: User): Promise<User> {
        // Implementation
        return user;
    }
    
    async delete(id: number): Promise<void> {
        // Implementation
    }
}
```

### Advanced Types

```typescript
// Utility types

// Partial - Make all properties optional
type PartialUser = Partial<User>;

// Required - Make all properties required
type RequiredUser = Required<User>;

// Readonly - Make all properties readonly
type ReadonlyUser = Readonly<User>;

// Pick - Select specific properties
type UserPreview = Pick<User, 'id' | 'name'>;

// Omit - Exclude specific properties
type UserWithoutEmail = Omit<User, 'email'>;

// Record - Create object type with specific keys and value types
type UserRoles = Record<string, string[]>;
// { [key: string]: string[] }

// Mapped types
type Nullable<T> = {
    [P in keyof T]: T[P] | null;
};

type NullableUser = Nullable<User>;

// Conditional types
type IsArray<T> = T extends any[] ? true : false;

type Check1 = IsArray<number[]>;  // true
type Check2 = IsArray<string>;    // false

// Template literal types
type EmailLocale = 'en' | 'fr' | 'de';
type EmailId = `${EmailLocale}_${string}`;

const emailId: EmailId = 'en_welcome';  // Valid
// const invalid: EmailId = 'es_welcome';  // Error

// Type guards
function isUser(obj: any): obj is User {
    return 'name' in obj && 'email' in obj;
}

function processData(data: User | Admin) {
    if (isUser(data)) {
        // TypeScript knows data is User here
        console.log(data.name);
    }
}

// Discriminated unions
type Shape =
    | { kind: 'circle'; radius: number }
    | { kind: 'square'; size: number }
    | { kind: 'rectangle'; width: number; height: number };

function getArea(shape: Shape): number {
    switch (shape.kind) {
        case 'circle':
            return Math.PI * shape.radius ** 2;
        case 'square':
            return shape.size ** 2;
        case 'rectangle':
            return shape.width * shape.height;
    }
}
```

### Generics

```typescript
// Generic function
function identity<T>(value: T): T {
    return value;
}

const num = identity<number>(42);
const str = identity('hello');  // Type inferred

// Generic with constraints
interface HasLength {
    length: number;
}

function getLength<T extends HasLength>(item: T): number {
    return item.length;
}

getLength('hello');      // OK
getLength([1, 2, 3]);    // OK
// getLength(42);        // Error: number doesn't have length

// Generic class
class DataStore<T> {
    private data: T[] = [];
    
    add(item: T): void {
        this.data.push(item);
    }
    
    get(index: number): T | undefined {
        return this.data[index];
    }
    
    filter(predicate: (item: T) => boolean): T[] {
        return this.data.filter(predicate);
    }
}

const userStore = new DataStore<User>();
userStore.add({ id: 1, name: 'Alice', email: 'alice@example.com' });

// Multiple type parameters
function merge<T, U>(obj1: T, obj2: U): T & U {
    return { ...obj1, ...obj2 };
}

const result = merge({ name: 'Alice' }, { age: 30 });
// result: { name: string; age: number }
```

### Decorators (Experimental)

```typescript
// Enable in tsconfig.json:
// "experimentalDecorators": true

// Class decorator
function logged<T extends { new(...args: any[]): {} }>(constructor: T) {
    return class extends constructor {
        constructor(...args: any[]) {
            super(...args);
            console.log(`Created instance of ${constructor.name}`);
        }
    };
}

@logged
class User {
    constructor(public name: string) {}
}

// Method decorator
function measureTime(
    target: any,
    propertyKey: string,
    descriptor: PropertyDescriptor
) {
    const original = descriptor.value;
    
    descriptor.value = async function(...args: any[]) {
        const start = Date.now();
        const result = await original.apply(this, args);
        const elapsed = Date.now() - start;
        console.log(`${propertyKey} took ${elapsed}ms`);
        return result;
    };
    
    return descriptor;
}

class DataService {
    @measureTime
    async fetchData() {
        // Slow operation
        return data;
    }
}

// Property decorator
function readonly(target: any, propertyKey: string) {
    Object.defineProperty(target, propertyKey, {
        writable: false
    });
}

class Config {
    @readonly
    apiUrl = 'https://api.example.com';
}
```

## React with TypeScript

### Component Types

```typescript
import React, { FC, ReactNode, useState, useEffect } from 'react';

// Props interface
interface UserCardProps {
    user: User;
    onEdit?: (user: User) => void;
    className?: string;
}

// Functional component
const UserCard: FC<UserCardProps> = ({ user, onEdit, className }) => {
    const handleClick = () => {
        onEdit?.(user);
    };
    
    return (
        <div className={className} onClick={handleClick}>
            <h3>{user.name}</h3>
            <p>{user.email}</p>
        </div>
    );
};

// Component with children
interface ContainerProps {
    children: ReactNode;
    title: string;
}

const Container: FC<ContainerProps> = ({ children, title }) => {
    return (
        <div>
            <h2>{title}</h2>
            {children}
        </div>
    );
};

// Hooks with TypeScript
const UserList: FC = () => {
    const [users, setUsers] = useState<User[]>([]);
    const [loading, setLoading] = useState<boolean>(false);
    const [error, setError] = useState<Error | null>(null);
    
    useEffect(() => {
        const fetchUsers = async () => {
            setLoading(true);
            try {
                const response = await fetch('/api/users');
                const data = await response.json();
                setUsers(data);
            } catch (err) {
                setError(err as Error);
            } finally {
                setLoading(false);
            }
        };
        
        fetchUsers();
    }, []);
    
    if (loading) return <div>Loading...</div>;
    if (error) return <div>Error: {error.message}</div>;
    
    return (
        <div>
            {users.map(user => (
                <UserCard key={user.id} user={user} />
            ))}
        </div>
    );
};

// Custom hook
function useLocalStorage<T>(key: string, initialValue: T) {
    const [value, setValue] = useState<T>(() => {
        const stored = localStorage.getItem(key);
        return stored ? JSON.parse(stored) : initialValue;
    });
    
    useEffect(() => {
        localStorage.setItem(key, JSON.stringify(value));
    }, [key, value]);
    
    return [value, setValue] as const;
}

// Usage
const [theme, setTheme] = useLocalStorage<'light' | 'dark'>('theme', 'light');
```

## Best Practices

### Error Handling

```typescript
// Custom error classes
class ValidationError extends Error {
    constructor(
        message: string,
        public field: string
    ) {
        super(message);
        this.name = 'ValidationError';
    }
}

class NotFoundError extends Error {
    constructor(
        message: string,
        public resource: string,
        public id: number
    ) {
        super(message);
        this.name = 'NotFoundError';
    }
}

// Error handling in async functions
async function fetchUser(id: number): Promise<User> {
    try {
        const response = await fetch(`/api/users/${id}`);
        
        if (!response.ok) {
            if (response.status === 404) {
                throw new NotFoundError('User not found', 'user', id);
            }
            throw new Error(`HTTP error: ${response.status}`);
        }
        
        const user = await response.json();
        
        if (!validateUser(user)) {
            throw new ValidationError('Invalid user data', 'user');
        }
        
        return user;
        
    } catch (error) {
        if (error instanceof ValidationError) {
            console.error(`Validation error in ${error.field}:`, error.message);
        } else if (error instanceof NotFoundError) {
            console.error(`${error.resource} ${error.id} not found`);
        } else {
            console.error('Unexpected error:', error);
        }
        throw error;
    }
}

// Result type pattern
type Result<T, E = Error> =
    | { ok: true; value: T }
    | { ok: false; error: E };

async function safeFunction(): Promise<Result<User>> {
    try {
        const user = await fetchUser(1);
        return { ok: true, value: user };
    } catch (error) {
        return { ok: false, error: error as Error };
    }
}

// Usage
const result = await safeFunction();
if (result.ok) {
    console.log(result.value.name);
} else {
    console.error(result.error.message);
}
```

### Null Safety

```typescript
// Optional chaining
const user: User | undefined = getUser();
const email = user?.email;  // undefined if user is undefined
const city = user?.address?.city;  // Safe navigation

// Nullish coalescing
const name = user?.name ?? 'Guest';  // Use 'Guest' if name is null/undefined
const port = config.port ?? 3000;    // Different from || (handles 0, '', false)

// Non-null assertion (use sparingly)
const element = document.getElementById('root')!;  // Asserts non-null

// Type narrowing
function processUser(user: User | null) {
    if (user === null) {
        return;
    }
    // TypeScript knows user is User here
    console.log(user.name);
}

// Discriminated unions for null handling
type Optional<T> =
    | { hasValue: true; value: T }
    | { hasValue: false };

function getOptional<T>(value: T | null): Optional<T> {
    if (value === null) {
        return { hasValue: false };
    }
    return { hasValue: true, value };
}
```

### Immutability

```typescript
// Spread for copies
const original = { name: 'Alice', age: 30 };
const updated = { ...original, age: 31 };  // New object

// Array operations (immutable)
const numbers = [1, 2, 3];

// Add item
const withFour = [...numbers, 4];

// Remove item
const without Two = numbers.filter(n => n !== 2);

// Update item
const doubled = numbers.map(n => n * 2);

// Update object in array
const users: User[] = [...];
const updated = users.map(user =>
    user.id === targetId
        ? { ...user, name: newName }
        : user
);

// Immer for complex updates
import produce from 'immer';

const newState = produce(state, draft => {
    draft.users[0].name = 'Bob';
    draft.users.push(newUser);
});
```

### Code Organization

```typescript
// Feature-based structure
src/
├── features/
│   ├── auth/
│   │   ├── components/
│   │   │   ├── LoginForm.tsx
│   │   │   └── RegisterForm.tsx
│   │   ├── hooks/
│   │   │   └── useAuth.ts
│   │   ├── services/
│   │   │   └── authService.ts
│   │   ├── types/
│   │   │   └── auth.types.ts
│   │   └── index.ts
│   ├── users/
│   │   ├── components/
│   │   ├── hooks/
│   │   ├── services/
│   │   └── types/
│   └── ...
├── shared/
│   ├── components/
│   ├── hooks/
│   ├── types/
│   └── utils/
├── App.tsx
└── index.tsx

// Barrel exports (index.ts)
export { LoginForm, RegisterForm } from './components';
export { useAuth } from './hooks';
export { authService } from './services';
export type { AuthState, Credentials } from './types';
```

## Testing

### Jest with TypeScript

```typescript
// user.test.ts
import { User } from './user';

describe('User', () => {
    let user: User;
    
    beforeEach(() => {
        user = new User('Alice', 'alice@example.com');
    });
    
    it('should create user with name and email', () => {
        expect(user.name).toBe('Alice');
        expect(user.email).toBe('alice@example.com');
    });
    
    it('should validate email', () => {
        expect(() => new User('Bob', 'invalid')).toThrow();
    });
});

// Mocking
import { fetchUser } from './api';

jest.mock('./api');
const mockedFetchUser = fetchUser as jest.MockedFunction<typeof fetchUser>;

test('should handle API response', async () => {
    mockedFetchUser.mockResolvedValue({
        id: 1,
        name: 'Alice',
        email: 'alice@example.com'
    });
    
    const user = await fetchUser(1);
    expect(user.name).toBe('Alice');
    expect(mockedFetchUser).toHaveBeenCalledWith(1);
});
```

### React Testing Library

```typescript
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { UserCard } from './UserCard';

describe('UserCard', () => {
    const mockUser: User = {
        id: 1,
        name: 'Alice',
        email: 'alice@example.com'
    };
    
    it('should render user information', () => {
        render(<UserCard user={mockUser} />);
        
        expect(screen.getByText('Alice')).toBeInTheDocument();
        expect(screen.getByText('alice@example.com')).toBeInTheDocument();
    });
    
    it('should call onEdit when clicked', async () => {
        const onEdit = jest.fn();
        render(<UserCard user={mockUser} onEdit={onEdit} />);
        
        await userEvent.click(screen.getByRole('button', { name: /edit/i }));
        
        expect(onEdit).toHaveBeenCalledWith(mockUser);
    });
    
    it('should handle loading state', async () => {
        render(<UserList />);
        
        expect(screen.getByText(/loading/i)).toBeInTheDocument();
        
        await waitFor(() => {
            expect(screen.queryByText(/loading/i)).not.toBeInTheDocument();
        });
    });
});
```

## Configuration

### tsconfig.json

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "moduleResolution": "node",
    "resolveJsonModule": true,
    "allowJs": true,
    "checkJs": false,
    "jsx": "react-jsx",
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "outDir": "./dist",
    "rootDir": "./src",
    "removeComments": true,
    "noEmit": true,
    "isolatedModules": true,
    "allowSyntheticDefaultImports": true,
    "esModuleInterop": true,
    "forceConsistentCasingInFileNames": true,
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "skipLibCheck": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist", "**/*.test.ts"]
}
```

### ESLint Configuration

```javascript
// .eslintrc.js
module.exports = {
  parser: '@typescript-eslint/parser',
  extends: [
    'eslint:recommended',
    'plugin:@typescript-eslint/recommended',
    'plugin:react/recommended',
    'plugin:react-hooks/recommended',
    'prettier'
  ],
  plugins: ['@typescript-eslint', 'react', 'react-hooks'],
  rules: {
    '@typescript-eslint/explicit-function-return-type': 'off',
    '@typescript-eslint/no-explicit-any': 'warn',
    '@typescript-eslint/no-unused-vars': ['error', { argsIgnorePattern: '^_' }],
    'react/react-in-jsx-scope': 'off',
    'react/prop-types': 'off'
  },
  settings: {
    react: {
      version: 'detect'
    }
  }
};
```

## Conclusion

Modern JavaScript/TypeScript development requires:
- ES6+ features for clean, expressive code
- TypeScript for type safety and better tooling
- Async/await for readable asynchronous code
- Proper error handling and null safety
- Immutable data patterns
- Comprehensive testing
- Strong typing and interfaces

Always prioritize code clarity, type safety, and maintainability.
