remotes::install_github("Dragon-odonates/dragonapp", force = TRUE)
library(dragonapp)

# update about.md
get_about_md(here::here("data", "derived"))
# manually edit the file update.md then
update_about_md(here::here("data", "derived", "about_obs.md"))

# add dataset
add_shiny_data(
  folder = here::here("data", "derived", "obs_50"),
  label = "obs_50",
  overwrite = TRUE
)
# take some time ...
runShiny()

rm_shiny_data("obs_50")
