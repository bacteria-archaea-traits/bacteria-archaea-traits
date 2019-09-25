source("R/functions.R")

# The NCBI taxonomy database

### Only need to run the commented code below once if a new version of the NBCI taxonomy data from the FTP

# nam <- readLines("data/taxonomy/names.dmp")
# nam <- lapply(nam, function(x) strsplit(x, "(\t\\|\t)|(\t\\|)")[[1]] )
# nam[lengths(nam) != 4] # check all element 4 in length
# nam <- data.frame(matrix(unlist(nam), nrow=length(nam), byrow=TRUE), stringsAsFactors=FALSE)
# names(nam) <- c("tax_id", "name_txt", "unique_name", "name_class")
# write.csv(nam, "output/taxonomy_names.csv", row.names=FALSE)

# nod <- readLines("data/taxonomy/nodes.dmp")
# nod <- lapply(nod, function(x) strsplit(x, "(\t\\|\t)|(\t\\|)")[[1]] )
# nod[lengths(nod) != 13] # check all element 4 in length
# nod <- data.frame(matrix(unlist(nod), nrow=length(nod), byrow=TRUE), stringsAsFactors=FALSE)
# names(nod) <- c("tax_id", "parent_tax_id", "rank", "embl_code", "division_id", "inherited_div_flag", "genetic_code_id", "inherited_GC_flag", "mitochondrial_genetic_code_id", "inherited_MGC_flag", "GenBank_hidden_flag", "hidden_subtree_root_flag", "comments")
# write.csv(nod, "output/taxonomy_nodes.csv", row.names=FALSE)

nam <- read.csv("output/taxonomy_names.csv", as.is=TRUE)
nod <- read.csv("output/taxonomy_nodes.csv", as.is=TRUE)

# keg <- read.csv("output/processed_data/kegg.csv", as.is=TRUE)

# nam$name_txt[nam$tax_id %in% keg$tax_id]
# nam$unique_name[nam$tax_id %in% keg$tax_id]

# This function will return the full taxonomic hierarchy from NCBI based on a NCBI taxon ID

get_species <- function(tax_id_original) {
	tax_list <- data.frame(tax_id_original=tax_id_original, tax_name_original=NA, species_tax_id=NA, species_name=NA)
  tax_id <- tax_id_original

	if (!is.na(tax_id) & any(nod$tax_id==tax_id)) {

    tax_name_original <- nam$name_txt[nam$tax_id==tax_id & nam$name_class=="scientific name"]

		while (tax_id != 1) {

      if (nod$rank[nod$tax_id==tax_id] == "species") {        
        tax_name <- nam$name_txt[nam$tax_id==tax_id & nam$name_class=="scientific name"]
        tax_list <- data.frame(tax_id_original=tax_id_original, tax_name_original=tax_name_original, species_tax_id=tax_id, species_name=tax_name)
        break      
      }
			tax_id <- nod$parent_tax_id[nod$tax_id==tax_id]
		}
	}
  print(sprintf("id: %s -> species id: %s",tax_id_original,tax_id))
	return(tax_list)
}


get_taxonomy2 <- function(tax_id, rank=NA) {
  
  #NOTE: To optimise script run time I recommend checking tax_id validity 
  #BEFORE running this funcion by matching it with a vector of all 
  #unique tax_ids in nod dataframe. 
  
  tax_list <- data.frame(rank=NULL, tax_id=NULL, tax_name=NULL)
  # tax_id <- 329726
  
  if (!is.na(tax_id)) {
    
      #Create full list of taxonomy before returning
      while(tax_id != 1) {
  
        if(!is.na(rank)) {
          
          #Rank has been specified, only add when found
          if(nod$rank[nod$tax_id==tax_id] == rank) {
            
            tax_name <- nam$name_txt[nam$tax_id==tax_id & nam$name_class=="scientific name"]
            tax_list <- rbind(tax_list, data.frame(rank=nod$rank[nod$tax_id==tax_id], tax_id=tax_id, tax_name=tax_name))
            break
          
          }
          
        } else {
          #Add all ranks to list
          tax_name <- nam$name_txt[nam$tax_id==tax_id & nam$name_class=="scientific name"]
          tax_list <- rbind(tax_list, data.frame(rank=nod$rank[nod$tax_id==tax_id], tax_id=tax_id, tax_name=tax_name))
        }
        
        tax_id <- nod$parent_tax_id[nod$tax_id==tax_id]
      }

  } 
  return(tax_list)
}

