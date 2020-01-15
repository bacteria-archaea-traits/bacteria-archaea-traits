# FAPROTAX.txt

print("Processing data-set 'faprotax'...", quote = FALSE)

# Open original dataset
fap <- readLines("data/raw/faprotax/FAPROTAX.txt")

fap <- fap[!grepl("^#.*", fap)] # commented text
fap <- fap[!grepl("^\\s*$", fap)] # blank lines

store <- data.frame()

for (i in 1:length(fap)) {
  if (grepl("^\\*.*$", fap[i])) {
    temp <- strsplit(fap[i], "\t.*\\# ")[[1]]
    species <- trim(gsub("\\*", " ", temp[1]))
    ref <- temp[2]
    store <- rbind(store, data.frame(species, group, subgroup=NA, ref, note))
  } else {
    if (grepl("^add_group.*$", fap[i])) {
      grp <- gsub("add_group:", "", fap[i])
      grp <- trim(strsplit(grp, "\t")[[1]][1])
      
      chunk <- store[store$group==grp,]
      chunk$subgroup <- chunk$group
      chunk$group <- group
      store <- rbind(store, chunk)
    } else {
      temp <- strsplit(fap[i], "\t")[[1]]
      group <- trim(temp[1])
      note <- temp[2]
    }
  }
}


#Save file
write.csv(store, "output/prepared_data/faprotax.csv", row.names=FALSE)

print("Done", quote = FALSE)