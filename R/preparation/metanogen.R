# Metanogen data extraction

# Open original dataset
met <- read.csv("data/raw/metanogen/metanogen.biotech.uni.wroc.csv", as.is=TRUE)

met$optimum_tmp <- NA
met$optimum_ph <- NA
for(i in 1:nrow(met)) {
  met$optimum_tmp[i] <- met$Min..optimal.growth.temp[i] + (met$Max..optimal.growth.temp.[i] - met$Min..optimal.growth.temp[i])/2
  met$optimum_ph[i] <- met$Min..optimal.growth.pH[i] + (met$Max..optimal.growth.pH[i] - met$Min..optimal.growth.pH[i])/2
}

#Grab required columns
met <- met[c("Name", "Cell.shape", "Gram.reaction", "Motility", "DSM.strain.number", "Growth.doubling.time..h.", "Min..cell.width", "Max..cell.width", "Min..cell.length", "Max..cell.length", "Description","optimum_tmp","optimum_ph","Main.publication")]

#Rename all columns
cols <- c("org_name", "cell_shape", "gram_stain", "motility", "DSM.strain.number", "doubling_h", "d1_lo", "d1_up", "d2_lo", "d2_up", "environment","optimum_tmp","optimum_ph","reference")
names(met) <- cols

#Add reference type column
met$ref_type <- "full_text"

# MAUNUAL FIX DATA ERRORS
# Methanococcus maripaludis optimum growth temperature is ~38C and not 85C as listed in this table
met[!is.na(met$org_name) & met$org_name %in% c("Methanococcus maripaludis"),"optimum_tmp"] <- 38

# Map taxonomy ids directly from ncbi db
met <- merge(met, nam, by.x="org_name", by.y="name_txt", all.x=TRUE)

# Remove redundant columns
met <- subset(met, select = -c(unique_name))

# Add column for oxygen requirement (this data frame only contains methanogenic archaea, so all anaerobic)
met$metabolism <- "Anaerobic"

#Add column for process (this data frame only contains methanogenic organisms)
#This may later be expanded to take into account the substrate use information (H2/CO2 etc)
met$processes <- "methanogenesis"

# Add in isolation_source concatenation
cc <- c("environment")
met$isolation_source <- apply(met[cc], 1, function(x) paste(x[!is.na(x)], collapse = ", "))
met$isolation_source <- tolower(met$isolation_source)

write.csv(met, "output/prepared_data/methanogen.csv", row.names=FALSE)