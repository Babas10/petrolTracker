"""
Tests for external API service.
"""
import pytest
from decimal import Decimal
from unittest.mock import AsyncMock, MagicMock, patch
import httpx

from app.services.external_api_service import ExternalAPIService


@pytest.fixture
def external_api_service():
    """Create external API service instance."""
    return ExternalAPIService()


@pytest.fixture
def mock_exchange_rates():
    """Mock exchange rates data."""
    return {
        "EUR": Decimal("0.85"),
        "GBP": Decimal("0.75"),
        "JPY": Decimal("110.0"),
        "CAD": Decimal("1.25"),
        "AUD": Decimal("1.35")
    }


class TestSupportedCurrencies:
    """Test supported currencies functionality."""
    
    def test_get_supported_currencies_from_config(self, external_api_service):
        """Test getting supported currencies from configuration."""
        with patch('app.services.external_api_service.settings') as mock_settings:
            mock_settings.supported_currencies = ["USD", "EUR", "GBP", "JPY"]
            
            currencies = external_api_service.get_supported_currencies()
            
            assert len(currencies) == 4
            assert "USD" in currencies
            assert "EUR" in currencies
            assert "GBP" in currencies
            assert "JPY" in currencies
    
    def test_supported_currencies_are_uppercase(self, external_api_service):
        """Test that all supported currencies are returned in uppercase."""
        with patch('app.services.external_api_service.settings') as mock_settings:
            mock_settings.supported_currencies = ["usd", "eur", "gbp"]
            
            currencies = external_api_service.get_supported_currencies()
            
            assert all(c.isupper() for c in currencies)


class TestRateValidation:
    """Test exchange rate validation logic."""
    
    @pytest.mark.asyncio
    async def test_validate_rate_valid_ranges(self, external_api_service):
        """Test validation of rates within expected ranges."""
        # Test various currency pairs with realistic rates
        test_cases = [
            ("USD", "EUR", Decimal("0.85")),    # Normal EUR rate
            ("USD", "GBP", Decimal("0.75")),    # Normal GBP rate
            ("USD", "JPY", Decimal("110.0")),   # Normal JPY rate
            ("USD", "CAD", Decimal("1.25")),    # Normal CAD rate
            ("USD", "CHF", Decimal("0.90")),    # Normal CHF rate
        ]
        
        for base, target, rate in test_cases:
            is_valid = await external_api_service.validate_rate(base, target, rate)
            assert is_valid, f"Rate {rate} for {base}/{target} should be valid"
    
    @pytest.mark.asyncio
    async def test_validate_rate_invalid_ranges(self, external_api_service):
        """Test validation rejects rates outside expected ranges."""
        test_cases = [
            ("USD", "EUR", Decimal("0.001")),   # Too low for EUR
            ("USD", "EUR", Decimal("2.0")),     # Too high for EUR
            ("USD", "JPY", Decimal("50.0")),    # Too low for JPY
            ("USD", "JPY", Decimal("200.0")),   # Too high for JPY
            ("USD", "GBP", Decimal("0.3")),     # Too low for GBP
            ("USD", "GBP", Decimal("1.5")),     # Too high for GBP
        ]
        
        for base, target, rate in test_cases:
            is_valid = await external_api_service.validate_rate(base, target, rate)
            assert not is_valid, f"Rate {rate} for {base}/{target} should be invalid"
    
    @pytest.mark.asyncio
    async def test_validate_rate_zero_negative(self, external_api_service):
        """Test validation rejects zero and negative rates."""
        test_cases = [
            ("USD", "EUR", Decimal("0")),
            ("USD", "EUR", Decimal("-0.85")),
            ("USD", "JPY", Decimal("-110.0")),
        ]
        
        for base, target, rate in test_cases:
            is_valid = await external_api_service.validate_rate(base, target, rate)
            assert not is_valid, f"Rate {rate} for {base}/{target} should be invalid"
    
    @pytest.mark.asyncio
    async def test_validate_rate_unsupported_currency(self, external_api_service):
        """Test validation for unsupported currencies."""
        is_valid = await external_api_service.validate_rate("USD", "XYZ", Decimal("1.0"))
        assert not is_valid


class TestExchangeRateFetching:
    """Test exchange rate fetching from external APIs."""
    
    @pytest.mark.asyncio
    async def test_fetch_exchange_rates_success(self, external_api_service, mock_exchange_rates):
        """Test successful rate fetching."""
        # Mock successful API response
        mock_response = {
            "success": True,
            "rates": {
                "EUR": 0.85,
                "GBP": 0.75,
                "JPY": 110.0,
                "CAD": 1.25,
                "AUD": 1.35
            }
        }
        
        with patch('httpx.AsyncClient.get') as mock_get:
            mock_get.return_value.status_code = 200
            mock_get.return_value.json.return_value = mock_response
            
            rates = await external_api_service.fetch_exchange_rates("USD")
            
            assert rates is not None
            assert len(rates) == 5
            assert rates["EUR"] == Decimal("0.85")
            assert rates["GBP"] == Decimal("0.75")
            assert rates["JPY"] == Decimal("110.0")
    
    @pytest.mark.asyncio
    async def test_fetch_exchange_rates_api_error(self, external_api_service):
        """Test handling of API errors."""
        with patch('httpx.AsyncClient.get') as mock_get:
            mock_get.return_value.status_code = 500
            
            rates = await external_api_service.fetch_exchange_rates("USD")
            
            assert rates is None
    
    @pytest.mark.asyncio
    async def test_fetch_exchange_rates_network_error(self, external_api_service):
        """Test handling of network errors."""
        with patch('httpx.AsyncClient.get') as mock_get:
            mock_get.side_effect = httpx.RequestError("Network error", request=None)
            
            rates = await external_api_service.fetch_exchange_rates("USD")
            
            assert rates is None
    
    @pytest.mark.asyncio
    async def test_fetch_exchange_rates_invalid_json(self, external_api_service):
        """Test handling of invalid JSON responses."""
        with patch('httpx.AsyncClient.get') as mock_get:
            mock_get.return_value.status_code = 200
            mock_get.return_value.json.side_effect = ValueError("Invalid JSON")
            
            rates = await external_api_service.fetch_exchange_rates("USD")
            
            assert rates is None
    
    @pytest.mark.asyncio
    async def test_fetch_exchange_rates_missing_rates(self, external_api_service):
        """Test handling of responses missing rates data."""
        mock_response = {
            "success": True,
            # Missing 'rates' key
        }
        
        with patch('httpx.AsyncClient.get') as mock_get:
            mock_get.return_value.status_code = 200
            mock_get.return_value.json.return_value = mock_response
            
            rates = await external_api_service.fetch_exchange_rates("USD")
            
            assert rates is None
    
    @pytest.mark.asyncio
    async def test_fetch_exchange_rates_api_failure_response(self, external_api_service):
        """Test handling of API failure responses."""
        mock_response = {
            "success": False,
            "error": {
                "code": 101,
                "info": "API key invalid"
            }
        }
        
        with patch('httpx.AsyncClient.get') as mock_get:
            mock_get.return_value.status_code = 200
            mock_get.return_value.json.return_value = mock_response
            
            rates = await external_api_service.fetch_exchange_rates("USD")
            
            assert rates is None


class TestExternalAPIFallback:
    """Test fallback between multiple external APIs."""
    
    @pytest.mark.asyncio
    async def test_api_fallback_sequence(self, external_api_service):
        """Test that service falls back to alternative APIs when primary fails."""
        # This test assumes the service has multiple API sources
        # We'll mock the internal _try_exchange_api and _try_fixer_api methods
        
        with patch.object(external_api_service, '_try_exchange_api') as mock_exchange:
            with patch.object(external_api_service, '_try_fixer_api') as mock_fixer:
                # Primary API fails
                mock_exchange.return_value = None
                
                # Secondary API succeeds
                mock_fixer.return_value = {
                    "EUR": Decimal("0.85"),
                    "GBP": Decimal("0.75")
                }
                
                rates = await external_api_service.fetch_exchange_rates("USD")
                
                assert rates is not None
                assert mock_exchange.called
                assert mock_fixer.called
    
    @pytest.mark.asyncio
    async def test_all_apis_fail(self, external_api_service):
        """Test behavior when all external APIs fail."""
        with patch.object(external_api_service, '_try_exchange_api') as mock_exchange:
            with patch.object(external_api_service, '_try_fixer_api') as mock_fixer:
                # All APIs fail
                mock_exchange.return_value = None
                mock_fixer.return_value = None
                
                rates = await external_api_service.fetch_exchange_rates("USD")
                
                assert rates is None
                assert mock_exchange.called
                assert mock_fixer.called


class TestRateProcessing:
    """Test rate data processing and conversion."""
    
    @pytest.mark.asyncio
    async def test_rate_decimal_conversion(self, external_api_service):
        """Test that rates are properly converted to Decimal objects."""
        mock_response = {
            "success": True,
            "rates": {
                "EUR": 0.85,           # float
                "GBP": "0.75",         # string
                "JPY": 110,            # int
            }
        }
        
        with patch('httpx.AsyncClient.get') as mock_get:
            mock_get.return_value.status_code = 200
            mock_get.return_value.json.return_value = mock_response
            
            rates = await external_api_service.fetch_exchange_rates("USD")
            
            assert rates is not None
            assert isinstance(rates["EUR"], Decimal)
            assert isinstance(rates["GBP"], Decimal)
            assert isinstance(rates["JPY"], Decimal)
            assert rates["EUR"] == Decimal("0.85")
            assert rates["GBP"] == Decimal("0.75")
            assert rates["JPY"] == Decimal("110")
    
    @pytest.mark.asyncio
    async def test_rate_filtering_unsupported_currencies(self, external_api_service):
        """Test that unsupported currencies are filtered out."""
        mock_response = {
            "success": True,
            "rates": {
                "EUR": 0.85,     # supported
                "GBP": 0.75,     # supported
                "XYZ": 999.99,   # unsupported
                "ABC": 1.23,     # unsupported
            }
        }
        
        with patch('httpx.AsyncClient.get') as mock_get:
            with patch('app.services.external_api_service.settings') as mock_settings:
                mock_settings.supported_currencies = ["USD", "EUR", "GBP"]
                mock_get.return_value.status_code = 200
                mock_get.return_value.json.return_value = mock_response
                
                rates = await external_api_service.fetch_exchange_rates("USD")
                
                assert rates is not None
                assert "EUR" in rates
                assert "GBP" in rates
                assert "XYZ" not in rates
                assert "ABC" not in rates


class TestAPIConfiguration:
    """Test API configuration and key management."""
    
    def test_api_key_configuration(self, external_api_service):
        """Test that API keys are properly configured."""
        with patch('app.services.external_api_service.settings') as mock_settings:
            mock_settings.exchange_api_key = "test_key_123"
            mock_settings.fixer_api_key = "fixer_key_456"
            
            # Test that service uses configured keys
            assert external_api_service._has_exchange_api_key() == bool(mock_settings.exchange_api_key)
            assert external_api_service._has_fixer_api_key() == bool(mock_settings.fixer_api_key)
    
    def test_api_without_keys(self, external_api_service):
        """Test behavior when no API keys are configured."""
        with patch('app.services.external_api_service.settings') as mock_settings:
            mock_settings.exchange_api_key = ""
            mock_settings.fixer_api_key = ""
            
            assert not external_api_service._has_exchange_api_key()
            assert not external_api_service._has_fixer_api_key()


if __name__ == "__main__":
    pytest.main([__file__])