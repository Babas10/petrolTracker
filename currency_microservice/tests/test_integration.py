"""
Integration tests for the complete currency microservice system.
"""
import pytest
import asyncio
from decimal import Decimal
from datetime import date, datetime
from unittest.mock import AsyncMock, MagicMock, patch
from fastapi.testclient import TestClient
from fastapi import status
import httpx

from app.main import app
from app.models.exchange_rate import ExchangeRateCreate, ExchangeRateResponse
from app.services.exchange_rate_service import exchange_rate_service
from app.services.cache_service import cache_service


@pytest.fixture
def client():
    """Create test client."""
    return TestClient(app)


@pytest.fixture
def auth_headers():
    """Authentication headers."""
    return {"Authorization": "Bearer dev-api-key"}


class TestCompleteDataFlow:
    """Test the complete data flow from external API to cache to client."""
    
    def test_complete_currency_conversion_flow(self, client, auth_headers):
        """Test complete flow: external API -> database -> cache -> API response."""
        mock_external_rates = {
            "EUR": 0.85,
            "GBP": 0.75,
            "JPY": 110.0
        }
        
        # Mock external API response
        mock_api_response = {
            "success": True,
            "rates": mock_external_rates
        }
        
        with patch('httpx.AsyncClient.get') as mock_get:
            with patch('app.api.endpoints.get_db') as mock_get_db:
                with patch('app.services.cache_service.cache_service') as mock_cache:
                    # Setup mocks
                    mock_get.return_value.status_code = 200
                    mock_get.return_value.json.return_value = mock_api_response
                    
                    mock_db = AsyncMock()
                    mock_get_db.return_value.__aenter__.return_value = mock_db
                    
                    # Mock cache miss for initial request
                    mock_cache.get_rate.return_value = None
                    mock_cache.set_rate.return_value = True
                    
                    # Mock database operations
                    mock_rate_record = MagicMock()
                    mock_rate_record.id = 1
                    mock_rate_record.base_currency = "USD"
                    mock_rate_record.target_currency = "EUR"
                    mock_rate_record.rate = Decimal("0.85")
                    mock_rate_record.date = date.today()
                    mock_rate_record.created_at = datetime.now()
                    
                    mock_db.execute.return_value.scalar_one_or_none.return_value = mock_rate_record
                    
                    # Test getting specific rate
                    response = client.get("/api/v1/rates/USD/EUR", headers=auth_headers)
                    
                    assert response.status_code == status.HTTP_200_OK
                    data = response.json()
                    assert data["base_currency"] == "USD"
                    assert data["target_currency"] == "EUR"
                    assert float(data["rate"]) == 0.85
    
    def test_flutter_daily_cache_optimization_flow(self, client, auth_headers):
        """Test the Flutter daily cache optimization pattern."""
        # Simulate the Flutter app making its daily API call
        
        mock_latest_rates = {
            "EUR": {
                "id": 1,
                "base_currency": "USD",
                "target_currency": "EUR",
                "rate": "0.85",
                "rate_date": "2025-09-09",
                "created_at": "2025-09-09T06:00:00Z"
            },
            "GBP": {
                "id": 2,
                "base_currency": "USD",
                "target_currency": "GBP",
                "rate": "0.75", 
                "rate_date": "2025-09-09",
                "created_at": "2025-09-09T06:00:00Z"
            }
        }
        
        with patch('app.api.endpoints.exchange_rate_service') as mock_service:
            mock_service.get_latest_rates.return_value = mock_latest_rates
            
            # First call - cache miss, loads from database
            response1 = client.get("/api/v1/rates/latest", headers=auth_headers)
            assert response1.status_code == status.HTTP_200_OK
            
            # Verify all currencies are returned
            data1 = response1.json()
            assert "EUR" in data1
            assert "GBP" in data1
            
            # Second call on same day - should use cached data
            response2 = client.get("/api/v1/rates/latest", headers=auth_headers)
            assert response2.status_code == status.HTTP_200_OK
            
            # Data should be identical
            data2 = response2.json()
            assert data1 == data2
    
    def test_error_handling_and_fallbacks(self, client, auth_headers):
        """Test error handling and fallback mechanisms."""
        # Test database connection error
        with patch('app.api.endpoints.check_database_connection') as mock_db_check:
            with patch('app.api.endpoints.cache_service') as mock_cache:
                mock_db_check.return_value = False  # Database down
                mock_cache.is_connected.return_value = True  # Cache up
                
                response = client.get("/api/v1/health")
                assert response.status_code == status.HTTP_503_SERVICE_UNAVAILABLE
        
        # Test cache connection error
        with patch('app.api.endpoints.check_database_connection') as mock_db_check:
            with patch('app.api.endpoints.cache_service') as mock_cache:
                mock_db_check.return_value = True  # Database up
                mock_cache.is_connected.return_value = False  # Cache down
                
                response = client.get("/api/v1/health")
                assert response.status_code == status.HTTP_503_SERVICE_UNAVAILABLE


class TestRealWorldScenarios:
    """Test real-world usage scenarios."""
    
    def test_multiple_currency_conversions(self, client, auth_headers):
        """Test multiple currency conversions in sequence."""
        conversion_scenarios = [
            {"amount": 100, "from": "USD", "to": "EUR", "expected_rate": 0.85},
            {"amount": 50, "from": "USD", "to": "GBP", "expected_rate": 0.75},
            {"amount": 1000, "from": "USD", "to": "JPY", "expected_rate": 110.0},
        ]
        
        for scenario in conversion_scenarios:
            mock_conversion = {
                "original_amount": str(scenario["amount"]),
                "original_currency": scenario["from"],
                "converted_amount": str(scenario["amount"] * scenario["expected_rate"]),
                "target_currency": scenario["to"],
                "exchange_rate": str(scenario["expected_rate"]),
                "rate_date": str(date.today())
            }
            
            with patch('app.api.endpoints.external_api') as mock_api:
                with patch('app.api.endpoints.exchange_rate_service') as mock_service:
                    mock_api.get_supported_currencies.return_value = ["USD", "EUR", "GBP", "JPY"]
                    mock_service.convert_currency.return_value = type('obj', (object,), mock_conversion)()
                    
                    response = client.post(
                        f"/api/v1/convert?amount={scenario['amount']}&from_currency={scenario['from']}&to_currency={scenario['to']}",
                        headers=auth_headers
                    )
                    
                    assert response.status_code == status.HTTP_200_OK
                    data = response.json()
                    assert float(data["original_amount"]) == scenario["amount"]
                    assert data["original_currency"] == scenario["from"]
                    assert data["target_currency"] == scenario["to"]
    
    def test_high_frequency_api_calls(self, client, auth_headers):
        """Test handling of high-frequency API calls."""
        # Simulate multiple rapid requests
        responses = []
        
        with patch('app.api.endpoints.exchange_rate_service') as mock_service:
            mock_latest_rates = {"EUR": {"rate": "0.85"}}
            mock_service.get_latest_rates.return_value = mock_latest_rates
            
            # Make multiple rapid requests
            for _ in range(10):
                response = client.get("/api/v1/rates/latest", headers=auth_headers)
                responses.append(response)
            
            # All should succeed (assuming no rate limiting in test)
            for response in responses:
                assert response.status_code == status.HTTP_200_OK
    
    def test_edge_case_currency_codes(self, client, auth_headers):
        """Test handling of edge cases in currency codes."""
        # Test lowercase currency codes (should be normalized)
        with patch('app.api.endpoints.external_api') as mock_api:
            with patch('app.api.endpoints.exchange_rate_service') as mock_service:
                mock_api.get_supported_currencies.return_value = ["USD", "EUR", "GBP"]
                mock_rate = type('obj', (object,), {
                    "base_currency": "USD",
                    "target_currency": "EUR", 
                    "rate": "0.85",
                    "rate_date": str(date.today()),
                    "id": 1,
                    "created_at": datetime.now().isoformat()
                })()
                mock_service.get_rate.return_value = mock_rate
                
                # Test lowercase input
                response = client.get("/api/v1/rates/usd/eur", headers=auth_headers)
                assert response.status_code == status.HTTP_200_OK
                
                data = response.json()
                assert data["base_currency"] == "USD"  # Should be normalized to uppercase
                assert data["target_currency"] == "EUR"
    
    def test_date_parameter_handling(self, client, auth_headers):
        """Test handling of date parameters in requests."""
        test_date = "2025-01-01"
        
        with patch('app.api.endpoints.external_api') as mock_api:
            with patch('app.api.endpoints.exchange_rate_service') as mock_service:
                mock_api.get_supported_currencies.return_value = ["USD", "EUR"]
                mock_rate = type('obj', (object,), {
                    "base_currency": "USD",
                    "target_currency": "EUR",
                    "rate": "0.85",
                    "rate_date": test_date,
                    "id": 1,
                    "created_at": datetime.now().isoformat()
                })()
                mock_service.get_rate.return_value = mock_rate
                
                response = client.get(f"/api/v1/rates/USD/EUR?date={test_date}", headers=auth_headers)
                assert response.status_code == status.HTTP_200_OK
                
                data = response.json()
                assert data["rate_date"] == test_date


class TestAdminOperations:
    """Test admin operations and maintenance tasks."""
    
    def test_manual_rate_fetch_operation(self, client, auth_headers):
        """Test manual triggering of rate fetching."""
        with patch('app.api.endpoints.exchange_rate_service') as mock_service:
            mock_service.fetch_and_store_daily_rates.return_value = True
            
            response = client.post("/api/v1/admin/fetch-rates", headers=auth_headers)
            
            assert response.status_code == status.HTTP_200_OK
            data = response.json()
            assert "successfully" in data["message"]
            mock_service.fetch_and_store_daily_rates.assert_called_once()
    
    def test_cache_management_operations(self, client, auth_headers):
        """Test cache management operations."""
        # Test cache clearing
        with patch('app.api.endpoints.cache_service') as mock_cache:
            mock_cache.clear_cache.return_value = True
            
            response = client.delete("/api/v1/admin/cache", headers=auth_headers)
            
            assert response.status_code == status.HTTP_200_OK
            data = response.json()
            assert data["message"] == "Cache cleared successfully"
        
        # Test cache statistics
        with patch('app.api.endpoints.cache_service') as mock_cache:
            mock_stats = {
                "status": "connected",
                "total_keys": 10,
                "memory_usage": "2.5MB"
            }
            mock_cache.get_cache_stats.return_value = mock_stats
            
            response = client.get("/api/v1/admin/cache/stats", headers=auth_headers)
            
            assert response.status_code == status.HTTP_200_OK
            data = response.json()
            assert "cache_stats" in data
            assert "optimization_info" in data
    
    def test_test_data_seeding(self, client, auth_headers):
        """Test seeding of test data for development."""
        mock_seed_result = {
            "status": "success",
            "rates_created": 21,
            "message": "Test data seeded successfully"
        }
        
        with patch('app.api.endpoints.seeding_service') as mock_seeding:
            with patch('app.api.endpoints.settings') as mock_settings:
                mock_settings.debug = True
                mock_seeding.seed_test_currency_data.return_value = mock_seed_result
                
                response = client.post("/api/v1/admin/seed-test-data", headers=auth_headers)
                
                assert response.status_code == status.HTTP_200_OK
                data = response.json()
                assert data["status"] == "success"
                assert data["rates_created"] == 21


class TestPerformanceAndScaling:
    """Test performance characteristics and scaling behavior."""
    
    def test_concurrent_requests_handling(self, client, auth_headers):
        """Test handling of concurrent requests."""
        import threading
        import time
        
        responses = []
        errors = []
        
        def make_request():
            try:
                with patch('app.api.endpoints.exchange_rate_service') as mock_service:
                    mock_service.get_latest_rates.return_value = {"EUR": {"rate": "0.85"}}
                    response = client.get("/api/v1/rates/latest", headers=auth_headers)
                    responses.append(response.status_code)
            except Exception as e:
                errors.append(str(e))
        
        # Create multiple threads to simulate concurrent requests
        threads = []
        for _ in range(5):
            thread = threading.Thread(target=make_request)
            threads.append(thread)
        
        # Start all threads
        for thread in threads:
            thread.start()
        
        # Wait for all threads to complete
        for thread in threads:
            thread.join()
        
        # Check results
        assert len(errors) == 0, f"Errors occurred: {errors}"
        assert all(status == 200 for status in responses), f"Non-200 responses: {responses}"
    
    def test_large_dataset_handling(self, client, auth_headers):
        """Test handling of large currency datasets."""
        # Simulate a large number of supported currencies
        large_currency_list = [f"CUR{i:03d}" for i in range(100)]
        
        with patch('app.api.endpoints.external_api') as mock_api:
            mock_api.get_supported_currencies.return_value = large_currency_list
            
            response = client.get("/api/v1/currencies", headers=auth_headers)
            
            assert response.status_code == status.HTTP_200_OK
            data = response.json()
            assert len(data) == 100
            assert isinstance(data, list)


if __name__ == "__main__":
    pytest.main([__file__])