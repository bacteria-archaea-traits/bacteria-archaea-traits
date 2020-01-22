# MediaDB data extraction

# Open original dataset
med <- read.csv("data/raw/mediadb/media_database.csv", as.is=TRUE)

#Remove columns of non-prokryotic species 
nonprot <- c("Aspergillus", "Komagataella", "Saccharomyces", "Neurospora", "Leishmania", "Candida")
med <- med[!(med$genus %in% nonprot), ]

# Make species org_name column (and trim whitespace)
med$org_name <- trimws(paste(trimws(med$genus), trimws(med$species)))

# Fix naming mistakes in MediaDB
med$org_name[med$org_name=="Neiserria meningitidis"] <- "Neisseria meningitidis"
med$org_name[med$org_name=="Pelagibacter sp"] <- "Candidatus Pelagibacter sp."
med$org_name[med$org_name=="Streptomyces Coelicolor"] <- "Streptomyces coelicolor"

#Add taxonomy ID
med <- merge(med, nam, by.x="org_name", by.y="name_txt", all.x=TRUE)

#Get row with higest growth rate per species
med2 <- med %>% group_by(org_name) %>% 
  arrange(org_name, desc(growth_rate)) %>% 
  filter(row_number() == 1)

# Remove species without doubling time measurements
med2 <- med2[!is.na(med2$growth_rate),]

#Convert growth_rate to doubling time
med2$growth_rate[med2$growth_rate == 0] <- NA
med2$doubling_h <- log(2)/med2$growth_rate

# Remove columns no longer needed
med2 <- subset(med2, select = -c(growth_units,unique_name))

#Change habitat column names to avoid clash with future merging
colnames(med2)[which(names(med2) == "temperature_C")] <- "growth_tmp"

med2$ref_type <- "doi"
med2$reference <- "doi.org/10.1371/journal.pone.0103548"

#Save file
write.csv(med2, "output/prepared_data/mediadb.csv", row.names=FALSE)