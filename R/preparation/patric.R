# PATRIC

# Open original dataset
pat <- read_delim("data/raw/patric/genome_metadata.txt", delim="\t")

# Get useful columns
cols <- c("taxon_id",
          "genome_name",
          "organism_name",
          "genome_status",
          "sequencing_status",
          "sequencing_depth",
          "genbank_accessions",
          "genome_length",
          "gc_content",
          "isolation_site",
          "isolation_source",
          "isolation_comments",
          "isolation_country",
          "geographic_location",
          "body_sample_site",
          "host_name",
          "habitat",
          "motility",
          "sporulation",
          "gram_stain",
          "cell_shape",
          "salinity",
          "oxygen_requirement",
          "optimal_temperature",
          "temperature_range",
          "publication",
          "bioproject_accession",
          "biosample_accession")

pat2 <- subset(pat, select=cols)

#Remove genome data where status = Plasmid
pat2$genome_length[pat2$genome_status == "Plasmid"] <- NA

#Remove genome data where sequencing_status is NOT complete or finished
pat2$genome_length[grepl("assembly|unfinished|in progress",pat2$sequencing_status)] <- NA

#Remove all genome data where sequencing depth < recommended
#Clean up column from text
pat2$sequencing_depth <- gsub("approximately|approx.|fold|ND|n.d|about|Unknown|unknown|missing|Not Applicable|not applicable|not specified|unspecified|at least|>|x|X|-|","",pat2$sequencing_depth)
pat2$sequencing_depth <- gsub(".*complete:\\s*|coverage.*", "", pat2$sequencing_depth)
pat2$sequencing_depth <- gsub(".*complete :", "", pat2$sequencing_depth)
pat2$sequencing_depth <- as.numeric(pat2$sequencing_depth)

#This removes just under 5000 data points out of 130,000
pat2$genome_length[pat2$sequencing_depth < 10] <- NA

# Remove negative genome lengths as well as anything below
# the smallest known genome (2018 ~ 0.58Mb)
# This cleans up most non-complete genomes
pat2$genome_length[pat2$genome_length <= 550000] <- NA


## REMOVE SAGs AND MAGs

#Remove rows where isolation source contains the term "single cell"
#These are essentially SAGs, and while they may be OK, many have too short genome length (not fully sequenced) (678 in total)
pat2 <- pat2[!grepl("single cell",pat2$isolation_source),]
#Remove genome size data from organisms with "SCGC" in their  name - these are single cell genomes
pat2 <- pat2[!grepl("SCGC",pat2$genome_name),]

#Remove all where species name contains the word "MAG-" 
#These are metagenome assembled genomes and are often much smaller than real genomes
pat2 <- pat2[!is.na(pat2$genome_name) & !grepl("MAG-", pat2$genome_name),]

##

#Remove nonsense words from motility
pat2$motility[pat2$motility == "mesophile"] <- NA

#Remove nonsense words from sporulation
pat2$sporulation[pat2$sporulation == "Motile"] <- NA

#Remove nonsense words from cell shape
pat2$cell_shape[pat2$cell_shape == "ARRAY(0x4ee9450)"] <- NA

#Clean html from cell shapes
pat2$cell_shape[!is.na(pat2$cell_shape)] <- apply(pat2[!is.na(pat2$cell_shape),"cell_shape"], 1, trimHtml)

# Remove odd words from cell_shape
words <- c("eFilamentous","eCoccobacilli","eCocci","eCurvedShaped","eTailed")
pat2$cell_shape <- gsub(paste0("\\b(",paste(words, collapse="|"),")\\b"), "", pat2$cell_shape)
# Remove any whitespace
pat2$cell_shape <- trimws(pat2$cell_shape)

# Remove "-" and " " from publications
pat2$publication[pat2$publication == "-"] <- NA
pat2$publication <- gsub(" ","",pat2$publication, fixed = TRUE)

# Remove ##### from publications
pat2$publication[grepl("#",pat2$publication)] <- NA

# Fix comma issues in publications and remove "000" ids
# explode list by "," and recombine
for(i in 1:nrow(pat2)) {
  if(!is.na(pat2$publication[i])) {
    list <- unlist(strsplit(pat2$publication[i],","))
    # Remove any empty positions
    list <- list[!(list %in% c(""," ","000"))]
    #recombine
    pat2$publication[i] <- paste0(unlist(list), collapse = ",")
  }
}

# Fix specific issues in temperature range
pat2$temperature_range[pat2$temperature_range == "22 - 27C"] <- "Mesophilic"
pat2$temperature_range[pat2$temperature_range == "25 C"] <- "Mesophilic"
pat2$temperature_range[pat2$temperature_range == "30 - 72 C"] <- "Mesophilic"

# Fix optimal temperature

#Remove all "C" from values
pat2$optimal_temperature <- gsub("C","",pat2$optimal_temperature, fixed = TRUE)
pat2$optimal_temperature <- gsub(" ","",pat2$optimal_temperature, fixed = TRUE)
pat2$optimal_temperature <- gsub("<","",pat2$optimal_temperature, fixed = TRUE)
pat2$optimal_temperature <- gsub("~","-",pat2$optimal_temperature, fixed = TRUE)
pat2$optimal_temperature <- gsub("to","-",pat2$optimal_temperature, fixed = TRUE)

#Fix specific issues
pat2$optimal_temperature[pat2$optimal_temperature == "25-32(28)"] <- "25-32"
pat2$optimal_temperature[pat2$optimal_temperature == "25-35(26)"] <- "25-35"
pat2$optimal_temperature[pat2$optimal_temperature == "\"Human,Homosapiens\""] <- NA
pat2$optimal_temperature[pat2$optimal_temperature == "F"] <- NA
pat2$optimal_temperature[pat2$optimal_temperature == "-"] <- NA
pat2$optimal_temperature[pat2$optimal_temperature == ""] <- NA

#Trim white space
pat2$optimal_temperature <- trimws(pat2$optimal_temperature)

# Some ranges have been converted into dates (typical excel error)
for(i in 1:nrow(pat2)) {
  if(!is.na(pat2$optimal_temperature[i])) {
    r <- excel_dates_to_numbers(pat2$optimal_temperature[i])
    if(length(r) == 2) {
      pat2$optimal_temperature[i] <- paste0(unlist(r), collapse = "-")
    }
  }
}

# Convert ranges to mean values using custom function
pat2$optimum_tmp <- as.numeric(NA)
for(i in 1:nrow(pat2)) {
  if(!is.na(pat2$optimal_temperature[i])) {
    pat2$optimum_tmp[i] <- func_average_range(pat2$optimal_temperature[i])
  }
}

# Name columns according to standards
colnames(pat2)[which(names(pat2) == "taxon_id")] <- "tax_id"
colnames(pat2)[which(names(pat2) == "organism_name")] <- "org_name"
colnames(pat2)[which(names(pat2) == "oxygen_requirement")] <- "metabolism"
colnames(pat2)[which(names(pat2) == "genome_length")] <- "genome_size"
colnames(pat2)[which(names(pat2) == "publication")] <- "reference"
colnames(pat2)[which(names(pat2) == "temperature_range")] <- "range_tmp"
colnames(pat2)[which(names(pat2) == "salinity")] <- "range_salinity"
# Rename original isolation columns to avoid clashing with standard names
colnames(pat2)[which(names(pat2) == "isolation_site")] <- "org_isolation_site"
colnames(pat2)[which(names(pat2) == "isolation_source")] <- "org_isolation_source"


# Create a reference column

# Fill with publication (pubmed ids)
# Then fill with bioproject ids


#Add reference type
pat2$ref_type <- NA
pat2$ref_type[!is.na(pat2$reference)] <- "pubmed_id"
#Fill with bioproject accession numbers
pat2$reference[is.na(pat2$reference) & !is.na(pat2$bioproject_accession)] <- pat2$bioproject_accession[is.na(pat2$reference) & !is.na(pat2$bioproject_accession)]
#Update ref type
pat2$ref_type[is.na(pat2$ref_type) & !is.na(pat2$reference)] <- "bioproject_id"


# Clean up any empty fields
pat2[pat2 == ""] <- NA
pat2[pat2 == " "] <- NA

# If we remove genome_size from below criteria, the data frame is reduced to ~17,000 rows... 
# Most of the data is genome size data..

#Remove any rows with no categorical information
cols <- c("metabolism","gram_stain","sporulation","cell_shape","motility","optimum_tmp","range_tmp","range_salinity")
pat3 <- pat2[rowSums(is.na(pat2[cols])) != length(cols), ]


# Adding in isolation_source concatenation
cc <- c("habitat","body_sample_site","org_isolation_site", "org_isolation_source")
pat3$isolation_source <- NA
pat3$isolation_source <- apply(pat3[cc], 1, function(x) paste(x[!is.na(x)], collapse = ", "))
pat3$isolation_source <- tolower(pat3$isolation_source)

#Remove empty isolation sources
pat3$isolation_source[pat3$isolation_source == ""] <- NA

##################################
# OUTPUT ISOLATION SOURCES FOR TRANSLATION (REMOVE FOR GENERAL PROCESSING)

# Get count of different environments
# envr_counts <- as.data.frame(table(pat3$isolation_source[!is.na(pat3$isolation_source) & pat3$isolation_source != " "]))
# # Restrict to where counts >= 5
# envr_counts <- envr_counts[envr_counts$Freq >= 5,]
# # Remove empty (count = 2200)
# envr_counts <- envr_counts[!(envr_counts$Freq > 2000),]
# # Remove any terms that already exists in environments lookup table
# look <- read.csv("conversion_tables/environment_renaming.csv", as.is=TRUE)
# envr_counts <- envr_counts[!(envr_counts$Var1 %in% look$Original),]
# 
# sum <- envr_counts %>% summarise(sum = sum(Freq))
# 
# write.csv(envr_counts, "output/tmp/patric_environments.csv", row.names=FALSE, quote=TRUE)
# 
# #If we want to go with a limited output, clear all isolation_sources from data frame
# #that is not included in the envr_counts list (not translated)
# pat2$isolation_source[!(pat2$isolation_source %in% envr_counts$Var1)] <- NA

##################################

# #Make sure that the output always only include terms
# #that exists in our environment lookup table (because we haven't translated all environment terms in patric)
look <- read.csv("data/conversion_tables/renaming_isolation_source.csv", as.is=TRUE)
pat3$isolation_source[!(pat3$isolation_source %in% look$Original)] <- NA


# Extract required columns
pat4 <- pat3[,c("tax_id","org_name","genome_size","gc_content","motility","gram_stain","sporulation","cell_shape","range_salinity","range_tmp","metabolism","optimum_tmp", "reference", "ref_type","isolation_source")]

#Remove any fully duplicated rows
pat4 <- unique(pat4[, names(pat4[1:12])])

pat4$ref_type <- "doi"
pat4$reference <- "doi.org/10.1093/nar/gkw1017"

# Fix gc_content values where reported as 0-1 instead of %
pat4$gc_content[!is.na(pat4$gc_content) & pat4$gc_content < 1] <- pat4$gc_content[!is.na(pat4$gc_content) & pat4$gc_content < 1]*100


#Save master data
write.csv(pat4, "output/prepared_data/patric.csv", row.names=FALSE, quote=TRUE)