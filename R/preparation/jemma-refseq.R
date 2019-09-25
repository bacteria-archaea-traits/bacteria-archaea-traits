# Jemma refseq data extraction

print("Processing data-set 'jemma-refseq'...", quote = FALSE)

# Open original dataset
jem <- read.csv("data/raw/jemma-refseq/Bacteria_archaea_traits_dataset.csv", as.is=TRUE)

#Fix name issues manually before mapping (mostly symbol errors possibly due to import)
#Note: The corrected names have been looked up in NCBI taxonomy browser

jem[!is.na(jem$Organism) & jem$Organism == "Aalophilic archaeon DL31", "Organism"] <- "halophilic archaeon DL31"
jem[!is.na(jem$Organism) & jem$Organism == "Aster yellows witches-broom phytoplasma AYWB", "Organism"] <- "Aster yellows witches'-broom phytoplasma AYWB"
jem[!is.na(jem$Organism) & jem$Organism == "Bartonella australis Aust", "Organism"] <- "Bartonella australis Aust/NH1"
jem[!is.na(jem$Organism) & jem$Organism == "Calothrix sp. 336", "Organism"] <- "Calothrix sp. 336/3"
jem[!is.na(jem$Organism) & jem$Organism == "Chlamydia felis Fe", "Organism"] <- "Chlamydia felis Fe/C-56"
jem[!is.na(jem$Organism) & jem$Organism == "Chlamydia gallinacea 08-1274", "Organism"] <- "Chlamydia gallinacea 08-1274/3"
jem[!is.na(jem$Organism) & jem$Organism == "Chlamydia trachomatis 434", "Organism"] <- "Chlamydia trachomatis 434/Bu"
jem[!is.na(jem$Organism) & jem$Organism == "cyanobacterium endosymbiont of Epithemia turgida isolate EtSB Lake", "Organism"] <- "cyanobacterium endosymbiont of Epithemia turgida isolate EtSB Lake Yunoko"
jem[!is.na(jem$Organism) & jem$Organism == "Desulfovibrio vulgaris str. Miyazaki F", "Organism"] <- "Desulfovibrio vulgaris str. 'Miyazaki F'"
jem[!is.na(jem$Organism) & jem$Organism == "Flavobacterium psychrophilum JIP02", "Organism"] <- "Flavobacterium psychrophilum JIP02/86"
jem[!is.na(jem$Organism) & jem$Organism == "Fusobacterium nucleatum subsp. animalis 7 1", "Organism"] <- "Fusobacterium nucleatum subsp. animalis 7_1"
jem[!is.na(jem$Organism) & jem$Organism == "Ignicoccus hospitalis KIN4", "Organism"] <- "Ignicoccus hospitalis KIN4/I"
jem[!is.na(jem$Organism) & jem$Organism == "Lawsonia intracellularis PHE", "Organism"] <- "Lawsonia intracellularis PHE/MN1-00"
jem[!is.na(jem$Organism) & jem$Organism == "Leptospira biflexa serovar Patoc strain Patoc 1 (Paris)", "Organism"] <- "Leptospira biflexa serovar Patoc strain 'Patoc 1 (Paris)'"
jem[!is.na(jem$Organism) & jem$Organism == "Listeria seeligeri serovar 1", "Organism"] <- "Listeria seeligeri serovar 1/2b str. SLCC3954"
jem[!is.na(jem$Organism) & jem$Organism == "Methanosarcina siciliae T4", "Organism"] <- "Methanosarcina siciliae T4/M"
jem[!is.na(jem$Organism) & jem$Organism == "Mycobacterium bovis AF2122", "Organism"] <- "Mycobacterium bovis AF2122/97"
jem[!is.na(jem$Organism) & jem$Organism == "Mycoplasma bovoculi M165", "Organism"] <- "Mycoplasma bovoculi M165/69"
jem[!is.na(jem$Organism) & jem$Organism == "Natranaerobius thermophilus JW", "Organism"] <- "Natranaerobius thermophilus JW/NM-WN-LF"
jem[!is.na(jem$Organism) & jem$Organism == "Sodalis glossinidius str. morsitans", "Organism"] <- "Sodalis glossinidius str. 'morsitans'"
jem[!is.na(jem$Organism) & jem$Organism == "Stigmatella aurantiaca DW4", "Organism"] <- "Stigmatella aurantiaca DW4/3-1"
jem[!is.na(jem$Organism) & jem$Organism == "Streptococcus agalactiae 2603V", "Organism"] <- "Streptococcus agalactiae 2603V/R"
jem[!is.na(jem$Organism) & jem$Organism == "Synechococcus sp. JA-2-3Ba(2-13)", "Organism"] <- "Synechococcus sp. JA-2-3B'a(2-13)"

# Map taxonomy ids directly from ncbi db
jem <- merge(jem, nam, by.x="Organism", by.y="name_txt", all.x=TRUE)

# Remove species that could not be mapped (2)
jem <- jem[!is.na(jem$tax_id),]

#update column names to standard for merger
colnames(jem)[which(names(jem) == "Organism")] <- "org_name"
colnames(jem)[which(names(jem) == "rRNA.16S")] <- "rRNA16S_genes"
colnames(jem)[which(names(jem) == "tRNAs")] <- "tRNA_genes"
colnames(jem)[which(names(jem) == "Genome.Length..nt.")] <- "genome_size"
colnames(jem)[which(names(jem) == "Coding.Genes")] <- "coding_genes"
colnames(jem)[which(names(jem) == "Total.Genes")] <- "total_genes"

#update column name for column 2 (contains a symbol that does not work on mac computers)
colnames(jem)[2] <- "genbank.Accession"

# Adding in isolation_source concatenation
cc <- c("Isolation.Source")
jem$isolation_source <- apply(jem[cc], 1, function(x) paste(x[!is.na(x)], collapse = ", "))
jem$isolation_source <- tolower(jem$isolation_source)

#Reduce to needed columns
jem2 <- jem[,c("tax_id","genbank.Accession","org_name","name_class","rRNA16S_genes","tRNA_genes","genome_size","total_genes","coding_genes","isolation_source")]

#Add reference column - at this stage we only have the genbank accession number to point to the original reference
jem2$reference <- jem2$genbank.Accession
jem2$ref_type <- "genbank_accession"

#Remove any fully duplicated rows
jem2 <- unique(jem2[, names(jem2)])

# Save master data
write.csv(jem2, "output/prepared_data/jemma-refseq.csv", row.names=FALSE)

print("Done", quote = FALSE)