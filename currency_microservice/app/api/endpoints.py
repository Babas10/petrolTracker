"""
API endpoints for the currency exchange rate microservice.
"""
from fastapi import APIRouter, Depends, HTTPException, Query, Request
from fastapi.responses import JSONResponse
from sqlalchemy.ext.asyncio import AsyncSession
from typing import Dict, List, Optional
from datetime import date, datetime
from decimal import Decimal

from app.database.connection import get_db, check_database_connection
from app.services.exchange_rate_service import exchange_rate_service
from app.services.cache_service import cache_service
from app.services.external_api_service import ExternalAPIService
from app.services.seeding_service import seeding_service
from app.models.exchange_rate import (
    ExchangeRateResponse, 
    CurrencyConversion, 
    HealthStatus, 
    ErrorResponse
)
from app.api.auth import rate_limit, optional_auth
from app.core.config import settings
import logging

logger = logging.getLogger(__name__)

# Create router
router = APIRouter(prefix="/api/v1")
external_api = ExternalAPIService()


@router.get(
    "/health",
    response_model=HealthStatus,
    summary="Health Check",
    description="Check the health status of the microservice and its dependencies."
)
async def health_check(
    request: Request,
    api_key: str = Depends(optional_auth)
):
    """Check service health including database and Redis connectivity."""
    
    # Check database
    db_status = await check_database_connection()
    
    # Check Redis
    redis_status = await cache_service.is_connected()
    
    status = "healthy" if db_status and redis_status else "unhealthy"
    
    health_info = HealthStatus(
        status=status,
        timestamp=datetime.now(),
        version=settings.version,
        database=db_status,
        redis=redis_status
    )
    
    status_code = 200 if status == "healthy" else 503
    return JSONResponse(content=health_info.dict(), status_code=status_code)


@router.get(
    "/currencies",
    response_model=List[str],
    summary="Supported Currencies",
    description="Get list of supported currency codes.",
    dependencies=[Depends(rate_limit)]
)
async def get_supported_currencies():
    """Get list of supported currencies."""
    return await external_api.get_supported_currencies()


@router.get(
    "/rates/{base}/{target}",
    response_model=ExchangeRateResponse,
    summary="Get Specific Exchange Rate",
    description="Get exchange rate between two currencies for a specific date (defaults to today).",
    responses={
        404: {"model": ErrorResponse, "description": "Exchange rate not found"},
        400: {"model": ErrorResponse, "description": "Invalid currency codes"}
    },
    dependencies=[Depends(rate_limit)]
)
async def get_exchange_rate(
    base: str,
    target: str,
    date: Optional[date] = Query(None, description="Date for the exchange rate (YYYY-MM-DD)"),
    db: AsyncSession = Depends(get_db)
):
    """Get exchange rate between two specific currencies."""
    
    # Validate currency codes
    supported_currencies = await external_api.get_supported_currencies()
    if base.upper() not in supported_currencies or target.upper() not in supported_currencies:
        raise HTTPException(
            status_code=400,
            detail=f"Unsupported currency. Supported currencies: {', '.join(supported_currencies)}"
        )
    
    base = base.upper()
    target = target.upper()
    rate_date = date or date.today()
    
    rate = await exchange_rate_service.get_rate(db, base, target, rate_date)
    
    if not rate:
        raise HTTPException(
            status_code=404,
            detail=f"Exchange rate not found for {base}/{target} on {rate_date}"
        )
    
    return rate


@router.get(
    "/rates/{base}",
    response_model=Dict[str, ExchangeRateResponse],
    summary="Get All Rates for Base Currency",
    description="Get latest exchange rates from base currency to all supported currencies.",
    responses={
        404: {"model": ErrorResponse, "description": "No rates found for base currency"},
        400: {"model": ErrorResponse, "description": "Invalid currency code"}
    },
    dependencies=[Depends(rate_limit)]
)
async def get_all_rates_for_base(
    base: str,
    date: Optional[date] = Query(None, description="Date for the exchange rates (YYYY-MM-DD)"),
    db: AsyncSession = Depends(get_db)
):
    """Get all exchange rates for a base currency."""
    
    # Validate currency code
    supported_currencies = await external_api.get_supported_currencies()
    if base.upper() not in supported_currencies:
        raise HTTPException(
            status_code=400,
            detail=f"Unsupported currency: {base}. Supported currencies: {', '.join(supported_currencies)}"
        )
    
    base = base.upper()
    
    if date:
        # Get rates for specific date
        rates = {}
        for target in supported_currencies:
            if target == base:
                continue
            rate = await exchange_rate_service.get_rate(db, base, target, date)
            if rate:
                rates[target] = rate
    else:
        # Get latest rates
        rates = await exchange_rate_service.get_latest_rates(db, base)
    
    if not rates:
        raise HTTPException(
            status_code=404,
            detail=f"No exchange rates found for {base}" + (f" on {date}" if date else "")
        )
    
    return rates


@router.get(
    "/rates/latest",
    response_model=Dict[str, ExchangeRateResponse],
    summary="Get Latest Rates",
    description="Get latest exchange rates for the default base currency.",
    dependencies=[Depends(rate_limit)]
)
async def get_latest_rates(
    db: AsyncSession = Depends(get_db)
):
    """Get latest exchange rates for the default base currency."""
    
    rates = await exchange_rate_service.get_latest_rates(db, settings.base_currency)
    
    if not rates:
        raise HTTPException(
            status_code=404,
            detail=f"No latest exchange rates found for {settings.base_currency}"
        )
    
    return rates


@router.post(
    "/convert",
    response_model=CurrencyConversion,
    summary="Convert Currency",
    description="Convert an amount from one currency to another using exchange rates.",
    responses={
        400: {"model": ErrorResponse, "description": "Invalid parameters"},
        404: {"model": ErrorResponse, "description": "Exchange rate not available"}
    },
    dependencies=[Depends(rate_limit)]
)
async def convert_currency(
    amount: Decimal = Query(..., description="Amount to convert", gt=0),
    from_currency: str = Query(..., description="Source currency code"),
    to_currency: str = Query(..., description="Target currency code"),
    date: Optional[date] = Query(None, description="Date for exchange rate (YYYY-MM-DD)"),
    db: AsyncSession = Depends(get_db)
):
    """Convert currency using exchange rates."""
    
    # Validate currency codes
    supported_currencies = await external_api.get_supported_currencies()
    from_curr = from_currency.upper()
    to_curr = to_currency.upper()
    
    if from_curr not in supported_currencies or to_curr not in supported_currencies:
        raise HTTPException(
            status_code=400,
            detail=f"Unsupported currency. Supported currencies: {', '.join(supported_currencies)}"
        )
    
    conversion_date = date or date.today()
    
    conversion = await exchange_rate_service.convert_currency(
        db, amount, from_curr, to_curr, conversion_date
    )
    
    if not conversion:
        raise HTTPException(
            status_code=404,
            detail=f"Cannot convert {from_curr} to {to_curr}. Exchange rate not available for {conversion_date}"
        )
    
    return conversion


@router.post(
    "/admin/fetch-rates",
    summary="Manually Trigger Rate Fetch",
    description="Manually trigger fetching of exchange rates from external APIs (admin only).",
    responses={
        200: {"description": "Rates fetched successfully"},
        500: {"model": ErrorResponse, "description": "Failed to fetch rates"}
    },
    dependencies=[Depends(rate_limit)]
)
async def manually_fetch_rates(
    base: Optional[str] = Query(None, description="Base currency (defaults to configured base)"),
    db: AsyncSession = Depends(get_db)
):
    """Manually trigger rate fetching (for testing/admin purposes)."""
    
    base_currency = base.upper() if base else settings.base_currency
    
    success = await exchange_rate_service.fetch_and_store_daily_rates(db, base_currency)
    
    if not success:
        raise HTTPException(
            status_code=500,
            detail="Failed to fetch exchange rates from external APIs"
        )
    
    return {"message": f"Exchange rates fetched and stored successfully for {base_currency}"}


@router.delete(
    "/admin/cache",
    summary="Clear Cache",
    description="Clear all cached exchange rate data (admin only).",
    dependencies=[Depends(rate_limit)]
)
async def clear_cache():
    """Clear all cached data."""
    
    success = await cache_service.clear_cache()
    
    if not success:
        raise HTTPException(
            status_code=500,
            detail="Failed to clear cache"
        )
    
    return {"message": "Cache cleared successfully"}


@router.get(
    "/admin/cache/stats",
    summary="Cache Statistics",
    description="Get cache statistics and monitoring information (admin only).",
    dependencies=[Depends(rate_limit)]
)
async def get_cache_stats():
    """Get cache statistics for monitoring."""
    
    stats = await cache_service.get_cache_stats()
    
    return {
        "cache_stats": stats,
        "optimization_info": {
            "daily_cache_pattern": True,
            "cache_ttl_hours": settings.cache_ttl_seconds // 3600,
            "designed_for": "Flutter daily fetch pattern - 1 API call per day"
        }
    }


@router.post(
    "/admin/seed-test-data",
    summary="Seed Test Currency Data",
    description="Populate database with realistic test currency data for development and testing.",
    dependencies=[Depends(rate_limit)]
)
async def seed_test_data(
    db: AsyncSession = Depends(get_db),
    base_currency: str = Query("USD", description="Base currency for exchange rates"),
    clear_existing: bool = Query(True, description="Clear existing data for today before seeding")
):
    """Seed database with test currency data for development and testing."""
    
    if not settings.debug:
        raise HTTPException(
            status_code=403,
            detail="Test data seeding only available in debug mode"
        )
    
    result = await seeding_service.seed_test_currency_data(
        db=db,
        base_currency=base_currency,
        clear_existing=clear_existing
    )
    
    if result["status"] == "error":
        raise HTTPException(
            status_code=500,
            detail=result["message"]
        )
    
    return result


@router.get(
    "/admin/test-conversions",
    summary="Generate Test Currency Conversions", 
    description="Generate sample currency conversions to test the complete data flow.",
    dependencies=[Depends(rate_limit)]
)
async def generate_test_conversions(
    db: AsyncSession = Depends(get_db),
    base_currency: str = Query("USD", description="Base currency for conversions")
):
    """Generate sample currency conversions for testing."""
    
    try:
        conversions = await seeding_service.generate_sample_conversions(db, base_currency)
        
        return {
            "base_currency": base_currency,
            "sample_conversions": conversions,
            "total_conversions": len(conversions),
            "message": "Sample conversions generated successfully - data flow working!"
        }
        
    except Exception as e:
        logger.error(f"Error generating test conversions: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"Failed to generate test conversions: {str(e)}"
        )


@router.get(
    "/admin/seeding-status",
    summary="Get Seeding Status",
    description="Check current test data seeding status and system readiness.",
    dependencies=[Depends(rate_limit)]
)
async def get_seeding_status(db: AsyncSession = Depends(get_db)):
    """Get current seeding status and data overview."""
    
    status = await seeding_service.get_seeding_status(db)
    
    return {
        "seeding_status": status,
        "testing_ready": status.get("ready_for_testing", False),
        "instructions": {
            "seed_data": "POST /api/v1/admin/seed-test-data to populate test currency data",
            "test_flow": "GET /api/v1/admin/test-conversions to verify complete data flow",
            "check_cache": "GET /api/v1/admin/cache/stats to monitor cache performance",
            "get_rates": "GET /api/v1/rates/latest to fetch all cached rates (Flutter pattern)"
        }
    }


# Error handlers
@router.exception_handler(HTTPException)
async def http_exception_handler(request: Request, exc: HTTPException):
    """Handle HTTP exceptions with consistent error format."""
    return JSONResponse(
        status_code=exc.status_code,
        content=ErrorResponse(
            detail=exc.detail,
            timestamp=datetime.now()
        ).dict()
    )