# API Reference Guide

Complete reference documentation for all Gapminder API endpoints.

## Base URL

When running locally:
```
http://localhost:8000
```

## Authentication

Currently, this API does not require authentication. For production deployments, consider adding API key authentication or OAuth.

## Response Format

All endpoints return data in JSON format unless otherwise specified.

### Success Response

```json
{
  "data": [...],
  "status": "success"
}
```

### Error Response

```json
{
  "error": "Error message",
  "status": "error"
}
```

## Endpoints

### 1. GET /countries

Retrieve countries from the Gapminder dataset based on filtering criteria.

#### Request

**HTTP Method**: GET

**Endpoint**: `/countries`

**Query Parameters**:

| Parameter | Type | Required | Description | Example |
|-----------|------|----------|-------------|---------|
| `in_continent` | string | Yes | Continent name. Valid values: "Africa", "Americas", "Asia", "Europe", "Oceania" | "Asia" |
| `in_lifeExpGT` | number | Yes | Minimum life expectancy (greater than) | 70 |
| `in_popGT` | number | Yes | Minimum population (greater than) | 1000000 |

#### Response

**Content-Type**: `application/json`

**Response Body**:

```json
[
  {
    "country": "Japan",
    "continent": "Asia",
    "year": 2007,
    "lifeExp": 82.603,
    "pop": 127467972,
    "gdpPercap": 31656.0681
  },
  {
    "country": "China",
    "continent": "Asia",
    "year": 2007,
    "lifeExp": 72.961,
    "pop": 1318683096,
    "gdpPercap": 4959.1149
  }
]
```

**Response Fields**:

| Field | Type | Description |
|-------|------|-------------|
| `country` | string | Country name |
| `continent` | string | Continent name |
| `year` | integer | Data year (always 2007) |
| `lifeExp` | number | Life expectancy in years |
| `pop` | integer | Population |
| `gdpPercap` | number | GDP per capita in USD |

#### Examples

**Request (curl)**:
```bash
curl "http://localhost:8000/countries?in_continent=Europe&in_lifeExpGT=75&in_popGT=5000000"
```

**Request (R)**:
```r
library(httr)
library(jsonlite)

response <- GET(
  "http://localhost:8000/countries",
  query = list(
    in_continent = "Europe",
    in_lifeExpGT = 75,
    in_popGT = 5000000
  )
)

countries <- fromJSON(content(response, "text"))
```

**Request (Python)**:
```python
import requests

params = {
    'in_continent': 'Europe',
    'in_lifeExpGT': 75,
    'in_popGT': 5000000
}

response = requests.get('http://localhost:8000/countries', params=params)
countries = response.json()
```

**Request (JavaScript)**:
```javascript
const params = new URLSearchParams({
  in_continent: 'Europe',
  in_lifeExpGT: 75,
  in_popGT: 5000000
});

fetch(`http://localhost:8000/countries?${params}`)
  .then(response => response.json())
  .then(data => console.log(data));
```

#### Error Cases

**Missing Required Parameter**:
- HTTP Status: 400 Bad Request
- Returns error message about missing parameter

**Invalid Continent**:
- Returns empty array `[]` if continent doesn't match

---

### 2. GET /plot

Generate a line chart showing life expectancy over time for a specific country.

#### Request

**HTTP Method**: GET

**Endpoint**: `/plot`

**Query Parameters**:

| Parameter | Type | Required | Description | Example |
|-----------|------|----------|-------------|---------|
| `in_country` | string | Yes | Full country name (case-sensitive) | "Japan" |
| `in_title` | string | Yes | Title for the chart | "Life Expectancy in Japan" |

#### Response

**Content-Type**: `image/png`

**Response Body**: Binary PNG image data

The chart includes:
- X-axis: Year
- Y-axis: Life expectancy
- Blue line and points showing the trend
- Custom title as specified

#### Examples

**Request (Browser)**:
```
http://localhost:8000/plot?in_country=Japan&in_title=Life%20Expectancy%20in%20Japan
```

**Request (curl - download)**:
```bash
curl "http://localhost:8000/plot?in_country=Japan&in_title=Life%20Expectancy%20in%20Japan" \
  --output japan_plot.png
```

**Request (R)**:
```r
library(httr)

# Download plot
GET(
  "http://localhost:8000/plot",
  query = list(
    in_country = "Japan",
    in_title = "Life Expectancy in Japan"
  ),
  write_disk("japan_plot.png", overwrite = TRUE)
)
```

**Request (Python)**:
```python
import requests
from PIL import Image
from io import BytesIO

params = {
    'in_country': 'Japan',
    'in_title': 'Life Expectancy in Japan'
}

response = requests.get('http://localhost:8000/plot', params=params)
img = Image.open(BytesIO(response.content))
img.save('japan_plot.png')
```

**Embed in HTML**:
```html
<img 
  src="http://localhost:8000/plot?in_country=Japan&in_title=Life%20Expectancy%20in%20Japan" 
  alt="Life Expectancy in Japan"
/>
```

#### Valid Country Names

Use exact country names from the Gapminder dataset. Examples:
- "Japan"
- "United States"
- "United Kingdom"
- "South Africa"
- "Brazil"

To get a list of all valid countries, use the `/countries` endpoint with minimal filters.

#### Error Cases

**Country Not Found**:
- Returns empty plot if country name doesn't exist
- Verify exact spelling and capitalization

---

### 3. POST /calculate_gdp

Calculate total GDP for a country using 2007 data.

#### Request

**HTTP Method**: POST

**Endpoint**: `/calculate_gdp`

**Content-Type**: `application/x-www-form-urlencoded`

**Body Parameters**:

| Parameter | Type | Required | Description | Example |
|-----------|------|----------|-------------|---------|
| `in_country` | string | Yes | Full country name | "Japan" |

#### Response

**Content-Type**: `application/json`

**Response Body**:

```json
[
  {
    "gdp": 4035469468800
  }
]
```

**Response Fields**:

| Field | Type | Description |
|-------|------|-------------|
| `gdp` | number | Total GDP in USD (population × GDP per capita) |

#### Examples

**Request (curl)**:
```bash
curl --data "in_country=Japan" http://localhost:8000/calculate_gdp
```

**Request (R)**:
```r
library(httr)
library(jsonlite)

response <- POST(
  "http://localhost:8000/calculate_gdp",
  body = list(in_country = "Japan"),
  encode = "form"
)

gdp_data <- fromJSON(content(response, "text"))
print(paste("GDP:", gdp_data$gdp))
```

**Request (Python)**:
```python
import requests

data = {'in_country': 'Japan'}
response = requests.post('http://localhost:8000/calculate_gdp', data=data)
gdp_data = response.json()
print(f"GDP: {gdp_data[0]['gdp']}")
```

**Request (JavaScript)**:
```javascript
fetch('http://localhost:8000/calculate_gdp', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/x-www-form-urlencoded'
  },
  body: 'in_country=Japan'
})
  .then(response => response.json())
  .then(data => console.log('GDP:', data[0].gdp));
```

#### Calculating GDP

GDP is calculated as:
```
GDP = population × GDP per capita
```

Using 2007 data from the Gapminder dataset.

#### Error Cases

**Country Not Found**:
- Returns empty array `[]`
- Verify country name spelling

---

## Rate Limiting

Currently, no rate limiting is implemented. For production deployments, consider implementing rate limiting to prevent abuse.

## CORS

Cross-Origin Resource Sharing (CORS) is not currently configured. To enable CORS for web applications:

Add to `R/gapminder_api.R`:

```r
#* @filter cors
cors <- function(req, res) {
  res$setHeader("Access-Control-Allow-Origin", "*")
  
  if (req$REQUEST_METHOD == "OPTIONS") {
    res$setHeader("Access-Control-Allow-Methods","*")
    res$setHeader("Access-Control-Allow-Headers", "*")
    res$status <- 200 
    return(list())
  } else {
    plumber::forward()
  }
}
```

## Swagger/OpenAPI Documentation

Access interactive API documentation at:
```
http://localhost:8000/__docs__/
```

This provides:
- Interactive testing interface
- Automatic request/response examples
- Parameter documentation
- Schema definitions

## Versioning

This API currently does not implement versioning. Future versions may use:
- URL versioning: `/v1/countries`
- Header versioning: `Accept: application/vnd.gapminder.v1+json`

## Support

For questions or issues:
- Open an issue on [GitHub](https://github.com/mkatogui/Plumber_API/issues)
- Check the [FAQ](guides/FAQ.md)
- Review [Getting Started Guide](guides/GETTING_STARTED.md)
