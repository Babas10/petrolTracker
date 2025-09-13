"""
External API service for fetching exchange rates from providers.
"""
import httpx
import asyncio
from typing import Dict, List, Optional
from datetime import date, datetime
from decimal import Decimal
from app.core.config import settings
import logging

logger = logging.getLogger(__name__)


class ExternalAPIService:
    """Service for fetching exchange rates from external APIs."""
    
    def __init__(self):
        self.client_timeout = httpx.Timeout(30.0)
    
    async def _fetch_from_exchangerate_api(self, base: str) -> Optional[Dict[str, Decimal]]:
        """Fetch rates from ExchangeRate-API."""
        if not settings.exchange_api_key:
            logger.warning("ExchangeRate-API key not configured")
            return None
        
        url = f"https://v6.exchangerate-api.com/v6/{settings.exchange_api_key}/latest/{base}"
        
        try:
            async with httpx.AsyncClient(timeout=self.client_timeout) as client:
                response = await client.get(url)
                response.raise_for_status()
                
                data = response.json()
                if data.get("result") == "success":
                    rates = {}
                    for currency, rate in data.get("conversion_rates", {}).items():
                        if currency in settings.supported_currencies:
                            rates[currency] = Decimal(str(rate))
                    logger.info(f"Fetched {len(rates)} rates from ExchangeRate-API for {base}")
                    return rates
                else:
                    logger.error(f"ExchangeRate-API error: {data.get('error-type', 'Unknown')}")
                    
        except httpx.RequestError as e:
            logger.error(f"ExchangeRate-API request failed: {e}")
        except httpx.HTTPStatusError as e:
            logger.error(f"ExchangeRate-API HTTP error: {e}")
        except Exception as e:
            logger.error(f"ExchangeRate-API unexpected error: {e}")
        
        return None
    
    async def _fetch_from_fixer_io(self, base: str) -> Optional[Dict[str, Decimal]]:
        """Fetch rates from Fixer.io."""
        if not settings.fixer_api_key:
            logger.warning("Fixer.io API key not configured")
            return None
        
        # Join supported currencies for the API call
        symbols = ",".join([c for c in settings.supported_currencies if c != base])
        url = f"http://data.fixer.io/api/latest"
        params = {
            "access_key": settings.fixer_api_key,
            "base": base,
            "symbols": symbols
        }
        
        try:
            async with httpx.AsyncClient(timeout=self.client_timeout) as client:
                response = await client.get(url, params=params)
                response.raise_for_status()
                
                data = response.json()
                if data.get("success"):
                    rates = {}
                    for currency, rate in data.get("rates", {}).items():
                        if currency in settings.supported_currencies:
                            rates[currency] = Decimal(str(rate))
                    # Add base currency with rate 1.0
                    rates[base] = Decimal("1.0")
                    logger.info(f"Fetched {len(rates)} rates from Fixer.io for {base}")
                    return rates
                else:
                    error_info = data.get("error", {})
                    logger.error(f"Fixer.io error: {error_info.get('info', 'Unknown')}")
                    
        except httpx.RequestError as e:
            logger.error(f"Fixer.io request failed: {e}")
        except httpx.HTTPStatusError as e:
            logger.error(f"Fixer.io HTTP error: {e}")
        except Exception as e:
            logger.error(f"Fixer.io unexpected error: {e}")
        
        return None
    
    async def _fetch_from_free_api(self, base: str) -> Optional[Dict[str, Decimal]]:
        """Fetch rates from a free API (backup option)."""
        url = f"https://api.exchangerate-api.com/v4/latest/{base}"
        
        try:
            async with httpx.AsyncClient(timeout=self.client_timeout) as client:
                response = await client.get(url)
                response.raise_for_status()
                
                data = response.json()
                rates = {}
                for currency, rate in data.get("rates", {}).items():
                    if currency in settings.supported_currencies:
                        rates[currency] = Decimal(str(rate))
                
                logger.info(f"Fetched {len(rates)} rates from free API for {base}")
                return rates
                
        except Exception as e:
            logger.error(f"Free API error: {e}")
        
        return None
    
    async def fetch_exchange_rates(self, base: str = None) -> Optional[Dict[str, Decimal]]:
        """
        Fetch exchange rates with fallback mechanism.
        
        Args:
            base: Base currency code. Defaults to configured base currency.
            
        Returns:
            Dictionary of currency codes to exchange rates, or None if all APIs fail.
        """
        base_currency = base or settings.base_currency
        
        # List of API methods to try in order
        api_methods = [
            self._fetch_from_exchangerate_api,
            self._fetch_from_fixer_io,
            self._fetch_from_free_api,
        ]
        
        for api_method in api_methods:
            try:
                rates = await api_method(base_currency)
                if rates:
                    logger.info(f"Successfully fetched rates using {api_method.__name__}")
                    return rates
            except Exception as e:
                logger.error(f"Failed to fetch from {api_method.__name__}: {e}")
                continue
        
        logger.error("All external APIs failed to provide exchange rates")
        return None
    
    async def validate_rate(self, base: str, target: str, rate: Decimal) -> bool:
        """
        Validate if an exchange rate is reasonable.
        
        Args:
            base: Base currency
            target: Target currency  
            rate: Exchange rate to validate
            
        Returns:
            True if rate seems reasonable, False otherwise
        """
        # Basic validation: rate should be positive and within reasonable bounds
        if rate <= 0:
            return False
        
        # Most exchange rates should be between 0.001 and 10000
        # This catches obvious errors while allowing for currencies like JPY
        if rate < Decimal("0.001") or rate > Decimal("10000"):
            logger.warning(f"Suspicious exchange rate: {base}/{target} = {rate}")
            return False
        
        return True
    
    async def get_supported_currencies(self) -> List[str]:
        """Get list of supported currencies."""
        return settings.supported_currencies.copy()