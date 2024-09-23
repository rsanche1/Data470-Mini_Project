library(dplyr)
library(ggplot2)
library(dbplyr)
library(DBI)
library(duckdb)
library(readr)

con <- DBI::dbConnect(
  duckdb::duckdb(), 
  dbdir = "my-db.duckdb"
)

#DBI::dbExecute(con, "CREATE TABLE fm_housing AS SELECT * FROM read_csv_auto('FM_Housing_2018_2022_clean.csv')")
library(readr)
data <- read_csv ("https://raw.githubusercontent.com/gmtanner-cord/DATA470-2024/refs/heads/main/fmhousing/FM_Housing_2018_2022_clean.csv")

df <- dplyr::tbl(con, "fm_housing") %>% collect()

## Define Model and Fit
model = lm(`Sold Price` ~ `Total SqFt.` + `Book Section` + `Total Bedrooms`, data = df)
model_summary = summary(model)

## Turn into Vetiver Model
library(vetiver)
v = vetiver_model(model, model_name='fm_housing_model')

## Save to Board
library(pins)
model_board <- board_temp(versioned = TRUE)
model_board %>% vetiver_pin_write(v)

## Turn model into API
library(plumber)
pr() %>%
  vetiver_api(v) %>%
  pr_run(port = 8080)

DBI::dbDisconnect(con)
