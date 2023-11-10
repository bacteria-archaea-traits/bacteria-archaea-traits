data_columns <- c("dsmz_list", "dsmz_risk_category", "A", "B", "C", "D", "E", "F", "G", "H", "I", "overall_score")

cogem_pdf_path <- "data/raw/cogem/coegm.pdf"

.scrape_pdf_data <- function() {
  cogem_data_pdf <- future_lapply(24:113, function(x) {
    extract_tables(cogem_pdf_path, pages = x, guess = FALSE, 
                   output = "data.frame", method='stream')
  })
  return(cogem_data_pdf)
}

combined_cogem_pdf_data <- function(cogem_data_lists, data_columns){
  result_data_df <- NULL
  for (i in 1:length(cogem_data_lists)){
    data <- as.data.frame(unnest(as.data.frame(cogem_data_lists[i])))
    if(i == 1) {
      data <- clean_data_frame(data, 6, data_columns)
    } else {
      data <- clean_data_frame(data, 1, data_columns)
    }
    result_data_df <- rbind(result_data_df, data)
  }
  write.table(as.data.frame(result_df),
              file="output/prepared_data/cogem_classification.csv", quote=F,sep=",",row.names=F)
  return()
}

clean_data_frame <- function(data, row, cols) {
  n <- nrow(data)
  data <- data[row:n-1, ]
  colnames(data) <- cols
  return(data)
}


merge_tax_mapping_bsl_levels <- function(data) {
  data_species_annotations <- .separate_species_genera(data)
  species <- data_species_annotations%>% filter(spec == T)
  genera <- data_species_annotations %>% filter(!spec == T)
  get_species_tax_name_mapping <- inner_join(.get_tax_id_by_name(species$dsmz_list), species, 
                                             by = join_by(species==dsmz_list))
  get_genera_tax_name_mapping <- inner_join(.get_tax_id_by_name(genera$dsmz_list), genera, 
                                            by = join_by(species==dsmz_list))
  print(sprintf("Unresolved species with taxdizedb %s",nrow(species)-nrow(get_species_tax_name_mapping)))
  print(sprintf("Unresolved genera with taxdizedb %s",nrow(genera)-nrow(get_genera_tax_name_mapping)))
  ## TO DO: fix to remove the record of all species with duplicates
  taxonomy_bsl_level_data <- get_species_tax_name_mapping %>% 
    mutate(tax_id = as.double(tax_id)) %>% 
    distinct(tax_id, .keep_all = T)
  return(taxonomy_bsl_level_data)
}

.separate_species_genera <- function(data){
  data <- data %>% mutate(new_dmsz_list = dsmz_list) %>%
    separate(new_dmsz_list, c("species", "genus")) %>% 
    mutate(spec = ifelse(!is.na(species) & !is.na(genus), T, F)) %>%
    select(-c(species,genus))
  return(data)
}

.get_tax_id_by_name <- function(species_names){
  tax_name_df <- taxizedb::name2taxid(species_names, verbose=T, out_type = "summary")
  colnames(tax_name_df) <- c("species", "tax_id")
  return(tax_name_df)
}

.resolve_with_tax_file <- function(species_name, tax){
  species_name_tax_id <- tax %>% filter(species_name == species_name) %>% select(c("tax_id")) 
  if(!is.null(species_name_tax_id)){
    return(species_name_tax_id)
  } else { return(NA) }
}

.resolve_tax_ids <- function(species_names, tax){
  tax <- tax %>% mutate(species_name = stringr::str_to_lower(species))
  for(species_name in species_names){
    print(.resolve_with_tax_file(species_name, tax))
    break
  }
}

.merger <- function(data, tax){
  by <- join_by(tax_id == tax_id)
  tax_cogem_data <- inner_join(tax,data, by = by, relationship="one-to-one")
  same_tax_cogem_names <- .use_species_with_same_names(tax_cogem_data)
  print(sprintf("Removed %s with different names in cogem_list and tax_id", nrow(tax_cogem_data) - nrow(same_tax_cogem_names)))
  return(same_tax_cogem_names)
}

.use_species_with_same_names <- function(data){
  return( 
    data %>% mutate(species.w = str_to_lower(species.x), species.w1 = str_to_lower(species.y )) %>%
      filter(species.w == species.w1) %>%
      rename(species = species.x) %>% select(-c(species.y, species.w, species.w1))
  )
}

cogem_wrapper <- function(prepared_cogem_file){
  if(!file.exists(prepared_cogem_file)){
    warning("The cogem file does not exist, rerun the .scrape_pdf_data functions.")
    return()
  }
  result_df_data <- readr::read_csv(prepared_cogem_file) %>% 
    mutate(dsmz_list = stringr::str_to_lower(dsmz_list))
  taxonomy_level_cogem_data <- merge_tax_mapping_bsl_levels(result_df_data)
  tax_names_cogem <- .merger(taxonomy_level_cogem_data, tax) %>%
                        select(c("tax_id", "species", "genus", "family", "order", "class", "phylum",
                                 "superkingdom", "tax_id", "species_tax_id", "overall_score")) %>%
                        rename(cogem_classification = overall_score)
  return(tax_names_cogem)
}

cogem_file_path <- "output/cogem_classification.csv"
tax_names_cogem_bsl_levels <- cogem_wrapper(cogem_file_path)
write_csv(tax_names_cogem_bsl_levels, "output/prepared_data/cogem_classification.csv")