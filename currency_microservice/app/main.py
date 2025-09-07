"""
Main FastAPI application for the currency exchange rate microservice.
"""
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.trustedhost import TrustedHostMiddleware
from fastapi.responses import JSONResponse
from contextlib import asynccontextmanager
import uvicorn
import logging
import sys

from app.core.config import settings
from app.database.connection import init_database, close_database_connection
from app.services.cache_service import cache_service
from app.services.scheduler_service import scheduler_service
from app.api.endpoints import router


# Configure logging
logging.basicConfig(
    level=logging.INFO if not settings.debug else logging.DEBUG,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    handlers=[
        logging.StreamHandler(sys.stdout)
    ]
)

logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan manager."""
    # Startup
    logger.info(f"Starting {settings.app_name} v{settings.version}")
    
    try:
        # Initialize database
        await init_database()
        logger.info("Database initialized")
        
        # Connect to Redis
        await cache_service.connect()
        logger.info("Cache service connected")
        
        # Start background scheduler
        await scheduler_service.start()
        logger.info("Scheduler service started")
        
        logger.info("Application startup completed successfully")
        
    except Exception as e:
        logger.error(f"Application startup failed: {e}")
        raise
    
    yield
    
    # Shutdown
    logger.info("Shutting down application")
    
    try:
        # Stop scheduler
        await scheduler_service.stop()
        logger.info("Scheduler service stopped")
        
        # Disconnect from Redis
        await cache_service.disconnect()
        logger.info("Cache service disconnected")
        
        # Close database connections
        await close_database_connection()
        logger.info("Database connections closed")
        
        logger.info("Application shutdown completed")
        
    except Exception as e:
        logger.error(f"Error during application shutdown: {e}")


# Create FastAPI application
app = FastAPI(
    title=settings.app_name,
    description="Microservice for managing currency exchange rates with automated daily updates",
    version=settings.version,
    lifespan=lifespan,
    docs_url="/docs" if settings.debug else None,
    redoc_url="/redoc" if settings.debug else None,
)

# Add middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure appropriately for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.add_middleware(
    TrustedHostMiddleware,
    allowed_hosts=["*"]  # Configure appropriately for production
)

# Include API routes
app.include_router(router)


@app.middleware("http")
async def log_requests(request: Request, call_next):
    """Middleware to log all requests."""
    start_time = time.time()
    
    # Log request
    logger.info(f"Request: {request.method} {request.url}")
    
    response = await call_next(request)
    
    # Log response
    process_time = time.time() - start_time
    logger.info(f"Response: {response.status_code} - {process_time:.3f}s")
    
    return response


@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    """Global exception handler."""
    logger.error(f"Unhandled exception: {exc}", exc_info=True)
    
    return JSONResponse(
        status_code=500,
        content={
            "detail": "Internal server error",
            "timestamp": datetime.now().isoformat()
        }
    )


@app.get("/")
async def root():
    """Root endpoint."""
    return {
        "name": settings.app_name,
        "version": settings.version,
        "status": "running",
        "docs": "/docs" if settings.debug else "disabled",
    }


if __name__ == "__main__":
    # For development only
    import time
    from datetime import datetime
    
    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=8000,
        reload=settings.debug,
        log_level="info" if not settings.debug else "debug"
    )