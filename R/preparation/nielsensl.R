# Nielsen SL. 2006 data extraction
# Note: Sizes is given in micrometre, growth rate is given in d-1 

print("Processing data-set 'nielsensl'...", quote = FALSE)

# Open original dataset
library("readxl")
nie = read_xlsx("data/raw/nielsensl/Cyano.xlsx")
refs = read_xlsx("data/raw/nielsensl/nielsensl_refs.xlsx")

#convert chr to numeric
nie$Growthrate <- as.numeric(nie$Growthrate)
nie$Size <- as.numeric(nie$Size)

#Fix species naming (based on ncbi taxonomy browser search)
nie$Species[nie$Species == "Gloeobacter violacea"] <- "Gloeobacter violaceus"
nie$Species[nie$Species == "Synechococcus leopoliensis"] <- "Synechococcus leopoliensis"

#Extract data
nie2 <- nie %>% slice(2:n()) %>% 
  filter(Type == "Unicell") %>% 
  group_by(Species) %>% 
  filter(Growthrate == max(Growthrate, na.rm = TRUE)) %>%
  mutate(doubling_h = 24 * (log(2) / Growthrate)) %>%
  left_join(nam, by=c("Species"="name_txt")) %>%
  filter(!is.na(tax_id)) %>%
  rename(ref_id=Reference) %>%
  left_join(refs, by = "ref_id") %>%
  mutate(ref_type = "full_text") %>%
  rename(org_name=Species) %>% 
  rename(d1_lo=Size) %>% 
  select(tax_id, org_name, doubling_h, d1_lo, reference, ref_type)

#Save master data
write.csv(nie2, "output/prepared_data/nielsensl.csv", row.names=FALSE)

print("Done", quote = FALSE)