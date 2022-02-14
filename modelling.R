# This file builds a simple model to predict diamond price from the
# diamonds dataset provided with ggplot2

library(magrittr)
library(dplyr)
library(ggplot2)


diamonds2 <- diamonds %>%
  mutate_if(is.factor, function(x) factor(x, ordered = FALSE)) %>%
  # Work with price on log scale
  mutate(lprice = log(price))


mod_diamond <- lm(lprice ~ carat + color + cut , data = diamonds2)

factor_levels <- diamonds2 %>%
  select_if(is.factor) %>%
  lapply(levels)

# Objects we need to make predictions
saveRDS(mod_diamond, "diamondpredict/data/mod_diamond.rds")
saveRDS(factor_levels, "diamondpredict/data/factor_levels.rds")



# Example predictions

example_data <- tribble(~carat, ~color, ~cut,
                        0.5, "E", "Good",
                        2, "E", "Good"
                        ) %>%
  mutate(color = factor(color, levels = factor_levels$color),
         cut = factor(cut, levels = factor_levels$cut))

exp(predict(mod_diamond, example_data, interval = "pred"))


