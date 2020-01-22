
# General functions used in many R scripts
options(stringsAsFactors=FALSE)


# PREPARATION

prepare_dataset <- function(CONSTANT_PREPARE_FILE_PATH,file) {
  # Create file path
  runfile <- sprintf("%s/%s.R",CONSTANT_PREPARE_FILE_PATH,file)
  # Run file
  print(sprintf("Processing data-set: %s...",file))
  source(runfile)
  print("Done")
}


# TRAIT CONDENSATION

load_prepared_dataset <- function(file) {
  
  #Extract unique name for reference
  data_source <- gsub(".csv","",file)
  
  dat <- read.csv(sprintf("output/prepared_data/%s",file))
  # Add prefix to column names
  names(dat) <- paste0(sprintf("%s.",data_source), names(dat))
  # Add source column
  dat$data_source <- data_source
  
  #output
  return(as.data.frame(dat))
}

# SPECIES CONDENSATION


# Function to obtain mean, stdev and count of all continuous traits

condense_continous_traits <- function(df,data,trait){
  
  results <- data %>% group_by(species) %>% 
    filter(!is.na(.data[[trait]])) %>% 
    summarise(n = n(), mean = mean(.data[[trait]]), stdev = sd(.data[[trait]])) %>% 
    mutate(mean = sprintf("%0.3f", mean)) %>% 
    mutate(stdev = sprintf("%0.3f", stdev))
  
  #Replace NaN with 0
  results$stdev[results$stdev == "NaN"] <- 0
  results$stdev[results$stdev == "NA"] <- NA
  
  # Join columns on to main data frame by species, 
  df <- df %>% left_join(results, by = "species")
  
  # Move data from temporary columns to main columns
  # Use n column to select rows from where to move data from
  df[!is.na(df$n),trait] <- as.double(df$mean[!is.na(df$n)])
  df[!is.na(df$n),sprintf("%s.stdev",trait)] <- as.double(df$stdev[!is.na(df$n)])
  df[!is.na(df$n),sprintf("%s.count",trait)] <- as.integer(df$n[!is.na(df$n)])
  
  # #Remove temporary columns
  df <- subset(df, select = -c(mean,n,stdev))
  
  #Return updated data frame
  return(df)
}  


# Function to select categorical trait value based on its proportion of the total
# If a decission cannot be made based on simple proportional representation, 
# a set of category and priority rules will be applied using lookup tables

condense_categorical_traits <- function(df,data,minProp,trait,priority=FALSE){
  
  # Count occurences of each trait value for each species
  t <- data %>% group_by(species,.data[[trait]]) %>% 
    filter(!is.na(.data[[trait]])) %>% 
    summarise(n = n())
  
  # Count number of different trait values
  t2 <- t %>% group_by(species) %>% 
    summarise(total = sum(n))
  
  # Join total count with per variable count
  t3 <- inner_join(t,t2, by = "species")
  
  # Calculate proportional representation of each trait value out of total
  t3 <- t3 %>% mutate(prop = n / total * 100)
  
  #Get maximum proportion for any given species
  #If two identical values exists, the first value will be selected
  results <- t3 %>% group_by(species) %>%
    filter(prop > minProp) %>%
    top_n(n=1,prop) %>% 
    filter(!duplicated(species))
  
  #Reduce decimal places
  results <- results %>% mutate(prop = sprintf("%0.1f",prop))
  
  
  ######
  # This section deals with data that was not resolved in above
  # Currently this only relates to "metabolism" and "motility"
  
  # Get any species that were not processed above 
  # and check if rules can help decide what to keep
  
  ruling <- t3 %>% filter(!(species %in% results$species)) %>% 
    mutate(prop = sprintf("%0.1f",prop))
  
  if(nrow(ruling)>0) {
    
    print(sprintf("Data for %s species require processing using category and priority tables",length(unique(ruling$species))))
    
    #Use priority ruling to decide which terms to keep
    #Categories and priorities values are located in the respective
    #traits renaming table
    
    # Get renaming table 
    file <- sprintf("renaming_%s.csv",trait)
    #Get file
    cat <- read.csv(sprintf("%s/%s",CONSTANT_LOOKUP_TABLE_PATH ,file), as.is=TRUE)
    
    if(nrow(cat)>0) {

      print(sprintf("Applying rules to decide %s for remaining species using file %s",trait,file))
      
      #Remove duplicated rows in lookup table
      cat <- cat[!duplicated(cat$New) ,c("New", "Priority", "Category")]
      
      # Attach grouping cateogories and priorities by the trait value
      # Note: Translated trait values are stored in the lookup table column "New"
      
      var1 <- trait
      var2 <- "New"
      ruling <- ruling %>% inner_join(cat, by = setNames(nm=var1, var2))
      
      # Count number of distinct categories for each species 
      # (if more than one, the data is contradictory)
      inconsistent <- ruling %>% group_by(species) %>% 
        summarise(n_cats = n_distinct(Category)) %>% 
        filter(n_cats >1)
      
      print(sprintf("%s species have inconsistent data, data removed", length(unique(inconsistent$species))))
      
      # Remove all species with multiple categories 
      # (data points contradictory, i.e. both anaerobic and aerobic)
      ruling <- ruling %>% filter(!(species %in% inconsistent$species))
      
      # From here, the ruling table only contains species for which 
      # we should be able to make a decission (if any left)
      
      if(nrow(ruling)>0) {
        
        # There are species with multiple trait values within a category
        # Chose which to keep based on setting
        
        if(priority == "max") {
          #Keep the most stringent (most informative) level (i.e. aerobic = 1, obligate aerobic = 2, keep #2)
          
          print("Chosing terms with MAXIMUM stringency")
          
          ruling <- ruling %>% group_by(species) %>% 
            filter(Priority == max(Priority))
          
        } else if(priority == "min") {
          #Keep the least stringent (least informative) word (i.e. aerobic = 1, obligate aerobic = 2, keep #1)
          
          print("Chosing terms with MININIMUM stringency")
          
          ruling <- ruling %>% group_by(species) %>% 
            filter(Priority == min(Priority))
        }
      
        # If any of the remaining species are recorded with multiple terms at the same priority level
        # (such as for motility "flagella" = 2 and gliding = 2), 
        # simply reduce the term to the lowest stringency level such as "yes" = 1
        
        # Get species still listed with more than one term (duplicated)
        update <- ruling[duplicated(ruling$species),]
        
        if(nrow(update)>0) {
          
          print(sprintf("%s species have multiple terms at same priority level, reducing to lower level priority", length(unique(update$species)))) 
          
          # Get data for these species from the current ruling table
          #update <- ruling %>% inner_join(update, by = "species")
          
          #Get just one row per species
          #update <- update[!(duplicated(update$species)),]
          
          #Update table
          for(i in 1:nrow(update)) {
            update[i,trait] <- as.character(cat[cat$Category == update$Category[i] & cat$Priority == (update$Priority[i]-1),"New"])
            # Since we're changing the data, we remove counts and proportions
            update[i,c("n","prop")] <- NA
          }
          
          #Remove redundant species from ruling table
          ruling <- ruling[!(ruling$species %in% update$species),]
          #Append newly updated species to ruling table
          ruling <- ruling %>% bind_rows(update)
          
        }
      
        # Finally, remove all species that could not be resolved in this process
        remove <- ruling %>% group_by(species) %>% 
          summarise(count = n()) %>% 
          filter(count > 1)
        
        if(nrow(remove)>0) {
          print(sprintf("Data for %s could not be processed, removed",length(unique(remove$species))))
          ruling <- ruling %>% filter(!(species %in% remove$species))
        }
        
        #Remove priority and category columns
        ruling <- subset(ruling, select = -c(Priority, Category))
        
        # Append ruled species to results
        results <- results %>% bind_rows(ruling)
        
      }
    }
  }
  #####
  
  #Attach to original data frame for data transfer
  
  #Change name of trait column to fixed
  colnames(results)[which(names(results) == trait)] <- "trait"
  
  # Join columns on to main data frame by species, 
  df <- df %>% left_join(results, by = "species")
  
  # Move data from temperary columns to main columns
  # Use total column to select rows from where to move data from
  df[!is.na(df$total),trait] <- as.character(df$trait[!is.na(df$total)])
  df[!is.na(df$total),sprintf("%s.prop",trait)] <- as.numeric(df$prop[!is.na(df$total)])
  df[!is.na(df$total),sprintf("%s.count",trait)] <- as.numeric(df$n[!is.na(df$total)])
  
  #Remove temporary columns
  df <- subset(df, select = -c(trait,total,n,prop))
  
  print("---finished---")
  
  #Return updated data frame
  return(df)
}


# FILL GTDB WITH NCBI

# Function to fill in missing species in the GTDB
# data frame with species from the NCBI phylogeny
# Note: This function is quite slow

fill_gtdb_with_ncbi <- function(df,gtdb) {
  
  print("Filling any missing GTDB phylogeny with data from NCBI")
  print("(This may take a long time!)")
  
  dat <- df %>% left_join(gtdb, by = c("species_tax_id"="ncbi_species_taxid"))
  
  # Just to keep track of the rows we're manipulating below
  # flag is initially set to TRUE wherever phylum is missing
  dat$flag_gtdb <- is.na(dat$phylum_gtdb) 
  
  #Add tag for at what level the gtdb data takes over the ncbi data
  dat$gtdb_phyl_lvl[!is.na(dat$species_gtdb)] <- "species"
  
  dat$speciesagg[!is.na(dat$species_gtdb)] <- dat$species_gtdb[!is.na(dat$species_gtdb)]
  
  rows_to_process <- nrow(dat[!is.na(dat$flag_gtdb),])
  
  #For each row where flag is TRUE (species doesn't exist in gtdb)
  for (i in which(dat$flag_gtdb)) {
    
    #Output for user 
    if(i %% 100==0) {
      perc <- i/rows_to_process*100
      perc <- round(perc,digits = 2)
      print(sprintf("%s percent processed",perc))
    }
    
    #If there is a genus in the gtdb that matches the genus for the missing species that exists in NCBI, get that data
    temp <- dat[!is.na(dat$genus_gtdb) & dat$genus_gtdb==dat$genus[i], ][1,]
    
    #If temp contains ANY data (a match was found at genus level)
    if (!is.na(temp$species[1])) {
      
      #Add the gtdb phylogeny information picked from the similar genus to this new species row
      dat$superkingdom_gtdb[i] <- temp$superkingdom_gtdb
      dat$phylum_gtdb[i] <- temp$phylum_gtdb
      dat$class_gtdb[i] <- temp$class_gtdb
      dat$order_gtdb[i] <- temp$order_gtdb
      dat$family_gtdb[i] <- temp$family_gtdb
      dat$genus_gtdb[i] <- temp$genus_gtdb
      
      #Add the original ncbi species name to the speciesagg column since this orgnanism doesn't currently exist in the gtdb phylogeny
      dat$speciesagg[i] <- dat$species[i]
      #Add tag for at what level the gtdb data takes over the ncbi data
      dat$gtdb_phyl_lvl[i] <- "genus"
      
    } 
    #and then repeat at family level 
    else {
      
      temp <- dat[!is.na(dat$family_gtdb) & dat$family_gtdb==dat$family[i],][1,]
      
      if (!is.na(temp$species[1])) {
        dat$superkingdom_gtdb[i] <- temp$superkingdom_gtdb
        dat$phylum_gtdb[i] <- temp$phylum_gtdb
        dat$class_gtdb[i] <- temp$class_gtdb
        dat$order_gtdb[i] <- temp$order_gtdb
        dat$family_gtdb[i] <- temp$family_gtdb
        
        #Here genus level information is missing, as we cannot know 
        #what genus name is appropriate for the gtdb phylogeny
        
        #Add the original ncbi species name to the speciesagg column
        dat$speciesagg[i] <- dat$species[i]
        #Add tag for at what level the gtdb data takes over the ncbi data
        dat$gtdb_phyl_lvl[i] <- "family"
        
      } else {
        temp <- dat[!is.na(dat$order_gtdb) & dat$order_gtdb==dat$order[i],][1,]
        if (!is.na(temp$species[1])) {
          dat$superkingdom_gtdb[i] <- temp$superkingdom_gtdb
          dat$phylum_gtdb[i] <- temp$phylum_gtdb
          dat$class_gtdb[i] <- temp$class_gtdb
          dat$order_gtdb[i] <- temp$order_gtdb
          
          #Here family level information is missing, as we cannot know 
          #what family name is appropriate for the gtdb phylogeny
          
          #Add the original ncbi species name to the gtdb species column
          dat$speciesagg[i] <- dat$species[i]
          #Add tag for at what level the gtdb data takes over the ncbi data
          dat$gtdb_phyl_lvl[i] <- "order"
          
        } else {
          temp <- dat[!is.na(dat$class_gtdb) & dat$class_gtdb==dat$class[i],][1,]
          if (!is.na(temp$species[1])) {
            dat$superkingdom_gtdb[i] <- temp$superkingdom_gtdb
            dat$phylum_gtdb[i] <- temp$phylum_gtdb
            dat$class_gtdb[i] <- temp$class_gtdb
            
            #Add the original ncbi species name to the speciesagg column
            dat$speciesagg[i] <- dat$species[i]
            #Add tag for at what level the gtdb data takes over the ncbi data
            dat$gtdb_phyl_lvl[i] <- "class"
            
          } else {
            temp <- dat[!is.na(dat$phylum_gtdb) & dat$phylum_gtdb==dat$phylum[i],][1,]
            if (!is.na(temp$species[1])) {
              dat$superkingdom_gtdb[i] <- temp$superkingdom_gtdb
              dat$phylum_gtdb[i] <- temp$phylum_gtdb
              
              #Add the original ncbi species name to the speciesagg column
              dat$speciesagg[i] <- dat$species[i]
              #Add tag for at what level the gtdb data takes over the ncbi data
              dat$gtdb_phyl_lvl[i] <- "phylum"
              
            } else {
              # break()
            }
          }
        }
      }
    }
  }
  
  #Transfer speciesagg data to species_gtdb
  dat$species_gtdb <- dat$speciesagg
  #Remove unneeded columns
  dat$flag_gtdb <- NULL
  dat$speciesagg <- NULL
  
  print("Done")
  return(dat)
}



# GENERAL

# Function to clear R environment but leave constants and functions
clear_envr <- function() {
  #Get all
  all <- ls(.GlobalEnv)
  funs <- lsf.str(all.names=TRUE)
  cons <- all[grepl("CONSTANT_",all)]
  keep <- c(funs,cons)
  remove <- setdiff(all, keep)
  #Remove selected
  rm(list=remove)  
  #Clean up
  rm(all,funs,cons,keep,remove)
}


# OLD


wideScreen <- function(howWide=Sys.getenv("COLUMNS")) {
  options(width=as.integer(howWide))
}

# returns string w/o leading whitespace
trim.leading <- function (x)  sub("^\\s+", "", x)

# returns string w/o trailing whitespace
trim.trailing <- function (x) sub("\\s+$", "", x)

# returns string w/o leading or trailing whitespace
trim <- function (x) gsub("^\\s+|\\s+$", "", x)

# Removes html from string
trimHtml <- function(htmlString) {
  return(gsub("<.*?>", "", htmlString))
}

# Volume ellipsoid
vol_ell <- function(a, b=a, c=a) {
	b[is.na(b)] <- a[is.na(b)]
	# c[is.na(c)] <- b[is.na(c)]
	(4/3)*pi*a*b*c
}

# Whether word "a" occur within distance "d" of word "b"
word_dist <- function(a, b, d=50) {
	ad <- abs(a - b)
	if (min(ad) <= 50) {
		return(which.min(ad))
	} else {
		return(NA)
	}
}

resolve_shape <- function(x) {
	shape <- "not_resolved"
	if (!all(is.na(x))) {
		if (x[1] & !x[2]) {
			shape <- "bacilloid"
		}
		if (!x[1] & x[2]) {
			shape <- "coccus"
		}
		if ((!x[1] & !x[2]) | (x[1] & x[2])) {
			if (x[3] & !x[4]) {
				shape <- "bacilloid"
			}
			if (!x[3] & x[4]) {
				shape <- "coccus"
			}
		}
	}
	return(shape)
}

diam_mean <- function(x) {

	store <- rep(NA, 2)
	for (i in c(1, 3)) {

		if (!is.na(x[i]) & !is.na(x[i+1])) {
			store[(i+1)/2] <- mean(c(x[i], x[i+1]))
		}
		if (!is.na(x[i]) & is.na(x[i+1])) {
			store[(i+1)/2] <- x[i]
		}
		if (is.na(x[i]) & !is.na(x[i+1])) {
			store[(i+1)/2] <- x[i+1]
		}
		if (is.na(x[i]) & is.na(x[i+1])) {
			store[(i+1)/2] <- NA
		}
	}
	if (is.na(store[1]) & !is.na(store[2])) {
		store[1] <- store[2]
		store[2] <- NA
	}
	if (!is.na(store[1]) & !is.na(store[2])) {
		if (store[1] > store[2]) {
			ss <- store[1]
			store[1] <- store[2]
			store[2] <- ss
		}
	}

	return(list(d1=store[1], d2=store[2]))
}

# Convert excel dates into their respective number ranges
excel_dates_to_numbers <- function(x) {
  
  #split date (format x-Month or Month-x)
  d <- strsplit(x, "-")
  #Extract character info (month)
  month <- gsub("[[:digit:]]","",x)
  #Use character info to extract number
  num1 <- as.numeric(gsub(month,"",x))
  #remove - from month
  month <- gsub("-","",month)
  
  #convert month to number
  num2 <- switch(month, 
                 "Jan" = 1,
                 "Feb" = 2, 
                 "Mar" = 3,
                 "Apr" = 4,
                 "May" = 5,
                 "Jun" = 6,
                 "Jul" = 7,
                 "Aug" = 8,
                 "Sep" = 9,
                 "Oct" = 10, 
                 "Nov" = 11,
                 "Dec" = 12
  )
  
  if(!is.null(num2)) {
    #Sort output
    output <- sort(as.numeric(c(num1,num2)), decreasing = FALSE)
  } else {
    #String doesn't contain month info, output as original array
    output <- sort(as.numeric(unlist(d)), decreasing = FALSE) 
  }
  #Return new string
  output
}

# Function to convert ranges to average values
func_average_range <- function(x) {
  if(!is.na(x)) {
    a <- strsplit(x,split='-', fixed=TRUE)
    if(lengths(a) == 2) {
      a <- unlist(a)
      if(is.numeric(as.numeric(a[1])) & is.numeric(as.numeric(a[2]))) {
        v <- (as.numeric(a[1])+as.numeric(a[2]))/2
        return(v) 
      } else {
        return(NA)
      }
    } else {
      return(as.numeric(x))
    }
  } 
}

# Function used to convert units to um

convert_unit <- function(x,unit) {
  x <- as.numeric(x)
  if (unit == "nm") {
    x <- x/1000
  } else if (unit == "mm") { 
    x <- x*1000
  } else if (unit == "cm") {
    x <- x*10000
  } else {
    #print(sprintf("Error: Could not convert unit %s",unit))
  }
  x <- format(x, scientific = FALSE)
}

# Functions used to get NBCI taxon information

get_species <- function(accession) {

	accession <- trim(accession)
	accession <- strsplit(accession, "äóñ|,|-|and|/")[[1]][1]
	accession <- trim(accession)
	accession <- gsub("(Unclear)  |26S given only; |", "", accession)
	accession <- strsplit(accession, " ")[[1]][1]
	accession <- as.character(accession)

	species <- NA
	acc_id <- NA
	tax_id <- NA
	ScientificName <- NA
	SpeciesID <- NA
	Species <- NA
	
	if (!is.na(accession) & accession != "") {

		acc_url <- paste0("https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=nucleotide&term=", accession, "[accn]")
		acc_get <- getURL(acc_url)
		acc_id <- gsub(".*<Id>|</Id>.*", "", acc_get)

		if (!grepl("xml|DOCTYPE", acc_id)) {

			tax_url <- paste0("https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=nucleotide&id=", acc_id)
			tax_get <- getURL(tax_url)
			tax_id <- gsub(".*<Item Name=\"TaxId\" Type=\"Integer\">|</Item>.*", "", tax_get)

			spe_url <- paste0("https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=taxonomy&id=", tax_id)
			spe_get <- getURL(spe_url)

			TaxaSet <- xmlParse(spe_get)
			TaxaSet <- xmlRoot(TaxaSet)
			ScientificName <- xmlValue(TaxaSet[[1]][["ScientificName"]])
			LineageEx <- TaxaSet[[1]][["LineageEx"]]
			LineageEx <- xmlSApply(LineageEx, function(x) xmlSApply(x, xmlValue))
			LineageEx <- data.frame(t(LineageEx),row.names=NULL, stringsAsFactors=FALSE)
			
			Species <- ScientificName
			SpeciesID <- tax_id
			if (any(LineageEx$Rank=="species")) {
			  Species <- LineageEx$ScientificName[LineageEx$Rank=="species"]
			  SpeciesID <- LineageEx$TaxId[LineageEx$Rank=="species"]
			}
			  
		} else {
			acc_id <- NA
		}
	}
	print(paste(accession, " -- ", Species))
	return(data.frame(accession=accession, ncbi_nucid=acc_id, ncbi_taxid=tax_id, name=ScientificName, ncbi_spid=SpeciesID, ncbi_species=Species))
}

# species <- "Acinetobacter ADP1"

check_species <- function(species) {

  if (grepl("subsp", species)) {subsp <- TRUE} else {subsp <- FALSE}
  if (grepl("f. sp.", species)) {fsp <- TRUE} else {fsp <- FALSE}
  if (grepl("^Candidatus ", species)) {candidatus <- TRUE
    species <- trim(gsub("Candidatus", "", species))
  } else {candidatus <- FALSE}
  
#  species <- "Terriglobus roseus"
  species2 <- gsub(" ", "+", species)
  
  tax_url <- paste0("https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=taxonomy&term=", species2)
  tax_get <- getURL(tax_url)
  tax_id <- gsub(".*<Id>|</Id>.*", "", tax_get)

  
  if (!grepl("xml|DOCTYPE", tax_id)) {
      
    spe_url <- paste0("https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=taxonomy&id=", tax_id)
    spe_get <- getURL(spe_url)
    
    TaxaSet <- xmlParse(spe_get)
    TaxaSet <- xmlRoot(TaxaSet)
    ScientificName <- xmlValue(TaxaSet[[1]][["ScientificName"]])
    LineageEx <- TaxaSet[[1]][["LineageEx"]]
    LineageEx <- xmlSApply(LineageEx, function(x) xmlSApply(x, xmlValue))
    LineageEx <- data.frame(t(LineageEx),row.names=NULL, stringsAsFactors=FALSE)
    
    Species <- ScientificName
    SpeciesID <- tax_id
    if (any(LineageEx$Rank=="species")) {
      Species <- LineageEx$ScientificName[LineageEx$Rank=="species"]
      SpeciesID <- LineageEx$TaxId[LineageEx$Rank=="species"]
    }
    
  } else {
    tax_id <- NA
    ScientificName <- NA
    SpeciesID <- NA
    Species <- NA
  }
  print(paste(species, " -- ", Species))
  return(data.frame(species=species, subsp, formasp=fsp, candidatus, ncbi_taxid=tax_id, name=ScientificName, ncbi_spid=SpeciesID, ncbi_species=Species))
}


# Adjust doubling time for temperature
temp_adjust_doubling_h <- function (d1,org_tmp,final_tmp,Q10) {
  
  #Convert doubling time to specific growth rate
  #Formula used:
  #g = ln(2)/d

  g1 <- log(2, exp(1))/as.numeric(d1)
  
  #Formula used:
  #g2 = g1 * Q10^((T2-T1)/10)
  #g2 = g1 * 2^((20-T1)/10)
  
  g2 <- g1*Q10^((final_tmp-as.numeric(org_tmp))/10)
  
  d2 <- log(2, exp(1))/g2
  
  return(d2)
}




