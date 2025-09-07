"""
Configuration settings for the currency microservice.
"""
from pydantic_settings import BaseSettings
from typing import List


class Settings(BaseSettings):
    """Application settings loaded from environment variables."""
    
    # Database
    database_url: str = "postgresql://postgres:password@localhost:5432/currency_rates"
    
    # Redis Cache
    redis_url: str = "redis://localhost:6379/0"
    cache_ttl_seconds: int = 86400  # 24 hours for daily cache pattern
    
    # API Configuration
    api_key: str = "dev-api-key"
    rate_limit_per_hour: int = 1000
    
    # External API Keys
    exchange_api_key: str = ""
    fixer_api_key: str = ""
    
    # Application
    debug: bool = False
    app_name: str = "Currency Exchange Rate Microservice"
    version: str = "1.0.0"
    
    # Scheduling
    daily_fetch_time: str = "06:00"
    timezone: str = "UTC"
    
    # Supported Currencies
    supported_currencies: List[str] = [
        "USD", "EUR", "GBP", "CAD", "AUD", "JPY", "CHF", "CNY", 
        "INR", "MXN", "BRL", "KRW", "SGD", "NZD", "NOK", "SEK", 
        "DKK", "PLN", "CZK", "HUF", "RUB", "TRY", "ZAR", "THB"
    ]
    
    # Base currency for conversions
    base_currency: str = "USD"
    
    class Config:
        env_file = ".env"


# Global settings instance
settings = Settings()