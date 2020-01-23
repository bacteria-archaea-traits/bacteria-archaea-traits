# Fierer data extraction

# Open corrected dataset 
# Note: this dataset was received from source with various corrections of excel number conversion issues,
# However, the corrected dataset turned out to be missing a significant proportion of relevant data. 
# Therefore, we back track and instead work with the uncorrected version, fixing issues as we go)
#ijsem <- read.csv("data/fierer/ijsem_05_05_15_clean_fixed.csv", check.names=F, fill=T, na.strings=c("NA", "", "Not indicated", " Not indicated","not indicated", "Not Indicated", "n/a", "N/A", "Na", "Not given", "not given","Not given for yeasts", "not indicated, available in the online version", "Not indicated for yeasts", "Not Stated", "Not described for yeasts", "Not determined", "Not determined for yeasts"))

#Daniel 31/07/2018
# Note: Some 16sRNA such as DQ855376 points to the wrong species, resulting in errors when we use the taxmap, which is based on match between 16S from the 
# original data source and taxonomy id. The initial tax mapping has therefore been excluded here and we only use the ncbi "output/taxonomy_names.csv" to extract tax_ids

# Open original dataset, with a series of errors
fie <- read.csv("data/raw/fierer/IJSEM_pheno_db_v1.0.csv", as.is=TRUE)

#Remove nonsense genus names containing numbers
fie <- fie[!grepl("^[0-9]", fie$Genus), ]

# Create a full name species column

# In a significant number of cases (241), the "species" column also contains the genus name. This doesn't work when we 
# merge the two to create the org_name column. Hence we need to clean these up first. 
# We do this by splitting all species values and removing the first value if there are more than one.
# Note that in some cases there is a trailing white space which needs to be removed

rm_genus <- function(x) {
  species <- unlist(strsplit(trimws(x[!is.na(x)]), " "))
  if(length(species) == 2) {
    species <- species[2]
  } else {
    species <- species[1]
  }
  return(species)
}

fie$Species <- apply(fie["Species"], 1, rm_genus)

# Fix inconsistencies in rRNA16S
fie$rRNA16S <- trimws(gsub(",", "", fie$rRNA16S))

#Some species names are listed with a capital - force to lower case
fie$Species <- tolower(fie$Species)

#Some genus names are listed with lower - force to upper
fie$Genus <- paste(toupper(substr(fie$Genus, 1, 1)), substr(fie$Genus, 2, nchar(fie$Genus)), sep="")

#Combine clean genus and species names into full name
fie$org_name <- paste(trimws(fie$Genus), trimws(fie$Species))

#update column names to standard for merger
colnames(fie)[which(names(fie) == "Oxygen")] <- "metabolism"
colnames(fie)[which(names(fie) == "Gram")] <- "gram_stain"
colnames(fie)[which(names(fie) == "Spore")] <- "sporulation"
colnames(fie)[which(names(fie) == "Shape")] <- "cell_shape"
colnames(fie)[which(names(fie) == "Motility")] <- "motility"
colnames(fie)[which(names(fie) == "pH_optimum")] <- "optimum_ph"
colnames(fie)[which(names(fie) == "Temp_optimum")] <- "optimum_tmp"
colnames(fie)[which(names(fie) == "DOI")] <- "reference"
colnames(fie)[which(names(fie) == "CarbonSubstrate")] <- "carbon_substrates"


#Change character columns to numeric
fie$optimum_tmp <- as.numeric(as.character(fie$optimum_tmp))
fie$optimum_ph <- as.numeric(as.character(fie$optimum_ph))
fie$Salt_optimum <- as.numeric(as.character(fie$Salt_optimum))

#Change habitat column names to avoid clash with future merging
colnames(fie)[which(names(fie) == "Habitat")] <- "environment"
colnames(fie)[which(names(fie) == "Subhabitat")] <- "subenvironment"


#Some species names are simply not spelt correctly in input - fix manually
#Note: The corrected names have been looked up in NCBI taxonomy browser

fie[!is.na(fie$org_name) & fie$org_name == "Algoiphagus locisalis", "org_name"] <- "Algoriphagus locisalis"
fie[!is.na(fie$org_name) & fie$org_name == "AMO1 methylomicrobium", "org_name"] <- "Methylomicrobium sp. AMO1"
fie[!is.na(fie$org_name) & fie$org_name == "Aquimarina agarlytica", "org_name"] <- "Aquimarina agarilytica"
fie[!is.na(fie$org_name) & fie$org_name == "Arthrobacter momumenti", "org_name"] <- "Arthrobacter monumenti"
fie[!is.na(fie$org_name) & fie$org_name == "Bacillus vietnamesis", "org_name"] <- "Bacillus vietnamensis"
fie[!is.na(fie$org_name) & fie$org_name == "Basfia succiniproducens", "org_name"] <- "Basfia succiniciproducens"
fie[!is.na(fie$org_name) & fie$org_name == "Bizonia algoritergicola", "org_name"] <- "Bizionia algoritergicola"
fie[!is.na(fie$org_name) & fie$org_name == "Chitiniphaga oryziterrae", "org_name"] <- "Chitinophaga oryziterrae"
fie[!is.na(fie$org_name) & fie$org_name == "Dactylosporangium lurisum", "org_name"] <- "Dactylosporangium luridum"
fie[!is.na(fie$org_name) & fie$org_name == "Dipodascus tetraspoureus", "org_name"] <- "Dipodascus tetrasporeus"
fie[!is.na(fie$org_name) & fie$org_name == "Gemella asacchariolytica", "org_name"] <- "Gemella asaccharolytica"
fie[!is.na(fie$org_name) & fie$org_name == "Gluconoacetobacter aggeris", "org_name"] <- "Gluconacetobacter aggeris"
fie[!is.na(fie$org_name) & fie$org_name == "Gordonia kroppenstedti", "org_name"] <- "Gordonia kroppenstedtii"
fie[!is.na(fie$org_name) & fie$org_name == "Halococcus hamlinensis", "org_name"] <- "Halococcus hamelinensis"
fie[!is.na(fie$org_name) & fie$org_name == "Halomonas almerie", "org_name"] <- "Halomonas almeriensis"
fie[!is.na(fie$org_name) & fie$org_name == "Halosimplex eubrum", "org_name"] <- ""
fie[!is.na(fie$org_name) & fie$org_name == "Halosimplex eubrum", "org_name"] <- "Halosimplex rubrum"
fie[!is.na(fie$org_name) & fie$org_name == "Halovivax asiasticus", "org_name"] <- "Halovivax asiaticus"
fie[!is.na(fie$org_name) & fie$org_name == "Helopenitus persicus", "org_name"] <- "Halopenitus persicus"
fie[!is.na(fie$org_name) & fie$org_name == "Herbasprillum chlorophenolicum", "org_name"] <- "Herbaspirillum chlorophenolicum"
fie[!is.na(fie$org_name) & fie$org_name == "Kineospora mesophilia", "org_name"] <- "Kineosporia mesophila"
fie[!is.na(fie$org_name) & fie$org_name == "Kribbella gingsengisoli", "org_name"] <- "Kribbella ginsengisoli"
fie[!is.na(fie$org_name) & fie$org_name == "Lysobacter ximonensi", "org_name"] <- "Lysobacter ximonensis"
fie[!is.na(fie$org_name) & fie$org_name == "Marinomonas dokdonesis", "org_name"] <- "Marinomonas dokdonensis"
fie[!is.na(fie$org_name) & fie$org_name == "Methylbacterium adhaesivum", "org_name"] <- "Methylobacterium adhaesivum"
fie[!is.na(fie$org_name) & fie$org_name == "Methylobcterium phyllosphaerae", "org_name"] <- "Methylobacterium phyllosphaerae"
fie[!is.na(fie$org_name) & fie$org_name == "Mycobacteriium parakoreense", "org_name"] <- "Mycobacterium parakoreense"
fie[!is.na(fie$org_name) & fie$org_name == "Mycobaterium senuense", "org_name"] <- "Mycobacterium senuense"
fie[!is.na(fie$org_name) & fie$org_name == "Ordoribacter laneus", "org_name"] <- "Odoribacter laneus"
fie[!is.na(fie$org_name) & fie$org_name == "Paenibacillius siamensis", "org_name"] <- "Paenibacillus siamensis"
fie[!is.na(fie$org_name) & fie$org_name == "Paenibacillus timonen", "org_name"] <- "Paenibacillus timonensis"
fie[!is.na(fie$org_name) & fie$org_name == "Photobacterium haloterans", "org_name"] <- "Photobacterium halotolerans"
fie[!is.na(fie$org_name) & fie$org_name == "Plasticicumulans not", "org_name"] <- "Plasticicumulans lactativorans"
fie[!is.na(fie$org_name) & fie$org_name == "Pseudomoas proteolytica", "org_name"] <- "Pseudomonas proteolytica"
fie[!is.na(fie$org_name) & fie$org_name == "Pseudomonas guinae", "org_name"] <- "Pseudomonas guineae"
fie[!is.na(fie$org_name) & fie$org_name == "Pseudomonas sabiulinigiri", "org_name"] <- "Pseudomonas sabulinigri"
fie[!is.na(fie$org_name) & fie$org_name == "Saccharopolyspora antimicrobia", "org_name"] <- "Saccharopolyspora antimicrobica"
fie[!is.na(fie$org_name) & fie$org_name == "Saccharospirillium salsuginis", "org_name"] <- ""
fie[!is.na(fie$org_name) & fie$org_name == "Saccharospirillium salsuginis", "org_name"] <- "Saccharospirillum salsuginis"
fie[!is.na(fie$org_name) & fie$org_name == "Salimicrobium lutem", "org_name"] <- "Salimicrobium luteum"
fie[!is.na(fie$org_name) & fie$org_name == "Salinibacillus xinjiangenesis", "org_name"] <- "Salinibacillus xinjiangensis"
fie[!is.na(fie$org_name) & fie$org_name == "Silvimonas silvimonas", "org_name"] <- "Silvimonas amylolytica"
fie[!is.na(fie$org_name) & fie$org_name == "Skermanella xinjiangenesis", "org_name"] <- "Skermanella xinjiangensis"
fie[!is.na(fie$org_name) & fie$org_name == "Stenotrophomonas stenotrophomonas", "org_name"] <- "Stenotrophomonas dokdonensis"
fie[!is.na(fie$org_name) & fie$org_name == "Streptmocyces lunalinharesii", "org_name"] <- "Streptomyces lunalinharesii"
fie[!is.na(fie$org_name) & fie$org_name == "Streptomyces thingherensis", "org_name"] <- "Streptomyces thinghiriensis"
fie[!is.na(fie$org_name) & fie$org_name == "Tenacibacterium litoreum", "org_name"] <- "Tenacibaculum litoreum"
fie[!is.na(fie$org_name) & fie$org_name == "Terrimnas rubra", "org_name"] <- "Terrimonas rubra"
fie[!is.na(fie$org_name) & fie$org_name == "Trichosporon chiarelli", "org_name"] <- "Trichosporon chiarellii"
fie[!is.na(fie$org_name) & fie$org_name == "Ulginosibacterium gangwonense", "org_name"] <- "Uliginosibacterium gangwonense"
fie[!is.na(fie$org_name) & fie$org_name == "Venenvibrio stagnispumantis", "org_name"] <- "Venenivibrio stagnispumantis"
fie[!is.na(fie$org_name) & fie$org_name == "Vibro rarus", "org_name"] <- "Vibrio rarus"
fie[!is.na(fie$org_name) & fie$org_name == "Virgibacillus subtrerraneus", "org_name"] <- "Virgibacillus subterraneus"


# Remove any completely duplicated rows
fie <- unique(fie[, names(fie)])

# Map taxonomy ids directly from ncbi db
fie <- merge(fie, nam, by.x="org_name", by.y="name_txt", all.x=TRUE)

# Remove columns no longer needed
fie <- subset(fie, select=-c(unique_name))

# At this stage 10 rows do not have a matching tax id
# Some of these are not prokaryotic. Just remove them
fie <- fie[!is.na(fie$tax_id),]

#PROCESS DATA

# Adjust erronous values
fie$Length[fie$tax_id == 1229268 & fie$Length == 2500] <- 2.5
fie$Width[fie$tax_id == 1229268 & fie$Width == 3500] <- 0.35

# Clean up size data (errors from excel date and number conversions)
fie$d1 <- gsub("_\xd1\xd0", "-", fie$Width)
fie$d2 <- gsub("_\xd1\xd0", "-", fie$Length)

rm <- "(not indicated, )|(not indicated, diameter = )|(not indicated )|(Filament width of )|(diameter: )|( in diameter)|( \\(diameter\\))"

fie$d1 <- gsub(rm, " ", fie$d1)
fie$d2 <- gsub(rm, " ", fie$d2)

# Remove any remaining parenthesis and < > signs (we ignore when size is indicated as smaller than "<" or larger than ">")
# This can be done with a single regex, but for now we do it the coarse way

fie$d1 <- gsub("\\(","", fie$d1)
fie$d1 <- gsub("\\)","", fie$d1)
fie$d1 <- gsub(">","", fie$d1)
fie$d1 <- gsub("<","", fie$d1)

fie$d2 <- gsub("\\(","", fie$d2)
fie$d2 <- gsub("\\)","", fie$d2)
fie$d2 <- gsub(">","", fie$d2)
fie$d2 <- gsub("<","", fie$d2)

#Replace "," with "." : Some numbers have been input using comma

fie$d1 <- gsub(",", ".", fie$d1)
fie$d2 <- gsub(",", ".", fie$d2)

##  Split d1 and d2 ranges into lower and upper values (and deal with excel dates)

fie$d1_lo <- as.numeric(NA)
fie$d1_up <- as.numeric(NA)
fie$d2_lo <- as.numeric(NA)
fie$d2_up <- as.numeric(NA)

for(i in 1:nrow(fie)) {
  
  w <- NA
  l <- NA
  
  #Get range of field d1
  if(!is.na(fie$d1[i])) {
    w <- excel_dates_to_numbers(fie$d1[i])
    #Store values
    fie$d1_lo[i] <- w[1]
    fie$d1_up[i] <- w[2]
  }
  
  if(!is.na(fie$d2[i])) {
    #Get range of field d2
    l <- excel_dates_to_numbers(fie$d2[i])
    #Store values
    fie$d2_lo[i] <- l[1]
    fie$d2_up[i] <- l[2]
  }
}

#Deal with size ranges saved in excel as dates of format dd/mm/yy

for(i in 1:nrow(fie)) {
  
  w <- NA
  l <- NA 
  d <- NA
  
  d <- strsplit(fie$d1[i], "/")
  d <- unlist(d)
  
  if(length(d) > 1) {
    d <- sort(as.numeric(d), decreasing = FALSE)
    fie$d1_lo[i] <- d[1]
    fie$d1_up[i] <- d[2]
  }
  
  d <- strsplit(fie$d2[i], "/")
  d <- unlist(d)
  
  if(length(d) > 1) {
    d <- sort(as.numeric(d), decreasing = FALSE)
    fie$d2_lo[i] <- d[1]
    fie$d2_up[i] <- d[2]
  }
}

#Check if d1 (width) is larger than d2 (length), if so, switch the two 
#Some organism data has been accidentally swapped during entry - this was confirmed by source
#We assume all shapes are longer than they are wide (alternatively restrict script to rods and coccoid - see commented code)

for(i in 1:nrow(fie)) {
  
  #if(!is.na(fie$Shape[i]) & (fie$Shape[i] == "rod" | fie$Shape[i] == "ovoid/coccobacillus")) {
  
  if(!is.na(fie$d1_lo[i]) & !is.na(fie$d2_lo[i]) & fie$d1_lo[i] > fie$d2_lo[i] || !is.na(fie$d1_up[i]) & !is.na(fie$d2_up[i]) & fie$d1_up[i] > fie$d2_up[i]) {
    
    #print(sprintf("%s d1_lo: %s > d2_lo: %s OR d1_up: %s > d2_up: %s!",fie$ncbi_species[i],fie$d1_lo[i],fie$d2_lo[i],fie$d1_up[i],fie$d2_up[i]))
    
    #Swap values!
    new_d1_lo <- fie$d2_lo[i]
    new_d1_up <- fie$d2_up[i]
    
    new_d2_lo <- fie$d1_lo[i]
    new_d2_up <- fie$d1_up[i]
    
    #Save values
    fie$d1_lo[i] <- new_d1_lo
    fie$d1_up[i] <- new_d1_up
    
    fie$d2_lo[i] <- new_d2_lo
    fie$d2_up[i] <- new_d2_up
    
  } 
  #}
}

# Clean up ph data
fie[!is.na(fie$optimum_ph) & fie$optimum_ph == "5.5-12.5","optimum_ph"] <- NA

# Clean up tmp data
fie[!is.na(fie$optimum_tmp) & fie$optimum_tmp == 300,"optimum_tmp"] <- NA

# Clean up size data
fie[!is.na(fie$d1_lo) & fie$d1_lo == 2500,"d1_lo"] <- NA
fie[!is.na(fie$d1_lo) & fie$d1_lo == 3500,"d2_lo"] <- NA

# Adding in isolation_source concatenation
cc <- c("environment", "subenvironment")
fie$isolation_source <- apply(fie[cc], 1, function(x) paste(x[!is.na(x)], collapse = ", "))
fie$isolation_source <- tolower(fie$isolation_source)

#Add nitrate_reduction where MetabAssays contains 'nitrate reduction to nitrite'
#Apparently aerobic denitrification is more common than previously assumed..
fie$pathways[grepl("nitrate reduction to nitrite", fie$MetabAssays)] <- "nitrate_reduction"

# Add doi.org/ to all dois
fie$reference <- paste("doi.org/", fie$reference, sep="")

#Check Salinibacillus xinjiangensis
#check <- fie2[fie2$org_name == "Salinibacillus xinjiangensis", ] 

#Reduce to needed columns
all_cols <- c("tax_id","name_class","org_name","Strain","metabolism","pathways","carbon_substrates","sporulation","cell_shape","motility","optimum_ph","optimum_tmp","d1_lo","d1_up","d2_lo","d2_up","isolation_source","reference")
fie2 <- fie[,all_cols]

#Remove any fully duplicated rows
fie2 <- unique(fie2[, all_cols])

#Add reference type column
fie2$ref_type <- "doi"

#Save output
write.csv(fie2, "output/prepared_data/fierer.csv", row.names=FALSE)
