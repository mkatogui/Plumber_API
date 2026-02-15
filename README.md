# Gapminder API

A RESTful web service built using the `plumber` package in R, providing programmatic access to the Gapminder dataset with endpoints for data retrieval, visualization, and analysis.

## Table of Contents

- [Overview](#overview)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [API Endpoints](#api-endpoints)
- [Usage Examples](#usage-examples)
- [Modern R Development Practices](#modern-r-development-practices)
- [Deployment](#deployment)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [Additional Resources](#additional-resources)

## Overview

The Gapminder API provides three main endpoints to interact with the Gapminder dataset:

- **GET `/countries`** - Filter and retrieve country data
- **GET `/plot`** - Generate life expectancy visualizations
- **POST `/calculate_gdp`** - Calculate GDP for specific countries

This API is built with modern R practices using the tidyverse ecosystem and follows RESTful design principles.

## Installation

### Prerequisites

- R version 4.1.0 or higher (for native pipe `|>` support)
- RStudio (recommended for development)

### Required Packages

Install the necessary R packages:

```r
install.packages(c("plumber", "dplyr", "ggplot2", "gapminder"))
```

### Clone the Repository

```bash
git clone https://github.com/mkatogui/Plumber_API.git
cd Plumber_API
```

## Quick Start

### Running the API Locally

1. Open R or RStudio in the project directory
2. Run the main API file:

```r
source("API.R")
```

The API will start on `http://localhost:8000`

### Testing the API

Open your browser or use curl to test the endpoints:

```bash
# Test the countries endpoint
curl "http://localhost:8000/countries?in_continent=Asia&in_lifeExpGT=60&in_popGT=1000000"

# Test the GDP calculation endpoint
curl --data "in_country=Japan" http://localhost:8000/calculate_gdp
```

### Interactive Documentation

Access the auto-generated Swagger documentation:

```
http://localhost:8000/__docs__/
```

## API Endpoints

### 1. Get Countries Endpoint

Filter countries from the Gapminder dataset based on multiple criteria.

**Endpoint**: `GET /countries`

**Parameters**:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `in_continent` | string | Yes | Continent name (e.g., "Asia", "Europe", "Africa", "Americas", "Oceania") |
| `in_lifeExpGT` | numeric | Yes | Minimum life expectancy threshold |
| `in_popGT` | numeric | Yes | Minimum population threshold |

**Response**: JSON array of country objects

**Example Request**:
```
GET http://localhost:8000/countries?in_continent=Asia&in_lifeExpGT=60&in_popGT=1000000
```

**Example Response**:
```json
[
  {
    "country": "Japan",
    "continent": "Asia",
    "year": 2007,
    "lifeExp": 82.603,
    "pop": 127467972,
    "gdpPercap": 31656.07
  }
]
```

### 2. Plot Life Expectancy Endpoint

Generate a line chart showing life expectancy trends over time for a specific country.

**Endpoint**: `GET /plot`

**Parameters**:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `in_country` | string | Yes | Country name (e.g., "Japan", "United States") |
| `in_title` | string | Yes | Chart title |

**Response**: PNG image

**Example Request**:
```
GET http://localhost:8000/plot?in_country=Japan&in_title=Life%20Expectancy%20in%20Japan
```

**Example Usage in Browser**:
```html
<img src="http://localhost:8000/plot?in_country=Japan&in_title=Life%20Expectancy%20in%20Japan" alt="Life Expectancy Chart">
```

### 3. Calculate GDP Endpoint

Calculate the total GDP for a country using 2007 data.

**Endpoint**: `POST /calculate_gdp`

**Parameters**:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `in_country` | string | Yes | Country name |

**Response**: JSON object with GDP calculation

**Example Request**:
```bash
curl --data "in_country=Japan" http://localhost:8000/calculate_gdp
```

**Example Response**:
```json
[
  {
    "gdp": 4035469468800
  }
]
```

## Usage Examples

### R Client Examples

#### Using httr Package

```r
library(httr)
library(jsonlite)

# Get countries data
response <- GET(
  "http://localhost:8000/countries",
  query = list(
    in_continent = "Asia",
    in_lifeExpGT = 70,
    in_popGT = 10000000
  )
)

countries <- fromJSON(content(response, "text"))
print(countries)

# Calculate GDP for multiple countries
countries_list <- c("Japan", "China", "India")

gdp_results <- purrr::map_dfr(countries_list, function(country) {
  response <- POST(
    "http://localhost:8000/calculate_gdp",
    body = list(in_country = country),
    encode = "form"
  )
  fromJSON(content(response, "text"))
})
```

#### Using curl Package

```r
library(curl)

# Get plot and save as file
h <- new_handle()
handle_setopt(h, customrequest = "GET")

curl_download(
  "http://localhost:8000/plot?in_country=Japan&in_title=Japan%20Life%20Expectancy",
  "japan_plot.png",
  handle = h
)
```

### Python Client Example

```python
import requests
import json
from PIL import Image
from io import BytesIO

# Base URL
BASE_URL = "http://localhost:8000"

# Get countries
params = {
    "in_continent": "Europe",
    "in_lifeExpGT": "75",
    "in_popGT": "1000000"
}
response = requests.get(f"{BASE_URL}/countries", params=params)
countries = response.json()
print(json.dumps(countries, indent=2))

# Calculate GDP
data = {"in_country": "France"}
response = requests.post(f"{BASE_URL}/calculate_gdp", data=data)
gdp = response.json()
print(f"France GDP: {gdp[0]['gdp']}")

# Get and display plot
params = {
    "in_country": "France",
    "in_title": "Life Expectancy in France"
}
response = requests.get(f"{BASE_URL}/plot", params=params)
img = Image.open(BytesIO(response.content))
img.show()
```

### JavaScript/Node.js Example

```javascript
const axios = require('axios');
const fs = require('fs');

const BASE_URL = 'http://localhost:8000';

// Get countries
async function getCountries() {
  const response = await axios.get(`${BASE_URL}/countries`, {
    params: {
      in_continent: 'Americas',
      in_lifeExpGT: 70,
      in_popGT: 1000000
    }
  });
  console.log(response.data);
}

// Calculate GDP
async function calculateGDP(country) {
  const response = await axios.post(`${BASE_URL}/calculate_gdp`, 
    `in_country=${country}`,
    { headers: { 'Content-Type': 'application/x-www-form-urlencoded' } }
  );
  return response.data;
}

// Download plot
async function downloadPlot(country, title, filename) {
  const response = await axios.get(`${BASE_URL}/plot`, {
    params: { in_country: country, in_title: title },
    responseType: 'arraybuffer'
  });
  fs.writeFileSync(filename, response.data);
}

// Run examples
getCountries();
calculateGDP('Brazil').then(data => console.log('Brazil GDP:', data));
downloadPlot('Brazil', 'Life Expectancy in Brazil', 'brazil.png');
```

## Modern R Development Practices

This API follows modern R development patterns. Here are some best practices used:

### Using the Native Pipe (`|>`)

The codebase can be modernized to use R's native pipe operator (R 4.1+):

```r
# Modern approach
gapminder |>
  filter(year == 2007) |>
  summarise(avg_life_exp = mean(lifeExp))

# Instead of magrittr pipe
gapminder %>% filter(year == 2007)
```

### Per-Operation Grouping with `.by`

Use `.by` instead of `group_by() |> ... |> ungroup()`:

```r
# Modern approach
gapminder |>
  summarise(
    avg_gdp = mean(gdpPercap),
    .by = c(continent, year)
  )

# Instead of
gapminder |>
  group_by(continent, year) |>
  summarise(avg_gdp = mean(gdpPercap)) |>
  ungroup()
```

### Type-Safe Functional Programming

Use `purrr` for type-stable iterations:

```r
library(purrr)

countries <- c("Japan", "China", "India")

# Type-safe mapping
gdp_values <- map_dbl(countries, function(country) {
  gapminder |>
    filter(country == !!country, year == 2007) |>
    summarise(gdp = pop * gdpPercap) |>
    pull(gdp)
})
```

**📚 Learn More**: See [docs/guides/MODERN_R.md](docs/guides/MODERN_R.md) for comprehensive modern R patterns.

## Deployment

### Deploying to RStudio Connect

1. Install `rsconnect` package:
```r
install.packages("rsconnect")
```

2. Configure your RStudio Connect account:
```r
rsconnect::setAccountInfo(
  name = "your-account",
  token = "your-token",
  secret = "your-secret"
)
```

3. Deploy the API:
```r
rsconnect::deployAPI("R/gapminder_api.R")
```

### Deploying with Docker

Create a `Dockerfile`:

```dockerfile
FROM rocker/r-ver:4.3.0

RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev

RUN R -e "install.packages(c('plumber', 'dplyr', 'ggplot2', 'gapminder'))"

WORKDIR /app
COPY . /app

EXPOSE 8000

CMD ["R", "-e", "source('API.R')"]
```

Build and run:
```bash
docker build -t gapminder-api .
docker run -p 8000:8000 gapminder-api
```

**📚 Learn More**: See [docs/deployment/DOCKER.md](docs/deployment/DOCKER.md) for detailed Docker deployment guide.

## Troubleshooting

### Common Issues

#### Port Already in Use

If port 8000 is already in use:

```r
# Use a different port
pr <- plumber::plumb("R/gapminder_api.R")
pr$run(port = 8080)
```

#### Package Installation Errors

If you encounter package installation errors:

```r
# Update R packages
update.packages(ask = FALSE)

# Install from CRAN mirror
options(repos = c(CRAN = "https://cran.rstudio.com"))
install.packages(c("plumber", "dplyr", "ggplot2", "gapminder"))
```

#### Plot File Permission Issues

If you encounter file permission errors when generating plots:

```r
# Ensure write permissions in working directory
getwd()  # Check current directory
# Or specify a writable temp directory in the plot function
```

**📚 Learn More**: See [docs/guides/FAQ.md](docs/guides/FAQ.md) for more troubleshooting tips.

### Getting Help

- Check the [Issues](https://github.com/mkatogui/Plumber_API/issues) page
- Refer to [Plumber documentation](https://www.rplumber.io/)
- See [Gapminder dataset documentation](https://www.gapminder.org/data/)

## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Quick Start for Contributors

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Make your changes following the code style guidelines
4. Test your changes locally
5. Submit a pull request

### Code Style

This project follows the [tidyverse style guide](https://style.tidyverse.org/):

- Use 2 spaces for indentation
- Use `<-` for assignment
- Use native pipe `|>` for chaining operations
- Use meaningful variable names
- Add roxygen2 comments for API endpoints

## Additional Resources

### Documentation

- 📖 [Getting Started Guide](docs/guides/GETTING_STARTED.md) - Step-by-step setup and usage
- 📖 [API Reference](docs/API_REFERENCE.md) - Detailed endpoint documentation
- 📖 [Modern R Development](docs/guides/MODERN_R.md) - Modern R practices and patterns
- 📖 [FAQ](docs/guides/FAQ.md) - Frequently asked questions
- 📖 [Docker Deployment](docs/deployment/DOCKER.md) - Containerization guide

### Learning Resources

- [Plumber Package Documentation](https://www.rplumber.io/)
- [Gapminder Data](https://www.gapminder.org/data/)
- [dplyr Documentation](https://dplyr.tidyverse.org/)
- [ggplot2 Documentation](https://ggplot2.tidyverse.org/)
- [R for Data Science](https://r4ds.had.co.nz/) - Free online book
- [Building APIs with Plumber](https://www.rplumber.io/articles/rendering-output.html)

### Related Projects

- [plumber](https://github.com/rstudio/plumber) - The R package powering this API
- [gapminder](https://github.com/jennybc/gapminder) - The data package used

---

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Gapminder Foundation for providing the dataset
- RStudio for the plumber package
- Contributors to the tidyverse ecosystem

---

**Author**: Marcelo Katogui  
**Repository**: [https://github.com/mkatogui/Plumber_API](https://github.com/mkatogui/Plumber_API)
