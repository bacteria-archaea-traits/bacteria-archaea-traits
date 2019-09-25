# GOLD notes

Data obtained from the JGI genome online database (GOLD). 

https://gold.jgi.doe.gov/

This data cannot be downloaded in its entirety from the website, and direct contact with JGI is therefore required.However, an older version is available here.

- The GOLD metadata export is very large and left as two zipped files:

(1) `Mark_Westoby_Organism_Metadata_Export_02152018.txt.zip`
This file contains the main trait data for each organism

(2) `Mark_Westoby_Genome_Size_Details_Export_02152018.txt.zip`
This file contains genome size estimates and are linked to the main data file using the gold organism id.

- To load the GOLD data, you need to unzip the two files. 

Since much of the GOLD data is input by individual users, there are a considerable number of inconsistencies, which is sorted out in the preparation process. 

This includes 

- conversion of different units to consistent terminology (i.e. "microns" -> "um") as well as same unit through calculation (i.e. "nm" -> "um")
- removal of units for temperature (i.e. "C", "degrees", "celsius"...)
- splitting different size range formats into separate columns and ensuring "length" is longer than "width".



