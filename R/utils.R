#' Get NCBI taxonomy data
#' Adopted from insectDisease getNCBI method. 
#' Process through a vector of species names to obtain taxonomic data
#' 
#' @param species a vector of species names
#' @param host (boolean) affects column naming (nice to keep host and pathogen separate)
#'
#' @return a data.frame with nrow == length(species) 
#' @name getNCBI
#' @importFrom taxize classification get_uid
#' @importFrom stats na.omit 
#' @importFrom utils tail
#' @importFrom plyr mutate
#' @export


getNCBI <- function(tax_id, host=TRUE){ 
  
  cc <- try(taxizedb::classification(tax_id))
  if(inherits(cc, 'try-error')){
    stop('NCBI resource is unavailable. Try again later.')
  }
  s <- unlist(lapply(cc, function(x){tryCatch(x$name[[which(x$rank=="species")]], error = function(e) {NA})}), use.names = FALSE)
  g <- unlist(lapply(cc, function(x){tryCatch(x$name[[which(x$rank=="genus")]], error = function(e) {NA})}), use.names = FALSE)
  f <- unlist(lapply(cc, function(x){tryCatch(x$name[[which(x$rank=="family")]], error = function(e) {NA})}), use.names = FALSE)
  o <- unlist(lapply(cc, function(x){tryCatch(x$name[[which(x$rank=="order")]], error = function(e) {NA})}), use.names = FALSE)
  c2 <- unlist(lapply(cc, function(x){tryCatch(x$name[[which(x$rank=="class")]], error = function(e) {NA})}), use.names = FALSE)
  k_super <- unlist(lapply(cc, function(x){tryCatch(x$name[[which(x$rank=="superkingdom")]], error = function(e) {NA})}), use.names = FALSE)
  p <- unlist(lapply(cc, function(x){tryCatch(x$name[[which(x$rank=="phylum")]], error = function(e) {NA})}), use.names = FALSE)
  levels <- c("species", "genus", "family", "order", "class", "phylum")
  
  u <- unlist(lapply(cc, function(x){
    tryCatch(tail(na.omit(x[x$rank %in% levels,'id']),1), 
             error = function(e) {NA})}), use.names = FALSE)
  ret <- data.frame(
    species = taxadb::clean_names(s),
    tax_id = u,
    genus = g,
    family = f,
    order = o, 
    class = c2, 
    phylum = p, 
    super_kingdom = k_super) 
  return(ret)
}

name2taxid <- function(names, out_type = "summary"){
  names <- taxadb::clean_names(names)
  result <- taxizedb::name2taxid(names, out_type = out_type) %>% 
    mutate()
  return(result)
}

bacteria_interaction_type <- function(data) {
  data <- data %>% mutate(interaction_type = NA)
  data <- data %>% mutate(
    interaction_type = ifelse(grepl("free living", isolation_source_full), "free living", interaction_type))
  data <- data %>% mutate(
    interaction_type = ifelse(grepl("symb*|mutual*", isolation_source_full), 
                              ifelse(!is.na(interaction_type), paste0("symbiotic", interaction_type), "symbiotic"),
                              interaction_type))
  data <- data %>% mutate(
    interaction_type = ifelse(grepl("[S|s]ymb", plant_host_phenotype),
                               ifelse(!is.na(interaction_type), paste0("Plant symbiotic", interaction_type), "symbiotic"),
                               interaction_type)
  )
  return(data)
}

## Loading docx file using docxtractr

load_cogem_file_from_docx <- function(file_path) {
  docx_obj <- docxtractr::read_docx(file_path)
  cogem_data <- NULL
  for (no_tab in 1:docxtractr::docx_tbl_count(docx_obj)) {
    print(no_tab)
    table_data <- as.data.frame(docxtractr::docx_extract_tbl(docx_obj, no_tab))
    if(is.null(cogem_data)){
      cogem_data <- table_data %>% mutate(A.P = "")
    } else{
      cogem_data <- rbind(cogem_data, table_data)
    }
  }
  cogem_data <- cogem_data %>% select(-c(No.))
  colnames(cogem_data) <- c("genus_species_strain", "class", "remarks_division_in_subspecies", "AP")
  
  return(cogem_data)
}