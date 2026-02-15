# Modern R Development Guide

This guide demonstrates modern R development practices used in the Gapminder API and how to apply them in your own projects.

## Table of Contents

- [Modern Tidyverse Patterns](#modern-tidyverse-patterns)
- [Native Pipe Operator](#native-pipe-operator)
- [Modern dplyr Features](#modern-dplyr-features)
- [Type-Safe Programming](#type-safe-programming)
- [Performance Optimization](#performance-optimization)
- [Best Practices](#best-practices)

## Modern Tidyverse Patterns

### The Evolution of R

R has evolved significantly, especially with R 4.1+ and dplyr 1.1+. This project demonstrates modern patterns that improve code readability and maintainability.

### Key Principles

1. **Prefer native pipe (`|>`)** over magrittr pipe (`%>%`)
2. **Use `.by` parameter** instead of `group_by() |> ... |> ungroup()`
3. **Use `join_by()`** for explicit join syntax
4. **Use `pick()` and `across()`** for column operations
5. **Type-stable functions** from purrr

## Native Pipe Operator

### Basic Usage

The native pipe `|>` (R 4.1+) is faster and more integrated with R than the magrittr pipe `%>%`.

```r
# Modern approach with |>
gapminder |>
  filter(year == 2007) |>
  select(country, lifeExp, gdpPercap) |>
  arrange(desc(lifeExp))

# Legacy approach (avoid)
gapminder %>%
  filter(year == 2007) %>%
  select(country, lifeExp, gdpPercap)
```

### Modernizing the API Code

Current code in `R/gapminder_api.R` uses `%>%`. Here's the modernized version:

**Current (legacy)**:
```r
function(in_continent, in_lifeExpGT, in_popGT) {
  gapminder %>%
    filter(
      year == 2007,
      continent == in_continent,
      lifeExp > in_lifeExpGT,
      pop > in_popGT
    )
}
```

**Modern approach**:
```r
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

### Placeholder with Native Pipe

Use `_` as placeholder (R 4.2+):

```r
# Use underscore for placeholder
gapminder |>
  filter(year == 2007) |>
  lm(lifeExp ~ gdpPercap, data = _)
```

## Modern dplyr Features

### Per-Operation Grouping with `.by`

Instead of using `group_by()` and `ungroup()`, use the `.by` parameter:

**Old approach**:
```r
gapminder |>
  group_by(continent) |>
  summarise(avg_life_exp = mean(lifeExp)) |>
  ungroup()
```

**Modern approach**:
```r
gapminder |>
  summarise(
    avg_life_exp = mean(lifeExp),
    .by = continent
  )
```

**Multiple grouping variables**:
```r
gapminder |>
  summarise(
    avg_gdp = mean(gdpPercap),
    total_pop = sum(pop),
    .by = c(continent, year)
  )
```

### Modern Join Syntax

Use `join_by()` for clear, explicit join conditions:

**Old approach**:
```r
left_join(countries, gdp_data, by = c("country_id" = "id"))
```

**Modern approach**:
```r
countries |>
  left_join(gdp_data, join_by(country_id == id))
```

**Inequality joins** (new in dplyr 1.1):
```r
# Find matching records within time ranges
transactions |>
  inner_join(
    price_changes,
    join_by(product_id == product_id, date >= effective_date)
  )
```

**Rolling joins**:
```r
# Find closest match
transactions |>
  inner_join(
    price_changes,
    join_by(product_id, closest(date >= effective_date))
  )
```

### Column Selection with `pick()`

Use `pick()` to select columns inside data-masking functions:

```r
gapminder |>
  summarise(
    n_numeric = ncol(pick(where(is.numeric))),
    n_char = ncol(pick(where(is.character))),
    .by = continent
  )
```

### Multiple Columns with `across()`

Apply functions to multiple columns:

```r
gapminder |>
  summarise(
    across(
      c(lifeExp, pop, gdpPercap),
      list(mean = mean, sd = sd),
      .names = "{.col}_{.fn}"
    ),
    .by = continent
  )
```

### Multi-Row Results with `reframe()`

Use `reframe()` instead of `summarise()` when returning multiple rows per group:

```r
gapminder |>
  reframe(
    quantile = c("25%", "50%", "75%"),
    value = quantile(lifeExp, c(0.25, 0.5, 0.75)),
    .by = continent
  )
```

## Type-Safe Programming

### Using purrr for Type-Stable Iteration

The `purrr` package provides type-safe alternatives to `apply` family functions:

```r
library(purrr)

countries <- c("Japan", "China", "India")

# map_dbl ensures numeric output
life_expectancies <- map_dbl(countries, function(country) {
  gapminder |>
    filter(country == !!country, year == 2007) |>
    pull(lifeExp)
})

# map_dfr returns data frame
country_data <- map_dfr(countries, function(country) {
  gapminder |>
    filter(country == !!country, year == 2007)
})
```

**Type-specific variants**:
- `map()` - returns list
- `map_lgl()` - returns logical vector
- `map_int()` - returns integer vector
- `map_dbl()` - returns numeric vector
- `map_chr()` - returns character vector
- `map_dfr()` - returns data frame (row-bind)
- `map_dfc()` - returns data frame (column-bind)

### Safely Handling Errors

```r
library(purrr)

countries <- c("Japan", "InvalidCountry", "China")

# safely() returns list with result and error
safe_get_life_exp <- safely(function(country) {
  result <- gapminder |>
    filter(country == !!country, year == 2007) |>
    pull(lifeExp)
  
  if (length(result) == 0) stop("Country not found")
  result
})

results <- map(countries, safe_get_life_exp)

# Extract successful results
successful <- map(results, "result") |>
  keep(~ !is.null(.))
```

## Performance Optimization

### When to Optimize

1. **Profile first**: Don't optimize prematurely
2. **Measure**: Use `bench::mark()` and `profvis::profvis()`
3. **Target bottlenecks**: Focus on slow operations

### Profiling with profvis

```r
library(profvis)

profvis({
  result <- gapminder |>
    filter(year == 2007) |>
    group_by(continent) |>
    summarise(
      avg_life_exp = mean(lifeExp),
      avg_gdp = mean(gdpPercap)
    )
})
```

### Benchmarking with bench

```r
library(bench)

# Compare different approaches
bench::mark(
  base_r = aggregate(lifeExp ~ continent, 
                     data = gapminder[gapminder$year == 2007, ], 
                     mean),
  dplyr_old = gapminder %>%
    filter(year == 2007) %>%
    group_by(continent) %>%
    summarise(avg = mean(lifeExp)),
  dplyr_modern = gapminder |>
    filter(year == 2007) |>
    summarise(avg = mean(lifeExp), .by = continent),
  check = FALSE
)
```

### Using data.table Backend

For large datasets, use `dtplyr` for data.table performance with dplyr syntax:

```r
library(dtplyr)

# Create lazy data.table
gapminder_dt <- lazy_dt(gapminder)

# Write dplyr code, get data.table performance
result <- gapminder_dt |>
  filter(year == 2007) |>
  summarise(avg_life_exp = mean(lifeExp), .by = continent) |>
  as_tibble()  # Collect results
```

## Best Practices

### 1. Code Style

Follow the [tidyverse style guide](https://style.tidyverse.org/):

```r
# Good
calculate_gdp <- function(country_name) {
  gapminder |>
    filter(
      country == country_name,
      year == 2007
    ) |>
    summarise(gdp = pop * gdpPercap)
}

# Avoid
calculateGDP=function(c){gapminder%>%filter(country==c&year==2007)%>%summarise(gdp=pop*gdpPercap)}
```

### 2. Use Meaningful Names

```r
# Good
calculate_country_gdp <- function(country_name, data_year = 2007) { }

# Avoid
calc_gdp <- function(c, y = 2007) { }
```

### 3. Validate Inputs

```r
get_country_data <- function(country_name) {
  # Validate inputs
  if (!is.character(country_name)) {
    stop("country_name must be a character string")
  }
  
  if (length(country_name) != 1) {
    stop("country_name must be a single value")
  }
  
  # Process
  result <- gapminder |>
    filter(country == country_name)
  
  # Check output
  if (nrow(result) == 0) {
    warning("No data found for country: ", country_name)
  }
  
  result
}
```

### 4. Document Functions

Use roxygen2 comments:

```r
#' Calculate GDP for a country
#'
#' @param country_name Character string with country name
#' @param data_year Integer year to filter data (default: 2007)
#' @return Data frame with GDP calculation
#' @examples
#' calculate_gdp("Japan")
#' calculate_gdp("China", 2002)
calculate_gdp <- function(country_name, data_year = 2007) {
  gapminder |>
    filter(
      country == country_name,
      year == data_year
    ) |>
    summarise(gdp = pop * gdpPercap)
}
```

### 5. Handle Missing Data

```r
# Explicit NA handling
gapminder |>
  summarise(
    avg_life_exp = mean(lifeExp, na.rm = TRUE),
    .by = continent
  )

# Count missing values
gapminder |>
  summarise(
    n_missing = sum(is.na(lifeExp)),
    pct_missing = mean(is.na(lifeExp)) * 100,
    .by = continent
  )
```

## Modernization Checklist

When updating R code, check for these improvements:

- [ ] Replace `%>%` with `|>`
- [ ] Replace `group_by() |> ... |> ungroup()` with `.by`
- [ ] Use `join_by()` for joins
- [ ] Use `across()` for column operations
- [ ] Use `pick()` for column selection in data-masking contexts
- [ ] Use `reframe()` instead of `summarise()` for multi-row results
- [ ] Replace `sapply()/lapply()` with `map_*()` functions
- [ ] Add input validation
- [ ] Add roxygen2 documentation
- [ ] Follow tidyverse style guide

## Additional Resources

- [R 4.1.0 Release Notes](https://cran.r-project.org/doc/manuals/r-release/NEWS.html) - Native pipe introduction
- [dplyr 1.1.0 Release](https://www.tidyverse.org/blog/2023/01/dplyr-1-1-0/) - .by parameter and join_by()
- [Tidyverse Style Guide](https://style.tidyverse.org/)
- [R for Data Science (2nd ed)](https://r4ds.hadley.nz/) - Modern R programming
- [Advanced R](https://adv-r.hadley.nz/) - Deep dive into R
