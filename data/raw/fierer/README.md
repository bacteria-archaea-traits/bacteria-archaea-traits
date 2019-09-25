# Fierer notes

- There were some issues with the Fierer data as release with their paper. 
- We contacted the group and received the `ijsem_05_05_15_clean.csv` dataset.
- The "clean" dataset contained a subset of the original dataset's columns
- Also, there were still accession numbers missing (and various other things) which have been addressed in `ijsem_05_05_15_clean_fixed.csv`
- `ijsem_05_05_15_clean_fixed.csv` is currently the dataset processed and used for analyses.

### Initial data setup (ignore)

The Fierer data were initially run through the following code from their figshare README.txt file in order to prep the data, which was then saved as a csv for our analysis.

Note that despite their reliance on accession number, I needed to go and find some from the original sources at IJSEM. Probably just some data entry issues on their end. I used the DOI in the spreadsheet to track down the original paper and extracted accession numbers from these papers.

\*Do not run this code again, because it will overwrite the datafile, in which I added the missing accessions numbers.

	#read table
	ijsem<-read.delim("data/fierer/ijsem_05_05_15_clean.txt", sep="\t", header=T, check.names=F, fill=T, na.strings=c("NA", "", "Not indicated", " Not indicated","not indicated", "Not Indicated", "n/a", "N/A", "Na", "Not given", "not given","Not given for yeasts", "not indicated, available in the online version", "Not indicated for yeasts", "Not Stated", "Not described for yeasts", "Not determined", "Not determined for yeasts"))

	#simplify column names
	colnames(ijsem)<-c("Habitat", "Year", "DOI", "rRNA16S", "GC", "Oxygen", "Length", "Width", "Motility", "Spore", "MetabAssays", "Genus", "Species", "Strain", "pH_optimum", "pH_range", "Temp_optimum", "Temp_range", "Salt_optimum", "Salt_range", "Pigment", "Shape", "Aggregation", "FirstPage", "CultureCollection", "CarbonSubstrate", "Genome", "Gram", "Subhabitat", "Biolog")

	#clean Habitat column
	levels(ijsem$Habitat)[levels(ijsem$Habitat)=="freshwater (river, lake, pond)"]<-"freshwater"
	levels(ijsem$Habitat)[levels(ijsem$Habitat)=="freshwater sediment (river, lake, pond"]<-"freshwater sediment"

	#clean Oxygen column
	levels(ijsem$Oxygen)[levels(ijsem$Oxygen)=="aerobic"]<-"obligate aerobe"
	levels(ijsem$Oxygen)[levels(ijsem$Oxygen)=="anerobic"]<-"obligate anerobe"
	levels(ijsem$Oxygen)[levels(ijsem$Oxygen)=="microerophile"]<-"microaerophile"

	#clean pH_optimum column
	ijsem$pH_optimum<-as.character(ijsem$pH_optimum)
	#this step splits the range values and takes the mean value
	#values that are not numeric are transformed to NAs
	ijsem$pH_optimum<-sapply(ijsem$pH_optimum, simplify=T, function(x){mean(as.numeric(unlist(strsplit(x, split="-", fixed=T))))})
	#remove pH values <0 and >10
	ijsem$pH_optimum[ijsem$pH_optimum<0 | ijsem$pH_optimum>10]<-NA

	#clean Temp_optimum column
	ijsem$Temp_optimum<-as.character(ijsem$Temp_optimum)
	#this step splits the range values and takes the mean value
	#values that are not numeric are transformed to NAs
	ijsem$Temp_optimum<-sapply(ijsem$Temp_optimum, simplify=T, function(x){mean(as.numeric(unlist(strsplit(x, split="-", fixed=T))))})

	#clean Salt_optimum column
	ijsem$Salt_optimum<-as.character(ijsem$Salt_optimum)
	#this step splits the range values and takes the mean value
	#values that are not numeric are transformed to NAs
	ijsem$Salt_optimum<-sapply(ijsem$Salt_optimum, simplify=T, function(x){mean(as.numeric(unlist(strsplit(x, split="-", fixed=T))))})
	#there are some formatting issues that should be solved

	write.csv(ijsem, "data/fierer/IJSEM_pheno_db_v1.0.csv", row.names=FALSE)
