# Security-First Development Skill

## Overview

This skill provides comprehensive security guidance for all development work. Security is not an afterthought or a checklist—it's a fundamental design principle that must be integrated into every stage of development.

## Core Security Principles

### Defense in Depth
Never rely on a single security control. Layer multiple defenses so that if one fails, others provide protection:
- Input validation AND output encoding
- Authentication AND authorization
- Network security AND application security
- Preventive controls AND detective controls

### Principle of Least Privilege
Grant only the minimum permissions necessary:
- Database users should have only required permissions
- API keys should be scoped to specific operations
- Service accounts should have minimal access
- Time-bound credentials when possible

### Fail Securely
When errors occur, fail in a secure state:
- Don't expose stack traces to users
- Don't leak system information in error messages
- Default to denying access, not granting it
- Log security failures for investigation

### Never Trust Input
Treat all input as potentially malicious:
- User input from forms and APIs
- File uploads and data imports
- URL parameters and headers
- Environment variables
- Database contents (defense against SQL injection)
- Third-party API responses

## OWASP Top 10 Prevention

### 1. Broken Access Control

**Prevention:**
- Implement centralized access control logic
- Deny by default; require explicit grants
- Validate permissions on every request, server-side
- Disable directory listing
- Log access control failures
- Rate-limit API access

**Example (Python/Flask):**
```python
from functools import wraps
from flask import abort, session

def require_permission(permission):
    """Decorator to check user permissions."""
    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            if not session.get('user_id'):
                abort(401)  # Unauthorized
            
            user = get_user(session['user_id'])
            if not user.has_permission(permission):
                abort(403)  # Forbidden
                
            return f(*args, **kwargs)
        return decorated_function
    return decorator

@app.route('/admin/users')
@require_permission('admin.users.view')
def list_users():
    # Only users with explicit permission can access
    return render_template('users.html', users=User.query.all())
```

### 2. Cryptographic Failures

**Prevention:**
- Use TLS for all data in transit (minimum TLS 1.2)
- Encrypt sensitive data at rest
- Use strong, modern algorithms (AES-256, RSA-2048+)
- Never implement custom crypto—use vetted libraries
- Proper key management and rotation
- Hash passwords with bcrypt, scrypt, or Argon2

**Example (Python):**
```python
import bcrypt
from cryptography.fernet import Fernet

# Password hashing
def hash_password(password: str) -> str:
    """Hash password with bcrypt."""
    salt = bcrypt.gensalt(rounds=12)  # Cost factor
    return bcrypt.hashpw(password.encode(), salt).decode()

def verify_password(password: str, hashed: str) -> bool:
    """Verify password against hash."""
    return bcrypt.checkpw(password.encode(), hashed.encode())

# Data encryption at rest
class DataEncryption:
    """Encrypt sensitive data using Fernet (AES-128)."""
    
    def __init__(self, key: bytes):
        self.cipher = Fernet(key)
    
    def encrypt(self, data: str) -> str:
        """Encrypt string data."""
        return self.cipher.encrypt(data.encode()).decode()
    
    def decrypt(self, encrypted: str) -> str:
        """Decrypt string data."""
        return self.cipher.decrypt(encrypted.encode()).decode()

# Key should be stored in secure key management system
# Never hardcode keys in source code
```

### 3. Injection Attacks

**Prevention:**
- Use parameterized queries (prepared statements)
- Use ORM query builders properly
- Validate and sanitize input
- Use allowlists for validation
- Escape special characters in output
- Use Content Security Policy headers

**SQL Injection Prevention:**
```python
# ❌ VULNERABLE - String concatenation
def get_user_bad(username):
    query = f"SELECT * FROM users WHERE username = '{username}'"
    return db.execute(query)

# ✅ SAFE - Parameterized query
def get_user_good(username):
    query = "SELECT * FROM users WHERE username = ?"
    return db.execute(query, (username,))

# ✅ SAFE - ORM usage
def get_user_orm(username):
    return User.query.filter_by(username=username).first()
```

**Command Injection Prevention:**
```python
import subprocess
import shlex

# ❌ VULNERABLE - Shell injection
def process_file_bad(filename):
    subprocess.run(f"process {filename}", shell=True)

# ✅ SAFE - No shell, validated input
def process_file_good(filename):
    # Validate filename first
    if not filename.isalnum():
        raise ValueError("Invalid filename")
    
    # Use list form, no shell
    subprocess.run(["process", filename], shell=False)
```

**NoSQL Injection Prevention:**
```python
# ❌ VULNERABLE - Direct object insertion
def find_user_bad(user_input):
    return db.users.find({"username": user_input})

# ✅ SAFE - Type validation
def find_user_good(user_input):
    # Ensure input is a string, not an object
    if not isinstance(user_input, str):
        raise ValueError("Username must be string")
    
    return db.users.find({"username": user_input})
```

### 4. Insecure Design

**Prevention:**
- Threat modeling during design phase
- Security requirements from the start
- Secure development lifecycle
- Peer review of designs
- Use established security patterns
- Avoid security by obscurity

**Threat Modeling Process:**
1. **Identify Assets**: What needs protection?
2. **Create Architecture**: Document data flows
3. **Identify Threats**: Use STRIDE methodology
4. **Mitigate Threats**: Design controls
5. **Validate**: Review and test

**Example: API Rate Limiting Design**
```python
from datetime import datetime, timedelta
from functools import wraps
from flask import request, abort
import redis

# Redis for distributed rate limiting
redis_client = redis.Redis(host='localhost', port=6379)

def rate_limit(max_requests: int, window_seconds: int):
    """
    Rate limiting decorator using sliding window.
    
    Prevents abuse and DoS attacks.
    """
    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            # Use IP + endpoint as key
            key = f"rate_limit:{request.remote_addr}:{request.endpoint}"
            
            # Get current request count
            current = redis_client.get(key)
            
            if current and int(current) >= max_requests:
                abort(429, "Too many requests")
            
            # Increment counter
            pipe = redis_client.pipeline()
            pipe.incr(key)
            pipe.expire(key, window_seconds)
            pipe.execute()
            
            return f(*args, **kwargs)
        return decorated_function
    return decorator

@app.route('/api/search')
@rate_limit(max_requests=100, window_seconds=60)
def search():
    # Limited to 100 requests per minute per IP
    return perform_search(request.args.get('q'))
```

### 5. Security Misconfiguration

**Prevention:**
- Disable unnecessary features and services
- Keep all software up to date
- Implement security headers
- Use secure default configurations
- Separate environments (dev/staging/prod)
- Automate security configuration

**Security Headers:**
```python
from flask import Flask

app = Flask(__name__)

@app.after_request
def set_security_headers(response):
    """Apply security headers to all responses."""
    
    # Prevent clickjacking
    response.headers['X-Frame-Options'] = 'DENY'
    
    # Prevent MIME sniffing
    response.headers['X-Content-Type-Options'] = 'nosniff'
    
    # XSS protection
    response.headers['X-XSS-Protection'] = '1; mode=block'
    
    # Content Security Policy
    response.headers['Content-Security-Policy'] = (
        "default-src 'self'; "
        "script-src 'self' 'unsafe-inline'; "
        "style-src 'self' 'unsafe-inline'; "
        "img-src 'self' data: https:; "
        "font-src 'self' data:; "
        "connect-src 'self'; "
        "frame-ancestors 'none';"
    )
    
    # HSTS - Force HTTPS
    response.headers['Strict-Transport-Security'] = (
        'max-age=31536000; includeSubDomains'
    )
    
    # Referrer policy
    response.headers['Referrer-Policy'] = 'strict-origin-when-cross-origin'
    
    # Permissions policy
    response.headers['Permissions-Policy'] = (
        'geolocation=(), microphone=(), camera=()'
    )
    
    return response
```

### 6. Vulnerable and Outdated Components

**Prevention:**
- Maintain inventory of components and versions
- Monitor for vulnerabilities (CVEs)
- Automate dependency updates
- Remove unused dependencies
- Use dependency scanning tools
- Subscribe to security advisories

**Example: Dependency Management**
```python
# requirements.txt - Pin versions
flask==3.0.0
sqlalchemy==2.0.23
cryptography==41.0.7
pyjwt==2.8.0

# Use safety for vulnerability scanning
# pip install safety
# safety check --json

# .github/workflows/security.yml
name: Security Scan
on: [push, pull_request]
jobs:
  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run Trivy vulnerability scanner
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          scan-ref: '.'
          format: 'sarif'
          output: 'trivy-results.sarif'
```

### 7. Identification and Authentication Failures

**Prevention:**
- Implement multi-factor authentication
- Strong password requirements
- Rate-limit login attempts
- Use secure session management
- Implement account lockout
- Log authentication failures

**Example: Secure Authentication**
```python
from datetime import datetime, timedelta
from typing import Optional
import jwt
import redis

redis_client = redis.Redis()

class AuthenticationService:
    """Secure authentication with rate limiting and MFA support."""
    
    MAX_LOGIN_ATTEMPTS = 5
    LOCKOUT_DURATION = 900  # 15 minutes
    
    def login(self, username: str, password: str, mfa_token: Optional[str] = None) -> dict:
        """
        Authenticate user with password and optional MFA.
        
        Returns JWT token on success.
        """
        # Check if account is locked
        lockout_key = f"lockout:{username}"
        if redis_client.get(lockout_key):
            raise AuthenticationError("Account temporarily locked")
        
        # Get user from database
        user = User.query.filter_by(username=username).first()
        
        if not user or not user.verify_password(password):
            self._record_failed_attempt(username)
            raise AuthenticationError("Invalid credentials")
        
        # Check MFA if enabled
        if user.mfa_enabled:
            if not mfa_token:
                return {"requires_mfa": True}
            
            if not self._verify_mfa(user, mfa_token):
                self._record_failed_attempt(username)
                raise AuthenticationError("Invalid MFA token")
        
        # Clear failed attempts
        redis_client.delete(f"failed_attempts:{username}")
        
        # Generate JWT token
        token = self._generate_token(user)
        
        # Log successful login
        self._log_login(user, success=True)
        
        return {
            "token": token,
            "user_id": user.id,
            "username": user.username
        }
    
    def _record_failed_attempt(self, username: str):
        """Record failed login attempt and lock if threshold exceeded."""
        key = f"failed_attempts:{username}"
        attempts = redis_client.incr(key)
        redis_client.expire(key, 3600)  # Reset after 1 hour
        
        if attempts >= self.MAX_LOGIN_ATTEMPTS:
            lockout_key = f"lockout:{username}"
            redis_client.setex(lockout_key, self.LOCKOUT_DURATION, "1")
            
            # Alert security team
            self._alert_account_lockout(username)
        
        self._log_login(username, success=False)
    
    def _generate_token(self, user) -> str:
        """Generate JWT token with short expiration."""
        payload = {
            'user_id': user.id,
            'username': user.username,
            'exp': datetime.utcnow() + timedelta(hours=1),
            'iat': datetime.utcnow(),
        }
        return jwt.encode(payload, app.config['SECRET_KEY'], algorithm='HS256')
```

### 8. Software and Data Integrity Failures

**Prevention:**
- Code signing and verification
- Use trusted repositories
- Implement CI/CD security
- Verify integrity of updates
- Use subresource integrity for CDN resources
- Implement secure deployment pipeline

**Example: Integrity Verification**
```python
import hashlib
import hmac

def verify_webhook(payload: bytes, signature: str, secret: str) -> bool:
    """
    Verify webhook payload authenticity.
    
    Prevents tampering with webhook data.
    """
    expected = hmac.new(
        secret.encode(),
        payload,
        hashlib.sha256
    ).hexdigest()
    
    return hmac.compare_digest(expected, signature)

# In your webhook handler
@app.route('/webhook', methods=['POST'])
def handle_webhook():
    signature = request.headers.get('X-Signature')
    
    if not verify_webhook(request.data, signature, WEBHOOK_SECRET):
        abort(401, "Invalid signature")
    
    # Process webhook safely
    process_webhook(request.json)
    return '', 204
```

### 9. Security Logging and Monitoring Failures

**Prevention:**
- Log all authentication events
- Log access control failures
- Log input validation failures
- Centralize logs
- Set up alerts for suspicious activity
- Protect log integrity

**Example: Security Logging**
```python
import logging
import structlog
from datetime import datetime

# Configure structured logging
structlog.configure(
    processors=[
        structlog.processors.TimeStamper(fmt="iso"),
        structlog.processors.JSONRenderer()
    ]
)

logger = structlog.get_logger()

class SecurityLogger:
    """Centralized security event logging."""
    
    @staticmethod
    def log_authentication(username: str, success: bool, ip: str, **kwargs):
        """Log authentication attempts."""
        logger.info(
            "authentication_attempt",
            username=username,
            success=success,
            ip_address=ip,
            **kwargs
        )
    
    @staticmethod
    def log_authorization_failure(user_id: int, resource: str, action: str, ip: str):
        """Log authorization failures."""
        logger.warning(
            "authorization_failure",
            user_id=user_id,
            resource=resource,
            action=action,
            ip_address=ip,
            severity="high"
        )
    
    @staticmethod
    def log_suspicious_activity(event_type: str, details: dict, ip: str):
        """Log suspicious activities."""
        logger.warning(
            "suspicious_activity",
            event_type=event_type,
            details=details,
            ip_address=ip,
            severity="critical"
        )
    
    @staticmethod
    def log_data_access(user_id: int, resource: str, action: str):
        """Log sensitive data access."""
        logger.info(
            "data_access",
            user_id=user_id,
            resource=resource,
            action=action,
            timestamp=datetime.utcnow().isoformat()
        )

# Usage in application
@app.route('/api/users/<int:user_id>')
@require_authentication
def get_user(user_id):
    current_user = get_current_user()
    
    # Check authorization
    if not current_user.can_access_user(user_id):
        SecurityLogger.log_authorization_failure(
            user_id=current_user.id,
            resource=f"user:{user_id}",
            action="read",
            ip=request.remote_addr
        )
        abort(403)
    
    # Log access
    SecurityLogger.log_data_access(
        user_id=current_user.id,
        resource=f"user:{user_id}",
        action="read"
    )
    
    return jsonify(User.query.get_or_404(user_id).to_dict())
```

### 10. Server-Side Request Forgery (SSRF)

**Prevention:**
- Validate and sanitize URLs
- Use allowlists for external requests
- Disable HTTP redirects
- Implement network segmentation
- Don't expose internal services

**Example: SSRF Prevention**
```python
import ipaddress
from urllib.parse import urlparse
import requests

class SSRFProtection:
    """Prevent Server-Side Request Forgery attacks."""
    
    ALLOWED_DOMAINS = ['api.example.com', 'cdn.example.com']
    BLOCKED_IPS = ['127.0.0.1', '0.0.0.0', '::1']
    
    @classmethod
    def is_safe_url(cls, url: str) -> bool:
        """Check if URL is safe to request."""
        try:
            parsed = urlparse(url)
            
            # Must be HTTP/HTTPS
            if parsed.scheme not in ['http', 'https']:
                return False
            
            # Check domain allowlist
            if parsed.hostname not in cls.ALLOWED_DOMAINS:
                return False
            
            # Resolve IP and check if it's internal
            ip = ipaddress.ip_address(parsed.hostname)
            
            if ip.is_private or ip.is_loopback:
                return False
            
            return True
            
        except Exception:
            return False
    
    @classmethod
    def safe_request(cls, url: str, **kwargs) -> requests.Response:
        """Make HTTP request with SSRF protection."""
        if not cls.is_safe_url(url):
            raise ValueError("Unsafe URL blocked")
        
        # Disable redirects
        kwargs['allow_redirects'] = False
        
        # Set timeout
        kwargs.setdefault('timeout', 5)
        
        return requests.get(url, **kwargs)

# Usage
@app.route('/api/fetch')
def fetch_external():
    url = request.args.get('url')
    
    try:
        response = SSRFProtection.safe_request(url)
        return response.content
    except ValueError as e:
        abort(400, str(e))
```

## API Security

### JWT Token Security

```python
from datetime import datetime, timedelta
import jwt
from typing import Dict, Optional

class JWTManager:
    """Secure JWT token management."""
    
    def __init__(self, secret_key: str, algorithm: str = 'HS256'):
        self.secret_key = secret_key
        self.algorithm = algorithm
        self.access_token_expires = timedelta(minutes=15)
        self.refresh_token_expires = timedelta(days=7)
    
    def create_access_token(self, user_id: int, **claims) -> str:
        """Create short-lived access token."""
        payload = {
            'user_id': user_id,
            'type': 'access',
            'exp': datetime.utcnow() + self.access_token_expires,
            'iat': datetime.utcnow(),
            **claims
        }
        return jwt.encode(payload, self.secret_key, algorithm=self.algorithm)
    
    def create_refresh_token(self, user_id: int) -> str:
        """Create long-lived refresh token."""
        payload = {
            'user_id': user_id,
            'type': 'refresh',
            'exp': datetime.utcnow() + self.refresh_token_expires,
            'iat': datetime.utcnow()
        }
        return jwt.encode(payload, self.secret_key, algorithm=self.algorithm)
    
    def verify_token(self, token: str, token_type: str = 'access') -> Optional[Dict]:
        """Verify and decode token."""
        try:
            payload = jwt.decode(
                token,
                self.secret_key,
                algorithms=[self.algorithm]
            )
            
            if payload.get('type') != token_type:
                return None
            
            return payload
            
        except jwt.ExpiredSignatureError:
            return None
        except jwt.InvalidTokenError:
            return None
```

### API Input Validation

```python
from pydantic import BaseModel, EmailStr, validator, Field
from typing import Optional

class UserCreateRequest(BaseModel):
    """Validate user creation request."""
    
    username: str = Field(..., min_length=3, max_length=50, regex='^[a-zA-Z0-9_-]+$')
    email: EmailStr
    password: str = Field(..., min_length=12)
    age: Optional[int] = Field(None, ge=13, le=120)
    
    @validator('password')
    def password_strength(cls, v):
        """Ensure password meets complexity requirements."""
        if not any(c.isupper() for c in v):
            raise ValueError('Password must contain uppercase letter')
        if not any(c.islower() for c in v):
            raise ValueError('Password must contain lowercase letter')
        if not any(c.isdigit() for c in v):
            raise ValueError('Password must contain digit')
        if not any(c in '!@#$%^&*' for c in v):
            raise ValueError('Password must contain special character')
        return v

# Usage in endpoint
@app.route('/api/users', methods=['POST'])
def create_user():
    try:
        # Pydantic validates and parses
        request_data = UserCreateRequest(**request.json)
        
        # Safe to use validated data
        user = create_user_account(request_data)
        return jsonify(user.to_dict()), 201
        
    except ValidationError as e:
        return jsonify({'errors': e.errors()}), 400
```

## Secrets Management

### Never Hardcode Secrets

```python
# ❌ BAD - Secrets in code
API_KEY = "sk-1234567890abcdef"
DATABASE_URL = "postgresql://user:password@localhost/db"

# ✅ GOOD - Secrets from environment
import os

API_KEY = os.environ.get('API_KEY')
DATABASE_URL = os.environ.get('DATABASE_URL')

if not API_KEY:
    raise RuntimeError("API_KEY environment variable not set")
```

### Use Secrets Management Services

```python
# AWS Secrets Manager example
import boto3
import json

def get_secret(secret_name: str) -> dict:
    """Retrieve secret from AWS Secrets Manager."""
    client = boto3.client('secretsmanager')
    
    try:
        response = client.get_secret_value(SecretId=secret_name)
        return json.loads(response['SecretString'])
    except Exception as e:
        logger.error(f"Failed to retrieve secret: {e}")
        raise

# Usage
db_credentials = get_secret('prod/database')
DATABASE_URL = db_credentials['connection_string']
```

### Rotate Secrets Regularly

```python
def rotate_api_key(user_id: int):
    """Rotate API key for user."""
    import secrets
    
    # Generate new key
    new_key = secrets.token_urlsafe(32)
    
    # Hash for storage
    key_hash = hash_api_key(new_key)
    
    # Update in database
    user = User.query.get(user_id)
    user.api_key_hash = key_hash
    user.key_updated_at = datetime.utcnow()
    db.session.commit()
    
    # Log rotation
    SecurityLogger.log_key_rotation(user_id)
    
    # Return plain key to user (only shown once)
    return new_key
```

## File Upload Security

```python
import os
from werkzeug.utils import secure_filename
from PIL import Image
import magic

ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif', 'pdf'}
MAX_FILE_SIZE = 10 * 1024 * 1024  # 10MB

def allowed_file(filename: str) -> bool:
    """Check if file extension is allowed."""
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

def validate_image(file_path: str) -> bool:
    """Validate that file is actually an image."""
    try:
        # Check MIME type
        mime = magic.Magic(mime=True)
        file_type = mime.from_file(file_path)
        
        if not file_type.startswith('image/'):
            return False
        
        # Try to open and verify with Pillow
        with Image.open(file_path) as img:
            img.verify()
        
        return True
    except Exception:
        return False

@app.route('/upload', methods=['POST'])
def upload_file():
    """Secure file upload handler."""
    if 'file' not in request.files:
        return jsonify({'error': 'No file part'}), 400
    
    file = request.files['file']
    
    if file.filename == '':
        return jsonify({'error': 'No selected file'}), 400
    
    # Check file size
    file.seek(0, os.SEEK_END)
    file_size = file.tell()
    file.seek(0)
    
    if file_size > MAX_FILE_SIZE:
        return jsonify({'error': 'File too large'}), 400
    
    # Validate extension
    if not allowed_file(file.filename):
        return jsonify({'error': 'Invalid file type'}), 400
    
    # Secure filename
    filename = secure_filename(file.filename)
    
    # Generate unique filename
    unique_filename = f"{uuid.uuid4()}_{filename}"
    
    # Save temporarily
    temp_path = os.path.join('/tmp', unique_filename)
    file.save(temp_path)
    
    try:
        # Validate file content
        if not validate_image(temp_path):
            os.remove(temp_path)
            return jsonify({'error': 'Invalid file content'}), 400
        
        # Move to permanent storage
        final_path = os.path.join(app.config['UPLOAD_FOLDER'], unique_filename)
        os.rename(temp_path, final_path)
        
        # Log upload
        SecurityLogger.log_file_upload(
            user_id=get_current_user().id,
            filename=unique_filename,
            size=file_size
        )
        
        return jsonify({'filename': unique_filename}), 201
        
    finally:
        # Cleanup temp file if it still exists
        if os.path.exists(temp_path):
            os.remove(temp_path)
```

## Security Checklist

### Before Deployment

- [ ] All secrets in environment variables or secrets manager
- [ ] HTTPS enforced (HSTS headers)
- [ ] Security headers implemented
- [ ] Input validation on all endpoints
- [ ] SQL injection prevention (parameterized queries)
- [ ] XSS prevention (output encoding)
- [ ] CSRF protection enabled
- [ ] Rate limiting on authentication endpoints
- [ ] Strong password requirements
- [ ] Account lockout after failed attempts
- [ ] MFA available for sensitive operations
- [ ] Secure session management
- [ ] Proper error handling (no information leakage)
- [ ] Security logging enabled
- [ ] Dependency vulnerabilities checked
- [ ] File upload validation
- [ ] API authentication and authorization
- [ ] CORS properly configured
- [ ] Database access controls
- [ ] Principle of least privilege applied

### Regular Maintenance

- [ ] Review security logs weekly
- [ ] Update dependencies monthly
- [ ] Rotate secrets quarterly
- [ ] Security audit annually
- [ ] Penetration testing annually
- [ ] Review access controls quarterly
- [ ] Update threat model as system changes

## Common Security Anti-Patterns to Avoid

### ❌ Security Through Obscurity
```python
# Don't rely on hiding endpoints or using non-standard ports
@app.route('/secret_admin_panel_x91k2')  # Bad
def admin():
    pass

# Use proper authentication instead
@app.route('/admin')
@require_permission('admin')
def admin():
    pass
```

### ❌ Rolling Your Own Crypto
```python
# Don't implement custom encryption
def my_encryption(data):  # Bad
    return ''.join(chr(ord(c) + 1) for c in data)

# Use established libraries
from cryptography.fernet import Fernet
cipher = Fernet(key)
encrypted = cipher.encrypt(data.encode())
```

### ❌ Trusting Client-Side Validation
```python
# Don't rely only on frontend validation
@app.route('/api/users', methods=['POST'])
def create_user():
    # Must validate server-side too
    data = request.json
    if not data.get('email'):
        abort(400, 'Email required')
    # ... more validation
```

### ❌ Weak Random Number Generation
```python
import random  # ❌ Not cryptographically secure

token = random.randint(1000, 9999)  # Bad for security

import secrets  # ✅ Cryptographically secure

token = secrets.token_urlsafe(32)  # Good
```

## Conclusion

Security is not optional. It must be designed in from the start, implemented consistently, and maintained continuously. Every developer is responsible for the security of the code they write.

When in doubt:
- Default to deny
- Validate everything
- Log security events
- Use established libraries
- Follow industry standards
- Get security review

Remember: It's always cheaper to build secure systems than to fix breaches.
