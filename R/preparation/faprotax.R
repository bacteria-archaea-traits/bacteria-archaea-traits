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

store2 <- store1[store1$species %in% nam$name_txt,]
dim(store2)

store3 <- merge(store2, nam[c("tax_id", "name_txt" )], by.x="species", by.y="name_txt", all.x=TRUE, sort=FALSE)
dim(store3)

# This shows a species that's being categorsied in multiple ways
store3[store3$species=="Methanoperedens nitroreducens",]

#Save file
write.csv(store3, "output/prepared_data/faprotax.csv", row.names=FALSE)
