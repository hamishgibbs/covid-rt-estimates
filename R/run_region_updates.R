#' Run Region Updates
#' Example usage:
#' Rscript R/run_region_updates.R -w -i united-states/texas,united-kingdom/*
#' Rscript R/run_region_updates.R -v -e afghanistan/*
#'
# Packages
library(optparse, quietly = TRUE) # bring this in ready for setting up a proper CLI
library(dplyr, quietly = TRUE)

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
  make_option(c("--log"), type = "character", help = "Specify log file name"),
  make_option(c("-e", "--exclude"), default = "", type = "character", help = "List of locations to exclude, comma separated (no spaces) in the format region/subregion or region/*"),
  make_option(c("-i", "--include"), default = "", type = "character", help = "List of locations to include (excluding all non-specified), comma separated (no spaces) in the format region/subregion or region/*"),
  make_option(c("-u", "--unstable"), action = "store_true", default = FALSE, help = "Include unstable locations")
)

args <- parse_args(OptionParser(option_list = option_list))

setup_log_from_args(args)

# handle include / exclude options
if (nchar(args$exclude) > 0 && nchar(args$include) > 0) {
  stop("not possible to both include and exclude regions / subregions")
}
excludes <- parse_cludes(args$exclude)
includes <- parse_cludes(args$include)

for (location in regions) {
  if (count(excludes %>% filter(region == location$name, subregion == "*")) > 0) {
    futile.logger::flog.debug("skipping location %s as it is in the exclude/* list", location$name)
    next()
  }
  if (count(includes) > 0 && count(includes %>% filter(region == location$name)) == 0) {
    futile.logger::flog.debug("skipping location %s as it is not in the include list", location$name)
    next()
  }
  if (location$stable || (exists("unstable", args) && args$unstable == TRUE)) {
    update_regional(location,
                    filter(excludes, region == location$name),
                    filter(includes, region == location$name))
  }else {
    futile.logger::flog.debug("skipping location %s as unstable", location$name)
  }
}