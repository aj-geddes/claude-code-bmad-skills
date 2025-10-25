# Python Development Excellence Skill

## Overview

This skill provides comprehensive Python development guidance covering modern Python (3.8+), best practices, idioms, and professional development patterns.

## Python Philosophy - The Zen of Python

```python
import this
```

Key principles to follow:
- **Explicit is better than implicit** - Clear code over clever tricks
- **Simple is better than complex** - Favor readability
- **Readability counts** - Code is read more than written
- **Errors should never pass silently** - Fail loud and clear
- **There should be one obvious way to do it** - Prefer idiomatic Python

## Modern Python Features (3.8+)

### Type Hints (Python 3.5+, improved 3.8+)

```python
from typing import List, Dict, Optional, Union, Callable, TypeVar, Generic
from dataclasses import dataclass

# Function annotations
def process_items(
    items: List[str],
    max_count: Optional[int] = None
) -> Dict[str, int]:
    """Process items and return count mapping."""
    result = {}
    for item in items[:max_count]:
        result[item] = result.get(item, 0) + 1
    return result

# Complex types
def apply_function(
    func: Callable[[int], int],
    values: List[int]
) -> List[int]:
    return [func(x) for x in values]

# Generic types
T = TypeVar('T')

class Stack(Generic[T]):
    """Type-safe stack implementation."""
    
    def __init__(self) -> None:
        self._items: List[T] = []
    
    def push(self, item: T) -> None:
        self._items.append(item)
    
    def pop(self) -> T:
        return self._items.pop()
    
    def peek(self) -> Optional[T]:
        return self._items[-1] if self._items else None

# Usage
stack: Stack[int] = Stack()
stack.push(42)
value: int = stack.pop()
```

### Walrus Operator (Python 3.8)

```python
# Assign and use in same expression
if (n := len(items)) > 10:
    print(f"List is long ({n} items)")

# In list comprehensions
filtered = [result for item in items 
            if (result := process(item)) is not None]

# While loops
while (line := file.readline()):
    process_line(line)
```

### Positional-Only and Keyword-Only Parameters (Python 3.8)

```python
def complex_function(
    positional_only,    # Before /
    /,                  # Positional-only marker
    positional_or_kw,   # Can be either
    *,                  # Keyword-only marker
    keyword_only        # After *
):
    """
    positional_only: Must pass by position
    positional_or_kw: Can pass either way
    keyword_only: Must pass by keyword
    """
    pass

# Valid calls
complex_function(1, 2, keyword_only=3)
complex_function(1, positional_or_kw=2, keyword_only=3)

# Invalid calls
# complex_function(positional_only=1, 2, keyword_only=3)  # Error
# complex_function(1, 2, 3)  # Error
```

### Structural Pattern Matching (Python 3.10)

```python
def process_command(command: dict) -> str:
    """Process commands using pattern matching."""
    match command:
        case {"action": "create", "type": "user", "name": name}:
            return f"Creating user: {name}"
        
        case {"action": "delete", "type": type_, "id": id_}:
            return f"Deleting {type_} with id {id_}"
        
        case {"action": "list", "type": type_}:
            return f"Listing all {type_}s"
        
        case _:
            return "Unknown command"

# Complex patterns
def process_point(point):
    match point:
        case (0, 0):
            return "Origin"
        case (0, y):
            return f"On Y-axis at {y}"
        case (x, 0):
            return f"On X-axis at {x}"
        case (x, y) if x == y:
            return f"On diagonal at {x}"
        case (x, y):
            return f"Point at ({x}, {y})"
```

### Dataclasses (Python 3.7+)

```python
from dataclasses import dataclass, field, asdict
from typing import List
from datetime import datetime

@dataclass
class User:
    """User model with automatic __init__, __repr__, __eq__."""
    
    id: int
    username: str
    email: str
    created_at: datetime = field(default_factory=datetime.now)
    tags: List[str] = field(default_factory=list)
    
    def __post_init__(self):
        """Validation after initialization."""
        if not self.email or '@' not in self.email:
            raise ValueError("Invalid email")
        self.username = self.username.lower()

# Usage
user = User(id=1, username="John", email="john@example.com")
print(user)  # Automatic __repr__
user_dict = asdict(user)  # Convert to dict

# Frozen dataclasses (immutable)
@dataclass(frozen=True)
class Point:
    x: float
    y: float
    
# Comparison
@dataclass(order=True)
class Task:
    priority: int
    name: str = field(compare=False)  # Exclude from comparison
```

## Python Idioms and Best Practices

### List Comprehensions and Generator Expressions

```python
# List comprehension - creates list in memory
squares = [x**2 for x in range(10)]

# Generator expression - lazy evaluation
squares_gen = (x**2 for x in range(10))

# Dict comprehension
word_lengths = {word: len(word) for word in words}

# Set comprehension
unique_lengths = {len(word) for word in words}

# Nested comprehensions
matrix = [[1, 2, 3], [4, 5, 6]]
flattened = [num for row in matrix for num in row]

# Conditional comprehensions
evens = [x for x in range(10) if x % 2 == 0]

# Complex transformations
processed = [
    transform(item)
    for sublist in data
    for item in sublist
    if validate(item)
]
```

### Context Managers

```python
# Built-in context managers
with open('file.txt', 'r') as f:
    content = f.read()

# Multiple context managers
with open('input.txt') as infile, open('output.txt', 'w') as outfile:
    outfile.write(infile.read())

# Custom context manager with class
class DatabaseConnection:
    """Context manager for database connections."""
    
    def __init__(self, connection_string: str):
        self.connection_string = connection_string
        self.connection = None
    
    def __enter__(self):
        self.connection = connect(self.connection_string)
        return self.connection
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        if self.connection:
            self.connection.close()
        return False  # Don't suppress exceptions

# Usage
with DatabaseConnection('postgresql://...') as conn:
    conn.execute("SELECT * FROM users")

# Context manager with decorator
from contextlib import contextmanager

@contextmanager
def timer(label: str):
    """Time a block of code."""
    import time
    start = time.time()
    try:
        yield
    finally:
        elapsed = time.time() - start
        print(f"{label}: {elapsed:.4f} seconds")

# Usage
with timer("Processing"):
    process_large_dataset()
```

### Decorators

```python
from functools import wraps
import time

# Basic decorator
def timing_decorator(func):
    """Measure function execution time."""
    @wraps(func)  # Preserves original function metadata
    def wrapper(*args, **kwargs):
        start = time.time()
        result = func(*args, **kwargs)
        elapsed = time.time() - start
        print(f"{func.__name__} took {elapsed:.4f}s")
        return result
    return wrapper

@timing_decorator
def slow_function():
    time.sleep(1)
    return "Done"

# Decorator with arguments
def retry(max_attempts: int = 3, delay: float = 1.0):
    """Retry decorator with configurable attempts."""
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            for attempt in range(max_attempts):
                try:
                    return func(*args, **kwargs)
                except Exception as e:
                    if attempt == max_attempts - 1:
                        raise
                    time.sleep(delay)
            return None
        return wrapper
    return decorator

@retry(max_attempts=3, delay=2.0)
def unreliable_api_call():
    # Might fail, will retry
    return requests.get('https://api.example.com/data')

# Class decorator
def singleton(cls):
    """Ensure class has only one instance."""
    instances = {}
    @wraps(cls)
    def get_instance(*args, **kwargs):
        if cls not in instances:
            instances[cls] = cls(*args, **kwargs)
        return instances[cls]
    return get_instance

@singleton
class DatabaseConnection:
    pass

# Property decorator
class User:
    def __init__(self, first_name: str, last_name: str):
        self._first_name = first_name
        self._last_name = last_name
    
    @property
    def full_name(self) -> str:
        """Read-only computed property."""
        return f"{self._first_name} {self._last_name}"
    
    @property
    def first_name(self) -> str:
        return self._first_name
    
    @first_name.setter
    def first_name(self, value: str) -> None:
        if not value:
            raise ValueError("First name cannot be empty")
        self._first_name = value
```

### Generators and Iterators

```python
# Generator function
def fibonacci(n: int):
    """Generate first n Fibonacci numbers."""
    a, b = 0, 1
    for _ in range(n):
        yield a
        a, b = b, a + b

# Usage
for num in fibonacci(10):
    print(num)

# Generator expression
squares = (x**2 for x in range(1000000))  # Memory efficient

# Custom iterator
class CountDown:
    """Iterator that counts down."""
    
    def __init__(self, start: int):
        self.current = start
    
    def __iter__(self):
        return self
    
    def __next__(self):
        if self.current <= 0:
            raise StopIteration
        self.current -= 1
        return self.current + 1

# Usage
for num in CountDown(5):
    print(num)

# Infinite generator
def infinite_sequence():
    """Generate infinite sequence."""
    num = 0
    while True:
        yield num
        num += 1

# Use with itertools
from itertools import islice
first_ten = list(islice(infinite_sequence(), 10))
```

### Argument Unpacking

```python
# Function arguments
def process(a, b, c):
    return a + b + c

args = [1, 2, 3]
result = process(*args)  # Unpack list

kwargs = {'a': 1, 'b': 2, 'c': 3}
result = process(**kwargs)  # Unpack dict

# Extended unpacking
first, *middle, last = [1, 2, 3, 4, 5]
# first = 1, middle = [2, 3, 4], last = 5

# Dictionary unpacking
base_config = {'host': 'localhost', 'port': 5432}
user_config = {'port': 3306, 'database': 'mydb'}

# Merge dicts (Python 3.9+)
config = base_config | user_config

# Or using unpacking
config = {**base_config, **user_config}
```

## Async Programming

### Async/Await (Python 3.5+)

```python
import asyncio
import aiohttp
from typing import List

async def fetch_url(session: aiohttp.ClientSession, url: str) -> str:
    """Fetch URL asynchronously."""
    async with session.get(url) as response:
        return await response.text()

async def fetch_all(urls: List[str]) -> List[str]:
    """Fetch multiple URLs concurrently."""
    async with aiohttp.ClientSession() as session:
        tasks = [fetch_url(session, url) for url in urls]
        return await asyncio.gather(*tasks)

# Run async code
async def main():
    urls = ['https://example.com', 'https://example.org']
    results = await fetch_all(urls)
    print(results)

# Execute
asyncio.run(main())

# Async context manager
class AsyncDatabaseConnection:
    async def __aenter__(self):
        self.conn = await create_connection()
        return self.conn
    
    async def __aexit__(self, exc_type, exc_val, exc_tb):
        await self.conn.close()

# Async generator
async def async_range(count: int):
    """Async generator example."""
    for i in range(count):
        await asyncio.sleep(0.1)
        yield i

# Usage
async def process():
    async for value in async_range(10):
        print(value)
```

## Error Handling

### Exception Best Practices

```python
# Specific exceptions
try:
    result = risky_operation()
except ValueError as e:
    # Handle specific exception
    logger.error(f"Invalid value: {e}")
    raise
except KeyError as e:
    # Handle another specific exception
    logger.error(f"Missing key: {e}")
    return default_value
except (IOError, OSError) as e:
    # Handle multiple exceptions
    logger.error(f"IO error: {e}")
    raise
finally:
    # Always executed
    cleanup()

# Custom exceptions
class ApplicationError(Exception):
    """Base exception for application."""
    pass

class ValidationError(ApplicationError):
    """Raised when validation fails."""
    
    def __init__(self, field: str, message: str):
        self.field = field
        self.message = message
        super().__init__(f"{field}: {message}")

class NotFoundError(ApplicationError):
    """Raised when resource not found."""
    pass

# Exception chaining
try:
    process_data()
except ValueError as e:
    raise ApplicationError("Processing failed") from e

# Suppress specific exceptions (use sparingly)
from contextlib import suppress

with suppress(FileNotFoundError):
    os.remove('temp_file.txt')

# Exception groups (Python 3.11+)
try:
    complex_operation()
except* ValueError as eg:
    # Handle all ValueErrors in group
    for exc in eg.exceptions:
        logger.error(f"Value error: {exc}")
except* KeyError as eg:
    # Handle all KeyErrors in group
    for exc in eg.exceptions:
        logger.error(f"Key error: {exc}")
```

## Testing

### pytest Best Practices

```python
import pytest
from typing import List

# Basic test
def test_addition():
    """Test basic addition."""
    assert 1 + 1 == 2

# Fixtures
@pytest.fixture
def sample_users():
    """Provide sample user data."""
    return [
        {'id': 1, 'name': 'Alice'},
        {'id': 2, 'name': 'Bob'}
    ]

def test_user_count(sample_users):
    """Test with fixture."""
    assert len(sample_users) == 2

# Parametrized tests
@pytest.mark.parametrize('input,expected', [
    (1, 2),
    (2, 4),
    (3, 6),
])
def test_double(input, expected):
    """Test with multiple inputs."""
    assert input * 2 == expected

# Exception testing
def test_division_by_zero():
    """Test exception is raised."""
    with pytest.raises(ZeroDivisionError):
        1 / 0

# Test classes
class TestUserManager:
    """Group related tests."""
    
    @pytest.fixture(autouse=True)
    def setup(self):
        """Setup before each test."""
        self.manager = UserManager()
        yield
        # Teardown after each test
        self.manager.cleanup()
    
    def test_add_user(self):
        user = self.manager.add_user('Alice')
        assert user.name == 'Alice'
    
    def test_remove_user(self):
        user = self.manager.add_user('Bob')
        self.manager.remove_user(user.id)
        assert self.manager.get_user(user.id) is None

# Mocking
from unittest.mock import Mock, patch

def test_api_call():
    """Test with mocked API."""
    with patch('requests.get') as mock_get:
        mock_get.return_value.json.return_value = {'status': 'ok'}
        result = fetch_data()
        assert result['status'] == 'ok'
        mock_get.assert_called_once()

# Property-based testing with hypothesis
from hypothesis import given, strategies as st

@given(st.lists(st.integers()))
def test_sort_idempotent(lst: List[int]):
    """Sorting is idempotent."""
    sorted_once = sorted(lst)
    sorted_twice = sorted(sorted_once)
    assert sorted_once == sorted_twice
```

## Code Organization

### Module Structure

```python
# module.py
"""
Module docstring describing purpose.

Longer description of what the module does.
"""

# Standard library imports
import os
import sys
from datetime import datetime
from typing import List, Optional

# Third-party imports
import requests
import numpy as np
from sqlalchemy import create_engine

# Local imports
from .models import User
from .utils import validate_email
from . import constants

# Module-level constants
DEFAULT_TIMEOUT = 30
MAX_RETRIES = 3

# Module-level "private" variables
_cache = {}

# Public API
__all__ = ['process_user', 'validate_data']


class UserProcessor:
    """Process user data."""
    
    def __init__(self, config: dict):
        self.config = config
        self._setup()
    
    def _setup(self):
        """Private setup method."""
        pass
    
    def process(self, user: User) -> dict:
        """Public process method."""
        return self._internal_process(user)
    
    def _internal_process(self, user: User) -> dict:
        """Private helper method."""
        pass


def process_user(user_id: int) -> Optional[User]:
    """
    Process user by ID.
    
    Args:
        user_id: ID of user to process
        
    Returns:
        Processed user or None if not found
        
    Raises:
        ValueError: If user_id is invalid
    """
    pass


def _internal_helper():
    """Private module function."""
    pass
```

### Package Structure

```
mypackage/
├── __init__.py           # Package initialization
├── __main__.py           # Makes package runnable (python -m mypackage)
├── config.py             # Configuration
├── constants.py          # Constants
├── exceptions.py         # Custom exceptions
├── models/               # Data models
│   ├── __init__.py
│   ├── user.py
│   └── product.py
├── services/             # Business logic
│   ├── __init__.py
│   ├── user_service.py
│   └── auth_service.py
├── api/                  # API layer
│   ├── __init__.py
│   ├── routes.py
│   └── schemas.py
└── utils/                # Utilities
    ├── __init__.py
    ├── validators.py
    └── helpers.py
```

## Performance Optimization

### Profiling

```python
import cProfile
import pstats
from functools import wraps
import time

# Time function execution
def profile_time(func):
    """Decorator to profile execution time."""
    @wraps(func)
    def wrapper(*args, **kwargs):
        start = time.perf_counter()
        result = func(*args, **kwargs)
        elapsed = time.perf_counter() - start
        print(f"{func.__name__}: {elapsed:.4f}s")
        return result
    return wrapper

# CPU profiling
def profile_cpu(output_file='profile_stats.txt'):
    """Profile CPU usage."""
    profiler = cProfile.Profile()
    profiler.enable()
    
    # Code to profile
    expensive_function()
    
    profiler.disable()
    
    with open(output_file, 'w') as f:
        stats = pstats.Stats(profiler, stream=f)
        stats.sort_stats('cumulative')
        stats.print_stats()

# Memory profiling
from memory_profiler import profile

@profile
def memory_intensive_function():
    """Profile memory usage."""
    large_list = [i for i in range(1000000)]
    return sum(large_list)
```

### Optimization Techniques

```python
# Use __slots__ for memory efficiency
class Point:
    """Memory-efficient point class."""
    __slots__ = ['x', 'y']
    
    def __init__(self, x: float, y: float):
        self.x = x
        self.y = y

# Use generators for large datasets
def read_large_file(filename: str):
    """Read file line by line (memory efficient)."""
    with open(filename) as f:
        for line in f:
            yield line.strip()

# Use sets for membership testing
# O(1) average case vs O(n) for lists
large_set = set(range(1000000))
if 500000 in large_set:  # Fast
    pass

# Cache expensive computations
from functools import lru_cache

@lru_cache(maxsize=128)
def expensive_computation(n: int) -> int:
    """Cached Fibonacci."""
    if n < 2:
        return n
    return expensive_computation(n-1) + expensive_computation(n-2)

# Use list comprehensions over loops
# Faster: list comprehension
squares = [x**2 for x in range(1000)]

# Slower: loop with append
squares = []
for x in range(1000):
    squares.append(x**2)

# Use built-in functions (implemented in C)
# Faster
total = sum(numbers)

# Slower
total = 0
for num in numbers:
    total += num
```

## Documentation

### Docstring Styles

```python
def calculate_average(numbers: List[float]) -> float:
    """
    Calculate the average of a list of numbers.
    
    Google Style:
    
    Args:
        numbers: List of numbers to average
        
    Returns:
        The arithmetic mean of the numbers
        
    Raises:
        ValueError: If the list is empty
        
    Examples:
        >>> calculate_average([1, 2, 3, 4, 5])
        3.0
        >>> calculate_average([10, 20])
        15.0
    """
    if not numbers:
        raise ValueError("Cannot calculate average of empty list")
    return sum(numbers) / len(numbers)


class User:
    """
    Represent a user in the system.
    
    Attributes:
        id: Unique user identifier
        username: User's chosen username
        email: User's email address
        created_at: Timestamp of user creation
        
    Example:
        >>> user = User(id=1, username="alice", email="alice@example.com")
        >>> print(user.username)
        alice
    """
    
    def __init__(self, id: int, username: str, email: str):
        """
        Initialize a new User.
        
        Args:
            id: Unique identifier
            username: User's username
            email: User's email address
        """
        self.id = id
        self.username = username
        self.email = email
        self.created_at = datetime.now()
```

## Common Patterns

### Singleton Pattern

```python
class Singleton:
    """Singleton using metaclass."""
    _instances = {}
    
    def __new__(cls, *args, **kwargs):
        if cls not in cls._instances:
            cls._instances[cls] = super().__new__(cls)
        return cls._instances[cls]

# Or using decorator (shown earlier)
```

### Factory Pattern

```python
from abc import ABC, abstractmethod

class Animal(ABC):
    """Abstract animal class."""
    
    @abstractmethod
    def speak(self) -> str:
        pass

class Dog(Animal):
    def speak(self) -> str:
        return "Woof!"

class Cat(Animal):
    def speak(self) -> str:
        return "Meow!"

class AnimalFactory:
    """Factory for creating animals."""
    
    _animals = {
        'dog': Dog,
        'cat': Cat
    }
    
    @classmethod
    def create(cls, animal_type: str) -> Animal:
        """Create animal by type."""
        animal_class = cls._animals.get(animal_type.lower())
        if not animal_class:
            raise ValueError(f"Unknown animal type: {animal_type}")
        return animal_class()

# Usage
dog = AnimalFactory.create('dog')
print(dog.speak())  # "Woof!"
```

### Builder Pattern

```python
class UserBuilder:
    """Builder for User objects."""
    
    def __init__(self):
        self._user = {}
    
    def with_id(self, user_id: int):
        self._user['id'] = user_id
        return self
    
    def with_username(self, username: str):
        self._user['username'] = username
        return self
    
    def with_email(self, email: str):
        self._user['email'] = email
        return self
    
    def build(self) -> User:
        """Build and validate user."""
        if 'id' not in self._user or 'username' not in self._user:
            raise ValueError("Missing required fields")
        return User(**self._user)

# Usage
user = (UserBuilder()
    .with_id(1)
    .with_username("alice")
    .with_email("alice@example.com")
    .build())
```

## Python Pitfalls to Avoid

### Mutable Default Arguments

```python
# ❌ BAD - Mutable default
def add_item(item, items=[]):
    items.append(item)
    return items

# This causes unexpected behavior:
# add_item(1)  # [1]
# add_item(2)  # [1, 2] - Unexpected!

# ✅ GOOD - Use None and create new list
def add_item(item, items=None):
    if items is None:
        items = []
    items.append(item)
    return items
```

### Late Binding Closures

```python
# ❌ BAD - All functions reference same i
functions = [lambda: i for i in range(5)]
results = [f() for f in functions]  # [4, 4, 4, 4, 4]

# ✅ GOOD - Capture value immediately
functions = [lambda i=i: i for i in range(5)]
results = [f() for f in functions]  # [0, 1, 2, 3, 4]
```

### Modifying List While Iterating

```python
# ❌ BAD - Modifying list during iteration
numbers = [1, 2, 3, 4, 5]
for num in numbers:
    if num % 2 == 0:
        numbers.remove(num)  # Dangerous!

# ✅ GOOD - Create new list
numbers = [1, 2, 3, 4, 5]
numbers = [num for num in numbers if num % 2 != 0]

# Or iterate over copy
numbers = [1, 2, 3, 4, 5]
for num in numbers[:]:  # Iterate over copy
    if num % 2 == 0:
        numbers.remove(num)
```

## Tools and Configuration

### pyproject.toml

```toml
[project]
name = "myproject"
version = "0.1.0"
description = "My Python project"
requires-python = ">=3.8"
dependencies = [
    "requests>=2.28.0",
    "pydantic>=2.0.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=7.0.0",
    "black>=23.0.0",
    "mypy>=1.0.0",
    "ruff>=0.1.0",
]

[tool.black]
line-length = 100
target-version = ['py38', 'py39', 'py310', 'py311']

[tool.mypy]
python_version = "3.8"
warn_return_any = true
warn_unused_configs = true
disallow_untyped_defs = true

[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = "test_*.py"
python_functions = "test_*"
addopts = "-v --cov=myproject --cov-report=term-missing"

[tool.ruff]
line-length = 100
select = ["E", "F", "W", "C90", "I", "N", "UP", "B", "A", "C4", "PT"]
```

## Conclusion

Python excellence comes from:
- Understanding and applying idiomatic Python
- Using modern language features effectively
- Writing clear, maintainable code
- Following PEP 8 and PEP 257
- Proper error handling and testing
- Performance awareness without premature optimization

When in doubt, `import this` and remember: **Readability counts**.
