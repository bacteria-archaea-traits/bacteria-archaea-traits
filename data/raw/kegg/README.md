# KEGG notes

This dataset is extracted from online using a html spider. The code in `R/web_extraction/extract_kegg.R` opens this html page: 

[http://www.genome.jp/kegg-bin/show_organism?category=Prokaryotes](http://www.genome.jp/kegg-bin/show_organism?category=Prokaryotes)

The code extracts information from each of the weblinks in the html page and creates an intermediate output file back in the keeg raw data folder (found in `data/raw/kegg/`):
	- `kegg_full.csv` retains multiple rows for each strain corresponding with chromosome and plasmid information

The regular cleaning script then creates the final dataset (found in `output/cleaned_data/`):
	- `kegg.csv` aggregates the chromosome and plasmid data as counts for each strain 
