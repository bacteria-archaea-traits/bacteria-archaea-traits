# Edwards

# Open original dataset and citation table
edw <- read_csv("data/raw/edwards/Table1.csv")
edw_cit <- read_csv("data/raw/edwards/Table2.csv")
edw_vol <- read_csv("data/raw/edwards/Table3.csv")

# Only include cyanobacteria
edw2 <- edw %>%
  filter(taxon=="cyano") %>%
  mutate(mu=pmax(mu_amm, mu_nit, mu_p, na.rm=TRUE)) %>%
  select(species, isolate, taxon, temperature, irradiance, light_hours, synonym, volume, mu, citation, system) %>%
  mutate(system=replace(system, system=="marine", "seawater")) %>%
  left_join(edw_cit, by=c("citation"="citation_number")) %>%
  mutate(ref_type="full_text") %>% 
  filter(!is.na(mu)) %>%
  group_by(species) %>% 
  filter(mu == max(mu)) %>%
  mutate(doubling_h = 24 * (log(2) / mu)) %>%
  left_join(nam, by=c("species"="name_txt")) %>%
  rename(org_name=species) %>%
  rename(growth_tmp=temperature) %>%
  rename(isolation_source=system) %>%
  rename(reference=full_citation) %>%
  select(tax_id, org_name, doubling_h, growth_tmp, irradiance, isolation_source, reference, ref_type)
  
#Save master data
write.csv(edw2, "output/prepared_data/edwards.csv", row.names=FALSE)