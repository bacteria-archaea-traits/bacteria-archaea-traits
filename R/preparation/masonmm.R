# Mason MM 1935 data set (growth rates)

print("Processing data-set 'masonmm'...", quote = FALSE)

# Get data
mas <- read.csv("data/raw/masonmm/masonmm.csv", as.is=TRUE)

# Calculate doubling times in hours
mas$doubling_h <- as.numeric(mas$generation_time_min/60)

# Map taxonomy ids directly from ncbi db
mas <- merge(mas, nam, by.x="mw_ncbi_name", by.y="name_txt", all.x=TRUE)

# Remove rows with no tax id
mas <- mas[!is.na(mas$tax_id),]

# Remove columns no longer needed
mas <- subset(mas, select=-c(unique_name))

# Change column names to standard
colnames(mas)[which(names(mas) == "original_name")] <- "org_name"
colnames(mas)[which(names(mas) == "growth_temperature")] <- "growth_tmp"
colnames(mas)[which(names(mas) == "org_ref")] <- "reference"

# Keep only needed columns
mas2 <- mas[,c("tax_id","org_name","doubling_h","growth_tmp","reference")]

#Add reference type column
mas2$ref_type <- "full_text"

#Save output
write.csv(mas2, "output/prepared_data/masonmm.csv", row.names=FALSE)

print("Done", quote = FALSE)