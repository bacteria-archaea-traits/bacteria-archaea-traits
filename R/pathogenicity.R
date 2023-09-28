#'https://www.nature.com/articles/s41597-019-0090-x
#'
#' This function consolidates different dataset to derive a list of pathogens. The
#' dataset being used here are shaw(https://github.com/liampshaw/Pathogen-host-range), 
#' phi-base pathogen (https://poc.molecularconnections.com/phibase-v2/#/home), and 
#' cogem_research_report(https://cogem.net/)
#'
#' @param datasets List of dataset to explore
#' @return consensus pathogens list
#' @export
#'
#' @examples
pathogenicity_consensus_by_dataset <- function(datasets, df){
  
  shaw_pathogens <- .get_pathogenicity_by_liamp_shaw(datasets[1]) %>% distinct_all()
  phi_base_pathogens <- .get_pathogenicity_by_phi_base(datasets[2]) %>% distinct_all()
  bsl_levels <- .get_cogem_bsl_lvl(df) %>% distinct_all()
  pathogens <-
    rbind(
      shaw_pathogens %>% mutate(data_source = "Liamp-shaw"),
      bsl_levels %>% mutate(data_source = "cogem_consensus_list_pasteur_microbe"),
      phi_base_pathogens %>% mutate(data_source = "phi-base")
    ) %>%
    mutate(pathogen = T) 
  write_csv(pathogens, "output/prepared_references/consensus_pathogens.csv")
  print(
    sprintf(
      "Total Pathogens %s, From datasets: Shaw %s, cogem-pasteur-microbe %s phi_base %s",
      nrow(pathogens),
      nrow(shaw_pathogens),
      nrow(bsl_levels),
      nrow(phi_base_pathogens)
    )
  )
  return(pathogens %>% select(-c(data_source)) %>% distinct_all())
}
.get_cogem_bsl_lvl <- function(data) {
  return(data %>% filter(cogem_classification > 1) %>% select(c(species_tax_id, species)))
}

#' Get pathogenic for shaw dataset
#' @param data 
#' @return pathogens list
#'
#' @examples
.get_pathogenicity_by_liamp_shaw <- function(data_file_path){
  
  pathogenic_species <- read_csv(data_file_path) %>% filter(Type == "Bacteria") %>%
    filter(grepl("[H|h]uman", HostGroup)) %>%
    filter(Association %in% c("Pathogenic", "Pathogenic?")) %>%
    select(c(Species, Association))
  ## taxonomify
  taxified_species <- taxizedb::name2taxid(unlist(pathogenic_species), out_type = "summary") %>%
                          rename(tax_id = id, species = name) %>% 
                          mutate(tax_id = as.double(tax_id))
  
  ## merge to get the species_tax_id
  pathogenic_species <- taxified_species %>% inner_join(tax, by = "tax_id") %>% 
    select(c(species_tax_id, species.y)) %>% rename(species = species.y)
  
  return(pathogenic_species)
  
}

#' Get pathogenic for shaw dataset
#' @param data 
#' @return pathogens list
#'
#' @examples
.get_pathogenicity_by_cogem <- function(data_file_path){
  pathogenic_species <- read_csv(data_file_path) %>% filter(cogem_classification > 1) %>% 
    select(c(species_tax_id, species))
  return(pathogenic_species)
}

#' Get pathogenic for shaw dataset
#' @param data 
#' @return pathogens list
#'
#' @examples
.get_pathogenicity_by_phi_base <- function(data_file_path){
  phi_base_data <- read_csv(data_file_path) %>%
    rename(species_tax_id=`Pathogen_NCBI_species_Taxonomy ID`, species = Pathogen_species) %>%
    filter(!(is.na(species_tax_id) | is.na(species)))
  return(phi_base_data)
}




