# dragonapp Observation data

Customize the [dragonapp](https://github.com/Dragon-odonates/dragonapp) with observation data at different spatial scales, and deploying it [online](https://rfrelat-cesab.shinyapps.io/Dragon_obs/).

The customization is made in four successive steps that are documented in this research compendium.

## Overview

This repository is structured as follow:

- :file_folder: &nbsp;`analysis/`: contains R script to format observation data to the shiny app;
- :file_folder: &nbsp;`app/`: contains the dragonapp shiny files (no data stored online);
- :file_folder: &nbsp;`data/`: folder that should contains the observation data (not stored online);

## Get started

> Follow this 4-step procedure to update occupancy model data in the shiny app.  


### 1. Install the latest version of dragonapp

First, you need to install the dragonapp R-package with the following step:

```r
## Install < remotes > package (if not already installed) ----
if (!requireNamespace(c("remotes"), quietly = TRUE)) {
  install.packages(c("remotes"))
}

## Install < dragonapp > from GitHub ----
remotes::install_github("Dragon-odonates/dragonapp", force = TRUE)

library(dragonapp)
```



### 2. Format the raw observations based on the selected grid

We use the [EEA Reference grid](https://ec.europa.eu/eurostat/web/gisco/geodata/grids) at 50km, 20km, and 10km.

```r
scales <- c(50, 20, 10)
for (i in scales){
  res <- i
  source("analysis/01_format_obs.R")
}
```

### 3. Update the Shiny App

#### Include the new observation datasets

```r
scales <- c(50, 20, 10)
lab <- c("B_50k", "A_20k", "C_10k")
for (i in seq_along(scales)) {
  # add dataset
  folder <- here::here("data", "derived",paste("obs", scales[i], sep = "_"))
  obsf <- list.files(folder, "^obs_.*rds$", full.names = TRUE)
  gridf <- file.path(folder, "grid.gpkg")
  add_shiny_data(
    sp_files = obsf,
    grid_file = gridf,
    label = lab[i],
    overwrite = TRUE
  )
}

# Finally remove the example dataset
rm_shiny_data("obs")
```

#### Update the page about.md

```r
# update about.md
get_about_md(here::here("data"))
# manually edit the file update.md then
update_about_md(here::here("data", "about_obs.md"))
```

### 4. Deploy the shinyapp on shinyapp.io

#### Test the shiny app

```r
# run the Shiny app locally
runShiny()
```
If you like it, proceed to the next step

#### Deploy the shiny app to shinyapps.io

```r
# deploy the shinyapp to online server
appDir <- system.file("app", package = "dragonapp")

rsconnect::deployApp(
    appDir = appDir,
    appFiles = rsconnect::listDeploymentFiles(appDir),
    appName = "Dragon_obs",
    appTitle = "Dragonfly observations"
)
# 39Mb : Huge !
```

#### Save the app locally

```r
save_app(here::here(), compress = FALSE)
```



## Acknowledgments

This research is a product of the [Dragon group](https://www.fondationbiodiversite.fr/en/the-frb-in-action/programs-and-projects/le-cesab/dragon/) funded from the [2022 FRB/MTE/OFB Impacts call](https://www.fondationbiodiversite.fr/la-frb-en-action/programmes-et-projets/impacts-sur-la-biodiversite-terrestre-dans-lanthropocene/).