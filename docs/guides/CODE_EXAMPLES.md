# Code Examples

Comprehensive code examples for using the Gapminder API in different programming languages and scenarios.

## Table of Contents

- [R Examples](#r-examples)
- [Python Examples](#python-examples)
- [JavaScript Examples](#javascript-examples)
- [Shell/Curl Examples](#shellcurl-examples)
- [Advanced Use Cases](#advanced-use-cases)

## R Examples

### Basic Data Retrieval

```r
library(httr)
library(jsonlite)
library(dplyr)

# Function to get countries data
get_countries <- function(continent, min_life_exp, min_pop) {
  response <- GET(
    "http://localhost:8000/countries",
    query = list(
      in_continent = continent,
      in_lifeExpGT = min_life_exp,
      in_popGT = min_pop
    )
  )
  
  # Check if request was successful
  stop_for_status(response)
  
  # Parse JSON response
  countries <- fromJSON(content(response, "text"))
  
  return(countries)
}

# Use the function
asian_countries <- get_countries("Asia", 70, 10000000)
print(asian_countries)
```

### Batch Processing Multiple Requests

```r
library(purrr)
library(httr)
library(jsonlite)

# Get GDP for multiple countries
countries <- c("Japan", "China", "India", "Indonesia", "South Korea")

get_country_gdp <- function(country) {
  response <- POST(
    "http://localhost:8000/calculate_gdp",
    body = list(in_country = country),
    encode = "form"
  )
  
  if (status_code(response) != 200) {
    return(data.frame(country = country, gdp = NA))
  }
  
  result <- fromJSON(content(response, "text"))
  data.frame(country = country, gdp = result$gdp)
}

# Process all countries
gdp_data <- map_dfr(countries, get_country_gdp)

# Sort by GDP
gdp_data |>
  arrange(desc(gdp)) |>
  mutate(gdp_billions = gdp / 1e9)
```

### Creating Visualizations from API Data

```r
library(httr)
library(jsonlite)
library(ggplot2)
library(dplyr)

# Get data for multiple continents
continents <- c("Asia", "Europe", "Africa", "Americas")

continent_data <- map_dfr(continents, function(cont) {
  countries <- get_countries(cont, 0, 0)
  countries$continent_filter <- cont
  countries
})

# Create a comparison plot
ggplot(continent_data, aes(x = gdpPercap, y = lifeExp, color = continent)) +
  geom_point(aes(size = pop), alpha = 0.7) +
  scale_size_continuous(range = c(2, 15), labels = scales::comma) +
  scale_x_log10(labels = scales::dollar) +
  labs(
    title = "Life Expectancy vs GDP per Capita (2007)",
    x = "GDP per Capita (log scale)",
    y = "Life Expectancy (years)",
    size = "Population",
    color = "Continent"
  ) +
  theme_minimal()
```

### Error Handling

```r
library(httr)
library(jsonlite)

safe_get_gdp <- function(country) {
  tryCatch({
    response <- POST(
      "http://localhost:8000/calculate_gdp",
      body = list(in_country = country),
      encode = "form",
      timeout(10)  # 10 second timeout
    )
    
    if (status_code(response) != 200) {
      warning(sprintf("HTTP %s for country: %s", status_code(response), country))
      return(NULL)
    }
    
    result <- fromJSON(content(response, "text"))
    
    if (length(result) == 0 || is.null(result$gdp)) {
      warning(sprintf("No GDP data for country: %s", country))
      return(NULL)
    }
    
    return(result$gdp)
    
  }, error = function(e) {
    warning(sprintf("Error for country %s: %s", country, e$message))
    return(NULL)
  })
}

# Use with error handling
countries <- c("Japan", "InvalidCountry", "China")
gdps <- map(countries, safe_get_gdp)
```

## Python Examples

### Basic Client Class

```python
import requests
from typing import Dict, List, Optional
import pandas as pd

class GapminderAPI:
    """Client for interacting with Gapminder API"""
    
    def __init__(self, base_url: str = "http://localhost:8000"):
        self.base_url = base_url
        self.session = requests.Session()
    
    def get_countries(self, continent: str, min_life_exp: float, 
                     min_pop: int) -> List[Dict]:
        """Get countries matching criteria"""
        params = {
            'in_continent': continent,
            'in_lifeExpGT': min_life_exp,
            'in_popGT': min_pop
        }
        
        response = self.session.get(
            f"{self.base_url}/countries",
            params=params
        )
        response.raise_for_status()
        return response.json()
    
    def calculate_gdp(self, country: str) -> float:
        """Calculate GDP for a country"""
        data = {'in_country': country}
        
        response = self.session.post(
            f"{self.base_url}/calculate_gdp",
            data=data
        )
        response.raise_for_status()
        result = response.json()
        return result[0]['gdp']
    
    def get_plot(self, country: str, title: str, 
                 output_file: str) -> None:
        """Download plot to file"""
        params = {
            'in_country': country,
            'in_title': title
        }
        
        response = self.session.get(
            f"{self.base_url}/plot",
            params=params
        )
        response.raise_for_status()
        
        with open(output_file, 'wb') as f:
            f.write(response.content)

# Usage
api = GapminderAPI()

# Get countries
asian_countries = api.get_countries("Asia", 70, 10000000)
print(f"Found {len(asian_countries)} countries")

# Calculate GDP
japan_gdp = api.calculate_gdp("Japan")
print(f"Japan GDP: ${japan_gdp:,.0f}")

# Download plot
api.get_plot("Japan", "Life Expectancy in Japan", "japan.png")
```

### Data Analysis with Pandas

```python
import pandas as pd
from gapminder_api import GapminderAPI  # Assuming saved as gapminder_api.py

api = GapminderAPI()

# Get data for all continents
continents = ["Africa", "Americas", "Asia", "Europe", "Oceania"]

all_data = []
for continent in continents:
    countries = api.get_countries(continent, 0, 0)
    all_data.extend(countries)

# Create DataFrame
df = pd.DataFrame(all_data)

# Analysis
print("Summary Statistics:")
print(df.groupby('continent').agg({
    'lifeExp': 'mean',
    'pop': 'sum',
    'gdpPercap': 'mean'
}).round(2))

# Find top 10 countries by life expectancy
top_life_exp = df.nlargest(10, 'lifeExp')[['country', 'lifeExp', 'continent']]
print("\nTop 10 Countries by Life Expectancy:")
print(top_life_exp)
```

### Async Requests with asyncio

```python
import asyncio
import aiohttp
from typing import List, Dict

class AsyncGapminderAPI:
    """Async client for Gapminder API"""
    
    def __init__(self, base_url: str = "http://localhost:8000"):
        self.base_url = base_url
    
    async def get_countries(self, session: aiohttp.ClientSession,
                           continent: str, min_life_exp: float,
                           min_pop: int) -> List[Dict]:
        params = {
            'in_continent': continent,
            'in_lifeExpGT': min_life_exp,
            'in_popGT': min_pop
        }
        
        async with session.get(
            f"{self.base_url}/countries",
            params=params
        ) as response:
            return await response.json()
    
    async def calculate_gdp(self, session: aiohttp.ClientSession,
                           country: str) -> Dict:
        data = {'in_country': country}
        
        async with session.post(
            f"{self.base_url}/calculate_gdp",
            data=data
        ) as response:
            result = await response.json()
            return {'country': country, 'gdp': result[0]['gdp']}

async def main():
    api = AsyncGapminderAPI()
    
    async with aiohttp.ClientSession() as session:
        # Fetch multiple continents in parallel
        continents = ["Asia", "Europe", "Africa"]
        
        tasks = [
            api.get_countries(session, cont, 70, 1000000)
            for cont in continents
        ]
        
        results = await asyncio.gather(*tasks)
        
        for continent, data in zip(continents, results):
            print(f"{continent}: {len(data)} countries")

# Run
asyncio.run(main())
```

## JavaScript Examples

### Node.js Client Module

```javascript
// gapminder-client.js
const axios = require('axios');
const fs = require('fs').promises;

class GapminderAPI {
  constructor(baseURL = 'http://localhost:8000') {
    this.client = axios.create({ baseURL });
  }

  async getCountries(continent, minLifeExp, minPop) {
    const response = await this.client.get('/countries', {
      params: {
        in_continent: continent,
        in_lifeExpGT: minLifeExp,
        in_popGT: minPop
      }
    });
    return response.data;
  }

  async calculateGDP(country) {
    const response = await this.client.post(
      '/calculate_gdp',
      `in_country=${country}`,
      {
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' }
      }
    );
    return response.data[0].gdp;
  }

  async downloadPlot(country, title, outputFile) {
    const response = await this.client.get('/plot', {
      params: { in_country: country, in_title: title },
      responseType: 'arraybuffer'
    });
    
    await fs.writeFile(outputFile, response.data);
  }
}

module.exports = GapminderAPI;
```

### Using the Client

```javascript
const GapminderAPI = require('./gapminder-client');

async function analyze() {
  const api = new GapminderAPI();
  
  try {
    // Get Asian countries
    const countries = await api.getCountries('Asia', 70, 10000000);
    console.log(`Found ${countries.length} countries`);
    
    // Calculate GDP for multiple countries
    const countryNames = ['Japan', 'China', 'India'];
    const gdpPromises = countryNames.map(name => 
      api.calculateGDP(name).then(gdp => ({ name, gdp }))
    );
    
    const gdpData = await Promise.all(gdpPromises);
    
    // Sort by GDP
    gdpData.sort((a, b) => b.gdp - a.gdp);
    
    console.log('\nGDP Rankings:');
    gdpData.forEach(({ name, gdp }, index) => {
      console.log(`${index + 1}. ${name}: $${gdp.toLocaleString()}`);
    });
    
    // Download plots
    for (const country of countryNames) {
      await api.downloadPlot(
        country,
        `Life Expectancy in ${country}`,
        `${country.toLowerCase().replace(' ', '_')}.png`
      );
    }
    
    console.log('\nPlots downloaded successfully');
    
  } catch (error) {
    console.error('Error:', error.message);
  }
}

analyze();
```

### Browser/Frontend Example

```html
<!DOCTYPE html>
<html>
<head>
  <title>Gapminder API Demo</title>
  <script src="https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js"></script>
</head>
<body>
  <h1>Gapminder API Demo</h1>
  
  <div>
    <select id="continent">
      <option value="Asia">Asia</option>
      <option value="Europe">Europe</option>
      <option value="Africa">Africa</option>
      <option value="Americas">Americas</option>
      <option value="Oceania">Oceania</option>
    </select>
    <button onclick="loadCountries()">Load Countries</button>
  </div>
  
  <div id="results"></div>
  
  <script>
    const API_BASE = 'http://localhost:8000';
    
    async function loadCountries() {
      const continent = document.getElementById('continent').value;
      const resultsDiv = document.getElementById('results');
      
      try {
        const response = await axios.get(`${API_BASE}/countries`, {
          params: {
            in_continent: continent,
            in_lifeExpGT: 60,
            in_popGT: 1000000
          }
        });
        
        const countries = response.data;
        
        // Display results
        const html = `
          <h2>${continent} - ${countries.length} countries</h2>
          <table>
            <tr>
              <th>Country</th>
              <th>Life Expectancy</th>
              <th>Population</th>
              <th>GDP per Capita</th>
            </tr>
            ${countries.map(c => `
              <tr>
                <td>${c.country}</td>
                <td>${c.lifeExp.toFixed(1)}</td>
                <td>${c.pop.toLocaleString()}</td>
                <td>$${c.gdpPercap.toFixed(2)}</td>
              </tr>
            `).join('')}
          </table>
        `;
        
        resultsDiv.innerHTML = html;
        
      } catch (error) {
        resultsDiv.innerHTML = `<p>Error: ${error.message}</p>`;
      }
    }
  </script>
</body>
</html>
```

## Shell/Curl Examples

### Bash Script for Batch Processing

```bash
#!/bin/bash

API_BASE="http://localhost:8000"

# Function to get countries
get_countries() {
  local continent=$1
  local min_life_exp=$2
  local min_pop=$3
  
  curl -s "${API_BASE}/countries?in_continent=${continent}&in_lifeExpGT=${min_life_exp}&in_popGT=${min_pop}"
}

# Function to calculate GDP
calculate_gdp() {
  local country=$1
  curl -s --data "in_country=${country}" "${API_BASE}/calculate_gdp"
}

# Function to download plot
download_plot() {
  local country=$1
  local title=$2
  local output=$3
  
  curl -s "${API_BASE}/plot?in_country=${country}&in_title=$(echo $title | sed 's/ /%20/g')" \
    --output "${output}"
}

# Get Asian countries with high life expectancy
echo "Asian countries with life expectancy > 75:"
get_countries "Asia" 75 1000000 | jq '.[] | {country, lifeExp}'

# Calculate GDP for multiple countries
echo -e "\nGDP Calculations:"
for country in "Japan" "China" "India"; do
  gdp=$(calculate_gdp "$country" | jq '.[0].gdp')
  echo "$country: $gdp"
done

# Download plots
echo -e "\nDownloading plots..."
download_plot "Japan" "Life Expectancy in Japan" "japan.png"
download_plot "China" "Life Expectancy in China" "china.png"
echo "Done!"
```

## Advanced Use Cases

### Building a Data Pipeline

```r
library(httr)
library(jsonlite)
library(dplyr)
library(DBI)
library(RSQLite)

# Create database connection
con <- dbConnect(SQLite(), "gapminder.db")

# Function to fetch and store data
fetch_and_store <- function(continent) {
  # Fetch from API
  response <- GET(
    "http://localhost:8000/countries",
    query = list(
      in_continent = continent,
      in_lifeExpGT = 0,
      in_popGT = 0
    )
  )
  
  data <- fromJSON(content(response, "text")) |>
    mutate(
      fetched_at = Sys.time(),
      source = "gapminder_api"
    )
  
  # Store in database
  dbWriteTable(con, "countries", data, append = TRUE)
  
  return(nrow(data))
}

# Fetch all continents
continents <- c("Africa", "Americas", "Asia", "Europe", "Oceania")
results <- sapply(continents, fetch_and_store)

print(paste("Total records stored:", sum(results)))

# Query the database
stored_data <- dbGetQuery(con, "
  SELECT continent, COUNT(*) as country_count, AVG(lifeExp) as avg_life_exp
  FROM countries
  GROUP BY continent
")

print(stored_data)

dbDisconnect(con)
```

### Monitoring and Alerting

```python
import requests
import time
import smtplib
from email.mime.text import MIMEText

def check_api_health(base_url="http://localhost:8000"):
    """Check if API is responding"""
    try:
        response = requests.get(
            f"{base_url}/countries",
            params={
                'in_continent': 'Asia',
                'in_lifeExpGT': 0,
                'in_popGT': 0
            },
            timeout=5
        )
        return response.status_code == 200
    except Exception as e:
        print(f"Health check failed: {e}")
        return False

def send_alert(message):
    """Send email alert"""
    # Configure your SMTP settings
    msg = MIMEText(message)
    msg['Subject'] = 'Gapminder API Alert'
    msg['From'] = 'monitor@example.com'
    msg['To'] = 'admin@example.com'
    
    # Send email (configure your SMTP server)
    # with smtplib.SMTP('localhost') as server:
    #     server.send_message(msg)
    print(f"ALERT: {message}")

def monitor_api(interval=60):
    """Monitor API health"""
    consecutive_failures = 0
    
    while True:
        if check_api_health():
            print(f"[{time.strftime('%Y-%m-%d %H:%M:%S')}] API is healthy")
            consecutive_failures = 0
        else:
            consecutive_failures += 1
            print(f"[{time.strftime('%Y-%m-%d %H:%M:%S')}] API check failed ({consecutive_failures})")
            
            if consecutive_failures >= 3:
                send_alert("API has been down for 3 consecutive checks!")
        
        time.sleep(interval)

if __name__ == "__main__":
    monitor_api(interval=30)  # Check every 30 seconds
```

## More Examples

For additional examples and use cases, see:
- [Getting Started Guide](GETTING_STARTED.md) - Basic usage examples
- [API Reference](../API_REFERENCE.md) - Endpoint-specific examples
- [Modern R Guide](MODERN_R.md) - Modern R programming patterns

## Contributing Examples

Have a useful example? Please contribute!

1. Fork the repository
2. Add your example to this file
3. Submit a pull request

See [CONTRIBUTING.md](../../CONTRIBUTING.md) for guidelines.
