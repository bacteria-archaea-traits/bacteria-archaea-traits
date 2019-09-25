# BacDive - Microaerophiles only!
print("Processing data-set 'bacdive-microa'...", quote = FALSE)

# Open original dataset, combine all cells into one long vector, clean and attempt to extract species names (i.e., strings >10 characters)
# bac <- read_csv("data/raw/bacdive-microa/bacdive-microa.csv", local = locale(encoding = "latin1"))
bac <- readLines("data/raw/bacdive-microa/bacdive-microa.csv")

# bac <- c(t(bac))
bac <- bac[bac != ""]
bac <- gsub("\"", "", bac)
bac <- gsub("DSM [1-9]|[0-9]|KCTC|CIP|CCUG|LMG|JCM|NCTC|NCDO|ATCC [A-Z]*|攼㸹", "", bac) 
bac <- unlist(strsplit(bac, ";"))
# bac <- bac[nchar(bac) > 10]
bac <- unique(bac)

# Add metabolism
bac <- data.frame(org_name=bac, metabolism="microaerophilic")

# Merge tax_id, this step removes junk strings not caught above.
bac <- bac %>% left_join(nam, by=c("org_name"="name_txt")) %>%
  select(tax_id, org_name, metabolism) %>%
  filter(!is.na(tax_id))

#Add reference
bac <- bac %>% mutate(ref_type = "doi", reference = "doi.org/10.1093/nar/gky879") 

#Save master data
write.csv(bac, "output/prepared_data/bacdive-microa.csv", row.names=FALSE)

print("Done", quote = FALSE)
