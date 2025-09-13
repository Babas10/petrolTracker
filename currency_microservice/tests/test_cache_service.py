"""
Tests for cache service with daily cache optimization.
"""
import pytest
import json
from unittest.mock import AsyncMock, MagicMock, patch
from datetime import date, datetime
from decimal import Decimal

from app.services.cache_service import CacheService
from app.core.config import settings


@pytest.fixture
def cache_service():
    """Create cache service instance."""
    service = CacheService()
    # Mock Redis client for testing
    service.redis_client = AsyncMock()
    return service


@pytest.fixture
def sample_rates():
    """Sample exchange rate data."""
    return {
        "EUR": {
            "id": 1,
            "base_currency": "USD",
            "target_currency": "EUR", 
            "rate": "0.85",
            "date": "2023-12-01",
            "created_at": "2023-12-01T06:00:00Z"
        },
        "GBP": {
            "id": 2,
            "base_currency": "USD",
            "target_currency": "GBP",
            "rate": "0.75", 
            "date": "2023-12-01",
            "created_at": "2023-12-01T06:00:00Z"
        }
    }


@pytest.mark.asyncio
async def test_get_cache_stats_connected(cache_service):
    """Test cache stats when Redis is connected."""
    # Mock Redis info response
    cache_service.redis_client.ping.return_value = True
    cache_service.redis_client.info.return_value = {
        "db0": {"keys": 10},
        "used_memory_human": "1.2MB",
        "uptime_in_seconds": 3600
    }
    cache_service.redis_client.keys.return_value = ["rate:USD:EUR:2023-12-01", "rate:USD:GBP:2023-12-01"]
    
    stats = await cache_service.get_cache_stats()
    
    assert stats["status"] == "connected"
    assert stats["total_keys"] == 10
    assert stats["rate_cache_keys"] == 2
    assert stats["memory_usage"] == "1.2MB"
    assert stats["cache_ttl_hours"] == 24  # 86400 seconds / 3600


@pytest.mark.asyncio
async def test_get_cache_stats_disconnected(cache_service):
    """Test cache stats when Redis is disconnected."""
    cache_service.redis_client = None
    
    stats = await cache_service.get_cache_stats()
    
    assert stats["status"] == "disconnected"


@pytest.mark.asyncio
async def test_get_cache_stats_error(cache_service):
    """Test cache stats when Redis throws an error."""
    cache_service.redis_client.ping.return_value = True
    cache_service.redis_client.info.side_effect = Exception("Redis error")
    
    stats = await cache_service.get_cache_stats()
    
    assert stats["status"] == "error"
    assert "message" in stats


@pytest.mark.asyncio
async def test_set_latest_rates_with_24h_ttl(cache_service, sample_rates):
    """Test setting latest rates with 24-hour TTL."""
    cache_service.redis_client.ping.return_value = True
    
    success = await cache_service.set_latest_rates("USD", sample_rates)
    
    assert success is True
    
    # Verify Redis setex was called with 24-hour TTL
    cache_service.redis_client.setex.assert_called_once()
    call_args = cache_service.redis_client.setex.call_args
    
    # Check key format
    assert call_args[0][0] == "latest_rates:USD"
    
    # Check TTL is 24 hours (86400 seconds)
    assert call_args[0][1] == 86400
    
    # Check data is JSON encoded
    assert json.loads(call_args[0][2]) == sample_rates


@pytest.mark.asyncio
async def test_get_latest_rates_cache_hit(cache_service, sample_rates):
    """Test getting latest rates from cache."""
    cache_service.redis_client.ping.return_value = True
    cache_service.redis_client.get.return_value = json.dumps(sample_rates, default=str)
    
    result = await cache_service.get_latest_rates("USD")
    
    assert result == sample_rates
    cache_service.redis_client.get.assert_called_once_with("latest_rates:USD")


@pytest.mark.asyncio
async def test_get_latest_rates_cache_miss(cache_service):
    """Test getting latest rates when not cached."""
    cache_service.redis_client.ping.return_value = True
    cache_service.redis_client.get.return_value = None
    
    result = await cache_service.get_latest_rates("USD")
    
    assert result is None


@pytest.mark.asyncio
async def test_set_rate_with_24h_ttl(cache_service):
    """Test setting individual rate with 24-hour TTL."""
    cache_service.redis_client.ping.return_value = True
    test_date = date(2023, 12, 1)
    test_rate = Decimal("0.85")
    
    success = await cache_service.set_rate("USD", "EUR", test_date, test_rate)
    
    assert success is True
    
    # Verify Redis setex was called with correct parameters
    cache_service.redis_client.setex.assert_called_once_with(
        "rate:USD:EUR:2023-12-01",
        86400,  # 24 hours
        "0.85"
    )


@pytest.mark.asyncio
async def test_cache_key_formats(cache_service):
    """Test cache key generation formats."""
    test_date = date(2023, 12, 1)
    
    # Test individual rate key
    rate_key = cache_service._rate_key("USD", "EUR", test_date)
    assert rate_key == "rate:USD:EUR:2023-12-01"
    
    # Test latest rates key
    latest_key = cache_service._latest_rates_key("USD")
    assert latest_key == "latest_rates:USD"


@pytest.mark.asyncio
async def test_cache_operations_when_disconnected(cache_service):
    """Test cache operations gracefully handle disconnection."""
    # Simulate disconnected Redis
    cache_service.redis_client.ping.side_effect = Exception("Connection refused")
    
    # All operations should return appropriate defaults without raising
    assert await cache_service.get_rate("USD", "EUR", date.today()) is None
    assert await cache_service.set_rate("USD", "EUR", date.today(), Decimal("0.85")) is False
    assert await cache_service.get_latest_rates("USD") is None
    assert await cache_service.set_latest_rates("USD", {}) is False
    assert await cache_service.clear_cache() is False


if __name__ == "__main__":
    pytest.main([__file__])