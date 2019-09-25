# Genbank

The genbank dataset is a combination of two individual data files that can be obtained online from Genbank:

(1) prokaryotes_browser.csv is downloaded from 
https://www.ncbi.nlm.nih.gov/genome/browse#!/prokaryotes/

This file is generated using the browser ("Genome information by organism") and limiting the table output to prokaryotes and adding tRNA to the column list. The data is downloaded using the supplied download link once the search has completed.

(2) prokaryotes_ftp.txt is downloaded from 
ftp://ftp.ncbi.nlm.nih.gov/genomes/GENOME_REPORTS/prokaryotes.txt

This is the main prokaryote data file from genbank which is updated regularly.