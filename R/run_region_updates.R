# Packages
library(optparse, quietly=TRUE) # bring this in ready for setting up a proper CLI
library(dplyr, quietly=TRUE)

# Pull in the definition of the regions
source(here::here("R", "region_list.R"))
# get the onward script
source(here::here("R", "update-regional.R"))
# load utils
source(here::here("R", "utils.R"))

# set up the arguments
option_list <- list(
  make_option(c("-v", "--verbose"), action = "store_true", default = FALSE, help = "Print verbose output "),
  make_option(c("-w", "--werbose"), action = "store_true", default = FALSE, help = "Print v.verbose output "),
  make_option(c("-q", "--quiet"), action = "store_true", default = FALSE, help = "Print less output "),
  make_option(c("--log"), type = "character", help = "List of locations to exclude, comma separated (no spaces) in the format region/subregion or region/*"),
  make_option(c("-e", "--exclude"), type = "character", help = "List of locations to exclude, comma separated (no spaces) in the format region/subregion or region/*"),
  make_option(c("-i", "--include"), type = "character", help = "List of locations to include (excluding all non-specified), comma separated (no spaces) in the format region/subregion or region/*")
)

args <- parse_args(OptionParser(option_list = option_list))

setup_log_from_args(args)

# handle include / exclude options
if (exists("exclude", args) && exists("include", args)) {
  stop("not possible to both include and exclude regions / subregions")
}
excludes <- NULL
if (exists("exclude", args)) {
  excludes <- parse_cludes(args$exclude)
}
includes <- NULL
if (exists("include", args)) {
  includes <- parse_cludes(args$include)
}

for (location in regions) {
  if (!is.null(excludes) && count(excludes %>% filter(region == location$name, subregion == "*")) > 0) {
    futile.logger::flog.debug("skipping location %s as it is in the exclude/* list", location$name)
    next()
  }
  if (!is.null(includes) &&
    count(includes)>0 &&
    count(includes %>% filter(region == location$name)) == 0) {
    futile.logger::flog.debug("skipping location %s as it is not in the include list", location$name)
    next()
  }
  if (location$stable) {
    print(location$name)
    #ToDo: pass any subregion restrictions on. Merge update_regional into here.
    #update_regional(location$name,
    #                location$covid_regional_data_identifier,
    #                location$case_modifier,
    #                location$generation_time,
    #                location$incubation_period,
    #                location$reporting_delay,
    #                location$cases_subregion_source,
    #                location$region_scale
    #)
  }
}