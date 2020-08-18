source(here::here("R", "region_entity.R"))

regions <- c(
  Region$new(name = "afghanistan",
             data_identifier = "afghanistan",
             cases_subregion_source = "province",
             case_modifier = function(cases) {
               cases <- cases[!is.na(iso_3166_2)]
               return(cases)
             },
             stable = FALSE
  ),
  Region$new(name = "belgium",
             data_identifier = "Belgium"
  ),
  Region$new(name = "brazil",
             data_identifier = "Brazil",
             cases_subregion_source = "state"
  ),
  region$new(name = "canada",
             data_identifier = "Canada",
             cases_subregion_source = "province"
  ),
  region$new(name = "colombia",
             data_identifier = "Colombia",
             cases_subregion_source = "departamento"
  ),
  region$new(name = "germany",
             data_identifier = "Germany",
             cases_subregion_source = "bundesland"
  ),
  region$new(name = "india",
             data_identifier = "India",
             cases_subregion_source = "state"
  ),
  region$new(name = "italy",
             data_identifier = "Italy"
  ),
  region$new(name = "russia",
             data_identifier = "Russia"
  ),
  region$new(name = "united-states",
             data_identifier = "USA",
             cases_subregion_source = "state",
             region_scale = "State"
  ),
  Region$new(name = "united-kingdom",
             data_identifier = "UK"
  ),
)