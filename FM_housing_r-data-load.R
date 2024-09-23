con <- DBI::dbConnect(duckdb::duckdb(), dbdir = "my-db.duckdb")
DBI::dbWriteTable(con, "fm_housing", "FM_Housing_2018_2022_clean.csv", overwrite = TRUE, row.names = FALSE)
DBI::dbDisconnect(con)


