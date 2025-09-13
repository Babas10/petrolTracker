"""
Tests for currency conversion logic and calculations.
"""
import pytest
import asyncio
from decimal import Decimal, ROUND_HALF_UP
from datetime import date, datetime
from unittest.mock import AsyncMock, MagicMock, patch

from app.services.exchange_rate_service import ExchangeRateService
from app.models.exchange_rate import ExchangeRateCreate, ExchangeRateResponse, CurrencyConversion


@pytest.fixture
def exchange_service():
    """Create exchange rate service instance."""
    return ExchangeRateService()


@pytest.fixture
def mock_db():
    """Create mock database session."""
    return AsyncMock()


class TestCurrencyConversionLogic:
    """Test currency conversion calculations and logic."""
    
    @pytest.mark.asyncio
    async def test_same_currency_conversion(self, exchange_service, mock_db):
        """Test conversion between same currencies."""
        result = await exchange_service.convert_currency(
            mock_db, 
            Decimal("100.50"), 
            "USD", 
            "USD", 
            date.today()
        )
        
        assert result is not None
        assert result.original_amount == Decimal("100.50")
        assert result.converted_amount == Decimal("100.50")
        assert result.exchange_rate == Decimal("1.0")
        assert result.original_currency == "USD"
        assert result.target_currency == "USD"
    
    @pytest.mark.asyncio
    async def test_direct_rate_conversion(self, exchange_service, mock_db):
        """Test conversion using direct exchange rate."""
        mock_rate = ExchangeRateResponse(
            id=1,
            base_currency="USD",
            target_currency="EUR",
            rate=Decimal("0.85"),
            rate_date=date.today(),
            created_at=datetime.now()
        )
        
        with patch.object(exchange_service, 'get_rate') as mock_get_rate:
            mock_get_rate.return_value = mock_rate
            
            result = await exchange_service.convert_currency(
                mock_db, 
                Decimal("100"), 
                "USD", 
                "EUR", 
                date.today()
            )
            
            assert result is not None
            assert result.original_amount == Decimal("100")
            assert result.converted_amount == Decimal("85.0")
            assert result.exchange_rate == Decimal("0.85")
            assert result.original_currency == "USD"
            assert result.target_currency == "EUR"
    
    @pytest.mark.asyncio
    async def test_reverse_rate_conversion(self, exchange_service, mock_db):
        """Test conversion using reverse exchange rate."""
        # Mock: no direct rate, but reverse rate exists
        mock_reverse_rate = ExchangeRateResponse(
            id=2,
            base_currency="EUR",
            target_currency="USD",
            rate=Decimal("1.1765"),  # 1/0.85 ≈ 1.1765
            rate_date=date.today(),
            created_at=datetime.now()
        )
        
        with patch.object(exchange_service, 'get_rate') as mock_get_rate:
            # First call returns None (no direct rate), second call returns reverse rate
            mock_get_rate.side_effect = [None, mock_reverse_rate]
            
            result = await exchange_service.convert_currency(
                mock_db, 
                Decimal("100"), 
                "USD", 
                "EUR", 
                date.today()
            )
            
            assert result is not None
            assert result.original_amount == Decimal("100")
            # 100 * (1 / 1.1765) ≈ 85.0
            expected_rate = Decimal("1") / Decimal("1.1765")
            expected_amount = Decimal("100") * expected_rate
            assert abs(result.converted_amount - expected_amount) < Decimal("0.01")
            assert result.original_currency == "USD"
            assert result.target_currency == "EUR"
    
    @pytest.mark.asyncio
    async def test_no_rate_available(self, exchange_service, mock_db):
        """Test conversion when no rate is available."""
        with patch.object(exchange_service, 'get_rate') as mock_get_rate:
            # Both direct and reverse rate calls return None
            mock_get_rate.return_value = None
            
            result = await exchange_service.convert_currency(
                mock_db, 
                Decimal("100"), 
                "USD", 
                "XYZ", 
                date.today()
            )
            
            assert result is None
    
    @pytest.mark.asyncio
    async def test_precision_handling(self, exchange_service, mock_db):
        """Test precision handling in conversions."""
        mock_rate = ExchangeRateResponse(
            id=1,
            base_currency="USD",
            target_currency="JPY",
            rate=Decimal("110.123456789"),  # High precision rate
            rate_date=date.today(),
            created_at=datetime.now()
        )
        
        with patch.object(exchange_service, 'get_rate') as mock_get_rate:
            mock_get_rate.return_value = mock_rate
            
            result = await exchange_service.convert_currency(
                mock_db, 
                Decimal("1.00"), 
                "USD", 
                "JPY", 
                date.today()
            )
            
            assert result is not None
            # Should maintain high precision
            assert result.converted_amount == Decimal("110.123456789")
            assert result.exchange_rate == Decimal("110.123456789")
    
    @pytest.mark.asyncio
    async def test_large_amount_conversion(self, exchange_service, mock_db):
        """Test conversion with large amounts."""
        mock_rate = ExchangeRateResponse(
            id=1,
            base_currency="USD",
            target_currency="EUR",
            rate=Decimal("0.85"),
            rate_date=date.today(),
            created_at=datetime.now()
        )
        
        with patch.object(exchange_service, 'get_rate') as mock_get_rate:
            mock_get_rate.return_value = mock_rate
            
            large_amount = Decimal("1000000.00")  # 1 million
            result = await exchange_service.convert_currency(
                mock_db, 
                large_amount, 
                "USD", 
                "EUR", 
                date.today()
            )
            
            assert result is not None
            assert result.original_amount == large_amount
            assert result.converted_amount == Decimal("850000.00")
    
    @pytest.mark.asyncio
    async def test_small_amount_conversion(self, exchange_service, mock_db):
        """Test conversion with small amounts."""
        mock_rate = ExchangeRateResponse(
            id=1,
            base_currency="USD",
            target_currency="EUR",
            rate=Decimal("0.85"),
            rate_date=date.today(),
            created_at=datetime.now()
        )
        
        with patch.object(exchange_service, 'get_rate') as mock_get_rate:
            mock_get_rate.return_value = mock_rate
            
            small_amount = Decimal("0.01")  # 1 cent
            result = await exchange_service.convert_currency(
                mock_db, 
                small_amount, 
                "USD", 
                "EUR", 
                date.today()
            )
            
            assert result is not None
            assert result.original_amount == small_amount
            assert result.converted_amount == Decimal("0.0085")
    
    @pytest.mark.asyncio
    async def test_historical_date_conversion(self, exchange_service, mock_db):
        """Test conversion with historical date."""
        historical_date = date(2023, 1, 1)
        mock_rate = ExchangeRateResponse(
            id=1,
            base_currency="USD",
            target_currency="EUR",
            rate=Decimal("0.90"),  # Different historical rate
            rate_date=historical_date,
            created_at=datetime.now()
        )
        
        with patch.object(exchange_service, 'get_rate') as mock_get_rate:
            mock_get_rate.return_value = mock_rate
            
            result = await exchange_service.convert_currency(
                mock_db, 
                Decimal("100"), 
                "USD", 
                "EUR", 
                historical_date
            )
            
            assert result is not None
            assert result.rate_date == historical_date
            assert result.exchange_rate == Decimal("0.90")
            assert result.converted_amount == Decimal("90.0")


class TestRealWorldConversionScenarios:
    """Test real-world conversion scenarios."""
    
    @pytest.mark.asyncio
    async def test_usd_to_eur_conversion(self, exchange_service, mock_db):
        """Test realistic USD to EUR conversion."""
        mock_rate = ExchangeRateResponse(
            id=1,
            base_currency="USD",
            target_currency="EUR",
            rate=Decimal("0.825906"),  # Real rate from test data
            rate_date=date.today(),
            created_at=datetime.now()
        )
        
        with patch.object(exchange_service, 'get_rate') as mock_get_rate:
            mock_get_rate.return_value = mock_rate
            
            result = await exchange_service.convert_currency(
                mock_db, 
                Decimal("100.00"), 
                "USD", 
                "EUR", 
                date.today()
            )
            
            assert result is not None
            assert result.converted_amount == Decimal("82.5906")
    
    @pytest.mark.asyncio
    async def test_eur_to_usd_reverse_conversion(self, exchange_service, mock_db):
        """Test EUR to USD using reverse rate calculation."""
        mock_eur_usd_rate = ExchangeRateResponse(
            id=1,
            base_currency="USD",
            target_currency="EUR",
            rate=Decimal("0.825906"),
            rate_date=date.today(),
            created_at=datetime.now()
        )
        
        with patch.object(exchange_service, 'get_rate') as mock_get_rate:
            # First call (EUR to USD) returns None, second call (USD to EUR) returns rate
            mock_get_rate.side_effect = [None, mock_eur_usd_rate]
            
            result = await exchange_service.convert_currency(
                mock_db, 
                Decimal("100.00"), 
                "EUR", 
                "USD", 
                date.today()
            )
            
            assert result is not None
            # 1 / 0.825906 ≈ 1.210791542863231
            expected_rate = Decimal("1") / Decimal("0.825906")
            expected_amount = Decimal("100.00") * expected_rate
            assert abs(result.converted_amount - expected_amount) < Decimal("0.001")
    
    @pytest.mark.asyncio
    async def test_usd_to_jpy_high_rate(self, exchange_service, mock_db):
        """Test USD to JPY conversion with high exchange rate."""
        mock_rate = ExchangeRateResponse(
            id=1,
            base_currency="USD",
            target_currency="JPY",
            rate=Decimal("150.315016"),  # Real rate from test data
            rate_date=date.today(),
            created_at=datetime.now()
        )
        
        with patch.object(exchange_service, 'get_rate') as mock_get_rate:
            mock_get_rate.return_value = mock_rate
            
            result = await exchange_service.convert_currency(
                mock_db, 
                Decimal("100.00"), 
                "USD", 
                "JPY", 
                date.today()
            )
            
            assert result is not None
            assert result.converted_amount == Decimal("15031.5016")
    
    @pytest.mark.asyncio
    async def test_multiple_conversion_consistency(self, exchange_service, mock_db):
        """Test that multiple conversions maintain mathematical consistency."""
        # USD -> EUR -> USD should approximately equal original amount
        usd_eur_rate = ExchangeRateResponse(
            id=1,
            base_currency="USD",
            target_currency="EUR",
            rate=Decimal("0.85"),
            rate_date=date.today(),
            created_at=datetime.now()
        )
        
        with patch.object(exchange_service, 'get_rate') as mock_get_rate:
            # First conversion: USD to EUR
            mock_get_rate.return_value = usd_eur_rate
            
            result1 = await exchange_service.convert_currency(
                mock_db, 
                Decimal("100.00"), 
                "USD", 
                "EUR", 
                date.today()
            )
            
            assert result1 is not None
            eur_amount = result1.converted_amount
            
            # Second conversion: EUR back to USD (using reverse rate)
            mock_get_rate.side_effect = [None, usd_eur_rate]  # No direct EUR->USD, use reverse
            
            result2 = await exchange_service.convert_currency(
                mock_db, 
                eur_amount, 
                "EUR", 
                "USD", 
                date.today()
            )
            
            assert result2 is not None
            # Should be approximately 100.00 (allowing for rounding)
            assert abs(result2.converted_amount - Decimal("100.00")) < Decimal("0.01")


class TestConversionValidation:
    """Test conversion input validation and edge cases."""
    
    @pytest.mark.asyncio
    async def test_zero_amount_conversion(self, exchange_service, mock_db):
        """Test conversion with zero amount."""
        mock_rate = ExchangeRateResponse(
            id=1,
            base_currency="USD",
            target_currency="EUR",
            rate=Decimal("0.85"),
            rate_date=date.today(),
            created_at=datetime.now()
        )
        
        with patch.object(exchange_service, 'get_rate') as mock_get_rate:
            mock_get_rate.return_value = mock_rate
            
            result = await exchange_service.convert_currency(
                mock_db, 
                Decimal("0.00"), 
                "USD", 
                "EUR", 
                date.today()
            )
            
            assert result is not None
            assert result.converted_amount == Decimal("0.00")
    
    @pytest.mark.asyncio
    async def test_negative_amount_conversion(self, exchange_service, mock_db):
        """Test conversion with negative amount (representing debt/credit)."""
        mock_rate = ExchangeRateResponse(
            id=1,
            base_currency="USD",
            target_currency="EUR",
            rate=Decimal("0.85"),
            rate_date=date.today(),
            created_at=datetime.now()
        )
        
        with patch.object(exchange_service, 'get_rate') as mock_get_rate:
            mock_get_rate.return_value = mock_rate
            
            result = await exchange_service.convert_currency(
                mock_db, 
                Decimal("-100.00"), 
                "USD", 
                "EUR", 
                date.today()
            )
            
            assert result is not None
            assert result.converted_amount == Decimal("-85.00")


if __name__ == "__main__":
    pytest.main([__file__])