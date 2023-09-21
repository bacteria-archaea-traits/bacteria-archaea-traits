#' @author Raymond Lesiyon

get_host_specific_gold_condensed_data <- function(condensed_data, gold_data, host) {
  #' @param condensed_data
  #' @param gold_data
  #' @param host 
  #' 
  #' @return
  #' @export
  #' 
  gold_host_specific_data <- .get_host_specific_gold_data(gold_data, host)
  condense_species_host_data <-.get_host_specific_condensed(condensed_data, host)
  
  host_specific_gold_condensed_data <- inner_join(gold_host_specific_data, condense_species_host_data, 
                                                  by = "species_tax_id") %>%select(c("species.x", "SYMBIOTIC_RELATIONSHIP.x", 
                                                                                     "Association")) %>% 
                                                  arrange(desc(SYMBIOTIC_RELATIONSHIP.x))
  return(host_specific_gold_condensed_data)
}

.get_host_specific_gold_data <- function(data, host){
  #' @param data 
  #' @param host 
  #' 
  #' @return
  #' @export
  #'
  
  data <- data %>% filter(grepl(host, isolation_source)) %>%
            select(c("tax_id", "SYMBIOTIC_RELATIONSHIP", "isolation_source")) %>% 
            inner_join(tax, by = "tax_id")%>%
            filter(!is.na(SYMBIOTIC_RELATIONSHIP))
  return(data)
}

.get_host_specific_condensed <- function(data, host){
  #' @param condensed_data
  #' @param host 
  #' 
  #' @return
  #' @export
  #' 
  
  host <- stringr::str_to_title(host)
  data <- data %>%filter(grepl(host, HostGroup))
  return(data)
}