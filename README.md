Overview of the Gapminder API
================
Marcelo Katogui

The Gapminder API is a RESTful web service built using the `plumber`
package in R, designed to provide data and visualizations based on the
Gapminder dataset. It offers three main endpoints that allow users to
retrieve information about countries, generate plots, and calculate GDP.

### How to Use the API

#### 1. Get Countries Endpoint

- **Endpoint**: `/countries`

- **Method**: GET

- **Description**: Returns a list of countries from the Gapminder
  dataset for the year 2007 that meet specified conditions.

- **Parameters**:

  - `in_continent`: The continent to filter countries by (e.g., “Asia”).
  - `in_lifeExpGT`: Minimum life expectancy (greater than) to filter by.
  - `in_popGT`: Minimum population (greater than) to filter by.

- **Usage Example**:

      http://localhost:8000/countries?in_continent=Asia&in_lifeExpGT=60&in_popGT=1000000

#### 2. Plot Life Expectancy Endpoint

- **Endpoint**: `/plot`

- **Method**: GET

- **Description**: Generates and returns a line plot of life expectancy
  over time for a specified country.

- **Parameters**:

  - `in_country`: The country for which to plot life expectancy (e.g.,
    “Japan”).
  - `in_title`: The title of the chart.

- **Response**: An image in PNG format.

- **Usage Example**:

      http://localhost:8000/plot?in_country=Japan&in_title=Life%20Expectancy%20in%20Japan

#### 3. Calculate GDP Endpoint

- **Endpoint**: `/calculate_gdp`

- **Method**: POST

- **Description**: Calculates and returns the most recent GDP for a
  specified country based on the year 2007 data.

- **Parameters**:

  - `in_country`: The country for which to calculate GDP (e.g.,
    “Japan”).

- **Usage Example**:

  ``` bash
  curl --data "in_country=Japan" http://localhost:8000/calculate_gdp
  ```

### Additional Notes

- **Running the API**: Ensure you have the necessary R packages
  installed (`plumber`, `dplyr`, `ggplot2`, `gapminder`) and run the
  script using `plumber` to start the API server.
- **Deployment**: For broader accessibility, consider deploying the API
  on a cloud platform or server that supports R applications.

This API provides a convenient way to interact with the Gapminder
dataset programmatically, allowing users to query, visualize, and
analyze data efficiently.
