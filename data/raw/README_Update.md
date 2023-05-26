### Manual Extraction from Publications

| dataset  | Last Updated | Notes/Changes 
| ------------- | ------------- | ------------- |
| Amend-Shock  | 2020-01-30 | - 
| bacdive-microa  | 2019-09-25 | - 
| bergeys  | 2019-09-25 | - 
| campedelli  | 2019-09-25 | - 
| cockrey  | 2019-09-25 | New related publication: https://www.utas.edu.au/profiles/staff/tia/Ross-Corkrey
| edirisinghe  | 2019-09-25 | `Dataset not used.` No preparation script for preparing the dataset.
| edwards  | 2019-09-25 | New publications: https://sites.google.com/site/kyleedwardsresearch/resume
| engqvist  | 2019-09-25 | - 
| fierer  | 2019-09-25 | - 
| kremer  | 2019-09-25 | New publication: https://aslopubs.onlinelibrary.wiley.com/authored-by/ContribAuthorRaw/Kremer/Colin+T.
| nielsensl  | 2019-09-25 | Obtained from the author.
| pochlorococcus | 2019-09-25 | Obtained directly from Author.
| Roden-jin  | 2020-01-20 | -
| schulz-jorgensen | 2020-10-15 | - 
| silva | 2019-09-25 | - 

### Online datasets
| dataset  | Last Updated | Notes/Changes 
| ------------- | ------------- | ------------- |
| gold  | 2020-06-10 | Direct contact with JGI need to fully download the data
| kegg  | 2019-09-25 | - 
| mediadb  | 2019-09-25 | sql dumb dataset: No changes.
| metanogen  | 2019-09-25 | url changed: http://phymet2.biotech.uni.wroc.pl/
| microbe-directory  | 2019-09-25 | Unmaintained website: https://microbe.directory/




### Regularly updated datasets

| dataset  | Last Updated | Changes 
| ------------- | ------------- | ------------- |
| genbank  | 2023-04-24 | <li>Updated prokaryotes_ftp dataset</li><li>Rows changed from `162688` to `519202`</li><li>The dataset from browser not working for now; it canot be downloaded</li>
| pasteur  | 2023-05-01 | <li>Rows changed from `13201` to `13444`</li><li>Prepated data: rows changed from `5480` to `5518`</li>
| rrndb  | 2023-05-01 | <li>The rrndb version change from `5.4` to `5.8`</li><li>Rows changed from `8522` to `28140`</li><li>Prepated data: rows changed from `5669` to `11143`</li>
| faprotax  | 2023-05-02 | <li>Dataset changed to version 1.2.6 from 1.2.1</li><li>Prepared dataset: rows changed from `9026` to `9021`</li>

### Other changes: 
| dataset  | Last Updated | Changes 
| ------------- | ------------- | ------------- |
| patric  | 2023-05-01 | <li>New data link: `ftp://ftp.bvbrc.org/RELEASE_NOTES/genome_metadata`</li>

#### Issues faced
genbank:
- prokaryotes.txt:  wget ftp://ftp.ncbi.nlm.nih.gov/genomes/GENOME_REPORTS/prokaryotes.txt Local Updated: 2023-04-24
- prokaryotes_browser: __the dataset in from the website returns and empty file__

bergeys
- Data extract from all data in PDFs, more sufficient description of the data extraction coming soon.

jemma-refseq
- The dataset is large, and the extracting script run too slow.

### Resultant Datasets
| dataset  | Last Updated | Changes 
| ------------- | ------------- | ------------- |
| condensed traits  | 2023-05-10 | <li>Rows changed from `170k` to `190k`</li>
| condensed species  | 2023-05-10 | <li>Rows changed from `14893` to `15224`</li><li>Added taxons: `338`, deleted taxons: `7`, updated taxons: `14886` </li>

The deleted species are shown below:

| species_tax_id	| species	| genus
| ------------- | ------------- | ------------- |
| 1904441	| Rhodobacteraceae bacterium	| NaN
| 2045020	| Enterobacteriaceae bacterium NZ1215	| NaN
| 2026787	| Rhodothermaceae bacterium	| NaN
| 1095191	| Oceanobacillus gochujangensis	| Oceanobacillus
| 1649257	| Mycobacterium arcueilense	| Mycobacterium
| 1544867	| Burkholderia ultramafica	| Burkholderia
| 1544861	| Burkholderia novacaledonica	| Burkholderia
