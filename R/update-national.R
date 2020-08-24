# Packages -----------------------------------------------------------------
require(EpiNow2, quietly = TRUE)
require(covidregionaldata, quietly = TRUE)
require(data.table, quietly = TRUE)
require(future, quietly = TRUE)
require(here, quietly = TRUE)
require(lubridate, quietly = TRUE)
require(futile.logger, quietly = TRUE)

# Load utils --------------------------------------------------------------

source(here::here("R", "utils.R"))

options <- c("cases", "deaths")

generation_time <- readRDS(here::here("data", "generation_time.rds"))
incubation_period <- readRDS(here::here("data", "incubation_period.rds"))

for (option in options) {

  # Update delays -----------------------------------------------------------

  if (option == "cases") {
    reporting_delay <- readRDS(here::here("data", "onset_to_admission_delay.rds"))
  }
  if (option == "deaths") {
    reporting_delay <- readRDS(here::here("data", "onset_to_death_delay.rds"))
  }

  # Set up logging ----------------------------------------------------------

  setup_log()

  futile.logger::flog.info("Processing national dataset for: %s", option)

  # Get cases  ---------------------------------------------------------------

  cases <- data.table::setDT(covidregionaldata::get_national_data(source = "ecdc"))

  if (option == "deaths") {
    cases <- cases[country != "Cases_on_an_international_conveyance_Japan"]
    cases <- cases[, .(region = country, date = as.Date(date), confirm = deaths_new)]
  }
  if (option == "cases") {
    cases <- cases[, .(region = country, date = as.Date(date), confirm = cases_new)]
  }
  cases <- cases[date <= Sys.Date()]
  cases <- cases[, .SD[date <= (max(date) - lubridate::days(3))], by = region]
  cases <- cases[, .SD[date >= (max(date) - lubridate::weeks(12))], by = region]
  data.table::setorder(cases, date)


  # Check to see if the data has been updated  ------------------------------

  if (check_for_update(cases, last_run = here::here("last-update", paste0(option, ".rds")))) {

    # # Set up cores -----------------------------------------------------

    no_cores <- setup_future(length(unique(cases$region)))

    # Run Rt estimation -------------------------------------------------------

    if (option == "cases") {
      chains <- 2
    }
    if (option == "deaths") {
      chains <- ifelse(no_cores <= 2, 2, no_cores)
    }
    regional_epinow(reported_cases = cases,
                    generation_time = generation_time,
                    delays = list(incubation_period, reporting_delay),
                    horizon = 14, burn_in = 14,
                    non_zero_points = 14,
                    samples = 2000, warmup = 500,
                    fixed_future_rt = TRUE,
                    cores = no_cores, chains = chains,
                    target_folder = paste0("national/", option, "/national"),
                    summary_dir = paste0("national/", option, "/summary"),
                    all_regions_summary = FALSE,
                    region_scale = "Country",
                    return_estimates = FALSE, verbose = FALSE)

    future::plan("sequential")
  }
}
