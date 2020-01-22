# GOLD data preparation

# Open original dataset
gol <- read.delim("data/raw/gold/Mark_Westoby_Organism_Metadata_Export_02152018.txt", as.is=TRUE)
# Replace (null) in gold with NA
gol[gol == "(null)"] <- NA

###################################
#Load and prepare GOLD genome data#
###################################

# For genome size estimates we use data from "Complete and Published" genomes where possisble, 
# and then fill with average Permanent Draft genome length per species.

#Get genome size estimates (This is merged on to the final data set using organism_id)
gol_genome <- read.delim("data/raw/gold/Mark_Westoby_Genome_Size_Details_Export_02152018.txt", as.is=TRUE)
#Get only completed and published genome sizes
gol_genome <- gol_genome[gol_genome$PROJECT_STATUS %in% c("Complete and Published","Permanent Draft","complete"),]
#Exclude organisms listed with less than 100K nucleotides
gol_genome <- gol_genome[gol_genome$EST_SIZE > 100000,]
#Reduce to needed columns
gol_genome <- subset(gol_genome, select = c(ORGANISM_ID,PROJECT_STATUS,EST_SIZE))
#Some organisms are duplicated in the list - For Complete and published genomes as well as Permanent Draft

# duplicates are all very similar in estimated size, but the larger is probably the more complete - so keep this
gol_genome <- gol_genome %>% 
  group_by(ORGANISM_ID, PROJECT_STATUS) %>% summarise(max(EST_SIZE))

#Remove all duplicate draft genomes (a result of both the draft and published genome being present)
gol_genome <- gol_genome[!(duplicated(gol_genome$ORGANISM_ID) & gol_genome$PROJECT_STATUS == "Permanent Draft"),] 

#Change column names for consistency
colnames(gol_genome) <- c("ORGANISM_ID", "GENOME_STATUS", "EST_GENOME_SIZE")

# Add genome size estimates for each organism in the data set
gol <- merge(gol,gol_genome, by.x = "GOLD_ORGANISM_ID", by.y = "ORGANISM_ID", all.x=TRUE)

#################################
#### Process main data frame ####
#################################

#Remove duplicate column OXYGEN_REQUIREMENT.1
if("OXYGEN_REQUIREMENT.1" %in% names(gol)) {
  gol <- subset(gol, select = -c(OXYGEN_REQUIREMENT.1))
}

#Remove some of the manu virus and fungus rows
gol <- filter(gol, !grepl("virus", SPECIES)) %>%
  filter(!grepl("virus", ORGANISM_NAME)) %>%
  filter(!grepl("virus", NCBI_SPECIES)) %>%
  filter(!grepl("Virus", NCBI_SPECIES)) %>%
  filter(!grepl("phage", ORGANISM_NAME)) %>% 
  filter(!grepl("phage", NCBI_SPECIES)) %>%
  filter(!grepl("Acanthamoeba", GENUS)) %>% 
  filter(!grepl("Candida", GENUS))

#############################
####### Fix size data #######
#############################

gol$d1_unit <- NA
gol$d2_unit <- NA

# expressions of micrometer
um <- "(micrometres)|(micrometer)|(microns)|(\\?\\?m)|(&#956;m)|(um)|(¿m)|(\\?m)|(uM)|(μm)|(u)|(UM)"
# expressions of nanometer
nm <- "(nm)"
# expressions of millimeter
mm <- "(mm)"
# expressions of millimeter
cm <- "(cm)"
# experession of space
sp <- "(&#8201;)| |(&#8197;)|`"
# experession of decimal
dc <- "(\\?\\?|\\;)"
# expressions of dashes
dh <- "(\\?)|(¿¿)|(to)|(¿)"

# Preserve unit information
gol$d1_unit[!is.na(gol$CELL_DIAMETER)] <- "um"
gol$d2_unit[!is.na(gol$CELL_LENGTH)] <- "um"

gol$d1_unit[grep(nm, gol$CELL_DIAMETER)] <- "nm"
gol$d2_unit[grep(nm, gol$CELL_LENGTH)] <- "nm"

gol$d1_unit[grep(mm, gol$CELL_DIAMETER)] <- "mm"
gol$d2_unit[grep(mm, gol$CELL_LENGTH)] <- "mm"

gol$d1_unit[grep(cm, gol$CELL_DIAMETER)] <- "cm"
gol$d2_unit[grep(cm, gol$CELL_LENGTH)] <- "cm"

# Strip out units
gol$d1 <- gsub(um, "", gol$CELL_DIAMETER)
gol$d1 <- gsub(nm, "", gol$d1)
gol$d1 <- gsub(mm, "", gol$d1)
gol$d1 <- gsub(cm, "", gol$d1)

gol$d2 <- gsub(um, "", gol$CELL_LENGTH)
gol$d2 <- gsub(nm, "", gol$d2)
gol$d2 <- gsub(mm, "", gol$d2)
gol$d2 <- gsub(cm, "", gol$d2)
gol$d2 <- gsub("variable", NA, gol$d2)
gol$d2 <- gsub("in length", "", gol$d2)

# Strip out space, fix decimals and dashes
gol$d1 <- gsub(sp, "", gol$d1)
gol$d1 <- gsub(dc, ".", gol$d1)
gol$d1 <- gsub(dh, "-", gol$d1)

gol$d2 <- gsub(sp, "", gol$d2)
gol$d2 <- gsub(dc, ".", gol$d2)
gol$d2 <- gsub(dh, "-", gol$d2)

# Remove leading characters
gol$d1 <- gsub("(-|s|\\.)$", "", gol$d1)
gol$d2 <- gsub("(-|s|\\.)$", "", gol$d2)

# Hard fixes (because there's no logic to fix otherwise...)
gol$d1 <- gsub("(0¿8-1¿0 )", "0.8-1.0", gol$d1)
gol$d1 <- gsub("(0.4\\+/-0.1)", "0.3-0.5", gol$d1)
gol$d1 <- gsub("0-8-1-0", "0.8-1.0", gol$d1)

gol$d2 <- gsub("(1.2\\+/-0.4)", "0.8-1.6", gol$d2)
gol$d2 <- gsub("(0.8  1.2)", "0.8-1.2", gol$d2)
gol$d2 <- gsub("I", "1", gol$d2)
gol$d2 <- gsub("(1.5-.5.0)", "1.5-5.0", gol$d2)

#DN ADDED..
gol$d1 <- gsub("(0Â-8-1Â-0)", "0.8-1.0", gol$d1)
gol$d1 <- gsub("(2.0Â-Â-2.5)", "2.0-2.5", gol$d1)
gol$d1 <- gsub("(0.3-0.6Â-Â)", "0.3-0.6", gol$d1)

gol$d2 <- gsub("(1-4Â-Â)", "1-4", gol$d2)
gol$d2 <- gsub("(2.5Â-Â-3.2)", "2.5-3.2", gol$d2)

#Remove remaining Â and Î¼m
gol$d1 <- gsub("Â", "", gol$d1)
gol$d1 <- gsub("Î¼m", "", gol$d1)

gol$d2 <- gsub("Â", "", gol$d2)
gol$d2 <- gsub("Î¼m", "", gol$d2)

# gol[c("d1", "d1_unit")][!is.na(gol$d1),]
# gol[c("d2", "d2_unit")][!is.na(gol$d2),]

gol$d1[gol$GOLD_ID == "Go0003681"] <- "2-5"
gol$d2[gol$GOLD_ID == "Go0003681"] <- "0.7-10"

# Split out lower and upper dimensions
d1 <- data.frame(do.call(rbind, strsplit(gol$d1, "-")))
names(d1) <- c("d1_lo", "d1_up")

#Convert factors to numbers in a safe way
#d1$d1_up <- as.numeric(levels(d1$d1_up))[d1$d1_up]
#d1$d1_lo <- as.numeric(levels(d1$d1_lo))[d1$d1_lo]

d1$d1_up <- as.numeric(as.character(d1$d1_up))
d1$d1_lo <- as.numeric(as.character(d1$d1_lo))

#Remove duplicate values
d1$d1_up[!is.na(d1$d1_lo) & d1$d1_lo == d1$d1_up] <- NA

d2 <- data.frame(do.call(rbind,strsplit(gol$d2, "-")))
names(d2) <- c("d2_lo", "d2_up")

#Convert factors to numbers in a safe way
#d2$d2_up <- as.numeric(levels(d2$d2_up))[d2$d2_up]
#d2$d2_lo <- as.numeric(levels(d2$d2_lo))[d2$d2_lo]

d2$d2_up <- as.numeric(as.character(d2$d2_up))
d2$d2_lo <- as.numeric(as.character(d2$d2_lo))

#Remove duplicate values
d2$d2_up[!is.na(d2$d2_lo) & d2$d2_lo == d2$d2_up] <- NA

gol <- cbind(gol, d1, d2)
# gol[c("CELL_DIAMETER", "CELL_LENGTH", "d1_lo", "d1_up", "d1_unit", "d2_lo", "d2_up", "d2_unit")]

# Remove temporary cell size range columns
gol <- subset(gol, select=-c(d1, d2))



##################################################
# Convert all sizes to um based on recorded unit #
##################################################

#(this is done to simplify handling later on)

measure <- c("d1_lo","d1_up","d2_lo","d2_up")

for(i in 1:nrow(gol)) {
  
  if (!is.na(gol$d1_lo[i]) | !is.na(gol$d1_up[i]) | !is.na(gol$d2_lo[i]) | !is.na(gol$d2_up[i])) {
    
    for(a in 1:length(measure)) {
      
      if (!is.na(gol[i, measure[a]])) {
        
        #Define column with unit
        if (measure[a] %in% c("d1_lo","d1_up")) {
          unit_col <- "d1_unit"
        } else {
          unit_col <- "d2_unit"
        }
        
        if (!is.na(gol[i, unit_col]) & gol[i, unit_col] != "um") {
          #convert unit
          gol[i, measure[a]] <- as.double(convert_unit(gol[i, measure[a]], gol[i, unit_col]))
        }
      }
      
    }
  }
}

#Remove unit columns
gol <- subset(gol, select=-c(d1_unit, d2_unit))

#check <- gol[!is.na(gol$ORGANISM_NAME) & gol$ORGANISM_NAME == "Gordonibacter pamelaeae 7-10-1-bT, DSM 19378",]

#Check if d1 (width) is larger than d2 (length), if so, switch the two 
#Some organism data has been accidentally swapped during entry - this has been confirmed by litterature search and comparison
#We assume all shapes are longer than they are wide (alternatively restrict script to rods and coccoid - see commented code)

for(i in 1:nrow(gol)) {
  
  if(!is.na(gol$d1_lo[i]) & !is.na(gol$d2_lo[i]) & gol$d1_lo[i] > gol$d2_lo[i] || !is.na(gol$d1_up[i]) & !is.na(gol$d2_up[i]) & gol$d1_up[i] > gol$d2_up[i]) {
    
    #print(sprintf("%s d1_lo: %s > d2_lo: %s OR d1_up: %s > d2_up: %s!",gol$NCBI_SPECIES[i],gol$d1_lo[i],gol$d2_lo[i],gol$d1_up[i],gol$d2_up[i]))
    
    #Swap values!
    new_d1_lo <- gol$d2_lo[i]
    new_d1_up <- gol$d2_up[i]
    
    new_d2_lo <- gol$d1_lo[i]
    new_d2_up <- gol$d1_up[i]
    
    #Save values
    gol$d1_lo[i] <- new_d1_lo
    gol$d1_up[i] <- new_d1_up
    
    gol$d2_lo[i] <- new_d2_lo
    gol$d2_up[i] <- new_d2_up
    
  } 
}

rm(d1,d2)


# Clean up temperature data (rough)
# Since these data represents temperature optima, it seems reasonable to get the mean of any range

#Remove any words
gol$TEMPERATURE_OPTIMUM <- gsub("degrees celsius", "", gol$TEMPERATURE_OPTIMUM)
gol$TEMPERATURE_OPTIMUM <- gsub("degree celcius", "", gol$TEMPERATURE_OPTIMUM)
gol$TEMPERATURE_OPTIMUM <- gsub("degree Celcius", "", gol$TEMPERATURE_OPTIMUM)
gol$TEMPERATURE_OPTIMUM <- gsub("degrees C", "", gol$TEMPERATURE_OPTIMUM)
gol$TEMPERATURE_OPTIMUM <- gsub("celsius", "", gol$TEMPERATURE_OPTIMUM)
gol$TEMPERATURE_OPTIMUM <- gsub("Celcius", "", gol$TEMPERATURE_OPTIMUM)
gol$TEMPERATURE_OPTIMUM <- gsub("Celsius", "", gol$TEMPERATURE_OPTIMUM)

gol$TEMPERATURE_OPTIMUM <- gsub("deg", "", gol$TEMPERATURE_OPTIMUM)
gol$TEMPERATURE_OPTIMUM <- gsub(" - Q188620", "", gol$TEMPERATURE_OPTIMUM)
gol$TEMPERATURE_OPTIMUM <- gsub(" - Q188620", "", gol$TEMPERATURE_OPTIMUM)

gol$TEMPERATURE_OPTIMUM[gol$TEMPERATURE_OPTIMUM == "Thermophile"] <- NA
gol$TEMPERATURE_OPTIMUM[gol$TEMPERATURE_OPTIMUM == "Hyperthermophile"] <- NA
gol$TEMPERATURE_OPTIMUM[gol$TEMPERATURE_OPTIMUM == "Mesphile"] <- NA
gol$TEMPERATURE_OPTIMUM[gol$TEMPERATURE_OPTIMUM == "Mesophile"] <- NA

gol$TEMPERATURE_OPTIMUM <- gsub("Â¿Â¿", "", gol$TEMPERATURE_OPTIMUM)
gol$TEMPERATURE_OPTIMUM <- gsub("Â¿", "", gol$TEMPERATURE_OPTIMUM)
gol$TEMPERATURE_OPTIMUM <- gsub("Â°C", "", gol$TEMPERATURE_OPTIMUM)
gol$TEMPERATURE_OPTIMUM <- gsub("â€“", "-", gol$TEMPERATURE_OPTIMUM)

gol$TEMPERATURE_OPTIMUM[gol$TEMPERATURE_OPTIMUM == "2025"] <- "20-25"
gol$TEMPERATURE_OPTIMUM[gol$TEMPERATURE_OPTIMUM == "20?25 ?C"] <- "20-25"

#Remove various letters and symbols
gol$TEMPERATURE_OPTIMUM <- gsub("oC", "", gol$TEMPERATURE_OPTIMUM)
gol$TEMPERATURE_OPTIMUM <- gsub("C", "", gol$TEMPERATURE_OPTIMUM)
gol$TEMPERATURE_OPTIMUM <- gsub("c", "", gol$TEMPERATURE_OPTIMUM)
gol$TEMPERATURE_OPTIMUM <- gsub("?", "", gol$TEMPERATURE_OPTIMUM, fixed = TRUE) #Important to remove all ?
gol$TEMPERATURE_OPTIMUM <- gsub("°", "", gol$TEMPERATURE_OPTIMUM)
gol$TEMPERATURE_OPTIMUM <- gsub(" ", "", gol$TEMPERATURE_OPTIMUM, fixed = TRUE) #Important to remove all " "
gol$TEMPERATURE_OPTIMUM <- gsub("to", "-", gol$TEMPERATURE_OPTIMUM)
gol$TEMPERATURE_OPTIMUM <- gsub(",", "-", gol$TEMPERATURE_OPTIMUM)

gol$TEMPERATURE_OPTIMUM[gol$TEMPERATURE_OPTIMUM == "2025"] <- "20-25"

#Trim all white space
gol$TEMPERATURE_OPTIMUM <- trimws(gol$TEMPERATURE_OPTIMUM)
#Remove any extra space between words
gol$TEMPERATURE_OPTIMUM <- gsub("\\s+"," ",gol$TEMPERATURE_OPTIMUM)

# Create new row for average optimum temperature values
gol$optimum_tmp <- NA

# Convert ranges to mean values using custom function
for(i in 1:nrow(gol)) {
  if(!is.na(gol$TEMPERATURE_OPTIMUM[i])) {
    gol$optimum_tmp[i] <- func_average_range(gol$TEMPERATURE_OPTIMUM[i])
  }
}



#update column names to standard for merger
colnames(gol)[which(names(gol) == "ORGANISM_NAME")] <- "org_name"
colnames(gol)[which(names(gol) == "NCBI_TAXONOMY_ID")] <- "tax_id"
colnames(gol)[which(names(gol) == "OXYGEN_REQUIREMENT")] <- "metabolism"
colnames(gol)[which(names(gol) == "GRAM_STAIN")] <- "gram_stain"
colnames(gol)[which(names(gol) == "SPORULATION")] <- "sporulation"
colnames(gol)[which(names(gol) == "CELL_SHAPE")] <- "cell_shape"
colnames(gol)[which(names(gol) == "MOTILITY")] <- "motility"
colnames(gol)[which(names(gol) == "EST_GENOME_SIZE")] <- "genome_size"
#Note: column "optimum_tmp" has been created in code above

# Add isolation_source concatenation
gol[gol == "Unclassified"] <- NA

cc <- c("ECOSYSTEM","ECOSYSTEM_CATEGORY","ECOSYSTEM_TYPE","ECOSYSTEM_SUBTYPE","SPECIFIC_ECOSYSTEM","BIOTIC_RELATIONSHIP","SYMBIOTIC_RELATIONSHIP")
gol$isolation_source <- apply(gol[cc], 1, function(x) paste(x[!is.na(x)], collapse = ", "))
gol$isolation_source <- tolower(gol$isolation_source)

#Reduce to needed columns
gol2 <- gol[,c("tax_id","org_name","STRAIN","GENBANK_16S_ID","metabolism","gram_stain","sporulation","cell_shape","motility","isolation_source","optimum_tmp","d1_lo","d1_up","d2_lo","d2_up","genome_size","GENOME_STATUS")]

#Remove any fully duplicated rows
gol2 <- unique(gol2[, names(gol2)])

#Remove any blank fields: This is important in particular for the isolation_source aggregation column
gol2[gol2 == ""] <- NA
gol2[gol2 == " "] <- NA

#Remove any rows with no categorical information
cols <- c("metabolism","gram_stain","sporulation","cell_shape","motility","isolation_source","optimum_tmp","d1_lo","d1_up","d2_lo","d2_up","genome_size")
# Remove rows with no categorical data
gol2 <- gol2[rowSums(is.na(gol2[cols])) != length(cols), ]

gol2$ref_type <- "doi"
gol2$reference <- "doi.org/10.1093/nar/gky977"

#Save master data
write.csv(gol2, "output/prepared_data/gold.csv", row.names=FALSE, quote=TRUE)