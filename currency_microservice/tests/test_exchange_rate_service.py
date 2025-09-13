"""
Tests for exchange rate service.
"""
import pytest
import asyncio
from decimal import Decimal
from datetime import date, datetime
from unittest.mock import AsyncMock, MagicMock, patch

from app.services.exchange_rate_service import ExchangeRateService
from app.models.exchange_rate import ExchangeRateCreate, ExchangeRateResponse


@pytest.fixture
def exchange_service():
    """Create exchange rate service instance."""
    return ExchangeRateService()


@pytest.fixture
def mock_db():
    """Create mock database session."""
    return AsyncMock()


@pytest.fixture
def sample_rate_data():
    """Sample exchange rate data."""
    return ExchangeRateCreate(
        base_currency="USD",
        target_currency="EUR",
        rate=Decimal("0.85"),
        date=date.today()
    )


@pytest.mark.asyncio
async def test_get_rate_from_cache(exchange_service, mock_db):
    """Test getting exchange rate from cache."""
    # Mock cache service
    with patch('app.services.exchange_rate_service.cache_service') as mock_cache:
        mock_cache.get_rate.return_value = Decimal("0.85")
        
        result = await exchange_service.get_rate(mock_db, "USD", "EUR", date.today())
        
        assert result is not None
        assert result.base_currency == "USD"
        assert result.target_currency == "EUR"
        assert result.rate == Decimal("0.85")


@pytest.mark.asyncio
async def test_get_rate_from_database(exchange_service, mock_db):
    """Test getting exchange rate from database when not in cache."""
    # Mock cache miss
    with patch('app.services.exchange_rate_service.cache_service') as mock_cache:
        mock_cache.get_rate.return_value = None
        mock_cache.set_rate.return_value = True
        
        # Mock database response
        mock_rate = MagicMock()
        mock_rate.base_currency = "USD"
        mock_rate.target_currency = "EUR"
        mock_rate.rate = Decimal("0.85")
        mock_rate.date = date.today()
        mock_rate.created_at = datetime.now()
        mock_rate.id = 1
        
        mock_db.execute.return_value.scalar_one_or_none.return_value = mock_rate
        
        result = await exchange_service.get_rate(mock_db, "USD", "EUR", date.today())
        
        assert result is not None
        assert result.base_currency == "USD"
        assert result.target_currency == "EUR"
        assert result.rate == Decimal("0.85")


@pytest.mark.asyncio
async def test_convert_currency_same_currency(exchange_service, mock_db):
    """Test currency conversion with same currency."""
    result = await exchange_service.convert_currency(
        mock_db, Decimal("100"), "USD", "USD", date.today()
    )
    
    assert result is not None
    assert result.original_amount == Decimal("100")
    assert result.converted_amount == Decimal("100")
    assert result.exchange_rate == Decimal("1.0")


@pytest.mark.asyncio
async def test_convert_currency_with_rate(exchange_service, mock_db):
    """Test currency conversion with exchange rate."""
    # Mock get_rate to return a rate
    with patch.object(exchange_service, 'get_rate') as mock_get_rate:
        mock_rate = ExchangeRateResponse(
            id=1,
            base_currency="USD",
            target_currency="EUR",
            rate=Decimal("0.85"),
            date=date.today(),
            created_at=datetime.now()
        )
        mock_get_rate.return_value = mock_rate
        
        result = await exchange_service.convert_currency(
            mock_db, Decimal("100"), "USD", "EUR", date.today()
        )
        
        assert result is not None
        assert result.original_amount == Decimal("100")
        assert result.converted_amount == Decimal("85.0")
        assert result.exchange_rate == Decimal("0.85")


@pytest.mark.asyncio
async def test_fetch_and_store_daily_rates_success(exchange_service, mock_db):
    """Test successful daily rate fetching."""
    # Mock external API
    with patch.object(exchange_service.external_api, 'fetch_exchange_rates') as mock_fetch:
        mock_fetch.return_value = {
            "EUR": Decimal("0.85"),
            "GBP": Decimal("0.75"),
            "JPY": Decimal("110.0")
        }
        
        # Mock validate_rate
        with patch.object(exchange_service.external_api, 'validate_rate') as mock_validate:
            mock_validate.return_value = True
            
            # Mock create_rate
            with patch.object(exchange_service, 'create_rate') as mock_create:
                mock_create.return_value = MagicMock()
                
                result = await exchange_service.fetch_and_store_daily_rates(mock_db, "USD")
                
                assert result is True
                assert mock_create.call_count == 3  # Called for each currency


@pytest.mark.asyncio
async def test_fetch_and_store_daily_rates_api_failure(exchange_service, mock_db):
    """Test daily rate fetching when external API fails."""
    # Mock external API failure
    with patch.object(exchange_service.external_api, 'fetch_exchange_rates') as mock_fetch:
        mock_fetch.return_value = None
        
        result = await exchange_service.fetch_and_store_daily_rates(mock_db, "USD")
        
        assert result is False


if __name__ == "__main__":
    pytest.main([__file__])