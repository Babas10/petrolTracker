"""
Tests for API endpoints.
"""
import pytest
import asyncio
from decimal import Decimal
from datetime import date, datetime
from unittest.mock import AsyncMock, MagicMock, patch
from fastapi.testclient import TestClient
from fastapi import status

from app.main import app
from app.models.exchange_rate import ExchangeRateResponse, CurrencyConversion, HealthStatus


@pytest.fixture
def client():
    """Create test client."""
    return TestClient(app)


@pytest.fixture
def auth_headers():
    """Authentication headers for testing."""
    return {"Authorization": "Bearer dev-api-key"}


@pytest.fixture
def sample_exchange_rate():
    """Sample exchange rate response."""
    return ExchangeRateResponse(
        id=1,
        base_currency="USD",
        target_currency="EUR",
        rate=Decimal("0.85"),
        rate_date=date.today(),
        created_at=datetime.now()
    )


@pytest.fixture
def sample_latest_rates():
    """Sample latest rates response."""
    return {
        "EUR": ExchangeRateResponse(
            id=1,
            base_currency="USD",
            target_currency="EUR",
            rate=Decimal("0.85"),
            rate_date=date.today(),
            created_at=datetime.now()
        ),
        "GBP": ExchangeRateResponse(
            id=2,
            base_currency="USD",
            target_currency="GBP",
            rate=Decimal("0.75"),
            rate_date=date.today(),
            created_at=datetime.now()
        )
    }


class TestHealthEndpoint:
    """Test health check endpoint."""
    
    def test_health_check_success(self, client):
        """Test successful health check."""
        with patch('app.api.endpoints.check_database_connection') as mock_db:
            with patch('app.api.endpoints.cache_service') as mock_cache:
                mock_db.return_value = True
                mock_cache.is_connected.return_value = True
                
                response = client.get("/api/v1/health")
                
                assert response.status_code == status.HTTP_200_OK
                data = response.json()
                assert data["status"] == "healthy"
                assert data["database"] is True
                assert data["redis"] is True
                assert data["version"] == "1.0.0"
    
    def test_health_check_database_failure(self, client):
        """Test health check with database failure."""
        with patch('app.api.endpoints.check_database_connection') as mock_db:
            with patch('app.api.endpoints.cache_service') as mock_cache:
                mock_db.return_value = False
                mock_cache.is_connected.return_value = True
                
                response = client.get("/api/v1/health")
                
                assert response.status_code == status.HTTP_503_SERVICE_UNAVAILABLE
    
    def test_health_check_redis_failure(self, client):
        """Test health check with Redis failure."""
        with patch('app.api.endpoints.check_database_connection') as mock_db:
            with patch('app.api.endpoints.cache_service') as mock_cache:
                mock_db.return_value = True
                mock_cache.is_connected.return_value = False
                
                response = client.get("/api/v1/health")
                
                assert response.status_code == status.HTTP_503_SERVICE_UNAVAILABLE


class TestCurrencyEndpoints:
    """Test currency-related endpoints."""
    
    def test_get_supported_currencies(self, client, auth_headers):
        """Test getting supported currencies."""
        with patch('app.api.endpoints.external_api') as mock_api:
            mock_api.get_supported_currencies.return_value = ["USD", "EUR", "GBP"]
            
            response = client.get("/api/v1/currencies", headers=auth_headers)
            
            assert response.status_code == status.HTTP_200_OK
            data = response.json()
            assert isinstance(data, list)
            assert "USD" in data
            assert "EUR" in data
            assert "GBP" in data
    
    def test_get_supported_currencies_no_auth(self, client):
        """Test getting supported currencies without authentication."""
        response = client.get("/api/v1/currencies")
        
        assert response.status_code == status.HTTP_401_UNAUTHORIZED


class TestExchangeRateEndpoints:
    """Test exchange rate endpoints."""
    
    def test_get_specific_exchange_rate(self, client, auth_headers, sample_exchange_rate):
        """Test getting specific exchange rate."""
        with patch('app.api.endpoints.external_api') as mock_api:
            with patch('app.api.endpoints.exchange_rate_service') as mock_service:
                mock_api.get_supported_currencies.return_value = ["USD", "EUR", "GBP"]
                mock_service.get_rate.return_value = sample_exchange_rate
                
                response = client.get("/api/v1/rates/USD/EUR", headers=auth_headers)
                
                assert response.status_code == status.HTTP_200_OK
                data = response.json()
                assert data["base_currency"] == "USD"
                assert data["target_currency"] == "EUR"
                assert data["rate"] == "0.85"
    
    def test_get_specific_exchange_rate_not_found(self, client, auth_headers):
        """Test getting exchange rate that doesn't exist."""
        with patch('app.api.endpoints.external_api') as mock_api:
            with patch('app.api.endpoints.exchange_rate_service') as mock_service:
                mock_api.get_supported_currencies.return_value = ["USD", "EUR", "GBP"]
                mock_service.get_rate.return_value = None
                
                response = client.get("/api/v1/rates/USD/EUR", headers=auth_headers)
                
                assert response.status_code == status.HTTP_404_NOT_FOUND
    
    def test_get_specific_exchange_rate_invalid_currency(self, client, auth_headers):
        """Test getting exchange rate with invalid currency."""
        with patch('app.api.endpoints.external_api') as mock_api:
            mock_api.get_supported_currencies.return_value = ["USD", "EUR", "GBP"]
            
            response = client.get("/api/v1/rates/USD/XYZ", headers=auth_headers)
            
            assert response.status_code == status.HTTP_400_BAD_REQUEST
    
    def test_get_latest_rates(self, client, auth_headers, sample_latest_rates):
        """Test getting latest exchange rates."""
        with patch('app.api.endpoints.exchange_rate_service') as mock_service:
            mock_service.get_latest_rates.return_value = sample_latest_rates
            
            response = client.get("/api/v1/rates/latest", headers=auth_headers)
            
            assert response.status_code == status.HTTP_200_OK
            data = response.json()
            assert "EUR" in data
            assert "GBP" in data
            assert data["EUR"]["rate"] == "0.85"
            assert data["GBP"]["rate"] == "0.75"
    
    def test_get_latest_rates_not_found(self, client, auth_headers):
        """Test getting latest rates when none exist."""
        with patch('app.api.endpoints.exchange_rate_service') as mock_service:
            mock_service.get_latest_rates.return_value = {}
            
            response = client.get("/api/v1/rates/latest", headers=auth_headers)
            
            assert response.status_code == status.HTTP_404_NOT_FOUND
    
    def test_get_all_rates_for_base(self, client, auth_headers, sample_latest_rates):
        """Test getting all rates for a base currency."""
        with patch('app.api.endpoints.external_api') as mock_api:
            with patch('app.api.endpoints.exchange_rate_service') as mock_service:
                mock_api.get_supported_currencies.return_value = ["USD", "EUR", "GBP"]
                mock_service.get_latest_rates.return_value = sample_latest_rates
                
                response = client.get("/api/v1/rates/USD", headers=auth_headers)
                
                assert response.status_code == status.HTTP_200_OK
                data = response.json()
                assert "EUR" in data
                assert "GBP" in data


class TestCurrencyConversionEndpoint:
    """Test currency conversion endpoint."""
    
    def test_convert_currency_success(self, client, auth_headers):
        """Test successful currency conversion."""
        conversion_result = CurrencyConversion(
            original_amount=Decimal("100"),
            original_currency="USD",
            converted_amount=Decimal("85.0"),
            target_currency="EUR",
            exchange_rate=Decimal("0.85"),
            rate_date=date.today()
        )
        
        with patch('app.api.endpoints.external_api') as mock_api:
            with patch('app.api.endpoints.exchange_rate_service') as mock_service:
                mock_api.get_supported_currencies.return_value = ["USD", "EUR", "GBP"]
                mock_service.convert_currency.return_value = conversion_result
                
                response = client.post(
                    "/api/v1/convert?amount=100&from_currency=USD&to_currency=EUR",
                    headers=auth_headers
                )
                
                assert response.status_code == status.HTTP_200_OK
                data = response.json()
                assert data["original_amount"] == "100"
                assert data["converted_amount"] == "85.0"
                assert data["exchange_rate"] == "0.85"
    
    def test_convert_currency_invalid_amount(self, client, auth_headers):
        """Test conversion with invalid amount."""
        response = client.post(
            "/api/v1/convert?amount=-100&from_currency=USD&to_currency=EUR",
            headers=auth_headers
        )
        
        assert response.status_code == status.HTTP_422_UNPROCESSABLE_ENTITY
    
    def test_convert_currency_unsupported_currency(self, client, auth_headers):
        """Test conversion with unsupported currency."""
        with patch('app.api.endpoints.external_api') as mock_api:
            mock_api.get_supported_currencies.return_value = ["USD", "EUR", "GBP"]
            
            response = client.post(
                "/api/v1/convert?amount=100&from_currency=USD&to_currency=XYZ",
                headers=auth_headers
            )
            
            assert response.status_code == status.HTTP_400_BAD_REQUEST
    
    def test_convert_currency_rate_not_available(self, client, auth_headers):
        """Test conversion when rate is not available."""
        with patch('app.api.endpoints.external_api') as mock_api:
            with patch('app.api.endpoints.exchange_rate_service') as mock_service:
                mock_api.get_supported_currencies.return_value = ["USD", "EUR", "GBP"]
                mock_service.convert_currency.return_value = None
                
                response = client.post(
                    "/api/v1/convert?amount=100&from_currency=USD&to_currency=EUR",
                    headers=auth_headers
                )
                
                assert response.status_code == status.HTTP_404_NOT_FOUND


class TestAdminEndpoints:
    """Test admin endpoints."""
    
    def test_manually_fetch_rates_success(self, client, auth_headers):
        """Test manual rate fetching."""
        with patch('app.api.endpoints.exchange_rate_service') as mock_service:
            mock_service.fetch_and_store_daily_rates.return_value = True
            
            response = client.post("/api/v1/admin/fetch-rates", headers=auth_headers)
            
            assert response.status_code == status.HTTP_200_OK
            data = response.json()
            assert "message" in data
            assert "successfully" in data["message"]
    
    def test_manually_fetch_rates_failure(self, client, auth_headers):
        """Test manual rate fetching failure."""
        with patch('app.api.endpoints.exchange_rate_service') as mock_service:
            mock_service.fetch_and_store_daily_rates.return_value = False
            
            response = client.post("/api/v1/admin/fetch-rates", headers=auth_headers)
            
            assert response.status_code == status.HTTP_500_INTERNAL_SERVER_ERROR
    
    def test_clear_cache_success(self, client, auth_headers):
        """Test cache clearing."""
        with patch('app.api.endpoints.cache_service') as mock_cache:
            mock_cache.clear_cache.return_value = True
            
            response = client.delete("/api/v1/admin/cache", headers=auth_headers)
            
            assert response.status_code == status.HTTP_200_OK
            data = response.json()
            assert data["message"] == "Cache cleared successfully"
    
    def test_clear_cache_failure(self, client, auth_headers):
        """Test cache clearing failure."""
        with patch('app.api.endpoints.cache_service') as mock_cache:
            mock_cache.clear_cache.return_value = False
            
            response = client.delete("/api/v1/admin/cache", headers=auth_headers)
            
            assert response.status_code == status.HTTP_500_INTERNAL_SERVER_ERROR
    
    def test_get_cache_stats(self, client, auth_headers):
        """Test getting cache statistics."""
        mock_stats = {
            "status": "connected",
            "total_keys": 5,
            "rate_cache_keys": 3,
            "latest_rates_keys": 1
        }
        
        with patch('app.api.endpoints.cache_service') as mock_cache:
            mock_cache.get_cache_stats.return_value = mock_stats
            
            response = client.get("/api/v1/admin/cache/stats", headers=auth_headers)
            
            assert response.status_code == status.HTTP_200_OK
            data = response.json()
            assert "cache_stats" in data
            assert "optimization_info" in data
            assert data["cache_stats"]["status"] == "connected"


class TestAuthenticationAndRateLimit:
    """Test authentication and rate limiting."""
    
    def test_endpoint_without_auth(self, client):
        """Test accessing protected endpoint without authentication."""
        response = client.get("/api/v1/rates/latest")
        
        assert response.status_code == status.HTTP_401_UNAUTHORIZED
    
    def test_endpoint_with_invalid_auth(self, client):
        """Test accessing endpoint with invalid API key."""
        headers = {"Authorization": "Bearer invalid-key"}
        response = client.get("/api/v1/rates/latest", headers=headers)
        
        assert response.status_code == status.HTTP_401_UNAUTHORIZED
    
    def test_endpoint_with_valid_auth(self, client, auth_headers):
        """Test accessing endpoint with valid API key."""
        with patch('app.api.endpoints.exchange_rate_service') as mock_service:
            mock_service.get_latest_rates.return_value = {"EUR": MagicMock()}
            
            response = client.get("/api/v1/rates/latest", headers=auth_headers)
            
            # Should not be 401 (may be other errors due to mocking)
            assert response.status_code != status.HTTP_401_UNAUTHORIZED


if __name__ == "__main__":
    pytest.main([__file__])