"""
Tests for seeding service and complete data flow testing.
"""
import pytest
from unittest.mock import AsyncMock, patch
from datetime import date, datetime
from decimal import Decimal

from app.services.seeding_service import SeedingService
from app.core.config import settings


@pytest.fixture
def seeding_service():
    """Create seeding service instance."""
    return SeedingService()


@pytest.fixture
def mock_db():
    """Create mock database session."""
    return AsyncMock()


@pytest.mark.asyncio
async def test_currency_ranges_realistic(seeding_service):
    """Test that currency ranges are realistic."""
    ranges = seeding_service.CURRENCY_RANGES
    
    # Should have major currencies
    assert "EUR" in ranges
    assert "GBP" in ranges
    assert "JPY" in ranges
    assert "CAD" in ranges
    
    # EUR range should be reasonable (0.80-0.95)
    eur_min, eur_max = ranges["EUR"]
    assert 0.70 < eur_min < 0.90
    assert 0.85 < eur_max < 1.00
    
    # JPY range should be reasonable (100-160)
    jpy_min, jpy_max = ranges["JPY"]
    assert 90 < jpy_min < 120
    assert 140 < jpy_max < 180


@pytest.mark.asyncio
async def test_seed_test_currency_data_success(seeding_service, mock_db):
    """Test successful currency data seeding."""
    with patch('app.services.seeding_service.exchange_rate_service') as mock_exchange:
        with patch('app.services.seeding_service.cache_service') as mock_cache:
            # Mock successful rate creation
            mock_exchange.create_rate.return_value = AsyncMock()
            mock_exchange.get_latest_rates.return_value = {"EUR": {}, "GBP": {}}
            mock_cache.clear_cache.return_value = True
            
            result = await seeding_service.seed_test_currency_data(
                db=mock_db,
                base_currency="USD",
                clear_existing=False
            )
            
            assert result["status"] == "success"
            assert result["base_currency"] == "USD"
            assert result["rates_created"] > 0
            assert "currencies" in result
            assert result["cache_warmed"] is True


@pytest.mark.asyncio
async def test_seed_test_currency_data_realistic_rates(seeding_service, mock_db):
    """Test that seeded rates are within realistic ranges."""
    created_rates = []
    
    # Capture created rates
    async def mock_create_rate(db, rate_data):
        created_rates.append(rate_data)
        return AsyncMock()
    
    with patch('app.services.seeding_service.exchange_rate_service') as mock_exchange:
        with patch('app.services.seeding_service.cache_service') as mock_cache:
            mock_exchange.create_rate.side_effect = mock_create_rate
            mock_exchange.get_latest_rates.return_value = {}
            mock_cache.clear_cache.return_value = True
            
            await seeding_service.seed_test_currency_data(mock_db, "USD")
            
            # Verify rates are within realistic ranges
            for rate_data in created_rates:
                currency = rate_data.target_currency
                rate_value = float(rate_data.rate)
                
                if currency in seeding_service.CURRENCY_RANGES:
                    min_rate, max_rate = seeding_service.CURRENCY_RANGES[currency]
                    assert min_rate <= rate_value <= max_rate, \
                        f"{currency} rate {rate_value} not in range [{min_rate}, {max_rate}]"


@pytest.mark.asyncio
async def test_generate_sample_conversions(seeding_service, mock_db):
    """Test sample conversion generation."""
    # Mock conversion service
    with patch('app.services.seeding_service.exchange_rate_service') as mock_exchange:
        mock_conversion = AsyncMock()
        mock_conversion.converted_amount = Decimal("85.0")
        mock_conversion.exchange_rate = Decimal("0.85")
        mock_exchange.convert_currency.return_value = mock_conversion
        
        conversions = await seeding_service.generate_sample_conversions(mock_db, "USD")
        
        assert len(conversions) > 0
        
        # Check conversion structure
        conversion = conversions[0]
        assert "from_amount" in conversion
        assert "from_currency" in conversion
        assert "to_amount" in conversion
        assert "to_currency" in conversion
        assert "exchange_rate" in conversion
        assert "formatted" in conversion


@pytest.mark.asyncio
async def test_get_seeding_status(seeding_service, mock_db):
    """Test seeding status retrieval."""
    with patch('app.services.seeding_service.cache_service') as mock_cache:
        # Mock database query results
        mock_result = AsyncMock()
        mock_result.scalars.return_value.all.return_value = ["rate1", "rate2", "rate3"]
        mock_db.execute.return_value = mock_result
        
        # Mock cache stats
        mock_cache.get_cache_stats.return_value = {
            "status": "connected",
            "total_keys": 10
        }
        
        status = await seeding_service.get_seeding_status(mock_db)
        
        assert "database" in status
        assert "cache" in status
        assert "test_data_available" in status
        assert "ready_for_testing" in status


@pytest.mark.asyncio
async def test_clear_existing_data(seeding_service, mock_db):
    """Test clearing existing data."""
    test_date = date.today()
    
    await seeding_service._clear_existing_data(mock_db, test_date)
    
    # Verify delete was called
    mock_db.execute.assert_called_once()
    mock_db.commit.assert_called_once()


def test_currency_ranges_completeness(seeding_service):
    """Test that we have ranges for all major currencies."""
    expected_currencies = [
        "EUR", "GBP", "JPY", "CAD", "AUD", "CHF", "CNY", 
        "INR", "MXN", "BRL", "KRW", "SGD", "NZD"
    ]
    
    ranges = seeding_service.CURRENCY_RANGES
    
    for currency in expected_currencies:
        assert currency in ranges, f"Missing range for {currency}"
        
        min_rate, max_rate = ranges[currency]
        assert min_rate < max_rate, f"Invalid range for {currency}: [{min_rate}, {max_rate}]"
        assert min_rate > 0, f"Negative minimum rate for {currency}"


if __name__ == "__main__":
    pytest.main([__file__])