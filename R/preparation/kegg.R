# KEGG prepare code.

# The full dataset contains a row for each chromosome and plasmid. The following tallies these number in a abbreviated dataset.
keg <- read.csv("data/raw/kegg/kegg_full.csv", as.is=TRUE)

# Tallying up chromosome and plasmids from keg
plasmids <- aggregate(type ~ t_number, keg, function(x) sum(x=="Plasmid"))
names(plasmids) <- c("t_number", "plasmids")
chromosomes <- aggregate(type ~ t_number, keg, function(x) sum(x=="Chromosome"))
names(chromosomes) <- c("t_number", "chromosomes")
chromosomes_plasmids <- aggregate(type ~ t_number, keg, length)
names(chromosomes_plasmids) <- c("t_number", "chromosomes_plasmids")

# The keg dataset has duplicate rows for each chromosome and plasmid, and so need to remove duplicates before merge
keg <- keg[!duplicated(keg$t_number),]

# Also merge the chormosome and plasmid counts from kegg
keg <- merge(keg, chromosomes, by="t_number", all.x=TRUE)
keg <- merge(keg, plasmids, by="t_number", all.x=TRUE)
keg <- merge(keg, chromosomes_plasmids, by="t_number", all.x=TRUE)

#update column names to standard for merger
colnames(keg)[which(names(keg) == "full_name")] <- "org_name"
colnames(keg)[which(names(keg) == "number_of_nucleotides")] <- "genome_size"
colnames(keg)[which(names(keg) == "number_of_protein_genes")] <- "coding_genes"
colnames(keg)[which(names(keg) == "comment")] <- "isolation_source"

# The Comment field contains information on isolation sources. However, most of these have not 
# currently been translated to our isolation source terminology. Hence, while including the 
# comment field as 'isolation_source' - here we remove any comments that have not been traslated
# i.e. doesn't exist in the environement translation table

look <- read.csv("data/conversion_tables/renaming_isolation_source.csv", as.is=TRUE)
keg$isolation_source[!(keg$isolation_source %in% look$Original)] <- NA

#Add reference column (bioproject id)
#Extract bioproject id

keg$reference <- NA
#the bioproject id is always the last word in the data source string, so just do
keg$reference <- word(keg$data_source,-1)

#Add reference type column
keg$ref_type <- "bioproject_id"

#Reduce to needed columns
keg2 <- keg[,c("tax_id","org_name","genome_size","coding_genes","isolation_source","reference","ref_type")]

#Remove any fully duplicated rows
keg2 <- unique(keg2[, names(keg2)])

write.csv(keg2, "output/prepared_data/kegg.csv", row.names=FALSE)