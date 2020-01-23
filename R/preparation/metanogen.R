# Metanogen data extraction

# Open original dataset
met <- read.csv("data/raw/metanogen/metanogen.biotech.uni.wroc.csv", as.is=TRUE)

met$optimum_tmp <- NA
met$optimum_ph <- NA
for(i in 1:nrow(met)) {
  met$optimum_tmp[i] <- met$Min..optimal.growth.temp[i] + (met$Max..optimal.growth.temp.[i] - met$Min..optimal.growth.temp[i])/2
  met$optimum_ph[i] <- met$Min..optimal.growth.pH[i] + (met$Max..optimal.growth.pH[i] - met$Min..optimal.growth.pH[i])/2
}

#Fix carbon source column names
colnames(met)[which(names(met) == "X1.butanol")] <- "1-butanol"
colnames(met)[which(names(met) == "X2.butanol")] <- "2-butanol"
colnames(met)[which(names(met) == "X2.propanol")] <- "2-propanol"
colnames(met)[which(names(met) == "Isobutanol")] <- "isobutanol"
colnames(met)[which(names(met) == "Acetate")] <- "acetate"
colnames(met)[which(names(met) == "Butanol")] <- "butanol"
colnames(met)[which(names(met) == "Carbon.Monoxide")] <- "carbon_monoxide"
colnames(met)[which(names(met) == "Cyclopentanol")] <- "cyclopentanol"
colnames(met)[which(names(met) == "Dimethylamine")] <- "dimethylamine"
colnames(met)[which(names(met) == "Dimethyl.sulfide")] <- "dimethyl_sulfide"
colnames(met)[which(names(met) == "Ethanol")] <- "ethanol"
colnames(met)[which(names(met) == "Methanol")] <- "methanol"
colnames(met)[which(names(met) == "Methylamine")] <- "methylamine"
colnames(met)[which(names(met) == "Propanol")] <- "propanol"
colnames(met)[which(names(met) == "Propionate")] <- "propionate"
colnames(met)[which(names(met) == "Trimethylamine")] <- "trimethylamine"
colnames(met)[which(names(met) == "H2.CO2")] <- "H2_CO2"
colnames(met)[which(names(met) == "H2.methanol")] <- "H2_methanol"

#For carbon source columns, replace 'no data' and 'no' with NA and 'yes' with the name of the column
carbon_cols <- c("1-butanol","2-butanol","2-propanol","isobutanol","acetate","butanol","carbon_monoxide","cyclopentanol",
                 "dimethylamine","dimethyl_sulfide","ethanol","methanol","methylamine","propanol","propionate","trimethylamine",
                 "H2_CO2","H2_methanol")

for(i in 1:length(carbon_cols)) {
  col <- carbon_cols[i]
  met[,col] <- ifelse(met[,col] %in% c("Yes","yes"), col, NA)
}

# Combine carbon substrate columns to one 
met$carbon_substrates <- apply(met[, carbon_cols], 1, function(i){ paste(na.omit(i), collapse = ", ") })

#Grab required columns
met <- met[c("Name", "Cell.shape", "Gram.reaction", "Motility", "carbon_substrates", "DSM.strain.number", "Growth.doubling.time..h.", "Min..cell.width", "Max..cell.width", "Min..cell.length", "Max..cell.length", "Description","optimum_tmp","optimum_ph","Main.publication")]
met$carbon_substrates[met$carbon_substrates == ""] <- NA

#Rename all columns
cols <- c("org_name", "cell_shape", "gram_stain", "motility", "carbon_substrates", "DSM.strain.number", "doubling_h", "d1_lo", "d1_up", "d2_lo", "d2_up", "environment","optimum_tmp","optimum_ph","reference")
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
met$pathways <- "methanogenesis"


# Add in isolation_source concatenation
cc <- c("environment")
met$isolation_source <- apply(met[cc], 1, function(x) paste(x[!is.na(x)], collapse = ", "))
met$isolation_source <- tolower(met$isolation_source)

write.csv(met, "output/prepared_data/methanogen.csv", row.names=FALSE)
