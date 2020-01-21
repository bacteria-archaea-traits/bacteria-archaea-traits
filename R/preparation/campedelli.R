# Campedelli

# Open original dataset
cam <- read_csv("data/raw/campedelli/campedelli.csv")

cam$species <- trimws(cam$species)

cam[!is.na(cam$species) & cam$species == "Lactobacilllus capillatus", "species"] <- "Lactobacillus capillatus"
cam[!is.na(cam$species) & cam$species == "Lactobacilus kitasatonis", "species"] <- "Lactobacillus kitasatonis"

cam2 <- cam %>% left_join(nam, by=c("species"="name_txt")) %>%
  rename(org_name=species) %>%
  rename(growth_tmp=temperature) %>% 
  select(tax_id,org_name,isolation_source,metabolism,growth_tmp) %>% 
  mutate(ref_type = "doi", reference = "doi.org/10.1128/AEM.01738-18") %>%
  mutate(isolation_source = tolower(isolation_source))


#Save master data
write.csv(cam2, "output/prepared_data/campedelli.csv", row.names=FALSE)