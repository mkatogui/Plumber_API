# Contributing to Gapminder API

Thank you for your interest in contributing to the Gapminder API! This document provides guidelines and instructions for contributing.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Code Style Guidelines](#code-style-guidelines)
- [Testing](#testing)
- [Submitting Changes](#submitting-changes)

## Code of Conduct

This project follows a code of conduct to ensure a welcoming environment for all contributors. Please be respectful and constructive in all interactions.

## Getting Started

### Prerequisites

- R version 4.1.0 or higher
- Git
- RStudio (recommended)

### Fork and Clone

1. Fork the repository on GitHub
2. Clone your fork locally:

```bash
git clone https://github.com/YOUR-USERNAME/Plumber_API.git
cd Plumber_API
```

3. Add the upstream repository:

```bash
git remote add upstream https://github.com/mkatogui/Plumber_API.git
```

### Install Dependencies

```r
install.packages(c("plumber", "dplyr", "ggplot2", "gapminder"))
```

## Development Workflow

1. Create a new branch for your feature or bugfix:

```bash
git checkout -b feature/your-feature-name
```

2. Make your changes following the code style guidelines

3. Test your changes locally:

```r
source("API.R")
# Test endpoints manually
```

4. Commit your changes with clear, descriptive messages:

```bash
git add .
git commit -m "Add feature: description of your changes"
```

5. Push to your fork:

```bash
git push origin feature/your-feature-name
```

6. Open a Pull Request on GitHub

## Code Style Guidelines

This project follows the [tidyverse style guide](https://style.tidyverse.org/). Key points:

### Naming Conventions

- Use snake_case for variable and function names
- Use meaningful, descriptive names
- Avoid single-letter variable names (except in short loops)

```r
# Good
calculate_country_gdp <- function(country_name, year) { }

# Avoid
calcGDP <- function(c, y) { }
```

### Spacing and Indentation

- Use 2 spaces for indentation (never tabs)
- Add spaces around operators
- Add space after commas

```r
# Good
result <- data |>
  filter(year == 2007) |>
  summarise(avg = mean(value))

# Avoid
result<-data|>filter(year==2007)|>summarise(avg=mean(value))
```

### Pipes

- Use the native pipe `|>` instead of `%>%`
- Put each pipe step on a new line
- Align pipe operators

```r
# Good
gapminder |>
  filter(continent == "Asia") |>
  group_by(country) |>
  summarise(avg_life_exp = mean(lifeExp))
```

### Modern tidyverse Patterns

Use modern dplyr features:

```r
# Use .by instead of group_by/ungroup
data |>
  summarise(mean_value = mean(value), .by = category)

# Use join_by() for joins
transactions |>
  inner_join(companies, by = join_by(company == id))
```

### API Endpoint Documentation

All API endpoints should use roxygen2-style comments:

```r
#* Returns countries that satisfy conditions
#* @param in_continent The continent to filter by
#* @param in_lifeExpGT Minimum life expectancy threshold
#* @param in_popGT Minimum population threshold
#* @get /countries
function(in_continent, in_lifeExpGT, in_popGT) {
  # Implementation
}
```

## Testing

### Manual Testing

Before submitting a PR, test all endpoints:

1. Start the API:
```r
source("API.R")
```

2. Test each endpoint:

```bash
# Test GET /countries
curl "http://localhost:8000/countries?in_continent=Asia&in_lifeExpGT=60&in_popGT=1000000"

# Test GET /plot
curl "http://localhost:8000/plot?in_country=Japan&in_title=Test" -o test.png

# Test POST /calculate_gdp
curl --data "in_country=Japan" http://localhost:8000/calculate_gdp
```

### Automated Testing (Future)

We plan to add automated tests using the `testthat` package. If you'd like to contribute to this, please open an issue to discuss.

## Submitting Changes

### Pull Request Process

1. Ensure your code follows the style guidelines
2. Update documentation if you've changed API behavior
3. Add examples for new features
4. Write a clear PR description explaining:
   - What changes you made
   - Why you made them
   - How to test them

### PR Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Performance improvement

## Testing
How to test these changes

## Checklist
- [ ] Code follows style guidelines
- [ ] Documentation updated
- [ ] Tested locally
```

### Review Process

- Maintainers will review your PR
- Address any feedback or requested changes
- Once approved, your PR will be merged

## Questions?

If you have questions, please:

1. Check existing [Issues](https://github.com/mkatogui/Plumber_API/issues)
2. Open a new issue with the `question` label
3. Be patient - we'll respond as soon as possible

## Recognition

Contributors will be recognized in:
- The README acknowledgments section
- Release notes for significant contributions

Thank you for contributing!
