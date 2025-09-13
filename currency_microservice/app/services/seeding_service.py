"""
Database seeding service for testing and development.
"""
import random
from decimal import Decimal
from datetime import date, datetime
from typing import List, Dict
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, delete

from app.models.exchange_rate import ExchangeRateDB, ExchangeRateCreate
from app.services.exchange_rate_service import exchange_rate_service
from app.services.cache_service import cache_service
from app.core.config import settings
import logging

logger = logging.getLogger(__name__)


class SeedingService:
    """Service for seeding database with test data."""
    
    # Realistic exchange rate ranges (approximate)
    CURRENCY_RANGES = {
        "EUR": (0.82, 0.92),    # USD to EUR
        "GBP": (0.70, 0.85),    # USD to GBP  
        "CAD": (1.20, 1.40),    # USD to CAD
        "AUD": (1.30, 1.55),    # USD to AUD
        "JPY": (100.0, 155.0),  # USD to JPY
        "CHF": (0.85, 0.95),    # USD to CHF
        "CNY": (6.8, 7.3),      # USD to CNY
        "INR": (75.0, 85.0),    # USD to INR
        "MXN": (16.0, 20.0),    # USD to MXN
        "BRL": (4.8, 5.8),      # USD to BRL
        "KRW": (1200.0, 1400.0), # USD to KRW
        "SGD": (1.30, 1.40),    # USD to SGD
        "NZD": (1.40, 1.70),    # USD to NZD
        "NOK": (9.0, 11.0),     # USD to NOK
        "SEK": (9.5, 11.5),     # USD to SEK
        "DKK": (6.0, 7.0),      # USD to DKK
        "PLN": (3.8, 4.5),      # USD to PLN
        "CZK": (21.0, 25.0),    # USD to CZK
        "HUF": (340.0, 380.0),  # USD to HUF
        "TRY": (25.0, 35.0),    # USD to TRY
        "ZAR": (15.0, 20.0),    # USD to ZAR
        "THB": (33.0, 38.0),    # USD to THB
    }
    
    async def seed_test_currency_data(
        self, 
        db: AsyncSession, 
        base_currency: str = "USD",
        target_date: date = None,
        clear_existing: bool = True
    ) -> Dict[str, any]:
        """
        Seed database with realistic test currency data.
        
        Args:
            db: Database session
            base_currency: Base currency for rates
            target_date: Date for the rates (defaults to today)
            clear_existing: Whether to clear existing data first
            
        Returns:
            Dictionary with seeding results
        """
        if target_date is None:
            target_date = date.today()
            
        logger.info(f"Starting currency data seeding for {target_date}")
        
        try:
            # Clear existing data if requested
            if clear_existing:
                await self._clear_existing_data(db, target_date)
            
            # Generate test rates
            rates_created = await self._create_test_rates(db, base_currency, target_date)
            
            # Clear cache to force fresh data loading
            await cache_service.clear_cache()
            
            # Warm cache with new data
            await self._warm_cache_with_test_data(db, base_currency)
            
            result = {
                "status": "success",
                "base_currency": base_currency,
                "target_date": target_date.isoformat(),
                "rates_created": rates_created,
                "currencies": list(self.CURRENCY_RANGES.keys()),
                "cache_warmed": True,
                "message": f"Successfully seeded {rates_created} currency rates for testing"
            }
            
            logger.info(f"Currency data seeding completed: {rates_created} rates created")
            return result
            
        except Exception as e:
            logger.error(f"Error seeding currency data: {e}")
            return {
                "status": "error",
                "message": str(e),
                "rates_created": 0
            }
    
    async def _clear_existing_data(self, db: AsyncSession, target_date: date):
        """Clear existing currency data for the target date."""
        logger.info(f"Clearing existing currency data for {target_date}")
        
        delete_stmt = delete(ExchangeRateDB).where(ExchangeRateDB.date == target_date)
        await db.execute(delete_stmt)
        await db.commit()
    
    async def _create_test_rates(
        self, 
        db: AsyncSession, 
        base_currency: str, 
        target_date: date
    ) -> int:
        """Create test exchange rates with realistic random values."""
        rates_created = 0
        
        for target_currency, (min_rate, max_rate) in self.CURRENCY_RANGES.items():
            if target_currency == base_currency:
                continue  # Skip same currency
                
            # Generate realistic random rate within range
            rate = Decimal(str(round(random.uniform(min_rate, max_rate), 6)))
            
            # Create exchange rate record
            rate_data = ExchangeRateCreate(
                base_currency=base_currency,
                target_currency=target_currency,
                rate=rate,
                date=target_date
            )
            
            try:
                await exchange_rate_service.create_rate(db, rate_data)
                rates_created += 1
                logger.debug(f"Created rate: {base_currency}/{target_currency} = {rate}")
                
            except Exception as e:
                logger.error(f"Failed to create rate {base_currency}/{target_currency}: {e}")
        
        return rates_created
    
    async def _warm_cache_with_test_data(self, db: AsyncSession, base_currency: str):
        """Warm cache with newly created test data."""
        logger.info("Warming cache with test data")
        
        try:
            # This will load all rates from DB and cache them
            latest_rates = await exchange_rate_service.get_latest_rates(db, base_currency)
            logger.info(f"Cache warmed with {len(latest_rates)} rates")
            
        except Exception as e:
            logger.error(f"Failed to warm cache: {e}")
    
    async def generate_sample_conversions(
        self, 
        db: AsyncSession, 
        base_currency: str = "USD"
    ) -> List[Dict[str, any]]:
        """
        Generate sample currency conversions for testing.
        
        Returns list of conversion examples showing the complete flow.
        """
        logger.info("Generating sample currency conversions")
        
        sample_amounts = [10.0, 50.0, 100.0, 500.0, 1000.0]
        sample_currencies = ["EUR", "GBP", "JPY", "CAD", "AUD"]
        conversions = []
        
        for amount in sample_amounts[:2]:  # Limit for testing
            for target_currency in sample_currencies[:3]:  # Limit for testing
                try:
                    conversion = await exchange_rate_service.convert_currency(
                        db=db,
                        amount=Decimal(str(amount)),
                        from_currency=base_currency,
                        to_currency=target_currency,
                        rate_date=date.today()
                    )
                    
                    conversions.append({
                        "from_amount": float(amount),
                        "from_currency": base_currency,
                        "to_amount": float(conversion.converted_amount),
                        "to_currency": target_currency,
                        "exchange_rate": float(conversion.exchange_rate),
                        "formatted": f"{amount} {base_currency} = {conversion.converted_amount:.2f} {target_currency}"
                    })
                    
                except Exception as e:
                    logger.error(f"Conversion failed {amount} {base_currency} -> {target_currency}: {e}")
        
        return conversions
    
    async def get_seeding_status(self, db: AsyncSession) -> Dict[str, any]:
        """Get current seeding status and data overview."""
        try:
            # Count total rates
            total_rates_result = await db.execute(select(ExchangeRateDB))
            total_rates = len(total_rates_result.scalars().all())
            
            # Count rates for today
            today_rates_result = await db.execute(
                select(ExchangeRateDB).where(ExchangeRateDB.date == date.today())
            )
            today_rates = len(today_rates_result.scalars().all())
            
            # Get cache stats
            cache_stats = await cache_service.get_cache_stats()
            
            return {
                "database": {
                    "total_exchange_rates": total_rates,
                    "today_rates": today_rates,
                    "supported_currencies": len(self.CURRENCY_RANGES),
                },
                "cache": cache_stats,
                "test_data_available": today_rates > 0,
                "ready_for_testing": today_rates > 0 and cache_stats.get("status") == "connected"
            }
            
        except Exception as e:
            logger.error(f"Error getting seeding status: {e}")
            return {
                "status": "error",
                "message": str(e)
            }


# Global seeding service instance
seeding_service = SeedingService()