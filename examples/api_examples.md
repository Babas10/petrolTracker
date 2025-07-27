# REST API Examples for Testing

The REST API is automatically started when running the app in debug mode on **mobile or desktop platforms** (not web) on `http://localhost:8080`.

## Platform Requirements

⚠️ **Important**: The REST API only works on **mobile and desktop platforms**. It is **not available when running on web** due to browser security restrictions.

To use the REST API:
1. Run the app on mobile: `flutter run -d <device-id>`
2. Run the app on desktop: `flutter run -d macos` (or `windows`, `linux`)
3. The REST API will be available at `http://localhost:8080`

## Why not web?
The HTTP server functionality (`shelf` package) is not supported in web browsers due to security restrictions. Web browsers cannot create HTTP servers.

## Health Check

```bash
curl http://localhost:8080/api/health
```

## Create Vehicle

```bash
curl -X POST http://localhost:8080/api/vehicles \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Toyota Camry 2020",
    "initialKm": 25000.0
  }'
```

## Create Fuel Entry

```bash
curl -X POST http://localhost:8080/api/fuel-entries \
  -H "Content-Type: application/json" \
  -d '{
    "vehicleId": 1,
    "date": "2024-01-15",
    "currentKm": 25400.0,
    "fuelAmount": 45.5,
    "price": 65.75,
    "country": "Canada",
    "pricePerLiter": 1.445
  }'
```

## Bulk Create Vehicles

```bash
curl -X POST http://localhost:8080/api/bulk/vehicles \
  -H "Content-Type: application/json" \
  -d '{
    "vehicles": [
      {
        "name": "Honda Civic 2019",
        "initialKm": 30000.0
      },
      {
        "name": "Ford F-150 2021",
        "initialKm": 15000.0
      }
    ]
  }'
```

## Bulk Create Mixed Data

```bash
curl -X POST http://localhost:8080/api/bulk/data \
  -H "Content-Type: application/json" \
  -d '{
    "vehicles": [
      {
        "name": "BMW X3 2022",
        "initialKm": 5000.0
      }
    ],
    "fuelEntries": [
      {
        "vehicleId": 1,
        "date": "2024-01-20",
        "currentKm": 25800.0,
        "fuelAmount": 42.0,
        "price": 60.90,
        "country": "Canada",
        "pricePerLiter": 1.450
      },
      {
        "vehicleId": 1,
        "date": "2024-01-25",
        "currentKm": 26200.0,
        "fuelAmount": 38.5,
        "price": 55.85,
        "country": "Canada",
        "pricePerLiter": 1.450
      }
    ]
  }'
```

## List All Vehicles

```bash
curl http://localhost:8080/api/vehicles
```

## List All Fuel Entries

```bash
curl http://localhost:8080/api/fuel-entries
```

## Delete Vehicle

```bash
curl -X DELETE http://localhost:8080/api/vehicles/1
```

## Delete Fuel Entry

```bash
curl -X DELETE http://localhost:8080/api/fuel-entries/1
```

## Clear All Data

```bash
curl -X DELETE http://localhost:8080/api/bulk/reset
```

## Test Scenario: Complete Setup

Here's a complete test scenario to set up a vehicle with multiple fuel entries:

```bash
# 1. Create a vehicle
curl -X POST http://localhost:8080/api/vehicles \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Vehicle",
    "initialKm": 50000.0
  }'

# 2. Add multiple fuel entries
curl -X POST http://localhost:8080/api/bulk/fuel-entries \
  -H "Content-Type: application/json" \
  -d '{
    "fuelEntries": [
      {
        "vehicleId": 1,
        "date": "2024-01-01",
        "currentKm": 50400.0,
        "fuelAmount": 40.0,
        "price": 58.00,
        "country": "Canada",
        "pricePerLiter": 1.450
      },
      {
        "vehicleId": 1,
        "date": "2024-01-08",
        "currentKm": 50800.0,
        "fuelAmount": 38.0,
        "price": 55.10,
        "country": "Canada",
        "pricePerLiter": 1.450
      },
      {
        "vehicleId": 1,
        "date": "2024-01-15",
        "currentKm": 51200.0,
        "fuelAmount": 42.0,
        "price": 60.90,
        "country": "Canada",
        "pricePerLiter": 1.450
      },
      {
        "vehicleId": 1,
        "date": "2024-01-22",
        "currentKm": 51600.0,
        "fuelAmount": 39.0,
        "price": 56.55,
        "country": "Canada",
        "pricePerLiter": 1.450
      },
      {
        "vehicleId": 1,
        "date": "2024-01-29",
        "currentKm": 52000.0,
        "fuelAmount": 41.0,
        "price": 59.45,
        "country": "Canada",
        "pricePerLiter": 1.450
      }
    ]
  }'
```

This will create a vehicle with 5 fuel entries, perfect for testing the chart functionality and x-axis optimization.