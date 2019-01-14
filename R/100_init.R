# tidyverse contains the packages tidyr, ggplot2, dplyr,
# readr, purrr and tibble
# install.packages("tidyverse")
# install.packages("lubridate")
# install.packages("readxl")
# install.packages("highcharter")
# install.packages("tidyquant")
# install.packages("timetk")
# install.packages("tibbletime")
# install.packages("quantmod")
# install.packages("PerformanceAnalytics")
# install.packages("scales")
library(tidyverse)
library(lubridate)
library(readxl)
library(highcharter)
library(tidyquant)
library(timetk)
library(tibbletime)
library(quantmod)
library(PerformanceAnalytics)
library(scales)

# + SPY (S&P500 ETF) weighted 25%
# + EFA (a non-US equities ETF) weighted 25%
# + IJS (a small-cap value ETF) weighted 20%
# + EEM (an emerging-markets ETF) weighted 20%
# + AGG (a bond ETF) weighted 10%

symbols <- c("SPY","EFA", "IJS", "EEM","AGG", "YELP")

prices <-
  getSymbols(symbols,
             src = 'yahoo',
             from = "2012-12-31",
             #to = "2017-12-31",
             auto.assign = TRUE,
             warnings = FALSE) %>%
  map(~Ad(get(.))) %>%
  reduce(merge) %>%
  `colnames<-`(symbols)

#tail(prices, 3)

prices_monthly <- to.monthly(prices,
                             indexAt = "lastof",
                             OHLC = FALSE)
tail(prices_monthly, 3)




asset_returns_tq_builtin <-
  prices %>%
  tk_tbl(preserve_index = TRUE,
         rename_index = "date") %>%
  gather(asset, prices, -date) %>%
  group_by(asset) %>%
  tq_transmute(mutate_fun = periodReturn,
               period = "monthly",
               type = "log") %>%
  spread(asset, monthly.returns) %>%
  select(date, symbols) %>%
  slice(-1)
head(asset_returns_tq_builtin, 3)
View(asset_returns_tq_builtin)
