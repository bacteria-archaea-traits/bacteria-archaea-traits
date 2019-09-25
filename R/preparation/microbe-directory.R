# microbe-directory data extraction

print("Processing data-set 'microbe-directory'...", quote = FALSE)

# Open original dataset, with a series of errors
mid <- read.csv("data/raw/microbe-directory/microbe-directory.csv", as.is=TRUE)

#update column names to standard for merger
colnames(mid)[which(names(mid) == "species")] <- "org_name"
colnames(mid)[which(names(mid) == "gram_stain")] <- "gram_stain"
colnames(mid)[which(names(mid) == "spore_forming")] <- "sporulation"
colnames(mid)[which(names(mid) == "optimal_temperature")] <- "optimum_tmp"
colnames(mid)[which(names(mid) == "optimal_ph")] <- "optimum_ph"

#Restrict output to kingdom Bacteria and Archaea
mid2 <- mid[mid$kingdom %in% c("Bacteria","Archaea"),]

#Some recorded pH values are nonsense. For instance for Hoeflea phototrophica, where optimal pH is listed as -1.5.
#Litterature states optimal pH is betweeen 6-9. Optimal tmp for this organism is correct though. Maybe only include this?

mid2[!is.na(mid2$optimum_ph) & mid2$optimum_ph < 0,"optimal_ph"] <- NA

# Map taxonomy ids directly from ncbi db
mid3 <- merge(mid2, nam, by.x="org_name", by.y="name_txt", all.x=TRUE)

#Select required columns
mid4 <- mid3[,c("tax_id","org_name","name_class","sporulation","gram_stain","optimum_tmp","optimum_ph")]

# Remove rows with no matching tax_id
mid4 <- mid4[!is.na(mid4$tax_id),]

#Remove any fully duplicated rows
mid4 <- unique(mid4[, names(mid4)])


mid4$ref_type <- "doi"
mid4$reference <- "doi.org/10.12688/gatesopenres.12772.1"

#Save output
write.csv(mid4, "output/prepared_data/microbe-directory.csv", row.names=FALSE)

print("Done", quote = FALSE)
