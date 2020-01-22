# The workflow

# Check for and install required packages
source("R/packages.R")

# Load functions
source("R/functions.R")

# Load settings
source("R/settings.R")

# Retrieve large files not in the GitHub repo
if (!file.exists("output/taxonomy/taxonomy_names.csv")) {
  download.file(url="https://ndownloader.figshare.com/files/14875220?private_link=ab40d2a35266d729698c", destfile = "output/taxonomy/taxonomy_names.csv")
}

if (!file.exists("data/raw/patric/genome_metadata.txt")) {
  download.file(url="ftp://ftp.patricbrc.org/RELEASE_NOTES/genome_metadata", destfile = "data/raw/patric/genome_metadata.txt")
}

# Load raw NCBI taxonomy table if not already loaded; takes a while but only done once
if(!exists('nam') || !is.data.frame(get('nam'))) {
  nam <- read.csv("output/taxonomy/taxonomy_names.csv", as.is=TRUE)
}

# Load NCBI archaea and bacteria tax_id, species_tax_id and taxonomy hierarchy if not already loaded
if(!exists('tax') || !is.data.frame(get('tax'))) {
  tax <- read.csv("output/taxonomy/ncbi_taxmap.csv", as.is=TRUE)
  tax <- unique(tax[, names(tax)])
}

# 1. Preparing original datasets (see/edit list in settings.R)
# Refer to README.md files in each of the original dataset directories for more information.
for(q in 1:length(CONSTANT_PREPARE_DATASETS)) {
  prepare_dataset(CONSTANT_PREPARE_FILE_PATH,CONSTANT_PREPARE_DATASETS[q])
}

# source("R/preparation/bacdive-microa.R")
# source("R/preparation/campedelli.R")
# source("R/preparation/corkrey.R")
# source("R/preparation/edwards.R")
# source("R/preparation/engqvist.R")
# source("R/preparation/fierer.R")
# source("R/preparation/genbank.R")
# source("R/preparation/gold.R")
# source("R/preparation/jemma-refseq.R")
# source("R/preparation/kegg.R")
# source("R/preparation/kremer.R")
# source("R/preparation/masonmm.R")
# source("R/preparation/mediadb.R")
# source("R/preparation/metanogen.R")
# source("R/preparation/microbe-directory.R")
# source("R/preparation/nielsensl.R")
# source("R/preparation/pasteur.R")
# source("R/preparation/patric.R")
# source("R/preparation/prochlorococcus.R")
# source("R/preparation/protraits.R")
# source("R/preparation/rrndb.R")
# source("R/preparation/silva.R")

# 2. Merging

# Choose taxonomy to be used ("NCBI" or Genome Taxonomy Database "GTDB"). Note that all other CONSTANTS are set in the "R/settings.R" file loaded above.
CONSTANT_BASE_PHYLOGENY <- "NCBI"

source("R/condense_traits.R")
source("R/condense_species.R")
