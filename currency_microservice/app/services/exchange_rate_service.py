"""
Exchange rate service for database operations and business logic.
"""
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_, desc
from sqlalchemy.exc import IntegrityError
from typing import List, Optional, Dict, Any
from datetime import date, datetime, timedelta
from decimal import Decimal

from app.models.exchange_rate import ExchangeRateDB, ExchangeRateCreate, ExchangeRateResponse, CurrencyConversion
from app.services.cache_service import cache_service
from app.services.external_api_service import ExternalAPIService
from app.core.config import settings
import logging

logger = logging.getLogger(__name__)


class ExchangeRateService:
    """Service for managing exchange rates."""
    
    def __init__(self):
        self.external_api = ExternalAPIService()
    
    async def get_rate(
        self, 
        db: AsyncSession, 
        base: str, 
        target: str, 
        rate_date: date = None
    ) -> Optional[ExchangeRateResponse]:
        """
        Get exchange rate for specific currency pair and date.
        
        Args:
            db: Database session
            base: Base currency code
            target: Target currency code
            rate_date: Date for the rate (defaults to today)
            
        Returns:
            Exchange rate or None if not found
        """
        if rate_date is None:
            rate_date = date.today()
        
        # Check cache first
        cached_rate = await cache_service.get_rate(base, target, rate_date)
        if cached_rate:
            logger.debug(f"Rate cache hit: {base}/{target} on {rate_date}")
            # Create response from cached data
            return ExchangeRateResponse(
                id=0,  # Cache doesn't store ID
                base_currency=base,
                target_currency=target,
                rate=cached_rate,
                date=rate_date,
                created_at=datetime.now()
            )
        
        # Query database
        result = await db.execute(
            select(ExchangeRateDB).where(
                and_(
                    ExchangeRateDB.base_currency == base,
                    ExchangeRateDB.target_currency == target,
                    ExchangeRateDB.date == rate_date
                )
            )
        )
        
        rate_record = result.scalar_one_or_none()
        if rate_record:
            # Cache the rate
            await cache_service.set_rate(base, target, rate_date, rate_record.rate)
            return ExchangeRateResponse.from_orm(rate_record)
        
        return None
    
    async def get_latest_rates(
        self, 
        db: AsyncSession, 
        base: str
    ) -> Dict[str, ExchangeRateResponse]:
        """
        Get latest rates for all supported currencies from base currency.
        
        Args:
            db: Database session
            base: Base currency code
            
        Returns:
            Dictionary mapping target currency to exchange rate
        """
        # Check cache first
        cached_rates = await cache_service.get_latest_rates(base)
        if cached_rates:
            logger.debug(f"Latest rates cache hit for {base}")
            return {
                currency: ExchangeRateResponse(**rate_data)
                for currency, rate_data in cached_rates.items()
            }
        
        # Query database for latest rates
        today = date.today()
        
        # Get most recent date with rates
        latest_date_result = await db.execute(
            select(ExchangeRateDB.date)
            .where(ExchangeRateDB.base_currency == base)
            .order_by(desc(ExchangeRateDB.date))
            .limit(1)
        )
        
        latest_date = latest_date_result.scalar_one_or_none()
        if not latest_date:
            return {}
        
        # Get all rates for the latest date
        result = await db.execute(
            select(ExchangeRateDB).where(
                and_(
                    ExchangeRateDB.base_currency == base,
                    ExchangeRateDB.date == latest_date
                )
            )
        )
        
        rates = result.scalars().all()
        response_dict = {}
        cache_data = {}
        
        for rate in rates:
            rate_response = ExchangeRateResponse.from_orm(rate)
            response_dict[rate.target_currency] = rate_response
            cache_data[rate.target_currency] = rate_response.dict()
        
        # Cache the results
        if cache_data:
            await cache_service.set_latest_rates(base, cache_data)
        
        return response_dict
    
    async def create_rate(
        self, 
        db: AsyncSession, 
        rate_data: ExchangeRateCreate
    ) -> ExchangeRateResponse:
        """
        Create or update an exchange rate.
        
        Args:
            db: Database session
            rate_data: Rate data to create
            
        Returns:
            Created exchange rate
        """
        db_rate = ExchangeRateDB(**rate_data.dict())
        
        try:
            db.add(db_rate)
            await db.commit()
            await db.refresh(db_rate)
            
            # Cache the new rate
            await cache_service.set_rate(
                rate_data.base_currency,
                rate_data.target_currency,
                rate_data.date,
                rate_data.rate
            )
            
            logger.info(f"Created rate: {rate_data.base_currency}/{rate_data.target_currency} = {rate_data.rate} on {rate_data.date}")
            return ExchangeRateResponse.from_orm(db_rate)
            
        except IntegrityError:
            # Rate already exists for this date, update it
            await db.rollback()
            
            result = await db.execute(
                select(ExchangeRateDB).where(
                    and_(
                        ExchangeRateDB.base_currency == rate_data.base_currency,
                        ExchangeRateDB.target_currency == rate_data.target_currency,
                        ExchangeRateDB.date == rate_data.date
                    )
                )
            )
            
            existing_rate = result.scalar_one()
            existing_rate.rate = rate_data.rate
            existing_rate.created_at = datetime.now()
            
            await db.commit()
            await db.refresh(existing_rate)
            
            # Update cache
            await cache_service.set_rate(
                rate_data.base_currency,
                rate_data.target_currency,
                rate_data.date,
                rate_data.rate
            )
            
            logger.info(f"Updated rate: {rate_data.base_currency}/{rate_data.target_currency} = {rate_data.rate} on {rate_data.date}")
            return ExchangeRateResponse.from_orm(existing_rate)
    
    async def fetch_and_store_daily_rates(self, db: AsyncSession, base: str = None) -> bool:
        """
        Fetch latest rates from external API and store in database.
        
        Args:
            db: Database session
            base: Base currency (defaults to configured base currency)
            
        Returns:
            True if successful, False otherwise
        """
        base_currency = base or settings.base_currency
        today = date.today()
        
        logger.info(f"Starting daily rate fetch for {base_currency} on {today}")
        
        # Fetch rates from external API
        rates = await self.external_api.fetch_exchange_rates(base_currency)
        if not rates:
            logger.error("Failed to fetch rates from external APIs")
            return False
        
        success_count = 0
        error_count = 0
        
        # Store each rate in database
        for target_currency, rate in rates.items():
            if target_currency == base_currency:
                continue  # Skip self-conversion
            
            # Validate rate
            if not await self.external_api.validate_rate(base_currency, target_currency, rate):
                logger.warning(f"Invalid rate skipped: {base_currency}/{target_currency} = {rate}")
                error_count += 1
                continue
            
            try:
                rate_data = ExchangeRateCreate(
                    base_currency=base_currency,
                    target_currency=target_currency,
                    rate=rate,
                    date=today
                )
                
                await self.create_rate(db, rate_data)
                success_count += 1
                
            except Exception as e:
                logger.error(f"Failed to store rate {base_currency}/{target_currency}: {e}")
                error_count += 1
        
        logger.info(f"Daily rate fetch completed: {success_count} success, {error_count} errors")
        return success_count > 0
    
    async def convert_currency(
        self,
        db: AsyncSession,
        amount: Decimal,
        from_currency: str,
        to_currency: str,
        rate_date: date = None
    ) -> Optional[CurrencyConversion]:
        """
        Convert amount from one currency to another.
        
        Args:
            db: Database session
            amount: Amount to convert
            from_currency: Source currency
            to_currency: Target currency  
            rate_date: Date for exchange rate (defaults to today)
            
        Returns:
            Conversion result or None if rate not available
        """
        if from_currency == to_currency:
            return CurrencyConversion(
                original_amount=amount,
                original_currency=from_currency,
                converted_amount=amount,
                target_currency=to_currency,
                exchange_rate=Decimal("1.0"),
                rate_date=rate_date or date.today()
            )
        
        rate_record = await self.get_rate(db, from_currency, to_currency, rate_date)
        if not rate_record:
            # Try reverse rate
            reverse_rate = await self.get_rate(db, to_currency, from_currency, rate_date)
            if reverse_rate:
                exchange_rate = Decimal("1") / reverse_rate.rate
                actual_rate_date = reverse_rate.date
            else:
                logger.warning(f"No rate available for {from_currency} to {to_currency}")
                return None
        else:
            exchange_rate = rate_record.rate
            actual_rate_date = rate_record.date
        
        converted_amount = amount * exchange_rate
        
        return CurrencyConversion(
            original_amount=amount,
            original_currency=from_currency,
            converted_amount=converted_amount,
            target_currency=to_currency,
            exchange_rate=exchange_rate,
            rate_date=actual_rate_date
        )


# Global service instance
exchange_rate_service = ExchangeRateService()