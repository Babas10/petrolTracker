"""
Redis cache service for exchange rates.
"""
import json
import redis.asyncio as redis
from typing import Optional, List, Dict, Any
from datetime import date, datetime, timedelta
from decimal import Decimal
from app.core.config import settings
from app.models.exchange_rate import ExchangeRateResponse
import logging

logger = logging.getLogger(__name__)


class CacheService:
    """Redis-based caching service for exchange rates."""
    
    def __init__(self):
        self.redis_client: Optional[redis.Redis] = None
    
    async def connect(self):
        """Connect to Redis."""
        try:
            self.redis_client = redis.from_url(
                settings.redis_url,
                encoding="utf-8",
                decode_responses=True
            )
            await self.redis_client.ping()
            logger.info("Connected to Redis successfully")
        except Exception as e:
            logger.error(f"Failed to connect to Redis: {e}")
            self.redis_client = None
    
    async def disconnect(self):
        """Disconnect from Redis."""
        if self.redis_client:
            await self.redis_client.close()
            logger.info("Disconnected from Redis")
    
    async def is_connected(self) -> bool:
        """Check if Redis is connected."""
        if not self.redis_client:
            return False
        try:
            await self.redis_client.ping()
            return True
        except:
            return False
    
    def _rate_key(self, base: str, target: str, date: date) -> str:
        """Generate cache key for exchange rate."""
        return f"rate:{base}:{target}:{date.isoformat()}"
    
    def _latest_rates_key(self, base: str) -> str:
        """Generate cache key for latest rates."""
        return f"latest_rates:{base}"
    
    async def get_rate(self, base: str, target: str, date: date) -> Optional[Decimal]:
        """Get cached exchange rate."""
        if not await self.is_connected():
            return None
        
        try:
            key = self._rate_key(base, target, date)
            cached_rate = await self.redis_client.get(key)
            if cached_rate:
                return Decimal(cached_rate)
        except Exception as e:
            logger.error(f"Cache get_rate error: {e}")
        
        return None
    
    async def set_rate(self, base: str, target: str, date: date, rate: Decimal, ttl: int = None) -> bool:
        """Cache exchange rate."""
        if not await self.is_connected():
            return False
        
        try:
            key = self._rate_key(base, target, date)
            ttl_seconds = ttl or settings.cache_ttl_seconds
            await self.redis_client.setex(key, ttl_seconds, str(rate))
            return True
        except Exception as e:
            logger.error(f"Cache set_rate error: {e}")
            return False
    
    async def get_latest_rates(self, base: str) -> Optional[Dict[str, Any]]:
        """Get cached latest rates for base currency."""
        if not await self.is_connected():
            return None
        
        try:
            key = self._latest_rates_key(base)
            cached_data = await self.redis_client.get(key)
            if cached_data:
                return json.loads(cached_data)
        except Exception as e:
            logger.error(f"Cache get_latest_rates error: {e}")
        
        return None
    
    async def set_latest_rates(self, base: str, rates: Dict[str, Any], ttl: int = None) -> bool:
        """Cache latest rates for base currency."""
        if not await self.is_connected():
            return False
        
        try:
            key = self._latest_rates_key(base)
            ttl_seconds = ttl or settings.cache_ttl_seconds
            await self.redis_client.setex(key, ttl_seconds, json.dumps(rates, default=str))
            return True
        except Exception as e:
            logger.error(f"Cache set_latest_rates error: {e}")
            return False
    
    async def delete_rate(self, base: str, target: str, date: date) -> bool:
        """Delete cached exchange rate."""
        if not await self.is_connected():
            return False
        
        try:
            key = self._rate_key(base, target, date)
            await self.redis_client.delete(key)
            return True
        except Exception as e:
            logger.error(f"Cache delete_rate error: {e}")
            return False
    
    async def clear_cache(self) -> bool:
        """Clear all cached data."""
        if not await self.is_connected():
            return False
        
        try:
            await self.redis_client.flushdb()
            logger.info("Cache cleared successfully")
            return True
        except Exception as e:
            logger.error(f"Cache clear error: {e}")
            return False
    
    async def get_cache_stats(self) -> Dict[str, Any]:
        """Get cache statistics for monitoring."""
        if not await self.is_connected():
            return {"status": "disconnected"}
        
        try:
            info = await self.redis_client.info()
            
            # Count keys by type for better visibility
            rate_keys = len(await self.redis_client.keys("rate:*"))
            latest_keys = len(await self.redis_client.keys("latest_rates:*"))
            
            return {
                "status": "connected",
                "total_keys": info.get("db0", {}).get("keys", 0),
                "rate_cache_keys": rate_keys,
                "latest_rates_keys": latest_keys,
                "memory_usage": info.get("used_memory_human", "N/A"),
                "uptime_seconds": info.get("uptime_in_seconds", 0),
                "cache_ttl_hours": settings.cache_ttl_seconds // 3600
            }
        except Exception as e:
            logger.error(f"Cache stats error: {e}")
            return {"status": "error", "message": str(e)}


# Global cache service instance
cache_service = CacheService()