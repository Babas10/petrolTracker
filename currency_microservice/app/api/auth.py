"""
Authentication and rate limiting middleware.
"""
from fastapi import HTTPException, Security, Depends
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from fastapi import Request
from typing import Dict
import time
from app.core.config import settings
import logging

logger = logging.getLogger(__name__)

# Simple in-memory rate limiter (use Redis in production)
rate_limiter_storage: Dict[str, Dict] = {}

security = HTTPBearer()


def verify_api_key(credentials: HTTPAuthorizationCredentials = Security(security)) -> str:
    """
    Verify API key authentication.
    
    Args:
        credentials: HTTP authorization credentials
        
    Returns:
        API key if valid
        
    Raises:
        HTTPException: If API key is invalid
    """
    if credentials.credentials != settings.api_key:
        logger.warning(f"Invalid API key attempt: {credentials.credentials[:10]}...")
        raise HTTPException(
            status_code=401,
            detail="Invalid API key"
        )
    
    return credentials.credentials


def rate_limit(request: Request, api_key: str = Depends(verify_api_key)) -> None:
    """
    Rate limiting middleware.
    
    Args:
        request: FastAPI request object
        api_key: Verified API key
        
    Raises:
        HTTPException: If rate limit exceeded
    """
    client_id = api_key  # Use API key as client identifier
    current_time = int(time.time())
    current_hour = current_time // 3600  # Hour bucket
    
    if client_id not in rate_limiter_storage:
        rate_limiter_storage[client_id] = {}
    
    client_data = rate_limiter_storage[client_id]
    
    # Clean old hour data
    old_hours = [hour for hour in client_data.keys() if hour < current_hour - 1]
    for old_hour in old_hours:
        del client_data[old_hour]
    
    # Check current hour rate limit
    if current_hour not in client_data:
        client_data[current_hour] = 0
    
    if client_data[current_hour] >= settings.rate_limit_per_hour:
        logger.warning(f"Rate limit exceeded for API key: {api_key[:10]}...")
        raise HTTPException(
            status_code=429,
            detail=f"Rate limit exceeded. Maximum {settings.rate_limit_per_hour} requests per hour."
        )
    
    # Increment request count
    client_data[current_hour] += 1
    
    logger.debug(f"Rate limit check passed: {client_data[current_hour]}/{settings.rate_limit_per_hour}")


# Optional dependency for endpoints that don't require auth (like health check)
def optional_auth(credentials: HTTPAuthorizationCredentials = Security(security, auto_error=False)) -> str:
    """
    Optional authentication that doesn't raise errors.
    
    Args:
        credentials: HTTP authorization credentials (optional)
        
    Returns:
        API key if provided and valid, empty string otherwise
    """
    if not credentials:
        return ""
    
    try:
        return verify_api_key(credentials)
    except HTTPException:
        return ""