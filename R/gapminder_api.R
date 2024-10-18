library(plumber)
library(dplyr)
library(ggplot2)
library(gapminder)

#* @apiTitle Gapminder API
#* @apiDescription API for exploring Gapminder dataset

#* Returns countries that satisfy condition
#* @param in_continent
#* @param in_lifeExpGT Life expectancy greater than
#* @param in_popGT Population greater than
#* @get /countries
function(in_continent, in_lifeExpGT, in_popGT) {
  gapminder %>%
    filter(
      year == 2007,
      continent == in_continent,
      lifeExp > in_lifeExpGT,
      pop > in_popGT
    )
}



#* Returns a line plot of life expectancy for country
#* @param in_country
#* @param in_title Chart title
#* @get /plot
#* @serializer contentType list(type='image/png')
function(in_country, in_title) {
  subset <- gapminder %>%
    filter(country == in_country)
  plot <- ggplot(subset, aes(x = year, y = lifeExp)) +
    geom_line(color = "#0099f9", size = 2) +
    geom_point(color = "#0099f9", size = 5) +
    ggtitle(in_title) +
    theme_classic() +
    theme(aspect.ratio = 9 / 16)
  file <- "plot.png"
  ggsave(file, plot)
  readBin(file, "raw", n = file.info(file)$size)
}




#* Returns most recent GDP for a country
#* @param in_country
#* @post /calculate_gdp
function(in_country) {
  gapminder %>%
    filter(
      year == 2007,
      country == in_country
    ) %>%
    summarize(gdp = pop * gdpPercap)
}