"""
Tests for scheduler service with daily cache optimization.
"""
import pytest
import asyncio
from unittest.mock import AsyncMock, MagicMock, patch
from datetime import datetime

from app.services.scheduler_service import SchedulerService
from app.core.config import settings


@pytest.fixture
def scheduler_service():
    """Create scheduler service instance."""
    return SchedulerService()


@pytest.fixture
def mock_db():
    """Create mock database session."""
    return AsyncMock()


@pytest.mark.asyncio
async def test_warm_daily_cache_success(scheduler_service, mock_db):
    """Test successful cache warming after daily rate fetch."""
    # Mock exchange rate service
    with patch('app.services.scheduler_service.exchange_rate_service') as mock_exchange:
        mock_rates = {
            "EUR": {"rate": "0.85", "date": "2023-12-01"},
            "GBP": {"rate": "0.75", "date": "2023-12-01"},
            "JPY": {"rate": "110.0", "date": "2023-12-01"}
        }
        mock_exchange.get_latest_rates.return_value = mock_rates
        
        # Call cache warming
        await scheduler_service._warm_daily_cache(mock_db)
        
        # Verify exchange service was called
        mock_exchange.get_latest_rates.assert_called_once_with(mock_db, settings.base_currency)


@pytest.mark.asyncio
async def test_warm_daily_cache_no_rates(scheduler_service, mock_db):
    """Test cache warming when no rates are available."""
    # Mock exchange rate service returning no rates
    with patch('app.services.scheduler_service.exchange_rate_service') as mock_exchange:
        mock_exchange.get_latest_rates.return_value = None
        
        # Call cache warming (should not raise exception)
        await scheduler_service._warm_daily_cache(mock_db)
        
        # Verify it was attempted
        mock_exchange.get_latest_rates.assert_called_once()


@pytest.mark.asyncio
async def test_warm_daily_cache_exception(scheduler_service, mock_db):
    """Test cache warming handles exceptions gracefully."""
    # Mock exchange rate service raising exception
    with patch('app.services.scheduler_service.exchange_rate_service') as mock_exchange:
        mock_exchange.get_latest_rates.side_effect = Exception("Test exception")
        
        # Call cache warming (should not raise exception)
        await scheduler_service._warm_daily_cache(mock_db)
        
        # Verify it was attempted
        mock_exchange.get_latest_rates.assert_called_once()


@pytest.mark.asyncio
async def test_fetch_daily_rates_job_with_cache_warming(scheduler_service):
    """Test daily rate fetch job includes cache warming."""
    with patch('app.services.scheduler_service.async_session_factory') as mock_session:
        with patch('app.services.scheduler_service.exchange_rate_service') as mock_exchange:
            mock_db = AsyncMock()
            mock_session.return_value.__aenter__.return_value = mock_db
            
            # Mock successful rate fetch
            mock_exchange.fetch_and_store_daily_rates.return_value = True
            
            # Mock cache warming
            with patch.object(scheduler_service, '_warm_daily_cache') as mock_warm_cache:
                # Call the job
                await scheduler_service._fetch_daily_rates_job()
                
                # Verify rate fetch was called
                mock_exchange.fetch_and_store_daily_rates.assert_called_once_with(mock_db, settings.base_currency)
                
                # Verify cache warming was called after successful fetch
                mock_warm_cache.assert_called_once_with(mock_db)


@pytest.mark.asyncio
async def test_fetch_daily_rates_job_no_cache_warming_on_failure(scheduler_service):
    """Test cache warming is skipped when rate fetch fails."""
    with patch('app.services.scheduler_service.async_session_factory') as mock_session:
        with patch('app.services.scheduler_service.exchange_rate_service') as mock_exchange:
            mock_db = AsyncMock()
            mock_session.return_value.__aenter__.return_value = mock_db
            
            # Mock failed rate fetch
            mock_exchange.fetch_and_store_daily_rates.return_value = False
            
            # Mock cache warming
            with patch.object(scheduler_service, '_warm_daily_cache') as mock_warm_cache:
                # Call the job
                await scheduler_service._fetch_daily_rates_job()
                
                # Verify rate fetch was called
                mock_exchange.fetch_and_store_daily_rates.assert_called_once()
                
                # Verify cache warming was NOT called after failed fetch
                mock_warm_cache.assert_not_called()


def test_scheduler_job_configuration(scheduler_service):
    """Test that scheduler configures jobs correctly."""
    # Mock scheduler
    scheduler_service.scheduler = MagicMock()
    
    # Test job setup
    asyncio.run(scheduler_service.start())
    
    # Verify daily rate fetch job was added
    daily_job_calls = [call for call in scheduler_service.scheduler.add_job.call_args_list 
                      if 'daily_rate_fetch' in str(call)]
    assert len(daily_job_calls) == 1
    
    # Verify cache cleanup job was added
    cleanup_job_calls = [call for call in scheduler_service.scheduler.add_job.call_args_list 
                        if 'cache_cleanup' in str(call)]
    assert len(cleanup_job_calls) == 1


def test_scheduler_multiple_start_calls(scheduler_service):
    """Test scheduler handles multiple start calls gracefully."""
    scheduler_service.scheduler = MagicMock()
    
    # First start
    asyncio.run(scheduler_service.start())
    assert scheduler_service.is_running
    
    # Second start (should log warning)
    asyncio.run(scheduler_service.start())
    
    # Should only call start once on the actual scheduler
    scheduler_service.scheduler.start.assert_called_once()


if __name__ == "__main__":
    pytest.main([__file__])