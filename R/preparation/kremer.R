# Kremer et al. 2017 data extraction
# Source of growth rates - so only records with max growth rates will be included

print("Processing data-set 'kremer'...", quote = FALSE)

# Open original datasets

#Main data
kre <- read.csv("data/raw/kremer/lno10523-sup-0008-suppinfo8-1.csv", as.is=TRUE)
#Table with full names
kre_names <- read.csv("data/raw/kremer/lno10523-sup-0003-suppinfo3-1.csv", as.is=TRUE)

# Only include cyanobacteria
kre <- kre[kre$group=="Cyanobacteria",]

# Use Name column (full species name) to select max growth rate within species
kre2 <- kre %>% group_by(name) %>% 
  filter(r == max(r, na.rm = TRUE)) %>% 
  filter(row_number() == 1)

# Add full name info from separate table
kre3 <- kre2 %>% inner_join(kre_names, by = "isolate.code")

# keep only needed columns
kre4 <- subset(kre3, select = c(name.y,r,temperature,environment))

# Convert growth rate to doubling time 
# (from suporting info: r = specific growth rate (day^-1))
kre4$r <- log(2)/kre4$r*24

# Rename columns
names(kre4) <- c("org_name","doubling_h","growth_tmp","isolation_source")

# Fix naming issues - fist remove 'strain' from names
kre4$org_name <- gsub("strain ","", kre4$org_name)

# Fix naming issues 
# Selected names could not be found in ncbi taxonomy table, translated to synonym/correct name.
# Note: Some names could not be translated and is left out
kre4$org_name[kre4$org_name=="Anabaena macrospora ST195AS"] <- "Dolichospermum macrosporum"
kre4$org_name[kre4$org_name=="Anabaena ucrainica LBRI 47"] <- "Dolichospermum ucrainicum"
kre4$org_name[kre4$org_name=="Aphanizomenon ovalisporum UAM 290"] <- "Chrysosporum ovalisporum UAM290"
kre4$org_name[kre4$org_name=="Crocosphaera watsonii A 2.5"] <- "Crocosphaera watsonii"
kre4$org_name[kre4$org_name=="Cylindrospermopsis raciborskii ACT-9502"] <- "Cylindrospermopsis raciborskii ATC-9502"
kre4$org_name[kre4$org_name=="Microcystis aeruginosa K-5"] <- "Microcystis aeruginosa UTEX LB 2388"
kre4$org_name[kre4$org_name=="Microcystis viridis N-1"] <- "Microcystis viridis"
kre4$org_name[kre4$org_name=="Prochlorococcus marinus MED4 (clade 2)"] <- "Prochlorococcus marinus"
kre4$org_name[kre4$org_name=="Synechocystis bourrellyi no. 153"] <- "Synechocystis bourrellyi"
kre4$org_name[kre4$org_name=="Trichodesmium erythraeum IMS101, CCMP 1985"] <- "Trichodesmium erythraeum IMS101"

# Add taxonomy ID
kre5 <- merge(kre4, nam, by.x="org_name", by.y="name_txt", all.x=TRUE)

# Remove species that could not be resolved
kre5 <- kre5[!is.na(kre5$tax_id),]

# Subset
kre5 <- subset(kre5, select = -c(unique_name,name_class))

kre5$ref_type <- "doi"
kre5$reference <- "doi.org/10.1002/lno.10523"


#Save file
write.csv(kre5, "output/prepared_data/kremer.csv", row.names=FALSE)

print("Done", quote = FALSE)