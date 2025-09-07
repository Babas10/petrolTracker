"""
Database models for exchange rates.
"""
from sqlalchemy import Column, Integer, String, Numeric, Date, DateTime, UniqueConstraint
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.sql import func
from pydantic import BaseModel, Field
from datetime import date, datetime
from decimal import Decimal
from typing import Optional

Base = declarative_base()


class ExchangeRateDB(Base):
    """SQLAlchemy model for exchange rates."""
    
    __tablename__ = "exchange_rates"
    
    id = Column(Integer, primary_key=True, index=True)
    base_currency = Column(String(3), nullable=False, index=True)
    target_currency = Column(String(3), nullable=False, index=True)
    rate = Column(Numeric(10, 6), nullable=False)
    date = Column(Date, nullable=False, index=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    __table_args__ = (
        UniqueConstraint('base_currency', 'target_currency', 'date', name='unique_rate_per_day'),
    )


# Pydantic models for API
class ExchangeRateBase(BaseModel):
    """Base exchange rate model."""
    base_currency: str = Field(..., max_length=3, description="Base currency code (e.g., USD)")
    target_currency: str = Field(..., max_length=3, description="Target currency code (e.g., EUR)")
    rate: Decimal = Field(..., gt=0, description="Exchange rate")
    date: date = Field(..., description="Rate date")


class ExchangeRateCreate(ExchangeRateBase):
    """Model for creating exchange rates."""
    pass


class ExchangeRateResponse(ExchangeRateBase):
    """Model for exchange rate API responses."""
    id: int
    created_at: datetime
    
    class Config:
        from_attributes = True


class ExchangeRateUpdate(BaseModel):
    """Model for updating exchange rates."""
    rate: Optional[Decimal] = Field(None, gt=0, description="New exchange rate")


class CurrencyConversion(BaseModel):
    """Model for currency conversion response."""
    original_amount: Decimal = Field(..., description="Original amount")
    original_currency: str = Field(..., max_length=3, description="Original currency")
    converted_amount: Decimal = Field(..., description="Converted amount")
    target_currency: str = Field(..., max_length=3, description="Target currency")
    exchange_rate: Decimal = Field(..., description="Exchange rate used")
    rate_date: date = Field(..., description="Date of exchange rate")


class HealthStatus(BaseModel):
    """Model for health check response."""
    status: str = Field(..., description="Service status")
    timestamp: datetime = Field(..., description="Check timestamp")
    version: str = Field(..., description="Service version")
    database: bool = Field(..., description="Database connectivity")
    redis: bool = Field(..., description="Redis connectivity")
    
    
class ErrorResponse(BaseModel):
    """Model for error responses."""
    detail: str = Field(..., description="Error details")
    timestamp: datetime = Field(default_factory=datetime.now, description="Error timestamp")