#' GcPathogen incorporation with condensed species. This code add the bsl level from 
#' https://nmdc.cn/gcpathogen/. ( The pathogenicity is added via pathogenicity.R package)
#' The code is called inside condensed_species.R
#'
#' @param file_path The file path for downloaded gc_pathogen table. 
#' @param cond Madin condensed species. 
#'
#' @return combined condensed species. 
#' @export
#'
gcpathogen <- function(file_path, cond){
  gc_pathogen <- readr::read_csv(file = file_path) %>%
    select(c(taxonid, level)) %>%
    mutate(level = case_when(
      grepl("1", level) ~ 1,
      grepl("2", level) ~ 2,
      grepl("3", level) ~ 3,
      grepl("4", level) ~ 4,
      TRUE ~ NA))
  cond <- cond %>% left_join(gc_pathogen, by = join_by("species_tax_id" == "taxonid")) %>%
    mutate(biosafety_level = ifelse(is.na(biosafety_level) & !is.na(level), 
                                      level,
                                    biosafety_level)) %>% select(-c(level))
  return(cond)
}