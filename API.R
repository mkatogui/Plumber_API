# Create a plumber router from your script
pr <- plumb("R/gapminder_api.R")

# Run the API on a specified port
pr$run(port = 8000)
