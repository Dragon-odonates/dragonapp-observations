# dragonapp Observation data

Customize the [dragonapp](https://github.com/Dragon-odonates/dragonapp) with observation data at different spatial scales, and deploying it [online](add link).

The customization is made in three successive steps that are documented in this research compendium.


### 1. Install the latest version of dragonapp

First, you need to install the dragonapp R-package with the following step:

```r
## Install < remotes > package (if not already installed) ----
if (!requireNamespace(c("remotes"), quietly = TRUE)) {
  install.packages(c("remotes"))
}

## Install < dragonapp > from GitHub ----
remotes::install_github("Dragon-odonates/dragonapp")
```



### 2. Format the raw observations based on the selected grid

We use the [EEA Reference grid](https://ec.europa.eu/eurostat/web/gisco/geodata/grids) at 50km, 20km, and 10km.

To follow this procedure, you need to clone this repository in Github. Then follow the three steps below.

#### 1. Update the metadata

```r
devtools::load_all()
source("analysis/01_prepare_data.R")
source("analysis/02_contingency.R")
```

#### 2. Test the shiny app

```r
# run the Shiny app locally
runShiny()
```

#### 3. Deploy the shiny app to shinyapps.io

```r
# deploy the shinyapp to online server
rsconnect::deployApp(
    appDir = "app",
    appFiles = rsconnect::listDeploymentFiles("app"),
    appName = "shinyFunBioDiv",
    appTitle = "FunBioDiv data explorer"
)
```


## Create the metadata Dashboard

```r
quarto::quarto_render("analysis/04_explore.qmd")
file.rename("analysis/04_explore.html", "docs/metadata_Funbiodiv.html")
```

```r
quarto::quarto_render("analysis/05_overview.qmd")
file.rename("analysis/05_overview.html", "docs/overview_Funbiodiv.html")
```