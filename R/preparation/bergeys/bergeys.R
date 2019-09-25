# The great Bergey's trait grab

source("R/preparation/bergeys/bergeys_functions_taxonomy.R")
source("R/preparation/bergeys/bergeys_functions_traits.R")

# The ontology was used to create the subsumption hierarchy for shape, but isn't currently used more broadly
# ont <- read_json("data/micro/MicrO.owl")

# Get chapters names from "bergeys" PDF directory
# pdfs <- dir("data/bergeys/genera")
# pdfs <- pdfs[grep("^[g]", pdfs)]

# Files causing problems. Largely green sulfur bacteria (Cyanobacteria), sub-section and formis chapters. This needs revisiting at some point.
# ignore <- c("gbm00378.pdf", "gbm00379.pdf", "gbm00409.pdf", "gbm00410.pdf", "gbm00411.pdf", "gbm00420.pdf", "gbm00422.pdf", "gbm00434.pdf", "gbm00437.pdf", "gbm00451.pdf", "gbm00456.pdf", "gbm00458.pdf", "gbm00460.pdf", "gbm00461.pdf", "gbm00462.pdf", "gbm00465.pdf", "gbm00468.pdf", "gbm00469.pdf", "gbm00470.pdf", "gbm00471.pdf", "gbm01134.pdf")
# pdfs <- pdfs[!(pdfs %in% ignore)]

### GET SPECIES TEXT

# The following files were formatted differently to standard bergeys chapters... They have been reformatted by hand.
# fixes <- c("gbm00001.pdf", "gbm00080.pdf", "gbm00094.pdf", "gbm00202.pdf", "gbm00207.pdf", "gbm00345.pdf", "gbm00492.pdf", "gbm00530.pdf", "gbm00544.pdf", "gbm00555.pdf", "gbm00604.pdf", "gbm00751.pdf", "gbm00781.pdf", "gbm00782.pdf", "gbm00794.pdf", "gbm00795.pdf", "gbm00820.pdf", "gbm00838.pdf", "gbm00892.pdf", "gbm00896.pdf", "gbm00909.pdf", "gbm00927.pdf", "gbm00943.pdf", "gbm00962.pdf", "gbm00991.pdf", "gbm01041.pdf", "gbm01055.pdf", "gbm01071.pdf", "gbm01073.pdf", "gbm01076.pdf", "gbm01077.pdf", "gbm01081.pdf", "gbm01100.pdf", "gbm01116.pdf", "gbm01135.pdf", "gbm01141.pdf", "gbm01150.pdf", "gbm01155.pdf", "gbm01158.pdf", "gbm01159.pdf", "gbm01167.pdf", "gbm01178.pdf", "gbm01204.pdf", "gbm01208.pdf", "gbm01210.pdf", "gbm01215.pdf", "gbm01218.pdf", "gbm01241.pdf", "gbm01266.pdf", "gbm01274.pdf", "gbm01324.pdf", "gbm01326.pdf", "gbm01421.pdf")

# Do not uncomment the following code unless you have spoken with Josh
# txt <- pdf_text(paste0("data/bergeys/genera/", pdf))
# txt <- strsplit(txt, "\n")
# taxa <- get_taxa(txt)
# tally <- get_tally(txt)
# species_tally <- get_species_tally(tally)
# nn <- strsplit(pdf, "\\.")[[1]][1]
# write.table(species_tally, paste0("output/bergeys_fixes/", nn, ".txt"), row.names=FALSE, col.names=FALSE)

### GET SPECIES TEXT

# The following commented code takes a long time, and so shouldn't be run unless the taxonomy functions have been changed
# sdat <- lapply(pdfs, get_species_txt)
# sdat <- do.call("rbind", sdat)
# write.csv(sdat, "output/processed_data/bergeys_species_text2.csv", row.names=FALSE)

### GET SPECIES TRAITS

# Load the species-level text from Bergeys
sdat <- read.csv("data/raw/bergeys/bergeys_species_text.csv", as.is=TRUE)

# Why are the following different?
# length(sdat$species)
# length(unique(sdat$species))
# cbind(sdat$species[duplicated(sdat$species)], sdat$reference[duplicated(sdat$species)])
# sdat$reference[sdat$species=="Alterococcus agarolyticus"]

# The following code extracts traits from bergeys genus-level text. The various functions have been developed to different extents

### GET SOURCE
ssou <- lapply(sdat$text, get_source)
ssou <- do.call("rbind", ssou)

### GET ACCESSION NUMBERS
sacc <- lapply(sdat$text, get_accession)
sacc <- do.call("rbind", sacc)

# TEST ONLY
# for (i in 1:nrow(sdat)) {
# 	get_accession(sdat$text[i])
# }

### GET DIAMETERS
sdia <- lapply(sdat$text, get_diams)
sdia <- do.call("rbind", sdia)

# TEST ONLY
#for (i in 1:nrow(sdat)) {
#	get_diams(sdat$text[i])
#}

### GET DOUBLING TIMES
sdou <- lapply(sdat$text, get_doubling)
sdou <- do.call("rbind", sdou)

### GET SHAPE
# ssha <- lapply(sdat$text, get_shape)
# ssha <- do.call("rbind", ssha)

### GET METABOLISM
smet <- lapply(sdat$text, get_metabolism)
smet <- do.call("rbind", smet)

### GET ENERGY
# sene <- lapply(sdat$text, get_energy)
# sene <- do.call("rbind", sene)

### GET INTRACELLULAR
# sint <- lapply(sdat$text, get_intracellular)
# sint <- do.call("rbind", sint)

### GET PATHOGEN
# spat <- lapply(sdat$text, get_pathogen)
# spat <- do.call("rbind", spat)

# Put the trait data together and save it.

smaster <- data.frame(sdat[c("reference", "genus", "species","text")], sdia, sacc, ssou, sdou, smet)
# smaster <- data.frame(sdat, sdia, sdou, ssha, smet, sene, sint, spat)
write.csv(smaster, "data/raw/bergeys/bergeys_species_master.csv", row.names=FALSE)


###########
# RESOLVE #
###########

# Run from here if above already exists

smaster <- read.csv("data/raw/bergeys/bergeys_species_master.csv", as.is=TRUE)

smaster$d1_lo[!is.na(smaster$d1_lo) & smaster$d1_lo==0] <- NA
smaster$d1_up[!is.na(smaster$d1_up) & smaster$d1_up==0] <- NA

ber_tm <- read.csv("output/taxonomy/taxmap_bergeys.csv", as.is=TRUE)
ber_tm <- subset(ber_tm, select=c(ncbi_species, ncbi_species.1))
ber <- cbind(smaster, ber_tm)

#Merge tax_ids onto data frame based on species name
ber <- merge(ber, nam, by.x="species", by.y="name_txt", all.x=TRUE)

#Try to sort out missing tax_ids
for (i in 1:nrow(ber)) {
	if (is.na(ber$tax_id[i])) {
		if (length(nam$tax_id[nam$name_txt == ber$ncbi_species[i]]) > 0) {
			ber$tax_id[i] <- nam$tax_id[nam$name_txt == ber$ncbi_species[i]]
			ber$unique_name[i] <- nam$unique_name[nam$name_txt == ber$ncbi_species[i]]
			ber$name_class[i] <- nam$name_class[nam$name_txt == ber$ncbi_species[i]]
		} else {
			if (length(nam$tax_id[nam$name_txt == ber$ncbi_species.1[i]]) > 0) {
				ber$tax_id[i] <- nam$tax_id[nam$name_txt == ber$ncbi_species.1[i]]
				ber$unique_name[i] <- nam$unique_name[nam$name_txt == ber$ncbi_species.1[i]]
				ber$name_class[i] <- nam$name_class[nam$name_txt == ber$ncbi_species.1[i]]
			}
		}
	}
}

sum(is.na(ber$tax_id))
ber <- ber[!is.na(ber$tax_id),]

#Rename original name column
colnames(ber)[which(names(ber) == "species")] <- "species_name"

# Remove extra columns that is not needed later
ber <- subset(ber, select=-c(genus,ncbi_species.1,unique_name))

# Merge full phylogeny based on tax_ids
ber <- inner_join(ber, tax, by = "tax_id")


# Correct metabolism information where manually checked and deemed wrong (matches on species name AND metabolism) 
# (see bergeys_metabolism_corrections.csv for notes)
# Note, if bergeys text extraction gets improved, this should be re-evaluated.

metc <- read.csv("R/preparation/bergeys/bergeys_metabolism_corrections.csv", as.is=TRUE)
for(i in 1:nrow(metc)) {
  ber$metabolism[ber$species_name == metc$species[i] & ber$metabolism == metc$old_metabolism[i]] <- metc$new_metabolism[i]
}

# Translate metabolism
# Load translation table
look <- read.csv("data/conversion_tables/renaming_metabolism.csv", as.is=TRUE)
# Convert all words to 
ber$metabolism <- look$New[match(unlist(ber$metabolism), look$Original)]


# Convert all sizes to um based on recorded unit

sizes <- c("d1_lo","d1_up","d2_lo","d2_up")
unit_col <- "diam_unit"

for(i in 1:nrow(ber)) {
  if (!is.na(ber$d1_lo[i]) | !is.na(ber$d1_up[i]) | !is.na(ber$d2_lo[i]) | !is.na(ber$d2_up[i])) {
    for(a in 1:length(sizes)) {
      if (!is.na(ber[i, sizes[a]])) {
        if (!is.na(ber[i, unit_col]) & ber[i, unit_col] != "um") {
          #convert unit
          ber[i, sizes[a]] <- as.double(convert_unit(ber[i, sizes[a]], ber[i, unit_col]))
        }
      }
    }
  }
}

# Make sure that length is always longer than diameter
# Note, we always swap the full set to not mix up ranges

for(i in 1:nrow(ber)) {
  if(!is.na(ber$d1_lo[i]) & !is.na(ber$d2_lo[i]) & ber$d1_lo[i] > ber$d2_lo[i] || !is.na(ber$d1_up[i]) & !is.na(ber$d2_up[i]) & ber$d1_up[i] > ber$d2_up[i]) {
    
    #Check
    #print(sprintf("%s d1_lo: %s > d2_lo: %s OR d1_up: %s > d2_up: %s!",ber$ncbi_species[i],ber$d1_lo[i],ber$d2_lo[i],ber$d1_up[i],ber$d2_up[i]))
    
    #Swap values!
    new_d1_lo <- ber$d2_lo[i]
    new_d1_up <- ber$d2_up[i]
    new_d2_lo <- ber$d1_lo[i]
    new_d2_up <- ber$d1_up[i]
    #Save values
    ber$d1_lo[i] <- new_d1_lo
    ber$d1_up[i] <- new_d1_up
    ber$d2_lo[i] <- new_d2_lo
    ber$d2_up[i] <- new_d2_up
  } 
}


# Remove sizes values if considered too large based on checks of raw data and text extractions
# This is a course exclusion system and should probably be refined in future versions to target
# verified data errors
ber[!is.na(ber$d1_lo) & ber$d1_lo >= 5,"d1_lo"] <- NA
ber[!is.na(ber$d1_up) & ber$d1_up >= 10,"d1_up"] <- NA
ber[!is.na(ber$d2_lo) & ber$d2_lo >= 100,"d2_lo"] <- NA
ber[!is.na(ber$d2_up) & ber$d2_up >= 100,"d2_up"] <- NA

# Remove sizes that are too small
ber[!is.na(ber$d1_lo) & ber$d1_lo < 0.1,"d1_lo"] <- NA
ber[!is.na(ber$d1_lo) & ber$d1_lo < 0.1,"d1_up"] <- NA


# Remove species size values where check shows it is wrong (typically cell wall or phage info)
# Note, if bergeys text extraction gets improved, this should be re-evaluated.

# ber[!is.na(ber$species_name) & ber$species_name == "Methanohalobium evestigatum", c("d1_lo","d1_up","d2_lo","d2_up")] <- NA
# ber[!is.na(ber$species_name) & ber$species_name == "Halomonas halodurans", c("d1_lo","d1_up","d2_lo","d2_up")] <- NA
# ber[!is.na(ber$species_name) & ber$species_name == "Asticcacaulis excentricus", c("d1_lo","d1_up","d2_lo","d2_up")] <- NA
# ber[!is.na(ber$species_name) & ber$species_name == "Caulobacter vibrioides", c("d1_lo","d1_up","d2_lo","d2_up")] <- NA


# Get minimum doubling times and convert to same unit (h-1)
ber$doubling_h <- NA
for(i in 1:nrow(ber)) {
  
  #Swap values if lo>up
  if(!is.na(ber$dt_lo[i]) & !is.na(ber$dt_up[i]) & ber$dt_lo[i] > ber$dt_up[i]) {
    dt_lo <- ber$dt_up[i]
    dt_up <- ber$dt_lo[i]
    ber$dt_lo[i] <- dt_lo 
    ber$dt_up[i] <- dt_up
  }
  
  #Get smallest value
  if(!is.na(ber$dt_lo[i])) {
    ber$doubling_h[i] <- ber$dt_lo[i]
  } 
  
  #Convert to per hours if required
  if(!is.na(ber$dt_unit[i])) {
    if(ber$dt_unit[i] == "days") {
      ber$doubling_h[i] <- ber$doubling_h[i]*24
    } else if(ber$dt_unit[i] == "minutes") {
      ber$doubling_h[i] <- ber$doubling_h[i]/60
    }
  }
  
}

# Remove all rows with no information for the currently relevant traits
cols <- c("metabolism","d1_lo","d1_up","d2_lo","d2_up","doubling_h")
# Remove rows with no categorical data
ber2 <- ber[rowSums(is.na(ber[cols])) != length(cols), ]

# Add internal id 
# This is used for below processing to remove duplicate species
# (this will be removed after duplicate species have been removed)

ber2$int_id <- NA;
for(i in 1:nrow(ber2)) {
  ber2$int_id[i] <- i+1
}


#Bergeys data frame contains some duplicates due to different names for the same organism (species merged into one)
#Here, we simply select the row with the most data available. We don't average or do any other selection on data
#This processing can be removed if bergeys gets included as its own data frame)
#Currently, we simply remove the less informative duplicate species

# Get all duplicated species
dup <- ber2[ber2$species_tax_id %in% ber2[duplicated(ber2$species_tax_id),"species_tax_id"],]
dup_sp <- unique(dup$species)

# Go through each duplicated species
for(i in 1:length(dup_sp)) {
  #Get all information for this species
  info <- dup %>% filter(species == dup_sp[i])
  
  most_info <- 0
  keep <- NA
  
  for(a in nrow(info)) {
    if(rowSums(!is.na(info[a,cols])) > most_info) {
      most_info <- rowSums(!is.na(info[a,cols]))
      keep <- info[a,"int_id"]
    }
  }
  
  #print(sprintf("%s [%sX]: keep row %s [data points: %s]",dup_sp[i],nrow(info),keep,most_info))
  
  #Now the id of the row with the most info for this species have been recorded 
  #(or a row with at least as much info as any other - random selection)
  
  #Remove all other rows for this species in main data frame
  ber2 <- ber2[!(ber2$species == dup_sp[i]) | ber2$int_id == keep,]
}

#Reduce to needed columns
ber2 <- ber2[c("tax_id", "species_tax_id","species_name","species", "reference", "metabolism", "d1_lo", "d1_up", "d2_lo", "d2_up", "doubling_h","accession", "source")]


ber2$reference <- as.vector(outer("doi.org/10.1002/9781118960608", unlist(lapply(strsplit(ber2$reference, "\\."), `[[`, 1)), paste, sep="."))
ber2$ref_type <- "doi"

#Save data frame
write.csv(ber2, "output/prepared_data/bergeys.csv", row.names=FALSE)
