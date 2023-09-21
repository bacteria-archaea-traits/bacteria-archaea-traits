## liampshaw dataset 
library(tidyverse)
pathogen_vs_host_db <- read.csv('~/Desktop/CU/work/Pathogen-host-range/data/PathogenVsHostDB-2019-05-30.csv', 
                                stringsAsFactors = F) %>% 
                          filter(Type == "Bacteria") %>%
                          select(
                                  c("Species", "HostGroup", "Human", "Association", "Disease", "VectorBorne", "Cell", 
                                    "GramStain", "Motility", "Spore", "Oxygen", "Infection", "Genome.GC")
                                ) 
condensed_species <- read_csv("output/condensed_species_NCBI.csv")

## Association: pathogenic, pathogenic?, Apathogenic, and Apathogenic?
## Joining techniques; join by host level eg. human
## Assumptions for each species will have only one host specification. 

## use left_join
## condensed species

by <- join_by(species == Species)

condensed_liamp_shaw <- left_join(condensed_species, pathogen_vs_host_db, by)
cols <- c("gram_stain","sporulation", "motility", "metabolism", "gc_content")
run_stats(cols)

## check the pathogenicity columns: 
gol <- read_csv("output/prepared_data/gold.csv")
df <- get_host_specific_gold_condensed_data(condensed_liamp_shaw, gol, "human")
