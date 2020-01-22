# Silva data preparation
# Source of growth rates

# Open original dataset
sil <- read.csv("data/raw/silva/data_silva_DN070917.csv", as.is=TRUE)

#Load references
sil_refs <- read.csv("data/raw/silva/Silva_refs.csv", as.is=TRUE)
sil_DN_refs <- read.csv("data/raw/silva/DN_refs.csv", as.is=TRUE)

#Create tmp columns for reference text
sil$sil_ref_fulltext <- NA
sil$DN_ref_fulltext <- NA


########################
# SORTING OUT REFERENCES

# Note: all DN references should be retained and replace any silva references
# for the given organism

#Remove brackets from reference ids 
sil$Vieira.Silva_d_reference <- gsub("\\[|\\]", "", sil$Vieira.Silva_d_reference)
sil$Vieira.Silva_d_reference <- as.integer(sil$Vieira.Silva_d_reference)

sil$DN_new_ref <- gsub("\\[|\\]", "", sil$DN_new_ref)
sil$DN_new_ref <- as.integer(sil$DN_new_ref)

#Sil references are combined ids, text string and DOI
#Need to split ids and DOIs out from main string

#Get reference id
sil_refs$id <- as.integer(NA)
sil_refs$id <- str_extract(sil_refs$full_text, "[^\\.]+")
sil_refs$id <- as.integer(sil_refs$id)

#Remove reference id from main string
sil_refs$full_text <- gsub("^.*?\\.","",sil_refs$full_text)

#Merge reference into main data frame
sil <- sil %>% left_join(sil_refs, by = c("Vieira.Silva_d_reference" = "id"))
#Change name of column
colnames(sil)[which(names(sil) == "full_text")] <- "silva_ref"

#Merge DN references into main data frame 
#(since we want to retain all of these references, make this the main reference column)
sil <- sil %>% left_join(sil_DN_refs, by = c("DN_new_ref"="id"))
colnames(sil)[which(names(sil) == "full_text")] <- "reference"

#Fill silvas references where there is none in the main reference column
sil$reference[is.na(sil$reference)] <- sil$silva_ref[is.na(sil$reference)]

########################

sil <- sil[c("ncbi_species", "species", "Vieira.Silva_d.h.", "DN_d.h.","DN_growth_tmp_C","reference")]

#Add taxonomy ID
sil2 <- merge(sil, nam, by.x="ncbi_species", by.y="name_txt", all.x=TRUE)

#Remove species that could not be mapped (2)
sil2 <- sil2[!is.na(sil2$tax_id),]

# Remove columns no longer needed
sil2 <- subset(sil2, select=-c(unique_name,Vieira.Silva_d.h.,species))

#Rename columns
names(sil2) <- c("org_name","doubling_h","growth_tmp","reference","tax_id","name_class")

#Add reference type column
sil2$ref_type <- "full_text"

# Save master data
write.csv(sil2, "output/prepared_data/silva.csv", row.names=FALSE)