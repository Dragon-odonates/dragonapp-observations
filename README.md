# dragonapp Observation data

Customize the [dragonapp](https://github.com/Dragon-odonates/dragonapp) with observation data at different spatial scales, and deploying it [online](https://rfrelat-cesab.shinyapps.io/Dragon_obs/).

The customization is made in four successive steps that are documented in this research compendium.


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
scales <- c(10, 20, 50)
for (i in scales){
  res <- i
  source("analysis/01_format_obs.R")
}
```

### 3. Update the Shiny App

#### Include the new observation datasets

```r
scales <- c(10, 20, 50)
for (i in paste("obs", scales, sep = "_")) {
  # add dataset
  add_shiny_data(
    folder = here::here("data", "derived", i),
    label = i,
    overwrite = TRUE
  )
}

# Finally remove the example dataset
rm_shiny_data("psi")
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
    appTitle = "Dragonflu observations"
)
# 26Mb : Huge !
```
