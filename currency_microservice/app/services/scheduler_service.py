"""
Background scheduler service for automated tasks.
"""
from apscheduler.schedulers.asyncio import AsyncIOScheduler
from apscheduler.triggers.cron import CronTrigger
from sqlalchemy.ext.asyncio import AsyncSession
from app.database.connection import async_session_factory
from app.services.exchange_rate_service import exchange_rate_service
from app.services.cache_service import cache_service
from app.core.config import settings
import logging

logger = logging.getLogger(__name__)


class SchedulerService:
    """Service for managing scheduled background tasks."""
    
    def __init__(self):
        self.scheduler = AsyncIOScheduler()
        self.is_running = False
    
    async def start(self):
        """Start the scheduler."""
        if self.is_running:
            logger.warning("Scheduler is already running")
            return
        
        # Parse daily fetch time (format: "HH:MM")
        try:
            hour, minute = map(int, settings.daily_fetch_time.split(':'))
        except ValueError:
            logger.error(f"Invalid daily fetch time format: {settings.daily_fetch_time}")
            hour, minute = 6, 0  # Default to 6:00 AM
        
        # Schedule daily rate fetching
        self.scheduler.add_job(
            self._fetch_daily_rates_job,
            trigger=CronTrigger(
                hour=hour,
                minute=minute,
                timezone=settings.timezone
            ),
            id='daily_rate_fetch',
            replace_existing=True,
            max_instances=1,
            coalesce=True
        )
        
        # Schedule cache cleanup (runs every 4 hours)
        self.scheduler.add_job(
            self._cleanup_old_cache_job,
            trigger=CronTrigger(
                hour='*/4',
                timezone=settings.timezone
            ),
            id='cache_cleanup',
            replace_existing=True,
            max_instances=1,
            coalesce=True
        )
        
        self.scheduler.start()
        self.is_running = True
        logger.info(f"Scheduler started. Daily rate fetch scheduled at {settings.daily_fetch_time} {settings.timezone}")
    
    async def stop(self):
        """Stop the scheduler."""
        if not self.is_running:
            return
        
        self.scheduler.shutdown(wait=True)
        self.is_running = False
        logger.info("Scheduler stopped")
    
    async def _fetch_daily_rates_job(self):
        """Background job to fetch daily exchange rates."""
        logger.info("Starting scheduled daily rate fetch")
        
        try:
            async with async_session_factory() as db:
                # Fetch rates for base currency
                success = await exchange_rate_service.fetch_and_store_daily_rates(db, settings.base_currency)
                
                if success:
                    logger.info("Scheduled daily rate fetch completed successfully")
                    # Warm cache for optimal Flutter daily fetching pattern
                    await self._warm_daily_cache(db)
                else:
                    logger.error("Scheduled daily rate fetch failed")
                    
        except Exception as e:
            logger.error(f"Error in scheduled daily rate fetch: {e}")
    
    async def _cleanup_old_cache_job(self):
        """Background job to clean up old cached data."""
        logger.info("Starting cache cleanup job")
        
        try:
            # Clean up expired cache entries and optimize memory
            if await cache_service.is_connected():
                # Get cache info before cleanup
                stats_before = await cache_service.get_cache_stats()
                
                # Redis automatically handles TTL expiration, but we can optimize memory
                await cache_service.redis_client.memory_purge()
                
                # Get stats after cleanup
                stats_after = await cache_service.get_cache_stats()
                
                logger.info(f"Cache cleanup completed. Keys: {stats_before.get('total_keys', 0)} -> {stats_after.get('total_keys', 0)}")
            else:
                logger.warning("Cache cleanup skipped - Redis not connected")
            
            logger.info("Cache cleanup job completed")
            
        except Exception as e:
            logger.error(f"Error in cache cleanup job: {e}")
    
    async def _warm_daily_cache(self, db: AsyncSession):
        """
        Warm the cache after daily rate fetch for optimal Flutter daily pattern.
        Pre-loads all currency rates into cache for 24-hour access.
        """
        logger.info("Starting daily cache warming for Flutter optimization")
        
        try:
            # Pre-load latest rates for all supported currencies into cache
            latest_rates = await exchange_rate_service.get_latest_rates(db, settings.base_currency)
            
            if latest_rates:
                logger.info(f"Cache warmed with {len(latest_rates)} currency rates")
                logger.debug(f"Cached currencies: {list(latest_rates.keys())}")
            else:
                logger.warning("No rates available for cache warming")
                
        except Exception as e:
            logger.error(f"Error warming daily cache: {e}")
    
    def get_job_status(self, job_id: str) -> dict:
        """Get status of a specific job."""
        job = self.scheduler.get_job(job_id)
        if job:
            return {
                'id': job.id,
                'name': job.name,
                'next_run_time': job.next_run_time,
                'trigger': str(job.trigger)
            }
        return None
    
    def list_jobs(self) -> list:
        """List all scheduled jobs."""
        jobs = []
        for job in self.scheduler.get_jobs():
            jobs.append({
                'id': job.id,
                'name': job.name,
                'next_run_time': job.next_run_time,
                'trigger': str(job.trigger)
            })
        return jobs


# Global scheduler service instance
scheduler_service = SchedulerService()