# Prochlorococcus data extraction

print("Processing data-set 'prochlorococcus'...", quote = FALSE)

# Open original dataset
pro <- read.csv("data/raw/prochlorococcus/cyano data.csv", as.is=TRUE)
pro_tm <- read.csv("output/taxonomy/taxmap_prochlorococcus.csv", as.is=TRUE)
pro_ref <- read.csv("data/raw/prochlorococcus/cyano data_refs.csv", as.is=TRUE)

# In this data set we're missing actual species names and thus we have to map according to the provided accession number
# We do this using a pre-prepared tax map

pro <- merge(pro, pro_tm, by.x="X16S.accession", by.y="accession", all.x=TRUE)
pro <- pro[!is.na(pro$ncbi_taxid),]

pro <- merge(pro, pro_ref, by.x="growth.rate.reference", by.y="ref_id", all.x=TRUE)
pro$ref_type <- "full_text"

 

pro <- subset(pro, select = c("ncbi_taxid", "name", "X16S.accession", "doubling.time..hrs.", "d1_lo", "d1_up", "d2_lo", "reference", "ref_type"))
names(pro) <- c("tax_id", "org_name", "X16S.accession", "doubling_h", "d1_lo", "d1_up", "d2_lo", "reference", "ref_type" )

#Add isolation_source information - all cyanos listed are from marine water
#The term "seawater" will be translated to water_marine at a later stage
pro$isolation_source <- "seawater"



# Save master data
write.csv(pro, "output/prepared_data/prochlorococcus.csv", row.names=FALSE)

print("Done", quote = FALSE)