# Getting Started with Gapminder API

This guide will walk you through setting up and using the Gapminder API for the first time.

## Prerequisites

Before you begin, ensure you have:

- **R** version 4.1.0 or higher installed
- **RStudio** (recommended but optional)
- Basic familiarity with R programming
- Basic understanding of REST APIs

## Installation

### Step 1: Install R

Download and install R from [CRAN](https://cran.r-project.org/):

- **Windows**: [Download R for Windows](https://cran.r-project.org/bin/windows/base/)
- **Mac**: [Download R for macOS](https://cran.r-project.org/bin/macosx/)
- **Linux**: Use your distribution's package manager

### Step 2: Install RStudio (Optional)

Download RStudio Desktop from [posit.co](https://posit.co/download/rstudio-desktop/)

### Step 3: Install Required Packages

Open R or RStudio and run:

```r
# Install required packages
install.packages(c("plumber", "dplyr", "ggplot2", "gapminder"))
```

This may take a few minutes depending on your internet connection.

### Step 4: Download the Project

**Option A: Using Git**

```bash
git clone https://github.com/mkatogui/Plumber_API.git
cd Plumber_API
```

**Option B: Download ZIP**

1. Go to https://github.com/mkatogui/Plumber_API
2. Click "Code" → "Download ZIP"
3. Extract the ZIP file
4. Navigate to the extracted folder

## Running the API

### Starting the Server

1. Open R or RStudio
2. Set your working directory to the project folder:

```r
setwd("/path/to/Plumber_API")
```

3. Run the API:

```r
source("API.R")
```

You should see output similar to:

```
Running plumber API at http://127.0.0.1:8000
Running swagger Docs at http://127.0.0.1:8000/__docs__/
```

The API is now running! Keep this R session open.

### Accessing Swagger Documentation

Open your web browser and navigate to:

```
http://localhost:8000/__docs__/
```

This interactive documentation allows you to:
- View all available endpoints
- See parameter descriptions
- Try out API calls directly from the browser

## Your First API Calls

### Example 1: Get Countries Data

Open a new terminal or command prompt and run:

```bash
curl "http://localhost:8000/countries?in_continent=Asia&in_lifeExpGT=70&in_popGT=10000000"
```

**Or in R:**

```r
library(httr)
library(jsonlite)

response <- GET(
  "http://localhost:8000/countries",
  query = list(
    in_continent = "Asia",
    in_lifeExpGT = 70,
    in_popGT = 10000000
  )
)

data <- fromJSON(content(response, "text"))
print(data)
```

**Expected Output:**
A JSON array of Asian countries with life expectancy > 70 and population > 10 million.

### Example 2: Generate a Plot

**In your browser:**

Navigate to:
```
http://localhost:8000/plot?in_country=Japan&in_title=Life%20Expectancy%20in%20Japan
```

You'll see a line chart showing Japan's life expectancy over time.

**Or download with curl:**

```bash
curl "http://localhost:8000/plot?in_country=Japan&in_title=Life%20Expectancy%20in%20Japan" \
  --output japan_life_exp.png
```

### Example 3: Calculate GDP

```bash
curl --data "in_country=Japan" http://localhost:8000/calculate_gdp
```

**Or in R:**

```r
response <- POST(
  "http://localhost:8000/calculate_gdp",
  body = list(in_country = "Japan"),
  encode = "form"
)

gdp <- fromJSON(content(response, "text"))
print(paste("Japan GDP:", gdp$gdp))
```

## Understanding the Response Format

### JSON Responses

Most endpoints return JSON data:

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

### Image Responses

The `/plot` endpoint returns a PNG image directly.

## Common Use Cases

### Use Case 1: Analyzing Regional Trends

Get all European countries with high life expectancy:

```r
library(httr)
library(jsonlite)
library(dplyr)

response <- GET(
  "http://localhost:8000/countries",
  query = list(
    in_continent = "Europe",
    in_lifeExpGT = 75,
    in_popGT = 1000000
  )
)

countries <- fromJSON(content(response, "text"))

# Analyze the results
summary(countries$lifeExp)
mean(countries$pop)
```

### Use Case 2: Comparing Countries

Compare GDP for multiple countries:

```r
countries_to_compare <- c("Japan", "Germany", "United States", "Brazil")

gdp_comparison <- purrr::map_dfr(countries_to_compare, function(country) {
  response <- POST(
    "http://localhost:8000/calculate_gdp",
    body = list(in_country = country),
    encode = "form"
  )
  
  data.frame(
    country = country,
    gdp = fromJSON(content(response, "text"))$gdp
  )
})

# Sort by GDP
gdp_comparison |>
  arrange(desc(gdp))
```

### Use Case 3: Creating a Dashboard

Generate plots for multiple countries:

```r
countries <- c("Japan", "India", "Brazil", "South Africa")

purrr::walk(countries, function(country) {
  download.file(
    url = paste0(
      "http://localhost:8000/plot?in_country=", 
      URLencode(country),
      "&in_title=", 
      URLencode(paste("Life Expectancy in", country))
    ),
    destfile = paste0(tolower(country), "_plot.png")
  )
})
```

## Next Steps

Now that you're familiar with the basics:

1. **Explore the Data**: Try different continent and threshold combinations
2. **Read the Full Documentation**: Check out the main [README.md](../../README.md)
3. **Integrate with Your Projects**: Use the API in your data analysis workflows
4. **Contribute**: See [CONTRIBUTING.md](../../CONTRIBUTING.md) to help improve the project

## Troubleshooting

### Port Already in Use

If port 8000 is already in use, specify a different port:

```r
pr <- plumber::plumb("R/gapminder_api.R")
pr$run(port = 8080)  # Use port 8080 instead
```

### Package Installation Issues

If packages fail to install, try:

```r
# Update existing packages
update.packages(ask = FALSE)

# Try installing one at a time
install.packages("plumber")
install.packages("dplyr")
install.packages("ggplot2")
install.packages("gapminder")
```

### Cannot Connect to API

Ensure:
- The R session running the API is still active
- You're using the correct URL (http://localhost:8000)
- No firewall is blocking the connection

## Getting Help

- **Issues**: Report bugs or request features on [GitHub Issues](https://github.com/mkatogui/Plumber_API/issues)
- **Discussions**: Ask questions in [GitHub Discussions](https://github.com/mkatogui/Plumber_API/discussions)
- **Documentation**: Check the [main README](../../README.md) for detailed API documentation
