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
  plant_pathogens <-.get_plant_data(datasets[3]) %>% filter(plant_host_phenotype == "Phytopathogen") %>% 
    select(-c(plant_host_phenotype)) %>% distinct_all()
  cogem_bsl_levels <- rbind(
    .get_cogem_bsl_lvl(df, "cogem_classification") %>% distinct_all(), 
    .get_cogem_bsl_lvl(df, "biosafety_level") %>% distinct_all())
  
  insect_pathogens <- 
    insectDisease::pathogen %>% 
      filter(Group %in% c("Bacteria", "Mollicutes")) %>% 
      inner_join(tax, by = join_by("PathTaxID" == "tax_id")) %>% 
      select(c("species_tax_id", "species")) %>% distinct_all()
  
  pathogens <-
    rbind(
      shaw_pathogens %>% mutate(data_source = "Liamp-shaw") ,
      cogem_bsl_levels %>% mutate(data_source = "cogem_consensus_list_pasteur_microbe_bugphyzz", host = NA),
      phi_base_pathogens %>% mutate(data_source = "phi-base", host = NA ),
      plant_pathogens %>% mutate(data_source = "plant dataset", host = "plants"), 
      insect_pathogens %>% mutate(data_source = "EDWIP", host = "insecta")
    ) %>%
    mutate(pathogen = T)
  write_csv(pathogens, "output/prepared_references/consensus_pathogens.csv")
  print(
    sprintf(
      "Total Pathogens %s, From datasets: Shaw %s, cogem-pasteur-microbe %s phi_base %s, plant pathogens %s, insect_pathogens %s",
      nrow(pathogens),
      nrow(shaw_pathogens),
      nrow(cogem_bsl_levels),
      nrow(phi_base_pathogens),
      nrow(plant_pathogens), 
      nrow(insect_pathogens)
    )
  )
  return(pathogens %>% select(-c(data_source, host)) %>% distinct_all())
}
.get_cogem_bsl_lvl <- function(data, data_column) {
  return(data %>% filter(!!as.symbol(data_column) > 1) %>% select(c(species_tax_id, species)))
}

#' Get pathogenic for shaw dataset
#' @param data 
#' @return pathogens list
#'
#' @examples
.get_pathogenicity_by_liamp_shaw <- function(data_file_path){
  
  pathogenic_species <- read_csv(data_file_path) %>% filter(Type == "Bacteria") %>%
    filter(Association %in% c("Pathogenic", "Pathogenic?")) %>%
    select(c(Species, HostGroup)) %>% mutate(host = stringr::str_to_lower(HostGroup))
  ## taxonomify
  taxified_species <- pathogenic_species %>% select(c(Species, host)) %>% 
                        inner_join(
                          taxizedb::name2taxid(unlist(pathogenic_species$Species), out_type = "summary"), 
                          by = join_by("Species" == "name")
                        ) %>%
                        rename(tax_id = id, species = Species) %>% 
                        mutate(tax_id = as.double(tax_id))
  ## merge to get the species_tax_id
  pathogenic_species <- taxified_species %>% inner_join(tax, by = "tax_id") %>% 
    select(c(species_tax_id, species.y, host)) %>% rename(species = species.y)
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

## getting plant_pathogens dataset. 

.get_plant_data <- function(file_path){
  plant_pathogens <- readr::read_csv(file_path) %>% 
    rename(tax_id = "NCBI TAX ID", plant_host_phenotype = "HOST PHENOTYPE") %>% 
    inner_join(tax, by = "tax_id") %>% select(c(species_tax_id, species, plant_host_phenotype))
  return(plant_pathogens)
}

host_association <- function(consensus_host_path, df ) {
  
  consensus_hosts_associations <- readr::read_csv(consensus_host_path) %>% 
    select(c(species_tax_id, host)) %>% distinct_all()
  
  consensus_hosts_associations <- df %>% 
    left_join(consensus_hosts_associations, by = "species_tax_id") %>%
    mutate(host = ifelse(!is.na(host), paste0("host_", host), "host_no"))
  
  hosts <- unique(consensus_hosts_associations$host)
  
  consensus_hosts_associations <- consensus_hosts_associations %>% 
    mutate(host_value = ifelse(host %in% hosts, "host_associated" , NA)) %>% 
    pivot_wider(names_from = host, values_from = host_value, values_fill = NA)
  
  return(consensus_hosts_associations)
}