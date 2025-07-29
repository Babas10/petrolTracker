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

## Real-World Example: Toyota Hilux 2013

Here's a complete example using real data for a Toyota Hilux 2013 with actual fuel entries:

```bash
# 1. Create the Toyota Hilux 2013
curl -X POST http://localhost:8080/api/vehicles \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Toyota Hilux 2013",
    "initialKm": 98510.0
  }'

# 2. Add all fuel entries in one bulk operation
curl -X POST http://localhost:8080/api/bulk/fuel-entries \
  -H "Content-Type: application/json" \
  -d '{
    "fuelEntries": [
      {
        "vehicleId": 1,
        "date": "2024-01-01",
        "currentKm": 98510.0,
        "fuelAmount": 30.5,
        "price": 25.46,
        "country": "USA",
        "pricePerLiter": 0.835
      },
      {
        "vehicleId": 1,
        "date": "2024-01-08",
        "currentKm": 99080.0,
        "fuelAmount": 25.4,
        "price": 25.46,
        "country": "USA", 
        "pricePerLiter": 1.003
      },
      {
        "vehicleId": 1,
        "date": "2024-01-15",
        "currentKm": 99303.0,
        "fuelAmount": 21.6,
        "price": 20.00,
        "country": "USA",
        "pricePerLiter": 0.926
      },
      {
        "vehicleId": 1,
        "date": "2024-01-22",
        "currentKm": 99600.0,
        "fuelAmount": 37.9,
        "price": 33.00,
        "country": "USA",
        "pricePerLiter": 0.871
      },
      {
        "vehicleId": 1,
        "date": "2024-01-29",
        "currentKm": 100106.0,
        "fuelAmount": 43.9,
        "price": 37.00,
        "country": "USA",
        "pricePerLiter": 0.843
      },
      {
        "vehicleId": 1,
        "date": "2024-02-05",
        "currentKm": 100422.0,
        "fuelAmount": 41.5,
        "price": 38.37,
        "country": "USA",
        "pricePerLiter": 0.925
      },
      {
        "vehicleId": 1,
        "date": "2024-02-12",
        "currentKm": 100800.0,
        "fuelAmount": 41.6,
        "price": 34.00,
        "country": "USA",
        "pricePerLiter": 0.817
      },
      {
        "vehicleId": 1,
        "date": "2024-02-19",
        "currentKm": 101379.0,
        "fuelAmount": 57.2,
        "price": 54.90,
        "country": "USA",
        "pricePerLiter": 0.960
      },
      {
        "vehicleId": 1,
        "date": "2024-02-26",
        "currentKm": 101921.0,
        "fuelAmount": 13.2,
        "price": 15.86,
        "country": "USA",
        "pricePerLiter": 1.201
      },
      {
        "vehicleId": 1,
        "date": "2024-03-05",
        "currentKm": 102405.0,
        "fuelAmount": 71.2,
        "price": 72.64,
        "country": "USA",
        "pricePerLiter": 1.020
      },
      {
        "vehicleId": 1,
        "date": "2024-03-12",
        "currentKm": 102960.0,
        "fuelAmount": 55.6,
        "price": 54.31,
        "country": "USA",
        "pricePerLiter": 0.977
      }
    ]
  }'
```

**Data Details:**
- Vehicle: Toyota Hilux 2013 starting at 98,510 km
- 11 fuel entries spanning from 98,510 km to 102,960 km (4,450 km total)
- Fuel amounts range from 3.5 to 18.8 gallons (converted to liters: 13.2L to 71.2L)
- Prices from $15.86 to $72.64
- Price per liter calculated from gallons and total price

This real-world dataset is perfect for testing:
- Chart display with varying consumption patterns
- X-axis optimization with realistic odometer readings
- Consumption calculations over different distances
- Price trend analysis
