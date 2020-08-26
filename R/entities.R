#` see SMG.md for documentation

library(R6)

AbstractDataset <- R6Class("AbstractDataset", list(
  name = NA,
  case_modifier = NA,
  generation_time = NA,
  incubation_period = NA,
  reporting_delay = NA,
  region_scale = NA,
  stable = TRUE,
  target_folder = NA,
  summary_dir = NA
))
# This seemed a better name than global...
SuperRegion <- R6Class("SuperRegion",
                       inherit = AbstractDataset,
                       public = list(covid_national_data_identifier = "ecdc",
                                     initialize = function(name,
                                                           covid_national_data_identifier = "ecdc",
                                                           case_modifier = NA,
                                                           generation_time = NA,
                                                           incubation_period = NA,
                                                           reporting_delay = NA,
                                                           region_scale = "Country",
                                                           stable = TRUE) {
                                       self$name <- name
                                       self$covid_national_data_identifier <- covid_national_data_identifier
                                       self$case_modifier <- case_modifier
                                       self$generation_time <- generation_time
                                       self$incubation_period <- incubation_period
                                       self$reporting_delay <- reporting_delay
                                       self$region_scale <- region_scale
                                       self$stable <- stable
                                       self$target_folder <- paste0("national/", name, "/national")
                                       self$summary_dir <- paste0("national/", name, "/summary")
                                     }))

Region <- R6Class("Region",
                  inherit = AbstractDataset,
                  public = list(covid_regional_data_identifier = NA,
                                cases_subregion_source = "region_level_1",
                                initialize = function(name,
                                                      covid_regional_data_identifier = NA,
                                                      case_modifier = NA,
                                                      generation_time = NA,
                                                      incubation_period = NA,
                                                      reporting_delay = NA,
                                                      cases_subregion_source = "region_level_1",
                                                      region_scale = "Region",
                                                      stable = TRUE) {
                                  self$name <- name
                                  self$covid_regional_data_identifier <- covid_regional_data_identifier
                                  self$case_modifier <- case_modifier
                                  self$generation_time <- generation_time
                                  self$incubation_period <- incubation_period
                                  self$reporting_delay <- reporting_delay
                                  self$cases_subregion_source <- cases_subregion_source
                                  self$region_scale <- region_scale
                                  self$stable <- stable
                                  self$target_folder <- paste0("subnational/", name, "/cases/national")
                                  self$summary_dir <- paste0("subnational/", name, "/cases/summary")
                                }))

