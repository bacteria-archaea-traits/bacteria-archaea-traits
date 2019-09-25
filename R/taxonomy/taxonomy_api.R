# The following code snippets send either specie names or accession numbers (or both) to the NCBI taxonomy API in order to try to create the best taxonomic mappings among data sets.  These only need to be run once, or after a change has been made to a dataset (which really shouldn't happen!) or the actual API code has been changed by Josh.

source("R/functions.R")

### prochlorococcus

pro <- read.csv("data/prochlorococcus/cyano data.csv", as.is=TRUE)

pro_store <- data.frame()
for (i in 1:nrow(pro)) {
	pro_store <- rbind(pro_store, get_species(pro$X16S.accession[i]))
}

write.csv(pro_store, "output/taxmaps/taxmap_prochlorococcus.csv", row.names=FALSE, quote=TRUE)

### bergeys

ber <- read.csv("output/bergeys_species_accessions.csv", as.is=TRUE)

ber_store <- data.frame()
for (i in 6389:nrow(ber)) {
	sp <- check_species(ber$species[i])
	ac <- get_species(ber$accession[i])
	ber_store <- rbind(ber_store, cbind(ber[i,], ac, sp))
}

write.csv(ber_store, "output/taxmaps/taxmap_bergeys.csv", row.names=FALSE, quote=TRUE)
