# Workflow settings

# File paths
CONSTANT_PREPARE_FILE_PATH <- "R/preparation"
CONSTANT_DATA_PATH <- "output/prepared_data"
CONSTANT_LOOKUP_TABLE_PATH <- "data/conversion_tables"

# Add full file names of files to exclude from processing (i.e. "genbank.csv")
CONSTANT_EXCLUDED_DATASETS <- c("bergeys.csv")
#Note: Bergeys is currently used as a filler after species condensation, and therefore should not be included
#in the general processing of data sets


####################
# Data preparation #
####################

#List datasets that need to be prepared before merging
CONSTANT_PREPARE_DATASETS <- c("amend-shock","bacdive-microa","campedelli","corkrey","edwards","engqvist","faprotax","fierer","genbank","gold","jemma-refseq",
                               "kegg","kremer","masonmm","mediadb","metanogen","microbe-directory","nielsensl","pasteur","patric",
                               "prochlorococcus","protraits","roden-jin","rrndb","schulz-jorgensen","silva")

#Process single for testing:
#CONSTANT_PREPARE_DATASETS <- c("silva")


######################
# Trait condensation #
######################

# Update these vectors as more columns/traits are added

# Categorical traits
CONSTANT_CATEGORICAL_DATA_COLUMNS <- c("gram_stain", "metabolism", "pathways", "carbon_substrates", "sporulation", "motility", "range_tmp", "range_salinity", "cell_shape", "isolation_source", "cogem_classification")

# Continuous traits
CONSTANT_CONTINOUS_DATA_COLUMNS <- c("d1_lo","d1_up", "d2_lo", "d2_up", "doubling_h", "genome_size", "gc_content", "coding_genes", "optimum_tmp", "optimum_ph", "growth_tmp", "rRNA16S_genes", "tRNA_genes")

# Other data
CONSTANT_OTHER_COLUMNS <- c("tax_id", "species_tax_id", "data_source", "org_name", "species", "genus", "family", "order", "class", "phylum", "superkingdom", "reference", "ref_type")

# Vector of all data columns
CONSTANT_ALL_DATA_COLUMNS <- c(CONSTANT_CATEGORICAL_DATA_COLUMNS, CONSTANT_CONTINOUS_DATA_COLUMNS)

# Vector of all columns required in final output
CONSTANT_FINAL_COLUMNS <- c(CONSTANT_OTHER_COLUMNS, CONSTANT_ALL_DATA_COLUMNS, "ref_id")
CONSTANT_FINAL_COLUMNS <- CONSTANT_FINAL_COLUMNS[!(CONSTANT_FINAL_COLUMNS %in% c("reference","ref_type"))]


# List any data column that has an associated renaming table 
# Note: These tables must be named as "renaming_column-name".csv

CONSTANT_DATA_FOR_RENAMING <- c("cell_shape", "gram_stain", "isolation_source", "metabolism", "pathways", "carbon_substrates", "motility", "range_salinity", "range_tmp", "sporulation")

# List data that needs to be translated but that are in comma delimited form from original source
# (i.e. each data point takes the form of 'x, y, z ...')
CONSTANT_DATA_COMMA_CONCATENATED <- c("pathways","carbon_substrates")

#Species names starting with 'Candidatus' are by definition uncultured organisms, 
#but in some cases these still have various trait data assigned to them which would generally 
#require culturing (such as for oxygen requirement 'metabolism')
#Any traits that is unlikely to have been properly assessed for an uncultured organism
#should be listed in the vector below. This will ensure that this trait is set to NA for all 
#such organisms after the trait condesation
CONSTANT_REMOVE_FROM_CANDIDATUS <- c("metabolism")

# Choose if the NCBI phylogeny should be used as 
# space filler in the GTDB phylogeny (if applicable)
# Because some NCBI species missing from GTDB
CONSTANT_FILL_GTDB_WITH_NCBI <- FALSE

########################
# Species condensation #
########################

# Categorical traits
# Some categorical traits need to be processed throught their own function (special),
# mostly because no simple decision can be made on what to prioritise. Hence, 
# any traits listed in below vector will be excluded form the general method of condensing 
# categorical traits
CONSTANT_SPECIAL_CATEGORICAL_TRAITS <- c("isolation_source", "pathways", "carbon_substrates")

# Create a list of general categorical traits to process using the normal function
CONSTANT_GENERAL_CATEGORICAL_PROCESSING <- CONSTANT_CATEGORICAL_DATA_COLUMNS[!CONSTANT_CATEGORICAL_DATA_COLUMNS %in% CONSTANT_SPECIAL_CATEGORICAL_TRAITS]

# Set the proportion of total a trait must occupy in order to be selected during species condensation
# If more than one trait exists at a higher proportion than the set value, 
# the script selects the most represented trait value.  
# If two trait values are equally represented, the first value will be extracted
CONSTANT_DOMINANT_TRAIT_PROPORTION <- 50

# Set which stringency (priority) level a trait must be selected by if it cannot be 
# chosen based on simple proportion indicated in above. This must be set to "max" or "min"
# "max" means if a two trait values exists in the selected category, the one with the highest
# stringency level will be selected (i.e. for metabolism, "obligate aerobic" = 2 > "aerobic" = 1)
CONSTANT_DOMINANT_TRAIT_PRIORITISE <- "max"

#######################################################
# Constants for calcualting standardised growth rates #
#######################################################

CONSTANT_GROWTH_RATE_ADJUSTMENT_FINAL_TMP <- 20
CONSTANT_GROWTH_RATE_ADJUSTMENT_Q10 <- 2
