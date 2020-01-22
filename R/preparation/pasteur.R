#Pasteur collection Bacteria

#Note, this data set has a lot of isolation source information, however, 
#for implementation >2000 will need to be translated manually 

# Open original dataset
pas <- read_csv("data/raw/pasteur/Collections_Pasteur.csv")

#Get useful columns without having to bother with problematic column names
pas2 <- pas[,c(3,22,32)]

#Rename columns
names(pas2) <- c("org_name","isolation_source","metabolism")

#Only keep unique combitions of the three columns
pas3 <- pas2 %>% distinct(org_name,isolation_source,metabolism)

#At this point we only include oxygen requirement, so exclude canophiles where no information on oxygen use is included
pas4 <- pas3 %>% filter(metabolism %in% c("Aerobic","Anaerobic","Microaerophilic"))

issues <- c("Surface of Beaufort, G",
            "Surface rind of Beaufort, G",
            "spoiled ciders",
            "Seawater by enrichment with",
            "Bandicoot / ",
            "bandicoot / ")

#fix issues with an isolation source name
pas4[grepl(paste(issues,collapse="|"),pas4$isolation_source),"isolation_source"] <- NA

#Remove duplicated species where no information is given on isolation source
duplicated <- unique(pas4$org_name[duplicated(pas4$org_name)])
pas5 <- pas4 %>% filter(!(org_name %in% duplicated & is.na(isolation_source) )) %>%
  mutate(isolation_source = tolower(isolation_source))

#For some reason, subsp. is not included in organism name.. Add this to allow better match with ncbi 
#This code is far from optimal as it creates several erronous names, has been excluded for now

# for(i in 1:nrow(pas5)) {
#   if(length(unlist(str_split(pas5$org_name[i]," "))) == 3) {
#     
#     words <- trimws(unlist(str_split(pas5$org_name[i]," ")))
#     #words <- as.numeric(words)
#     
#     if(!length(words) > 3 & is.na(as.numeric(words[3]))) {
#       #If the third word starts with a capital, this is a serovar as opposed to a subsp.
#       if(words[3] == toupper(words[3])) {
#         type <- "serovar"
#       } else if (words[3] == tolower(words[3])) {
#         type <- "subsp."
#       } 
#       
#     } else {
#       type <- ""
#     }
#     
#     sp <- c(words[1:2],type,words[3])
#     new <- paste(trimws(sp), collapse = " ")
#     pas5$org_name[i] <- new
#     
#   }
# }

#Match up with tax id from ncbi
pas6 <- pas5 %>% left_join(nam, by=c("org_name"="name_txt")) %>%
  filter(!is.na(tax_id)) %>%
  select(tax_id,org_name,isolation_source,metabolism) 


#Save master data
write.csv(pas6, "output/prepared_data/pasteur.csv", row.names=FALSE)


#Get unique environments not already translated in our environment table
# iso <- read_csv("data/conversion_tables/renaming_isolation_source.csv")
# 
# check <- pas5 %>% filter(!is.na(isolation_source)) %>% 
#   anti_join(iso, by = c("isolation_source" = "Original")) %>% 
#   distinct(isolation_source)