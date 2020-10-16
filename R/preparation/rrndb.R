# rrnDB data preparation

# Open original dataset
rrn <- read.delim("data/raw/rrndb/rrnDB-5.4.tsv", as.is=TRUE)

rrn[rrn == ""] <- NA

#update column names to standard for merger
colnames(rrn)[which(names(rrn) == "Data.source.organism.name")] <- "org_name"
colnames(rrn)[which(names(rrn) == "NCBI.tax.id")] <- "tax_id"
colnames(rrn)[which(names(rrn) == "X16S.gene.count")] <- "rRNA16S_genes"
colnames(rrn)[which(names(rrn) == "tRNA.gene.count")] <- "tRNA_genes"
colnames(rrn)[which(names(rrn) == "References")] <- "reference"

#Add reference type column wherever there is a reference
rrn <- rrn %>% mutate(ref_type = ifelse(!is.na(reference), "full_text",NA))

rrn <- rrn[,c("tax_id","org_name","rRNA16S_genes","tRNA_genes","reference","ref_type")]

#Due to unique data source record ids (which are excluded here), 
#the column reduced data frame has multiple duplicate entries (identical across all rows)

#Remove any fully duplicate rows
rrn <- unique(rrn[, names(rrn)])

#Save master data
write.csv(rrn, "output/prepared_data/rrndb.csv", row.names=FALSE, quote=TRUE)
