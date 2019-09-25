# Corkrey

print("Processing data-set 'corkrey'...", quote = FALSE)

# Get data
cor <- read_csv("data/raw/corkrey/journal.pone.0153343.s004.CSV")
ref <- read_csv("data/raw/corkrey/corkrey_refs.csv")
ref_map <- read_csv("data/raw/corkrey/tabula-journal.pone.0153343.s003.csv")

cor2 <- cor %>% 
  inner_join(nam, by=c("binomial.name"="name_txt")) %>%
  select(-unique_name, -name_class) %>%
  inner_join(tax, by="tax_id") %>% # This is here to remove any non-prokaryote species from the table
  left_join(ref_map, by=c("strain.code"="Code")) %>%
  left_join(ref, by=c("Lit."="ref_code")) %>%
  select(tax_id, species_tax_id, binomial.name, T.C, rate.per.minute, aero, trophy, reference) %>%
  mutate(ref_type="full_text") %>% 
  group_by(species_tax_id) %>% # Grab max growth rate value for each species
  filter(rate.per.minute == max(rate.per.minute)) %>%
  distinct(species_tax_id, .keep_all = TRUE) %>%
  mutate(doubling_h=round((log(2)/(rate.per.minute))/60, 2)) %>%
  mutate(growth_tmp=round(T.C, 1)) %>% 
  mutate(trophy=replace(trophy, trophy=="U", NA)) %>%
  rename(metabolism=aero) %>%
  rename(org_name=binomial.name) %>% 
  ungroup() %>%
  select(tax_id, org_name, growth_tmp, metabolism, trophy, doubling_h, reference, ref_type)

#Save data
write.csv(cor2, "output/prepared_data/corkrey.csv", row.names=FALSE)

print("Done", quote = FALSE)