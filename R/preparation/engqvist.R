# Engqvist

eng <- read_tsv(file = "data/raw/engqvist/temperature_data.tsv")

eng2 <- eng %>%
  filter(domain %in% c("Bacteria", "Archaea")) %>%
  select(taxid, organism, temperature) %>%
  group_by(taxid) %>%
  filter(!duplicated(temperature)) %>% # As we cannot tell whether multiple identical numbers reported within a given species is a result of entry duplication from different sources, we keep only unique numbers per species (taxid)
  rename(org_name=organism) %>%
  rename(tax_id=taxid) %>%
  rename(growth_tmp=temperature)
  
eng2$ref_type <- "doi"
eng2$reference <- "doi.org/10.1186/s12866-018-1320-7"

# Save master data
write.csv(eng2, "output/prepared_data/engqvist.csv", row.names=FALSE)