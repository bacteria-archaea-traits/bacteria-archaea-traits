# Amend & Shock

#Load list of species and reaction ids
sp <- read.csv("data/raw/amend-shock/amend&shock2001_species.csv", as.is=TRUE)
#Load references
ref <- read.csv("data/raw/amend-shock/amend&shock2001_references.csv", as.is=TRUE)
#Load reactions
rec <- read.csv("data/raw/amend-shock/amend&shock2001_reactions.csv", as.is=TRUE)
#Load table of species cross referenced to reactions
mi <- read.csv("data/raw/amend-shock/amend&shock2001_species_reactions.csv", as.is=TRUE)
#Load table with manually translated species names (from short form in original publication to full form)
tbl <- read.csv("data/raw/amend-shock/amend&shock2001_namefix.csv", as.is=TRUE)


# Extract all species from lists

#Note: The list to be processed is quite messy with commas missing and many references not clearly linked to specific species. Therefore,
#only references that can be clearly connected with a specific species is extracted. This inevitably leaves out many original references, 
#but is considered for now to be the best way forward with respect to ensuring correct referencing as well as saving time.

mi2 <- mi[0,]
mi2$name <- as.character()
mi2$note <- as.character()
mi2$ref <- as.character()

for(i in 1:nrow(mi)){
  
  add_note <- FALSE
  note <- NA
  
  #Split string into elements at comma
  tmp <- NA
  
  #Check if string contains a note
  if(length(unlist(strsplit(mi$organisms[i],":"))) > 1) {
    add_note <- TRUE
    note <- trimws(unlist(strsplit(mi$organisms[i],":"))[1])
    #Move rest to tmp (without note info)
    tmp <- trimws(unlist(strsplit(mi$organisms[i],":"))[2])
    #Split remaining string
    tmp <- trimws(unlist(strsplit(tmp,",")))
  } else {
    #Split whole string
    tmp <- trimws(unlist(strsplit(mi$organisms[i], ",")))
  }
  
  #sort out each element into respective columns
  for(a in 1:length(tmp)) {
    
    #Add row
    mi2[nrow(mi2)+1,] <- NA
    
    #Add id
    mi2$id[nrow(mi2)] <- mi$id[i]
    #Add original text
    mi2$organisms[nrow(mi2)] <- mi$organisms[i]
    #Add note
    if(add_note == TRUE) {
      mi2$note[nrow(mi2)] <- note
    }
    
    #Split out any references 
    #(sometimes multiple organisms in list without commas but separeted by references)
    if(length(unlist(strsplit(tmp[a],"\\]"))) > 1) {
      
      tmp2 <- unlist(strsplit(tmp[a],"\\]"))
      
      for(b in 1:length(tmp2)) {
        
        #Add row
        if(b > 1) {
          mi2[nrow(mi2)+1,] <- NA
        }
        
        #Add id
        mi2$id[nrow(mi2)] <- mi$id[i]
        #Add original text
        mi2$organisms[nrow(mi2)] <- mi$organisms[i]
        #Add note
        if(add_note == TRUE) {
          mi2$note[nrow(mi2)] <- note
        }
        
        mi2$name[nrow(mi2)] <- unlist(strsplit(tmp2[b],"\\["))[1]
        mi2$ref[nrow(mi2)] <- unlist(strsplit(tmp2[b],"\\["))[2]
        
      }
      
    } else {
      
      #only one item in this list (as there should be)
      
      #Check if string contains reference info
      if(length(unlist(strsplit(tmp[a],"\\["))) > 1) {
        mi2$name[nrow(mi2)] <- unlist(strsplit(tmp[a],"\\["))[1]
        mi2$ref[nrow(mi2)] <- sub("]","",unlist(strsplit(tmp[a],"\\["))[2])
      } else {
        mi2$name[nrow(mi2)] <- tmp[a]
      }
      
    }
  }
}

mi2$name <- str_squish(mi2$name)


#Translate short names to full

#First use names from publication
#Combine genus and species name
sp$org <- sprintf("%s %s", sp$Genus,sp$Species)
sp$org <- str_squish(sp$org)
sp$short <- sprintf("%s. %s",substr(sp$Genus,0,1),sp$Species)
#Remove funny white space that doesn't go away with trimws
sp$short <- str_squish(sp$short)
#Match short names
mi3 <- mi2 %>% left_join(sp, by = c("name"="short"))
#Transfer full names
mi3$name[!is.na(mi3$org)] <- mi3$org[!is.na(mi3$org)]
mi3 <- mi3[,1:5]

#Translate remaining using lookup table
mi4 <- mi3 %>% left_join(tbl, by = c("name"))
mi4$name[!is.na(mi4$full_name)] <- mi4$full_name[!is.na(mi4$full_name)]
mi4 <- mi4[,1:5]
mi4$name <- str_squish(mi4$name)

#Fix bad names according to NCBI (doesn't retrieve tax id merge)
#Note: A good deal of species could not be confirmd using the NCBI taxonomy browser

mi4$name[mi4$name == "Bacillus Stearothermophilus"] <- "Geobacillus stearothermophilus"
mi4$name[mi4$name == "Desulfotomaculum nigrificans ssp. salinus"] <- "Desulfotomaculum nigrificans"
mi4$name[mi4$name == "Methanobacterium thermoautotrophicus"] <- "Methanothermobacter thermautotrophicus"
mi4$name[mi4$name == "Methanococcus fervens (AG86)"] <- "Methanocaldococcus fervens AG86"
mi4$name[mi4$name == "Pseudomonas strain MT-1"] <- "Pseudomonas sp. MT-1"
mi4$name[mi4$name == "S. barnesii strain SES-3"] <- "Sulfurospirillum barnesii SES-3"
mi4$name[mi4$name == "S. barnesii strain SES-3 ("] <- "Sulfurospirillum barnesii SES-3"
mi4$name[mi4$name == "Sulfolobacillus thermosulfidooxidans"] <- "Sulfobacillus thermosulfidooxidans"
mi4$name[mi4$name == "Sulfurospirillum barnesii strain SES-3"] <- "Sulfurospirillum barnesii SES-3"
mi4$name[mi4$name == "Thiobacillus prosperus"] <- "Acidihalobacter prosperus"

mi5 <- mi4[lengths(strsplit(mi4$name, " ")) == 2,]

mi5 <- mi5 %>% inner_join(nam[,c("name_txt","tax_id")], by = c("name"="name_txt"))
mi5 <- mi5 %>% select(-organisms) %>% 
  distinct(name, id, .keep_all = TRUE)
names(mi5) <- c("reaction_id","org_name","note","ref_id","tax_id")

#Add pathways
mi6 <- mi5 %>% inner_join(rec[,c("id","pathways")], by = c("reaction_id"="id"))

# Sort out references
# Remove all cross reference rows
ref2 <- ref %>% filter(!grepl("Crossref|PubMed|Google",ref$reference))
#Get all ids
for(i in 1:nrow(ref2)) {
  tmp <- unlist(strsplit(ref2$reference[i],"\\]"))
  ref2$id[i] <- gsub("\\[","",tmp[1])
  ref2$reference[i] <- trimws(tmp[2])
}
ref2$ref_type <- "full_text"

#Merge references onto main 
mi7 <- mi6 %>% left_join(ref2, by = c("ref_id"="id")) %>%
  select(-ref_id,-reaction_id)

#Note: this data set also includes informaiton on metabolism (anaerobic or aerobic), heterotrophy or autotrophy and max growth temperature.
#However, this is not included for now.

#Save data 
write.csv(mi7, "output/prepared_data/amend-shock.csv")