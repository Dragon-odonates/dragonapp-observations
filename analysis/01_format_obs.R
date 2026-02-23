# Prepare observation data for the Shiny app

# clean occ_all.rds
# select time period
# make sure coordinates are in Europe
# create ID
# Input
# save as occ_clean_all.rds
# Output:
# One folder per spatial scale with :
#   - grid.gpkg
#   - psi_genus_species.rds files per species with 3 columns:
#     'median', 'year' and 'grid_id'

# out <- readRDS("data/derived/psi_Crocothemis_erythraea.rds")
# names(out)

library(data.table)
library(terra)
library(here)
count_unique <- function(x) length(unique(x))

# Parameters --------------------------------------------------------------
period <- 1990:2024 # time period of interest

res <- 50 # 50, 20, or 10

# Initialization ----------------------------------------------------------
# Load data
df <- readRDS(here("data", "raw", "occ_all.rds"))
# nrow(df) # 12.442.338

# set the output directory
outdir <- here("data", "derived", paste0("obs_", res))
if (!file.exists(outdir)) {
  dir.create(outdir)
}

# Load the grid (EEA grid from https://ec.europa.eu/eurostat/web/gisco/geodata/grids
grid <- vect(here("data", "raw", gsub("XX", res, "grid_XXkm_surf.gpkg")))

# Simplify and rename the attributes
grid <- grid[, "GRD_ID"]
names(grid) <- "grid_id"


# Clean and transform observations ----------------------------------------
# select based on year and full coordinates
df[, Year := year(eventDate)] # data.table syntax should be faster

keep <- !is.na(df$decimalLongitude) &
  !is.na(df$decimalLatitude) &
  df$Year %in% period
df <- df[keep, ]

# remove coordinates that are obviously not in EU
checklong <- df$decimalLongitude > 2000000 & df$decimalLongitude < 7000000
checklat <- df$decimalLatitude > 1000000 & df$decimalLatitude < 6000000
df <- df[checklong & checklat, ]

# add dataset ID
df[, dbID := ifelse(is.na(parentDatasetID), datasetID, parentDatasetID)]


# Extract the grid_id per coordinates -------------------------------------
# transform the dataset as SpatVect
vdf <- vect(
  df,
  geom = c("decimalLongitude", "decimalLatitude"),
  crs = "EPSG:3035"
)

# get the id of the grid for each coordinate
id_grid <- terra::extract(grid, vdf)
df$grid_id <- id_grid$grid_id

# create an observation ID with the grid ID
# there is less observations at 50km than at 10km !
df$observationID <- paste(
  df$eventDate,
  df$dbID,
  df$grid_id,
  sep = "_"
)

# format as species, year, grid and number of observations
ag <- aggregate(
  df$observationID,
  list(df$species, df$Year, df$grid_id),
  FUN = count_unique
)
names(ag) <- c("species", "year", "grid_id", "n")
ag$year_grid <- paste(ag$year, ag$grid_id, sep = "_")

# calculate the number of observation per grid cell and per year
tot_obs <- aggregate(
  df$observationID,
  list(df$Year, df$grid_id),
  FUN = count_unique
)
names(tot_obs) <- c("year", "grid_id", "n")
tot_obs$year_grid <- paste(tot_obs$year, tot_obs$grid_id, sep = "_")

# get the total number of observations
ag$tot_obs <- tot_obs$n[match(ag$year_grid, tot_obs$year_grid)]

# get the percentage of observation
ag$median <- round(ag$n / ag$tot_obs, 5)

# remove species with too little grid cell
grid_per_species <- tapply(ag$grid_id, ag$species, count_unique)
year_per_species <- tapply(ag$year, ag$species, count_unique)
# table(year_per_species > 10 & grid_per_species > 250/res)
# plot(grid_per_species, year_per_species, log = "x")
# abline(h = 10, v = 250/res)
keep_sp <- names(year_per_species)[year_per_species > 10 & grid_per_species > 5]
ag <- ag[ag$species %in% keep_sp, ]

# remove grid cell with too few information
obs_per_grid <- tapply(ag$n, ag$grid_id, sum)
# plot(sort(obs_per_grid), log = "y")
# abline(h = floor(res / 10))
# table(obs_per_grid > floor(res / 10))
keep_grid <- names(obs_per_grid)[obs_per_grid > floor(res / 10)]
ag <- ag[ag$grid_id %in% keep_grid, ]
# dim(ag) # 50k: 483462, 10k: 1878451
# apply(ag[, 1:3], 2, count_unique)
# 50k: 105 species, 35 years, 1145 grid cells
# 10k: 109 species, 18101 grid cells

# Export data -------------------------------------------------------------
# project grid to latlong
grid_4326 <- project(grid, "EPSG:4326")
# export as grid.gpkg
writeVector(grid_4326, file.path(outdir, "grid.gpkg"), overwrite = TRUE)

keepC <- c("year", "grid_id", "median")
for (i in sort(unique(ag$species))) {
  # select data for species i
  agi <- ag[ag$species == i, keepC]
  # set file name
  outi <- paste0("psi_", gsub(" ", "_", i), ".rds")
  # save as rds
  saveRDS(agi, file = file.path(outdir, outi))
}

# Total size:
# 4.2Mb for the 50km grid
