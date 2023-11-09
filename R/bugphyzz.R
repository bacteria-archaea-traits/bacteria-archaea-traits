## cached bugphyzz api
#' Procedure
#'1. Subset by attribute value == TRUE
#'2. get NCBI/Taxonomy names
#'3. Merge to tax to get respective taxonomy classification
#'5. Merge to condensed_spp. - Get starts of merging.
### settings the dataset priority

### Bugphyzz transformations mapping
## store in a json file.

gram_stain_maps <-
  c(
    "gram stain negative" = "negative",
    "gram stain positive" = "positive",
    "gram stain variable" = NA
  )

aerophilicity_maps <- c(
  "aerobic" = "aerobic",
  "anaerobic" = "anaerobic",
  "facultatively anaerobic" = "facultative",
  "facultative aerobe" = "facultative",
  "aerotolerant" = NA,
  "microaerotolerant" = NA
)

biosafety_level_maps <- c(
  "biosafety level 1" = 1,
  "biosafety level L1" = 1,
  "biosafety level 2" = 2,
  "biosafety level 3" = 3,
  "biosafety level 1+" = NA,
  "biosafety level 3**" = NA
)

motility_maps <- c("motility" = "yes")

# cell_shape <- c("coccus"=c("diplococcus-shaped", "coccus", "staphylococcus", "coccus-shaped"),
#                 "diplococcus-shaped"="coccus",
#                 "staphylococcus"="coccus",
#                 "coccus"="coccus",
#                 "coccus"="coccus",
#                 "bacillus"="bacillus",
#                 "coccobacillus"="coccobacillus",
#                 "spiral"=c()
#
#                 )

bugphyzz_to_condensed_species_mapping = tibble::tibble(
  bugphyzz = c(
    "biosafety level",
    "aerophilicity",
    "gram stain",
    "motility",
    "growth temperature",
    "optimal ph",
    "coding genes",
    "genome size",
    "halophily", 
    "shape", 
    "length"
  ),
  condensed_species = c(
    "biosafety_level",
    "metabolism",
    "gram_stain",
    "motility",
    "growth_tmp",
    "optimum_ph",
    "coding_genes",
    "genome_size",
    "range_salinity",
    "cell_shape",
    "d2_lo"
  )
)

fill_missing_attribute_with_bugphyzz <-
  function(trait, condensed_spp, trait_mappers = NULL) {
    condensed_spp_keyword_mapping <-
      .keyword_cond_spp_mapping(bugphyzz_to_condensed_species_mapping,
                                trait)
    cat(sprintf("Get physiology data from bugphyzz for %s\n", trait))
    bugphyzz_attribute <- .get_cached_physiologies(trait)
    cat(sprintf("Getting taxonomy ids \n"))
    taxonomized_physiology_bugphyzz <- .get_tax_id(bugphyzz_attribute)
    
    cat(
      sprintf("Merging data to species level; using data source priority based on bugphyzz definitions \n")
    )
    species_level_physiology <-
      .bugphyzz_merger(taxonomized_physiology_bugphyzz, trait)
    ## attribute values mapping:
    cat("Transforming values from bugphyzz to madin using dictionaries. \n")
    species_level_physiology <- .mappers(species_level_physiology,
                                         trait_mappers,
                                         condensed_spp_keyword_mapping)
    cat(sprintf("Getting species with missing %s .", condensed_spp_keyword_mapping))
    
    missing_condensed_spp_trait <- condensed_spp %>%
      filter(is.na(!!as.symbol(condensed_spp_keyword_mapping))) %>%
      select(-c(!!as.symbol(condensed_spp_keyword_mapping)))
    
    ## compare condensed_spp with bugphyzz ph
    
    cat("Filling the missing the values using bugphyzz. \n")
    filled_condensed_traits <- .fill_missing_condensed_spp_bugphyzz(
          missing_condensed_spp_trait %>% select(c(species_tax_id)),
          species_level_physiology) %>% 
        filter(!is.na(!!as.symbol(condensed_spp_keyword_mapping)))
    
    ## join back to condensed_spp
    cat(
      sprintf(
        "Missing values for %s are : %s, filled %s ==> filling percentage %s \n",
        trait,
        nrow(missing_condensed_spp_trait),
        nrow(filled_condensed_traits),
        nrow(filled_condensed_traits) / nrow(missing_condensed_spp_trait)
      )
    )
    print(names(filled_condensed_traits))
    
    ## Fill in the value based on bugphyzz.
    cat("Joining the filled values to condensed spp \n")
    left_suffix = ".x"
    right_suffix = ".y"
    left_column_name <-
      paste(condensed_spp_keyword_mapping, left_suffix, sep = "")
    right_column_name <-
      paste(condensed_spp_keyword_mapping, right_suffix, sep = "")
    data <-
      condensed_spp %>% left_join(filled_condensed_traits, by = "species_tax_id") %>%
      mutate(
        !!as.symbol(condensed_spp_keyword_mapping) :=
          ifelse(
            is.na(!!as.symbol(left_column_name)),!!as.symbol(right_column_name),!!as.symbol(left_column_name)
          )
      ) %>%
      select(-c(
        !!as.symbol(right_column_name),
        !!as.symbol(left_column_name)
      ))
    cat("Done filling condensed species with bugphyzz \n")
    return(data)
  }

## Mappers
#' Maps the columns names based on the dictionary definitions.
#' Rename the Attribute column to specified condensed_spp_keyword_mapping
.mappers <-
  function(data,
           mapping_dictionary,
           condensed_spp_keyword_mapping) {
    if (!is.null(mapping_dictionary)) {
      data <-
        data %>%
        mutate(Attribute = mapping_dictionary[Attribute])
    }
    data <-
      data %>%
      rename(!!as.symbol(condensed_spp_keyword_mapping) := Attribute)
    return(data)
  }

.fill_missing_condensed_spp_bugphyzz <- function(condensed_spp,
                                                 species_level_physiology) {
  results <- inner_join(condensed_spp,
                        species_level_physiology,
                        by = "species_tax_id")
  return(results)
  
}

cached_physiologies <- memoise::memoise(bugphyzz::physiologies,
                                        cache = cachem::cache_mem(max_age = 60 *
                                                                    60 * 24 * 7))

.get_cached_physiologies <-
  function(keyword, cache_dir = "~/bugphyzz_cache") {
    if (!dir.exists(cache_dir)) {
      dir.create(cache_dir, recursive = TRUE)
    }
    result <- cached_physiologies(keyword)[[1]]
    print(sprintf("Data sources for %s in bugphyzz \n. %s",keyword, paste0(paste(unique(result$Attribute_source)))))
    if ("range" %in% unique(result$Attribute_type)) {
      result <- result %>%
        mutate(Attribute = Attribute_value_max) %>%
        select(-c(Attribute_value_max, Attribute_value_min))
    } else {
      result <- .subset_attribute_value_by_true(result)
    }
    return(result)
  }

.subset_attribute_value_by_true <- function(physiology_data) {
  if ("Attribute_value" %in% names(physiology_data) &
      typeof(physiology_data$Attribute_value) == "logical") {
    return(physiology_data %>% filter(Attribute_value == TRUE))
  }
  return(physiology_data)
}

.get_tax_id <- function(physiology_data) {
  ## decide tax_id based on NCBI_ID or Parent_NCBI_ID
  physiology_data <- physiology_data %>%
    mutate(tax_id = ifelse(is.na(NCBI_ID), Parent_NCBI_ID, NCBI_ID))
  # fill missing tax_id; by using taxizedb
  ## get tax_id by Taxon_name
  if (physiology_data %>% filter(is.na(tax_id)) %>% nrow() == 0) {
    return(.merger_tax(physiology_data))
  }
  missing_tax <-
    physiology_data %>% filter(is.na(tax_id)) %>%
    mutate(clean_taxon_name = taxadb::clean_names(Taxon_name))
  cat(sprintf("Missing taxonomy NCBIs: %s", nrow(missing_tax)))
  
  fill_by_taxon_name <-
    .get_taxid_by_name(missing_tax$clean_taxon_name) %>%
    inner_join(
      missing_tax,
      by = join_by("name" == "clean_taxon_name"),
      relationship = "many-to-many"
    ) %>%
    mutate(tax_id = id) %>% select(-c(id, name))
  
  cat(sprintf(
    "Out of %s records with missing tax_id , and %s were resolved with taxizedb \n",
    nrow(missing_tax),
    nrow(fill_by_taxon_name)
  ))
  
  ## filter missing tax_ids, and rank == genus
  ## merge with tax to get taxonomy classifications.
  physiology_data <-
    .merger_tax(rbind(physiology_data, fill_by_taxon_name))
  return(physiology_data)
}

.merger_tax <- function(data) {
  data %>% mutate(tax_id = as.double(tax_id)) %>%
    filter(!is.na(tax_id)) %>% filter(Rank != "genus") %>%
    inner_join(tax %>% select(c(species_tax_id, tax_id)), by = "tax_id") %>%
    select(-c(tax_id))
}


#'4. group-by species species_tax_id
#'  - Multiple source use priority value: Largest priority
#'
.bugphyzz_merger <- function(physiology_bugphyzz, trait) {
  ## different data source will have the same priority and all of them capture.
  physiology_bugphyzz <-
    physiology_bugphyzz %>%
    inner_join(.get_priority(), by = "Attribute_source") %>%
    group_by(species_tax_id) %>%
    slice_max(data_source_priority) %>%
    slice(1) %>% select(c(species_tax_id, Attribute))
  
  ## get max based on highest confidence_priority
  #slice_max(confidence_priority) %>%
  ## get max based on highest confidence_priority
  #slice_max(evidence_priority)
  
  return(physiology_bugphyzz)
}

.set_bugphyzz_data_source_priority_mergers <- function() {
  bugphyzz_source_path <-
    system.file("extdata", "attribute_sources.tsv",
                package = "bugphyzz")
  attribute_sources <- readr::read_tsv(bugphyzz_source_path) %>%
    select(-c(full_source))
  ### Defining the tables priorities
  
  evidence_priority <- tibble::tibble(evidence = c("exp", "igc", "tas", "nas"),
                                      priority = c(4, 3, 2, 1))
  confidence_priority <- tibble::tibble(confidence = c("high", "medium", "low"),
                                        priority = c(3, 2, 1))
  
  ## merge the dataset
  attribute_sources <- attribute_sources %>%
    left_join(evidence_priority, by = c("Evidence" = "evidence")) %>%
    rename(evidence_priority = priority) %>%
    left_join(confidence_priority,
              by = c("Confidence_in_curation" = "confidence")) %>%
    rename(confidence_priority = priority)
  
  attribute_sources <- attribute_sources %>%
    mutate(data_source_priority = confidence_priority * evidence_priority)
  write_csv(
    attribute_sources,
    "output/prepared_references/bugphyzz_data_source_priority.csv"
  )
}

.get_priority <- function() {
  if (!file.exists("output/prepared_references/bugphyzz_data_source_priority.csv")) {
    .set_bugphyzz_data_source_priority_mergers()
  }
  return(
    readr::read_csv(
      "output/prepared_references/bugphyzz_data_source_priority.csv"
    )
  )
}

.get_taxid_by_name <- function(names) {
  return(taxizedb::name2taxid(names, out_type = "summary"))
}

.keyword_cond_spp_mapping <-
  function(bugphyzz_to_condensed_species_mapping,
           keyword) {
    bug_phyzz_csp_mapping <- bugphyzz_to_condensed_species_mapping %>%
      filter(bugphyzz == keyword) %>%
      pull(condensed_species)
    return(as.character(bug_phyzz_csp_mapping))
  }

bugphyzz_filling_workflow <- function(data, bugphyzz_to_condensed_species_mapping){
  results <- data
  for(col in c("growth temperature", "optimal ph", "coding genes", "genome size", "biosafety level", "aerophilicity","gram stain" , "motility")){
   ##if statement to subset the graphs for 
   if (col %in% c("growth temperature", "optimal ph", "coding genes", "genome size")){
     results <- fill_missing_attribute_with_bugphyzz(col, data)
   } else {
     results <- switch (col,
       "biosafety level" = fill_missing_attribute_with_bugphyzz(col, data, biosafety_level_maps),
       "aerophilicity" = fill_missing_attribute_with_bugphyzz(col, data, aerophilicity_maps),
       "gram stain" = fill_missing_attribute_with_bugphyzz(col, data, gram_stain_maps),
       "motility" = fill_missing_attribute_with_bugphyzz(col, data, motility_maps),
       results
     ) 
   }
   data <- results
  }
  return(data)
}
