# Documentation Index

Welcome to the Gapminder API documentation! This index will help you find the information you need.

## Quick Links

### Getting Started
- **New to the API?** → [Getting Started Guide](guides/GETTING_STARTED.md)
- **Quick Start** → See [README.md](../README.md#quick-start)
- **Installation** → See [README.md](../README.md#installation)

### API Reference
- **Endpoint Documentation** → [API Reference](API_REFERENCE.md)
- **Usage Examples** → [README.md](../README.md#usage-examples)
- **Swagger/OpenAPI Docs** → `http://localhost:8000/__docs__/` (when running)

### Development
- **Contributing** → [CONTRIBUTING.md](../CONTRIBUTING.md)
- **Modern R Patterns** → [Modern R Development Guide](guides/MODERN_R.md)
- **Code Style** → [CONTRIBUTING.md - Code Style](../CONTRIBUTING.md#code-style-guidelines)

### Deployment
- **Docker** → [Docker Deployment Guide](deployment/DOCKER.md)
- **Cloud Platforms** → [README.md - Deployment](../README.md#deployment)
- **Production Best Practices** → [FAQ - Deployment](guides/FAQ.md#deployment-questions)

### Support
- **FAQ** → [Frequently Asked Questions](guides/FAQ.md)
- **Troubleshooting** → [README.md - Troubleshooting](../README.md#troubleshooting)
- **GitHub Issues** → [Report a Bug](https://github.com/mkatogui/Plumber_API/issues)

## Documentation Structure

```
Plumber_API/
├── README.md                          # Main project overview and quick start
├── CONTRIBUTING.md                    # How to contribute to the project
├── docs/
│   ├── INDEX.md                      # This file - documentation index
│   ├── API_REFERENCE.md              # Complete API endpoint reference
│   ├── guides/
│   │   ├── GETTING_STARTED.md        # Step-by-step setup guide
│   │   ├── MODERN_R.md               # Modern R development practices
│   │   └── FAQ.md                    # Frequently asked questions
│   └── deployment/
│       └── DOCKER.md                 # Docker deployment guide
└── R/
    └── gapminder_api.R               # API implementation
```

## By Topic

### Installation & Setup
1. [System Prerequisites](../README.md#prerequisites)
2. [Installing R Packages](../README.md#required-packages)
3. [Running the API](guides/GETTING_STARTED.md#running-the-api)
4. [First API Call](guides/GETTING_STARTED.md#your-first-api-calls)

### API Usage
1. [All Endpoints Overview](API_REFERENCE.md)
2. [GET /countries](API_REFERENCE.md#1-get-countries)
3. [GET /plot](API_REFERENCE.md#2-get-plot)
4. [POST /calculate_gdp](API_REFERENCE.md#3-post-calculate_gdp)

### Code Examples
1. [R Examples](../README.md#r-client-examples)
2. [Python Examples](../README.md#python-client-example)
3. [JavaScript Examples](../README.md#javascriptnodejs-example)
4. [curl Examples](API_REFERENCE.md)

### Modern R Development
1. [Native Pipe Operator](guides/MODERN_R.md#native-pipe-operator)
2. [Modern dplyr Features](guides/MODERN_R.md#modern-dplyr-features)
3. [Type-Safe Programming](guides/MODERN_R.md#type-safe-programming)
4. [Performance Optimization](guides/MODERN_R.md#performance-optimization)

### Deployment
1. [Docker Setup](deployment/DOCKER.md)
2. [RStudio Connect](../README.md#deploying-to-rstudio-connect)
3. [Cloud Platforms](deployment/DOCKER.md#deploying-to-cloud-platforms)
4. [Production Best Practices](deployment/DOCKER.md#best-practices)

### Troubleshooting
1. [Common Issues](guides/FAQ.md#troubleshooting)
2. [Port Issues](../README.md#port-already-in-use)
3. [Package Problems](../README.md#package-installation-errors)
4. [Performance Issues](guides/FAQ.md#performance-questions)

## Learning Paths

### Path 1: Just Want to Use the API
1. Read [Quick Start](../README.md#quick-start)
2. Review [API Reference](API_REFERENCE.md)
3. Check [FAQ](guides/FAQ.md) if you have issues

### Path 2: Setting Up for the First Time
1. Follow [Getting Started Guide](guides/GETTING_STARTED.md)
2. Try the [Usage Examples](guides/GETTING_STARTED.md#your-first-api-calls)
3. Explore [API Reference](API_REFERENCE.md)

### Path 3: Want to Contribute
1. Read [CONTRIBUTING.md](../CONTRIBUTING.md)
2. Study [Modern R Development](guides/MODERN_R.md)
3. Set up development environment
4. Make your first contribution

### Path 4: Deploying to Production
1. Review [Docker Guide](deployment/DOCKER.md)
2. Check [Production Best Practices](deployment/DOCKER.md#best-practices)
3. Read [FAQ - Deployment](guides/FAQ.md#deployment-questions)
4. Set up monitoring and logging

## Frequently Accessed

### Quick Reference
- **API Base URL**: `http://localhost:8000`
- **Swagger Docs**: `http://localhost:8000/__docs__/`
- **GitHub Repo**: https://github.com/mkatogui/Plumber_API
- **Issue Tracker**: https://github.com/mkatogui/Plumber_API/issues

### Common Commands

**Start API**:
```r
source("API.R")
```

**Test endpoint**:
```bash
curl "http://localhost:8000/countries?in_continent=Asia&in_lifeExpGT=70&in_popGT=1000000"
```

**Build Docker image**:
```bash
docker build -t gapminder-api .
docker run -p 8000:8000 gapminder-api
```

## External Resources

- [Plumber Documentation](https://www.rplumber.io/)
- [Gapminder Dataset](https://www.gapminder.org/data/)
- [R for Data Science](https://r4ds.had.co.nz/)
- [Tidyverse Style Guide](https://style.tidyverse.org/)
- [Docker Documentation](https://docs.docker.com/)

## Need Help?

Can't find what you're looking for?

1. **Search the FAQ**: [guides/FAQ.md](guides/FAQ.md)
2. **Check existing issues**: [GitHub Issues](https://github.com/mkatogui/Plumber_API/issues)
3. **Ask a question**: [GitHub Discussions](https://github.com/mkatogui/Plumber_API/discussions)
4. **Report a bug**: [New Issue](https://github.com/mkatogui/Plumber_API/issues/new)

---

**Last Updated**: 2026-02-15  
**Documentation Version**: 1.0
