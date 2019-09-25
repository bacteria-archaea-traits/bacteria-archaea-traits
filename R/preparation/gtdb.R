# GTDB prepare code.

arc_tax <- read.table(text = gsub(";", "\t", readLines("data/raw/gtdb/ar122_taxonomy.tsv")), sep = "\t", header = FALSE)
bac_tax <- read.table(text = gsub(";", "\t", readLines("data/raw/gtdb/bac120_taxonomy.tsv")), sep = "\t", header = FALSE)
gtdb_tax <- rbind(arc_tax, bac_tax)

names(gtdb_tax) <- c("accession", "superkingdom_gtdb", "phylum_gtdb", "class_gtdb", "order_gtdb", "family_gtdb", "genus_gtdb", "species_gtdb")
gtdb_tax$superkingdom_gtdb <- gsub(".__", "", gtdb_tax$superkingdom_gtdb)
gtdb_tax$phylum_gtdb <- gsub(".__", "", gtdb_tax$phylum_gtdb)
gtdb_tax$class_gtdb <- gsub(".__", "", gtdb_tax$class_gtdb)
gtdb_tax$order_gtdb <- gsub(".__", "", gtdb_tax$order_gtdb)
gtdb_tax$family_gtdb <- gsub(".__", "", gtdb_tax$family_gtdb)
gtdb_tax$genus_gtdb <- gsub(".__", "", gtdb_tax$genus_gtdb)
gtdb_tax$species_gtdb <- gsub(".__", "", gtdb_tax$species_gtdb)

arc_met <- read.delim("data/raw/gtdb/ar122_metadata.tsv", sep = "\t", header = TRUE)
bac_met <- read.delim("data/raw/gtdb/bac120_metadata.tsv", sep = "\t", header = TRUE)
gtdb_met <- rbind(arc_met, bac_met)
gtdb_met$species_ncbi <- gsub("^.*(s__)", "", gtdb_met$ncbi_taxonomy)
gtdb_met <- gtdb_met[c("accession", "genome_size", "ncbi_species_taxid", "species_ncbi")]

gtdb <- merge(gtdb_tax, gtdb_met)
# head(gtdb[duplicated(gtdb$ncbi_species_taxid),])
# gtdb <- gtdb[!duplicated(gtdb$ncbi_species_taxid),]

write.csv(gtdb, "output/taxonomy/taxmap_gtdb.csv", row.names=FALSE)
