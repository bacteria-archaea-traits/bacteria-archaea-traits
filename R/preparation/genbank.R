# Genbank data extraction
# This data frame is created from two individual datasets downloaded from genbank. See readme for details.

# Note: These two data frames contain mostly the same information, but are joined to include reference information

# Read datasets
gen1 <- read_delim("data/raw/genbank/prokaryotes_ftp.txt", delim="\t", na = c("", "NA", "-"), ) %>%
  filter(Status %in% c("Complete Genome"))

gen2 <- read_csv("data/raw/genbank/prokaryotes_browser.csv") %>%
  filter("#Organism Name" != "candidate division") %>% #Remove odd organisms
  mutate(tRNA=replace(tRNA, tRNA==0, NA)) # There are multiple species with 0 tRNA genes listed. This is not possible. Change to NA

gen <- gen1 %>%
  inner_join(gen2, by=c("BioProject Accession"="BioProject", "BioSample Accession" = "BioSample")) %>%
  select(TaxID, "Organism/Name", Strain.x, "BioProject Accession", "BioSample Accession", "Size (Mb)", "GC%", Genes.x, Proteins, tRNA, Host, "RefSeq category", Status, "FTP Path") %>%
  rename(tax_id=TaxID, org_name="Organism/Name", strain=Strain.x, bioproject_id="BioProject Accession", biosample_id="BioSample Accession", genome_size="Size (Mb)", gc_content="GC%", total_genes=Genes.x, coding_genes=Proteins, tRNA_genes=tRNA, host=Host, RefSeq_category="RefSeq category", genome_status=Status, ftp_path="FTP Path", reference="BioProject Accession") %>%
  mutate(ref_type="bioproject_id") %>%
  mutate(genome_size=genome_size*1000000)


# References

# gen$reference[gen$reference == "A"] <- NA
# gen$reference <- gsub(",", "", gen$reference)
# gen$reference <- substring(gen$reference, 1, 8)
# gen$reference2 <- NA
# 
# gen <- read_csv("output/prepared_data/genbank.csv")
# 
# temp <- gen$reference[gen$tax_id==176280]
# 
# for (i in 1717:length(gen$reference)) {
#   if (!is.na(gen$reference[i])) {
#     temp <- gen$reference[i]
#     dois <- getURL(paste0("https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=pubmed&id=", temp, "&api_key=f95295d3776cb3f4c33f3423721a314a0807"))
#     dois <- strsplit(dois, "\n|\t")[[1]]
# 
#     reg <- dois[grepl('DOI', dois)]
#     if (length(reg) == 0) {
#       temp <- substring(temp, 1, 7)
# 
#       dois <- getURL(paste0("https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=pubmed&id=", temp, "&api_key=f95295d3776cb3f4c33f3423721a314a0807"))
#       dois <- strsplit(dois, "\n|\t")[[1]]
# 
#       reg <- dois[grepl('DOI', dois)]
# 
#     }
# 
#     if (length(reg) > 0) {
#       gen$reference2[i] <- strsplit(reg, "<|>")[[1]][3]
#     }
#   }
# }


# refs <- gen$reference[!is.na(gen$reference)]

# dois <- getURL(paste0("https://www.ncbi.nlm.nih.gov/pmc/utils/idconv/v1.0/?ids=", paste0(refs[1:10], collapse=",")))
# dois <- xmlParse(dois)
# 
# #https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&term=12024217
# 
# removeNodes(dois[names(dois) == "live"])
# 
# do.call("rbind", xpathApply(dois, "//record", function(x) 
#   data.frame(reference=as.numeric(xmlAttrs(x)[["requested-id"]]), DOI=as.numeric(xmlAttrs(x)[["pmid"]])))
# )

  #   paste0(refs, collapse=",")


# #Remove odd pubmed ids (formatted as multiple numbers separated by commas)
# #Remove any reference with a comma
# gen4$reference[!is.na(gen4$reference) & grepl(',',gen4$reference)] <- NA
# gen4$ref_type[is.na(gen4$reference)] <- NA
# 
# #Make genome size into full value
# gen4$genome_size <- gen4$genome_size*1000000
# 
# #Convert character fields to numeric
# gen4$gc_content <- as.numeric(as.character(gen4$gc_content))
# gen4$total_genes <- as.numeric(as.character(gen4$total_genes))
# gen4$coding_genes <- as.numeric(as.character(gen4$coding_genes))
# gen4$tRNA_genes <- as.numeric(as.character(gen4$tRNA_genes))
# 


write.csv(gen, "output/prepared_data/genbank.csv", row.names=FALSE)