# FAPROTAX.txt

# Open original dataset
fap <- readLines("data/raw/faprotax/FAPROTAX.txt")

fap <- fap[!grepl("^#.*", fap)] # commented text
fap <- fap[!grepl("^\\s*$", fap)] # blank lines

store <- data.frame()

for (i in 1:length(fap)) {
  if (grepl("^\\*.*$", fap[i])) {
    temp <- strsplit(fap[i], "\t.*\\# ")[[1]]
    species <- trim(gsub("\\*", " ", temp[1]))
    reference <- temp[2]
    store <- rbind(store, data.frame(species, pathways, subpathways=NA, reference, note))
  } else {
    if (grepl("^add_group.*$", fap[i])) {
      grp <- gsub("add_group:", "", fap[i])
      grp <- trim(strsplit(grp, "\t")[[1]][1])
      
      chunk <- store[store$pathways==grp,]
      chunk$subpathways <- chunk$pathways
      chunk$pathways <- pathways
        
      store <- rbind(store, chunk)
    } else {
      temp <- strsplit(fap[i], "\t")[[1]]
      pathways <- trim(temp[1])
      note <- temp[2]
    }
  }
}
dim(store)

store1 <- store[!duplicated(store[c("species", "pathways", "subpathways")]),]
dim(store1)

#There are a few errors in the output for pathways where species names are included
#Remove all 'pathways' with * in the name
store1 <- store1 %>% filter(!grepl("\\*|human|pathogen|parasites|symbionts|gut",store1$pathways))

store2 <- store1[store1$species %in% nam$name_txt,]
dim(store2)

#Only include organisms with both genus and species name 
store3 <- store2[lengths(strsplit(store2$species, " ")) == 2,]
dim(store3)

store4 <- merge(store3, nam[c("tax_id", "name_txt" )], by.x="species", by.y="name_txt", all.x=TRUE, sort=FALSE)
dim(store4)

#Add ref_type column
store4$ref_type <- NA

store4$ref_type[grepl("DOI",store4$reference)] <- "doi"
store4$ref_type[grepl("^[0-9]",store4$reference)] <- "doi"
store4$ref_type[!is.na(store4$reference) & is.na(store4$ref_type)] <- "full_text"

# This shows a species that's being categorsied in multiple ways
store4[store4$species=="Methanoperedens nitroreducens",]

store4 <- store4 %>% rename(org_name = species)

#Save file
write.csv(store4, "output/prepared_data/faprotax.csv", row.names=FALSE)
