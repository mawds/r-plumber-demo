library(plumber)
library(magrittr)
library(tibble)
library(dplyr)

# Read in objects required for predictions
mod_diamond <- readRDS("data/mod_diamond.rds")
factor_levels <- readRDS("data/factor_levels.rds")

#* @apiTitle Plumber Example API
#* @apiDescription This API predicts the value of a diamond

#' Get model predictions
#'
#' @param indata Tibble containing our input data (>=1 rows), containing
#' carat, color and cut
#' @param interval Whether to include prediction interval in the results. Must be none or pred
#'
#' @return Model predictions
get_predictions <- function(indata, interval = "none") {

  indata <- indata %>%
    mutate(carat = as.numeric(carat),
           color = factor(color, levels = factor_levels$color),
           cut = factor(cut, levels = factor_levels$cut))

  if(any(is.na(indata$color))) {
    stop("Invalid colour given; valid values are: ", paste0(factor_levels$color,
                                                            collapse = ","))
  }

  if(any(is.na(indata$cut))) {
    stop("Invalid cut given; valid values are: ", paste0(factor_levels$cut,
                                                            collapse = ","))

  }

  if(!is.numeric(indata$carat)) {
    stop("Carat must be numeric")
  }

  if(nrow(indata) != sum(complete.cases(indata))) {

    stop("Missing data; carat, color and cut are required")

  }

  if(!(interval %in% c("none", "pred"))) {

    stop("Interval must be none or pred")


  }

  predictions <- exp(predict(mod_diamond, indata, interval = interval))

  return(predictions)

}


#* Predict the value of a diamond
#* @param carat:dbl The number of carats
#* @param color:string The color of the diamond (D-J)
#* @param cut:string The cut of the diamond ("Fair", "Good", "Very Good", "Premium", "Ideal")
#* @post /predict
function(carat, color, cut) {

  indata <- tibble(carat = carat,
                   color = color,
                   cut = cut)

  stopifnot(nrow(indata) == 1)

  prediction <- get_predictions(indata)

  return(prediction)

}


#* Predict the value of several diamonds
#* @param carat:[dbl] The number of carats
#* @param color:[string] The color of the diamond (D-J)
#* @param cut:[string] The cut of the diamond ("Fair", "Good", "Very Good", "Premium", "Ideal")
#* @post /predict_bulk
function(carat, color, cut) {

  indata <- tibble(carat = carat,
                   color = color,
                   cut = cut)

  prediction <- get_predictions(indata)

  return(prediction)

}

