# Frequently Asked Questions (FAQ)

Common questions and answers about the Gapminder API.

## General Questions

### What is the Gapminder API?

The Gapminder API is a RESTful web service that provides programmatic access to the Gapminder dataset. It allows users to query country data, generate visualizations, and perform calculations without needing to download and process the data locally.

### What data does the API provide?

The API provides access to the Gapminder dataset, which includes:
- Country names
- Continents
- Life expectancy data
- Population data
- GDP per capita
- Historical data from 1952 to 2007

### Is this API free to use?

Yes, this is an open-source project available for free use. However, note that this is a demonstration/educational API. For production use, consider deploying your own instance.

### Can I use this API in production?

The API code is open source and you can deploy your own instance. The publicly available demo instance (if any) is for educational purposes and should not be relied upon for production applications.

## Installation & Setup

### What version of R do I need?

R version 4.1.0 or higher is recommended for full feature support, especially the native pipe operator (`|>`).

### How do I install the required packages?

Run in R:
```r
install.packages(c("plumber", "dplyr", "ggplot2", "gapminder"))
```

### The API won't start. What should I check?

1. Verify all packages are installed
2. Check if port 8000 is available
3. Ensure you're in the correct working directory
4. Check R version (4.1.0+)
5. Review error messages in the R console

### Can I change the default port?

Yes, modify `API.R`:
```r
pr <- plumber::plumb("R/gapminder_api.R")
pr$run(port = 8080)  # Use your preferred port
```

## Usage Questions

### How do I get a list of all countries?

Use the `/countries` endpoint with minimal filters:
```bash
curl "http://localhost:8000/countries?in_continent=Asia&in_lifeExpGT=0&in_popGT=0"
```

Then repeat for other continents: Africa, Americas, Europe, Oceania.

### What are valid continent names?

Valid continent names are:
- "Africa"
- "Americas"
- "Asia"
- "Europe"
- "Oceania"

Note: These are case-sensitive.

### Why is the `/plot` endpoint returning an empty chart?

Common causes:
1. **Incorrect country name**: Country names are case-sensitive. Use exact names like "United States", not "USA"
2. **Country not in dataset**: Verify the country exists in the Gapminder data
3. **Encoding issues**: Ensure URL encoding for special characters

### How do I get data for multiple countries?

Call the endpoint multiple times or use the `/countries` endpoint with appropriate filters. Example in R:

```r
countries <- c("Japan", "China", "India")
results <- purrr::map_dfr(countries, function(country) {
  # Make API call for each country
})
```

### Can I filter by year?

Currently, the API filters use year 2007 for consistency. To get historical data, you would need to modify the API code or download the Gapminder dataset directly.

### What's the difference between GET and POST endpoints?

- **GET** (`/countries`, `/plot`): Used for retrieving data. Parameters in URL.
- **POST** (`/calculate_gdp`): Used for operations that process data. Parameters in request body.

## Technical Questions

### Why use POST for `/calculate_gdp` instead of GET?

This demonstrates REST conventions. While a GET would work technically, POST is used because:
1. It represents a computational operation
2. It demonstrates different HTTP methods
3. In a real application, calculations might involve larger payloads

### Does the API support CORS?

By default, no. To enable CORS, add a filter to `R/gapminder_api.R`:

```r
#* @filter cors
cors <- function(req, res) {
  res$setHeader("Access-Control-Allow-Origin", "*")
  plumber::forward()
}
```

### How do I enable authentication?

Add an authentication filter:

```r
#* @filter authentication
function(req, res) {
  api_key <- req$HTTP_X_API_KEY
  
  if (is.null(api_key) || api_key != "your-secret-key") {
    res$status <- 401
    return(list(error = "Unauthorized"))
  }
  
  plumber::forward()
}
```

### Can I return data in CSV format?

Yes, add a new endpoint:

```r
#* @get /countries_csv
#* @serializer csv
function(in_continent, in_lifeExpGT, in_popGT) {
  gapminder |>
    filter(
      year == 2007,
      continent == in_continent,
      lifeExp > in_lifeExpGT,
      pop > in_popGT
    )
}
```

### How do I add rate limiting?

Use a rate limiting package or implement custom logic:

```r
# Simple in-memory rate limiter (not production-ready)
request_counts <- new.env()

#* @filter rate_limit
function(req, res) {
  ip <- req$REMOTE_ADDR
  current_time <- Sys.time()
  
  # Implementation logic here
  
  plumber::forward()
}
```

## Deployment Questions

### Can I deploy this to the cloud?

Yes! See our deployment guides:
- [Docker Deployment](deployment/DOCKER.md)
- Cloud platforms: AWS, Google Cloud, Azure, Heroku

### What are the hardware requirements?

Minimal requirements:
- 1 CPU core
- 512 MB RAM
- 1 GB disk space

For production with higher traffic:
- 2+ CPU cores
- 2+ GB RAM
- Load balancing for multiple instances

### How do I monitor the API in production?

Consider adding:
1. **Logging**: Log all requests and errors
2. **Metrics**: Track response times, error rates
3. **Health checks**: Implement `/health` endpoint
4. **Alerting**: Set up alerts for downtime

### Should I use HTTPS?

Yes, always use HTTPS in production:
1. Use a reverse proxy (nginx, Apache)
2. Obtain SSL certificate (Let's Encrypt)
3. Configure proper security headers

## Data Questions

### Where does the Gapminder data come from?

The data comes from the [Gapminder Foundation](https://www.gapminder.org/), made available through the R package `gapminder`.

### How current is the data?

The gapminder package includes data up to 2007. For more recent data, visit the [Gapminder website](https://www.gapminder.org/data/).

### Can I add my own data?

Yes, modify `R/gapminder_api.R` to:
1. Load your own dataset
2. Update filtering logic
3. Adjust endpoints as needed

### What's the GDP calculation formula?

```
GDP = Population × GDP per Capita
```

## Development Questions

### Can I contribute to this project?

Yes! See [CONTRIBUTING.md](../CONTRIBUTING.md) for guidelines.

### What coding standards should I follow?

Follow the [tidyverse style guide](https://style.tidyverse.org/):
- Use native pipe `|>`
- Use 2-space indentation
- Use snake_case naming
- Document with roxygen2 comments

### How do I add a new endpoint?

Add to `R/gapminder_api.R`:

```r
#* Description of endpoint
#* @param param_name Description
#* @get /new-endpoint
function(param_name) {
  # Implementation
}
```

### Where should I add tests?

Create a `tests/` directory and use the `testthat` package:

```r
library(testthat)
library(httr)

test_that("Countries endpoint returns data", {
  response <- GET(
    "http://localhost:8000/countries",
    query = list(
      in_continent = "Asia",
      in_lifeExpGT = 70,
      in_popGT = 1000000
    )
  )
  
  expect_equal(status_code(response), 200)
  expect_true(length(content(response)) > 0)
})
```

## Troubleshooting

### "Package 'X' not found"

Install the missing package:
```r
install.packages("package_name")
```

### "Port already in use"

Change the port in `API.R` or kill the process using port 8000:
```bash
# Linux/Mac
lsof -ti:8000 | xargs kill

# Windows
netstat -ano | findstr :8000
taskkill /PID [process_id] /F
```

### Plot endpoint returns 500 error

Check:
1. Write permissions in working directory
2. ggplot2 is properly installed
3. Country name is exactly correct
4. Sufficient disk space for temp files

### JSON parsing errors

Ensure:
1. Proper URL encoding of parameters
2. Content-Type headers are set correctly
3. Valid JSON in POST body (if applicable)

## Performance Questions

### The API is slow. How can I improve performance?

1. **Profile the code**: Use `profvis::profvis()`
2. **Cache results**: Implement caching for repeated queries
3. **Use data.table**: For larger datasets
4. **Optimize plots**: Reduce plot resolution if needed
5. **Add indexes**: If using a database backend

### Can the API handle multiple concurrent requests?

Yes, but performance depends on:
- Server resources
- R version
- Number of workers (if using multiple processes)

Consider using multiple worker processes:
```r
future::plan(future::multisession, workers = 4)
```

### How many requests per second can it handle?

Depends on:
- Endpoint complexity
- Server resources
- Network bandwidth

Typical performance:
- Simple endpoints: 10-50 req/sec
- Plot generation: 1-5 req/sec

## Still Have Questions?

- Check the [Getting Started Guide](guides/GETTING_STARTED.md)
- Review the [API Reference](API_REFERENCE.md)
- Open an issue on [GitHub](https://github.com/mkatogui/Plumber_API/issues)
- Join discussions in [GitHub Discussions](https://github.com/mkatogui/Plumber_API/discussions)
