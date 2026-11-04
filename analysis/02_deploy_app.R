folder <- here::here("app", "data")

sp <- c("Aeshna_affinis", "Aeshna_juncea", "Anax_parthenope")
# load datasets
files <- list.files(folder, recursive = TRUE, full.names = TRUE)

# subset ts file
ts <- grepv("ts_country.csv", files)
for (i in ts) {
  ts_i <- read.csv(i)
  ts_i <- ts_i[ts_i$species %in% sp, ]
  write.csv(ts_i, file = i, row.names = FALSE)
}

# subset df file
psi <- grepv("grid_df.rds", files)
for (i in psi) {
  psi_i <- readRDS(i)
  keepC <- as.vector(sapply(sp, function(s) grepv(s, names(psi_i))))
  psi_i <- psi_i[, c("grid_id", keepC)]
  psi_i <- saveRDS(psi_i, file = i)
}

# check the app locally
app_path <- here::here("app")
# run the Shiny app locally
library(dragonapp)
shiny::runApp(app_path, display.mode = "normal")

rsconnect::deployApp(
  appDir = app_path,
  appFiles = rsconnect::listDeploymentFiles(app_path),
  appName = "dragon_observations",
  appTitle = "Odonates observations in Europe"
) #4Mb
