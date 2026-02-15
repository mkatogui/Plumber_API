# Deploying Gapminder API to Docker

This guide walks through containerizing and deploying the Gapminder API using Docker.

## Prerequisites

- Docker installed on your system ([Get Docker](https://docs.docker.com/get-docker/))
- Basic familiarity with Docker concepts
- The Gapminder API source code

## Creating a Dockerfile

Create a `Dockerfile` in the project root:

```dockerfile
# Use official R image as base
FROM rocker/r-ver:4.3.0

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libfontconfig1-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    && rm -rf /var/lib/apt/lists/*

# Install R packages
RUN R -e "install.packages(c('plumber', 'dplyr', 'ggplot2', 'gapminder'), repos='https://cran.rstudio.com/')"

# Create app directory
WORKDIR /app

# Copy application files
COPY API.R /app/
COPY R/ /app/R/

# Expose port
EXPOSE 8000

# Run the application
CMD ["R", "-e", "source('API.R')"]
```

## Building the Docker Image

### Build Command

```bash
docker build -t gapminder-api:latest .
```

This command:
- Builds an image from the Dockerfile
- Tags it as `gapminder-api:latest`
- Uses the current directory (`.`) as build context

### Build with Custom Tag

```bash
docker build -t gapminder-api:v1.0.0 .
```

## Running the Container

### Basic Run

```bash
docker run -p 8000:8000 gapminder-api:latest
```

Access the API at: `http://localhost:8000`

### Run in Background (Detached Mode)

```bash
docker run -d -p 8000:8000 --name gapminder-api gapminder-api:latest
```

### Run with Custom Port

```bash
docker run -p 8080:8000 gapminder-api:latest
```

Access at: `http://localhost:8080`

### Run with Volume Mount (Development)

For development, mount your local code:

```bash
docker run -p 8000:8000 \
  -v $(pwd)/R:/app/R \
  -v $(pwd)/API.R:/app/API.R \
  gapminder-api:latest
```

## Docker Compose

For easier management, create a `docker-compose.yml`:

```yaml
version: '3.8'

services:
  api:
    build: .
    ports:
      - "8000:8000"
    restart: unless-stopped
    environment:
      - R_LIBS_USER=/usr/local/lib/R/site-library
    volumes:
      # Optional: mount for development
      # - ./R:/app/R
      # - ./API.R:/app/API.R
```

### Using Docker Compose

```bash
# Start the service
docker-compose up -d

# View logs
docker-compose logs -f

# Stop the service
docker-compose down
```

## Managing Containers

### List Running Containers

```bash
docker ps
```

### View Logs

```bash
# Live logs
docker logs -f gapminder-api

# Last 100 lines
docker logs --tail 100 gapminder-api
```

### Stop Container

```bash
docker stop gapminder-api
```

### Remove Container

```bash
docker rm gapminder-api
```

### Remove Image

```bash
docker rmi gapminder-api:latest
```

## Optimizing the Docker Image

### Multi-Stage Build

For a smaller image, use multi-stage builds:

```dockerfile
# Build stage
FROM rocker/r-ver:4.3.0 as builder

RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev

RUN R -e "install.packages(c('plumber', 'dplyr', 'ggplot2', 'gapminder'))"

# Runtime stage
FROM rocker/r-ver:4.3.0

# Copy only necessary files from builder
COPY --from=builder /usr/local/lib/R/site-library /usr/local/lib/R/site-library

RUN apt-get update && apt-get install -y \
    libcurl4 \
    libssl3 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY API.R /app/
COPY R/ /app/R/

EXPOSE 8000
CMD ["R", "-e", "source('API.R')"]
```

### Using .dockerignore

Create a `.dockerignore` file to exclude unnecessary files:

```
.git
.gitignore
README.md
*.Rproj
.Rproj.user
.Rhistory
.RData
docs/
*.png
*.html
```

## Deploying to Docker Hub

### Tag Image

```bash
docker tag gapminder-api:latest yourusername/gapminder-api:latest
```

### Push to Docker Hub

```bash
# Login
docker login

# Push
docker push yourusername/gapminder-api:latest
```

### Pull and Run

Others can now pull and run your image:

```bash
docker pull yourusername/gapminder-api:latest
docker run -p 8000:8000 yourusername/gapminder-api:latest
```

## Deploying to Cloud Platforms

### AWS Elastic Container Service (ECS)

1. Push image to Amazon ECR
2. Create ECS task definition
3. Create ECS service
4. Configure load balancer

See [AWS ECS Documentation](https://docs.aws.amazon.com/ecs/)

### Google Cloud Run

```bash
# Build and push to Google Container Registry
gcloud builds submit --tag gcr.io/PROJECT-ID/gapminder-api

# Deploy to Cloud Run
gcloud run deploy gapminder-api \
  --image gcr.io/PROJECT-ID/gapminder-api \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --port 8000
```

### Azure Container Instances

```bash
# Push to Azure Container Registry
az acr build --registry myregistry --image gapminder-api:latest .

# Deploy to ACI
az container create \
  --resource-group myResourceGroup \
  --name gapminder-api \
  --image myregistry.azurecr.io/gapminder-api:latest \
  --dns-name-label gapminder-api \
  --ports 8000
```

## Health Checks

Add a health check endpoint in `R/gapminder_api.R`:

```r
#* Health check endpoint
#* @get /health
function() {
  list(status = "healthy", timestamp = Sys.time())
}
```

Update Dockerfile:

```dockerfile
# Add health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD Rscript -e "httr::GET('http://localhost:8000/health')" || exit 1
```

## Troubleshooting

### Container Exits Immediately

Check logs:
```bash
docker logs gapminder-api
```

### Port Binding Issues

Ensure port is not already in use:
```bash
# On Linux/Mac
lsof -i :8000

# On Windows
netstat -ano | findstr :8000
```

### Permission Errors

Run with appropriate user:
```bash
docker run --user $(id -u):$(id -g) -p 8000:8000 gapminder-api:latest
```

### Cannot Access API from Host

Ensure:
- Container is running: `docker ps`
- Port is correctly mapped: `-p 8000:8000`
- Firewall allows connection
- Use `http://localhost:8000`, not `http://127.0.0.1:8000` if on Docker Desktop

## Best Practices

1. **Use Specific Base Image Versions**: Instead of `latest`, use specific versions
2. **Layer Caching**: Order Dockerfile commands from least to most frequently changing
3. **Security Scanning**: Use `docker scan gapminder-api:latest` to check for vulnerabilities
4. **Resource Limits**: Set memory and CPU limits in production
5. **Non-Root User**: Run container as non-root user when possible

## Next Steps

- Set up CI/CD pipeline for automated builds
- Implement container orchestration with Kubernetes
- Add monitoring and logging
- Configure HTTPS/TLS for production
