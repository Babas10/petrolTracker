# Currency Exchange Rate Microservice

A high-performance FastAPI microservice for managing currency exchange rates with automated daily updates and caching.

## Features

- 🔄 **Automated Daily Updates**: Fetches exchange rates daily from multiple external APIs
- 🚀 **High Performance**: Redis caching with <100ms response times
- 🛡️ **Production Ready**: Docker containerization, rate limiting, authentication
- 🔧 **Multiple API Support**: ExchangeRate-API, Fixer.io, and free APIs with fallback
- 📊 **Comprehensive API**: RESTful endpoints for rates, conversions, and admin functions
- 🗄️ **PostgreSQL Storage**: Reliable data persistence with proper indexing
- ⚡ **Background Scheduling**: APScheduler for automated tasks

## Quick Start

### Using Docker Compose (Recommended)

1. **Clone and setup**:
```bash
cd currency_microservice
cp .env.example .env
# Edit .env with your API keys and configuration
```

2. **Start services**:
```bash
docker-compose up -d
```

3. **Verify health**:
```bash
curl http://localhost:8000/api/v1/health
```

### Manual Setup

1. **Install dependencies**:
```bash
pip install -r requirements.txt
```

2. **Set environment variables**:
```bash
export DATABASE_URL="postgresql://user:pass@localhost:5432/currency_rates"
export REDIS_URL="redis://localhost:6379/0"
export API_KEY="your-secure-api-key"
export EXCHANGE_API_KEY="your-exchange-api-key"
```

3. **Start PostgreSQL and Redis**

4. **Run the application**:
```bash
uvicorn app.main:app --host 0.0.0.0 --port 8000
```

## API Documentation

### Authentication

All endpoints (except `/health`) require Bearer token authentication:

```bash
curl -H "Authorization: Bearer your-api-key" \
     http://localhost:8000/api/v1/rates/USD/EUR
```

### Core Endpoints

#### Get Exchange Rate
```bash
GET /api/v1/rates/{base}/{target}?date=2023-12-01
```

#### Get All Rates for Base Currency
```bash
GET /api/v1/rates/{base}?date=2023-12-01
```

#### Get Latest Rates
```bash
GET /api/v1/rates/latest
```

#### Convert Currency
```bash
POST /api/v1/convert?amount=100&from_currency=USD&to_currency=EUR&date=2023-12-01
```

#### Health Check
```bash
GET /api/v1/health
```

#### Supported Currencies
```bash
GET /api/v1/currencies
```

### Admin Endpoints

#### Manually Fetch Rates
```bash
POST /api/v1/admin/fetch-rates?base=USD
```

#### Clear Cache
```bash
DELETE /api/v1/admin/cache
```

#### Cache Statistics
```bash
GET /api/v1/admin/cache/stats
```
Returns cache performance metrics and daily optimization info.

#### Test Data Management (Debug Mode Only)
```bash
# Seed realistic test currency data
POST /api/v1/admin/seed-test-data?base_currency=USD&clear_existing=true

# Check seeding status and system readiness
GET /api/v1/admin/seeding-status

# Generate sample currency conversions to test data flow
GET /api/v1/admin/test-conversions?base_currency=USD
```
These endpoints are only available when `DEBUG=True` and provide comprehensive testing tools.

## Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `DATABASE_URL` | PostgreSQL connection string | `postgresql://postgres:password@localhost:5432/currency_rates` |
| `REDIS_URL` | Redis connection string | `redis://localhost:6379/0` |
| `API_KEY` | Authentication API key | `your_secure_api_key_here` |
| `EXCHANGE_API_KEY` | ExchangeRate-API key | - |
| `FIXER_API_KEY` | Fixer.io API key | - |
| `RATE_LIMIT_PER_HOUR` | Requests per hour limit | `1000` |
| `CACHE_TTL_SECONDS` | Cache TTL in seconds | `86400` (24 hours for Flutter daily pattern) |
| `DAILY_FETCH_TIME` | Daily fetch time (HH:MM) | `06:00` |
| `TIMEZONE` | Timezone for scheduling | `UTC` |

### Supported Currencies

USD, EUR, GBP, CAD, AUD, JPY, CHF, CNY, INR, MXN, BRL, KRW, SGD, NZD, NOK, SEK, DKK, PLN, CZK, HUF, RUB, TRY, ZAR, THB

## Architecture

```
┌─────────────────┐    ┌──────────────┐    ┌─────────────┐
│   FastAPI App   │────│  PostgreSQL  │────│    Redis    │
└─────────────────┘    └──────────────┘    └─────────────┘
         │
         ├── External APIs (ExchangeRate-API, Fixer.io)
         ├── Background Scheduler (APScheduler)  
         └── Authentication & Rate Limiting
```

### Components

- **FastAPI**: High-performance web framework
- **PostgreSQL**: Primary data storage with proper indexing
- **Redis**: Caching layer for fast response times  
- **APScheduler**: Background job scheduling
- **SQLAlchemy**: Async ORM for database operations
- **Pydantic**: Data validation and serialization

## Development

### Testing the Complete Data Flow

The microservice includes comprehensive testing tools to verify the entire data flow from database → cache → API → Flutter integration.

#### 1. **Automatic Test Data (Debug Mode)**
When `DEBUG=True`, the microservice automatically seeds test data on startup:

```bash
# Enable debug mode in .env
DEBUG=True

# Start the application
uvicorn app.main:app --reload

# Check logs for: "✅ Test data initialized: 23 currency rates"
```

#### 2. **Manual Test Data Seeding**
```bash
# Seed fresh test data
POST /api/v1/admin/seed-test-data?base_currency=USD

# Response shows realistic exchange rates created
{
  "status": "success",
  "rates_created": 23,
  "currencies": ["EUR", "GBP", "JPY", "CAD", ...],
  "cache_warmed": true
}
```

#### 3. **Verify Complete Data Flow**
```bash
# 1. Check seeding status
GET /api/v1/admin/seeding-status

# 2. Test sample conversions (DB → Cache → API)
GET /api/v1/admin/test-conversions

# 3. Monitor cache performance  
GET /api/v1/admin/cache/stats

# 4. Test Flutter daily pattern - fetch all rates
GET /api/v1/rates/latest
```

#### 4. **End-to-End Testing Workflow**
```bash
# Complete testing sequence
curl -H "Authorization: Bearer your-api-key" http://localhost:8000/api/v1/admin/seed-test-data
curl -H "Authorization: Bearer your-api-key" http://localhost:8000/api/v1/admin/test-conversions  
curl -H "Authorization: Bearer your-api-key" http://localhost:8000/api/v1/rates/latest
curl -H "Authorization: Bearer your-api-key" http://localhost:8000/api/v1/admin/cache/stats
```

**Expected Results:**
- ✅ Database populated with 20+ realistic currency rates
- ✅ Cache warmed with 24-hour TTL
- ✅ Sample conversions show accurate calculations
- ✅ `/rates/latest` returns all cached rates instantly (Flutter pattern)
- ✅ Cache stats show high hit rates and 24-hour TTL

### Running Unit Tests
```bash
pytest tests/ -v
```

### Code Quality
```bash
# Format code
black app/ tests/

# Lint code  
flake8 app/ tests/

# Type checking
mypy app/
```

### Database Migrations
```bash
# Generate migration
alembic revision --autogenerate -m "description"

# Run migrations
alembic upgrade head
```

## Monitoring

### Health Check
The `/api/v1/health` endpoint provides comprehensive health information:

```json
{
  "status": "healthy",
  "timestamp": "2023-12-01T12:00:00Z",
  "version": "1.0.0",
  "database": true,
  "redis": true
}
```

### Logging
- Structured JSON logging to stdout
- Request/response logging with timing
- Error tracking with stack traces
- Background job execution logs

### Metrics
- Response time tracking
- Cache hit/miss ratios
- External API success rates
- Rate limiting statistics

## Production Deployment

### Docker
```bash
# Build image
docker build -t currency-microservice .

# Run container
docker run -d \
  -p 8000:8000 \
  -e DATABASE_URL="postgresql://..." \
  -e REDIS_URL="redis://..." \
  -e API_KEY="secure-key" \
  currency-microservice
```

### Security Considerations
- Use strong API keys in production
- Configure CORS for your domains
- Set up TLS/HTTPS termination
- Use a reverse proxy (nginx/traefik)
- Implement request logging and monitoring
- Regular security updates

### Scaling
- Horizontal scaling: Multiple container instances
- Database: PostgreSQL with read replicas
- Cache: Redis Cluster for high availability
- Load balancing: Multiple app instances
- Background jobs: Single scheduler instance

## API Integration

### Flutter Daily Cache Pattern (Recommended)

**Optimal approach**: Fetch all currencies once per day, cache locally for 24 hours.

```dart
class CurrencyService {
  Future<Map<String, double>> getAllRates() async {
    // Check if today's rates are cached
    if (_shouldFetchNewRates(DateTime.now())) {
      await _fetchAllRates(); // One API call per day
    }
    return _cachedRates;
  }

  Future<double> convertCurrency({
    required double amount,
    required String from,
    required String to,
  }) async {
    final rates = await getAllRates();
    return amount * (rates[to]! / rates[from]!);
  }

  Future<void> _fetchAllRates() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/rates/latest'), // Bulk fetch
      headers: {'Authorization': 'Bearer $apiKey'},
    );
    // Parse and cache all rates locally
  }
}
```

**Benefits:**
- 📱 **1 API call per day** instead of many
- ⚡ **Instant conversions** using cached data  
- 🔋 **Better battery life** and data usage
- 📶 **Offline capability** with local cache

See `examples/flutter_daily_cache_service.dart` for complete implementation.

### Alternative: Individual Rate Fetching
```dart
class CurrencyApiClient {
  Future<ExchangeRate> getRate(String base, String target) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/rates/$base/$target'),
      headers: {'Authorization': 'Bearer $apiKey'},
    );
    return ExchangeRate.fromJson(jsonDecode(response.body));
  }
}
```

### Rate Limiting
- 1000 requests per hour per API key (configurable)
- 429 status code when limit exceeded
- Rate limit headers in responses
- Per-client tracking and enforcement

## Troubleshooting

### Common Issues

1. **Database Connection Failed**
   - Check PostgreSQL is running and accessible
   - Verify DATABASE_URL format and credentials
   - Ensure database exists

2. **Redis Connection Failed**  
   - Check Redis is running and accessible
   - Verify REDIS_URL format
   - Check network connectivity

3. **External API Errors**
   - Verify API keys are valid and active
   - Check API rate limits and quotas  
   - Review API provider status pages

4. **Rate Limiting Issues**
   - Check API key configuration
   - Verify rate limit settings
   - Monitor request patterns

### Debug Mode
Set `DEBUG=True` in environment to enable:
- Detailed SQL query logging
- Full error stack traces
- API documentation at `/docs`
- Extended logging output

## License

This project is part of the petrolTracker application suite.

## Support

For issues and questions:
1. Check the troubleshooting section
2. Review application logs
3. Check external API status
4. Verify configuration settings