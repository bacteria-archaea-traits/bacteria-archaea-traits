# Schulz & Jorgensen 2001

# Open original dataset
sj <- read.csv("data/raw/schulz-jorgensen/schulz-jorgensen_table1.csv", as.is = TRUE)
#Fix potential name issue
names(sj)[1] <- "Organism"
sj[sj == ""] <- NA


#Correct names according to NCBI taxonomy browser
sj$Organism[sj$Organism == "Beggiatoa spp."] <- "Beggiatoa sp."
sj$Organism[sj$Organism == "Thermodiscus sp."] <- "uncultured Thermodiscus sp."

#Sort out sizes: If one value is listed this is the diameter of a sphere, if two, it is the length and heigh of disc shaped cell in filament

sj$d1_lo <- NA
sj$d2_lo <- NA

for(i in 1:nrow(sj)) {
  #Get values and sort smaller to larger - we define the smallest value as d1.
  tmp <- sort(as.numeric(unlist(strsplit(sj$Size[i], "x"))))
  sj$d1_lo[i] <- tmp[1]
  if(length(tmp) == 2) {
    sj$d2_lo[i] <- tmp[2]
  } 
}

names(sj) <- tolower(names(sj))

sj2 <- sj %>% inner_join(nam, by = c("organism" = "name_txt")) %>%
  rename(org_name = organism) %>%
  mutate(ref_type = "full_text") %>% 
  select(tax_id,org_name,cell_shape,d1_lo,d2_lo,reference,ref_type)

write.csv(sj2, "output/prepared_data/schulz-jorgensen.csv", row.names = FALSE)
