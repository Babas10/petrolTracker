"""
Pytest configuration and shared fixtures.
"""
import pytest
import asyncio
from decimal import Decimal
from datetime import date, datetime
from unittest.mock import AsyncMock, MagicMock, patch

# Configure asyncio for pytest
pytest_plugins = ('pytest_asyncio',)


@pytest.fixture(scope="session")
def event_loop():
    """Create an instance of the default event loop for the test session."""
    loop = asyncio.new_event_loop()
    yield loop
    loop.close()


@pytest.fixture
def mock_settings():
    """Mock settings for testing."""
    settings_mock = MagicMock()
    settings_mock.api_key = "dev-api-key"
    settings_mock.rate_limit_per_hour = 1000
    settings_mock.base_currency = "USD"
    settings_mock.cache_ttl_seconds = 86400
    settings_mock.debug = True
    settings_mock.version = "1.0.0"
    settings_mock.app_name = "Currency Exchange Rate Microservice"
    settings_mock.supported_currencies = [
        "USD", "EUR", "GBP", "CAD", "AUD", "JPY", "CHF", "CNY",
        "INR", "MXN", "BRL", "KRW", "SGD", "NZD", "NOK", "SEK",
        "DKK", "PLN", "CZK", "HUF", "TRY", "ZAR", "THB"
    ]
    settings_mock.exchange_api_key = "test_exchange_key"
    settings_mock.fixer_api_key = "test_fixer_key"
    return settings_mock


@pytest.fixture
def sample_exchange_rate_create():
    """Sample ExchangeRateCreate object."""
    from app.models.exchange_rate import ExchangeRateCreate
    return ExchangeRateCreate(
        base_currency="USD",
        target_currency="EUR",
        rate=Decimal("0.85"),
        rate_date=date.today()
    )


@pytest.fixture
def sample_exchange_rate_response():
    """Sample ExchangeRateResponse object."""
    from app.models.exchange_rate import ExchangeRateResponse
    return ExchangeRateResponse(
        id=1,
        base_currency="USD",
        target_currency="EUR",
        rate=Decimal("0.85"),
        rate_date=date.today(),
        created_at=datetime.now()
    )


@pytest.fixture
def sample_currency_conversion():
    """Sample CurrencyConversion object."""
    from app.models.exchange_rate import CurrencyConversion
    return CurrencyConversion(
        original_amount=Decimal("100.00"),
        original_currency="USD",
        converted_amount=Decimal("85.00"),
        target_currency="EUR",
        exchange_rate=Decimal("0.85"),
        rate_date=date.today()
    )


@pytest.fixture
def mock_database_session():
    """Mock database session."""
    mock_session = AsyncMock()
    mock_session.execute.return_value.scalar_one_or_none.return_value = None
    mock_session.execute.return_value.scalars.return_value.all.return_value = []
    return mock_session


@pytest.fixture
def mock_redis_client():
    """Mock Redis client."""
    mock_redis = AsyncMock()
    mock_redis.ping.return_value = True
    mock_redis.get.return_value = None
    mock_redis.set.return_value = True
    mock_redis.setex.return_value = True
    mock_redis.delete.return_value = 1
    mock_redis.keys.return_value = []
    mock_redis.info.return_value = {
        "db0": {"keys": 0},
        "used_memory_human": "1MB",
        "uptime_in_seconds": 3600
    }
    return mock_redis


@pytest.fixture
def sample_external_api_response():
    """Sample external API response."""
    return {
        "success": True,
        "base": "USD",
        "date": str(date.today()),
        "rates": {
            "EUR": 0.85,
            "GBP": 0.75,
            "JPY": 110.0,
            "CAD": 1.25,
            "AUD": 1.35,
            "CHF": 0.90,
            "CNY": 7.0,
            "INR": 80.0
        }
    }


@pytest.fixture
def auth_headers():
    """Authentication headers for API testing."""
    return {"Authorization": "Bearer dev-api-key"}


@pytest.fixture
def invalid_auth_headers():
    """Invalid authentication headers for testing."""
    return {"Authorization": "Bearer invalid-key"}


# Async test utilities
def async_test(coro):
    """Decorator to run async tests."""
    def wrapper(*args, **kwargs):
        loop = asyncio.new_event_loop()
        try:
            return loop.run_until_complete(coro(*args, **kwargs))
        finally:
            loop.close()
    return wrapper


# Mock data generators
def generate_mock_rates(base_currency="USD", count=5):
    """Generate mock exchange rates."""
    currencies = ["EUR", "GBP", "JPY", "CAD", "AUD"][:count]
    rates = {}
    
    for i, currency in enumerate(currencies):
        rates[currency] = {
            "id": i + 1,
            "base_currency": base_currency,
            "target_currency": currency,
            "rate": str(0.8 + (i * 0.1)),  # Generate different rates
            "rate_date": str(date.today()),
            "created_at": datetime.now().isoformat()
        }
    
    return rates


def generate_mock_conversion(amount=100, from_currency="USD", to_currency="EUR", rate=0.85):
    """Generate mock currency conversion."""
    return {
        "original_amount": str(amount),
        "original_currency": from_currency,
        "converted_amount": str(amount * rate),
        "target_currency": to_currency,
        "exchange_rate": str(rate),
        "rate_date": str(date.today())
    }


# Test data validation
def validate_exchange_rate_response(data):
    """Validate exchange rate response structure."""
    required_fields = ["base_currency", "target_currency", "rate", "rate_date", "id", "created_at"]
    return all(field in data for field in required_fields)


def validate_currency_conversion_response(data):
    """Validate currency conversion response structure."""
    required_fields = ["original_amount", "original_currency", "converted_amount", 
                      "target_currency", "exchange_rate", "rate_date"]
    return all(field in data for field in required_fields)


def validate_health_response(data):
    """Validate health check response structure."""
    required_fields = ["status", "timestamp", "version", "database", "redis"]
    return all(field in data for field in required_fields)