# Packages
library("optparse") # bring this in ready for setting up a proper CLI

# Pull in the definition of the regions
source(here::here("R", "region_list.R"))
source(here::here("R", "update-regional.R"))


for (location in regions) {
  update_regional(location$name,
                  location$data_identifier,
                  location$case_modifier,
                  location$generation_time,
                  location$incubation_period,
                  location$reporting_delay,
                  location$cases_subregion_source,
                  location$region_scale
  )
}