# Functions taxonomy

get_taxa <- function(txt) {
		# Get taxonomic information
	taxa <- gsub("“|”", "", txt[[1]][2])
	taxa <- trim(strsplit(taxa, "/")[[1]])

	if (length(taxa) == 1) {
		genus <- taxa
		taxa <- rep(NA, 4)		
	} else {
		genus <- trim(gsub("“|”|(gen. nov.)|(gen. nov)", "", txt[[1]][3]))
	}

	if (length(taxa) == 3) {
		taxa <- c(taxa, NA)
	}

	genus <- strsplit(genus, " ")[[1]]
	genus <- genus[length(genus)]

	if (genus == "Candidatus" | genus == "I." | genus == "VII." | genus == "VI." | genus == "XII." | genus == "XXVI.") {
		genus <- trim(gsub("“|”", "", txt[[1]][4]))		
	}

	if (genus == "Jeotigalicoccus") {
		genus <- "Jeotgalicoccus"
	}

	return(list(genus=genus, taxa=taxa))
}

get_tally <- function(txt) { 

	tally <- list()
	for (page in 1:length(txt)) {
		t1 <- txt[[page]]	
		t2 <- c(trim(substr(t1, 1, 90)), trim(substr(t1, 91, 1000)))

		if (length(grep("Bergey’s Manual Trust", t2)) > 0) {
			t2 <- t2[-grep("Bergey’s Manual Trust", t2)]
		}
		if (length(grep("Bergey’s Manual of Systematics", t2)) > 0) {
			t2 <- t2[-grep("Bergey’s Manual of Systematics", t2)]
		}

		t3 <- gsub("^[.]{90,}", "", t2)
		t4 <- t3[t3 != "" & !is.na(t3)]
		# t4[nchar(t4) > 80]

		tally[[page]] <- t4
	}
	tally <- unlist(tally)

	return(tally)
}


get_species_tally <- function(tally) { 

	# Remove top

	test <- grep("^List(s)? of.*species (of|in)", tally)
	if (length(test) == 0) {
		print("Check for species!")
		# warn <- paste(warn, "Check for species!", sep=";")
	} else {
		if (length(test) > 1) {
			print("There are multiple species lists!")
			# warn <- paste(warn, "Check for species!", sep=";")
		}
		tally <- tally[(test[1]+1):length(tally)]
	}

	# Removes references

	ref <- grep("(^References$)|(^Reference$)", tally)
	if (length(ref) == 1) {
		tally <- tally[1:(ref-1)]
	} else {
		print("Seems that there are no references!")
		# warn <<- paste(warn, "Check for species!", sep=";")
	}

	# Remove tables
	if (length(grep("[ ]{4,}", tally)) > 0) {
		tally <- tally[-grep("[ ]{4,}", tally)]
	}

	return(tally)
}

get_genus_tally <- function(tally) { 

	# Remove top

	test <- c()#grep("further descriptive information", tolower(tally))
	if (length(test) == 0) {
		test2 <- grep("taxonomic comments", tolower(tally))
		if (length(test2) == 0) {
			test3 <- grep("list of.*species (of|in) the genus", tolower(tally))
			if (length(test3) == 0) {
				test4 <- grep("references", tolower(tally))
				if (length(test4) == 0) {
					print("Check for descriptive information!")
					break()	
				} else {
					tally <- tally[1:(test4[1]-1)]
				}
			} else {
				tally <- tally[1:(test3[1]-1)]
			}
		} else {
			tally <- tally[1:(test2[1]-1)]
		}

	} else {
		tally <- tally[1:(test[1]-1)]
	}

	# Remove tables
	if (length(grep("[ ]{4,}", tally)) > 0) {
		tally <- tally[-grep("[ ]{4,}", tally)]
	}

	return(tally)
}

dot_prox <- function(line, dots) {
	dl <- dots - line
	any(dl[dl > 0] < 9)
}


get_species <- function(species_tally, taxa) {

	gens <- grep(paste0("^(“| |“ )?(Candidatus |Ca. |)", taxa$genus, " "), species_tally)
	dots <- grep("^[.]{6,}", species_tally)

	lines <- rep(NA, length(dots))

	for (d in 1:length(dots)) {

		dl1 <- dots[d] - gens
		dl2 <- sort(dl1[dl1 > 0])

		if (length(dl2) > 0) {
			if (length(dl2) > 1 & dl2[2] - dl2[1] < 14) {

				check1 <- strsplit(species_tally[dots[d] - dl2[1]], " ")[[1]]
				check2 <- strsplit(species_tally[dots[d] - dl2[2]], " ")[[1]]
				check3 <- strsplit(species_tally[dots[d] - dl2[3]], " ")[[1]]

				check1 <- check1[check1 != "“"]
				
				if (length(check1) == 2 | (length(check1) == 3 & any(grepl("Candidatus", check1))) | (length(check1) == 4 & any(grepl("subsp|biovar|pathovar", check1)))) {

					lines[d] <- dots[d] - dl2[1]

				} else {
					if (length(check2) == 2 | (length(check2) == 3 & any(grepl("Candidatus", check2))) | (length(check2) == 4 & any(grepl("subsp|biovar|pathovar", check2)))) {
						lines[d] <- dots[d] - dl2[2]
					} else {
						if (length(check3) == 2 | (length(check3) == 3 & any(grepl("Candidatus", check3))) | (length(check3) == 4 & any(grepl("subsp|biovar|pathovar", check3)))) {
							lines[d] <- dots[d] - dl2[3]
						} else {
							print("QQQQQQQQQQQQQQQQ")
						}
					}
				}
			} else {
				if (dl2[1] < 14) {
					lines[d] <- dots[d] - dl2[1]
				}
			}
		}
	}	

	lines <- unique(lines[!is.na(lines)])

	species_names <- gsub("“|”", "", species_tally[lines])
	species_names <- gsub("\\*", "", species_names)
	species <- data.frame(lines=lines, species_names=species_names)

	return(as.list(species))
}

get_species_txt <- function(pdf, spp=FALSE) {

	warn <- ""
	master <- data.frame()

	txt <- pdf_text(paste0("data/bergeys/genera/", pdf))
	txt <- strsplit(txt, "\n")

	taxa <- get_taxa(txt)
	tally <- get_tally(txt)

	if (pdf %in% fixes) {
		nn <- strsplit(pdf, "\\.")[[1]][1]
		species_tally <- read.table(paste0("output/bergeys/", nn, ".txt"))$V1
	} else {
		species_tally <- get_species_tally(tally)
	}

	species <- get_species(species_tally, taxa)
	
	if (length(species$lines) > 0 & !(any(is.na(species$lines)))) {
		for (i in 1:length(species$lines)) {

			if (i == length(species$lines)) {
				temp <- species_tally[species$lines[i]:length(species_tally)]
			} else {
				temp <- species_tally[species$lines[i]:(species$lines[i+1]-1)]
			}

			text <- paste(temp[2:length(temp)], collapse=" ")
			text <- gsub("- ", "", text)

			# Write data to data frame
			master <- rbind(master, data.frame(
				reference=pdf, 
				phylum=taxa$taxa[1], 
				class=taxa$taxa[2], 
				order=taxa$taxa[3], 
				family=taxa$taxa[4], 
				genus=taxa$genus, 
				species=trim(species$species_names[i]),
				# species_text=species$species_text[i],
				text=text,
				warnings=warn
			))
		}
	} else {
		print("BOOBOOBOOBOO")

		# missing <- rbind(missing, data.frame(reference=pdfs[pdf], issue="no species found"))
	}
	print(pdf)
	if (spp) {
		return(master$species)
	} else {
		return(master)
	}
}

get_genus_txt <- function(pdf) {

	warn <- ""
	txt <- pdf_text(paste0("data/bergeys/genera/", pdf))
	txt <- strsplit(txt, "\n")

	taxa <- get_taxa(txt)
	tally <- get_tally(txt)
	genus_tally <- get_genus_tally(tally)

	text <- paste(genus_tally[2:length(genus_tally)], collapse=" ")
	text <- gsub("- ", "", text)

	# Write data to data frame
	master <- data.frame(
		reference=pdf, 
		phylum=taxa$taxa[1], 
		class=taxa$taxa[2], 
		order=taxa$taxa[3], 
		family=taxa$taxa[4], 
		genus=taxa$genus, 
		text=text,
		warnings=warn
			)

	return(master)
}


