# Functions traits
library(stringr)

# temp <- sdat$text[sdat$species=="Bifidobacterium adolescentis"]
# temp <- gdat$text[gdat$reference=="gbm00009.pdf"]
# temp <- sdat$text[sdat$species=="Actinoplanes auranticolor"]

# gdia[(!is.na(gdia$d1_lo) & is.na(gdia$d1_up) & !is.na(gdia$d2_lo) & is.na(gdia$d2_up)) | (!is.na(gdia$d1_lo) & is.na(gdia$d1_up) & is.na(gdia$d2_lo) & is.na(gdia$d2_up)),]

get_diams <- function(temp) {

	# temp <- tolower(temp)
	diam_unit <- diam_text <- NA
	d1_lo <- d1_up <- d2_lo <- d2_up <- NA

	# r0 <- "[^.?!]*(?<=[.?\\s!])((morulae|flagella).*(μm|𝛍m)|(μm|𝛍m).*(morulae|flagella))(?=[\\s.?!])[^.?!]*[.?!]"

	# One-off fixes
	temp <- gsub("0.2–0.5 mm by 3–30 mm", "0.2–0.5 μm by 3–30 μm", temp, fixed = TRUE)	
	temp <- gsub("2 × 0.5 to 6 × 1.4 μm", "0.5-1.4 × 2-6 μm", temp, fixed = TRUE)	
	temp <- gsub("(∼2 × 2 μm) and flat (0.2 mm thick)", "2 × 0.2 μm", temp, fixed = TRUE)
	temp <- gsub("= 0.5 μm", "", temp, fixed = TRUE)
	temp <- gsub("= 5 μm", "", temp, fixed = TRUE)
	temp <- gsub("= 10 μm", "", temp, fixed = TRUE)
	temp <- gsub("= 50 μm", "", temp, fixed = TRUE)
	temp <- gsub("= 1 μm", "", temp, fixed = TRUE)
	temp <- gsub("1 μm (0.5–1.6 μm) in width and 2.1 μm (1.6–3.2 μm)", "0.5–1.6 μm × 1.6–3.2 μm", temp, fixed = TRUE)
	temp <- gsub("10 μm 10 μm", "", temp, fixed = TRUE)

	m0 <- c()

	# Avoiding sizes related to different parts of cell or spores
	r0 <- "[^\\.]*(F|f)lagella.*?\\. "
	m0 <- c(m0, str_extract_all(temp, r0)[[1]])

	r0 <- "[^\\.]*(M|m)orulae.*?\\. "
	m0 <- c(m0, str_extract_all(temp, r0)[[1]])

	r0 <- "[^\\.]*(S|s)porangia.*?\\. "
	m0 <- c(m0, str_extract_all(temp, r0)[[1]])

	r0 <- "[^\\.]*(S|s)pore.*?\\. "
	m0 <- c(m0, str_extract_all(temp, r0)[[1]])

	r0 <- "[^\\.]*(H|h)yphae.*?\\. "
	m0 <- c(m0, str_extract_all(temp, r0)[[1]])

	r0 <- "[^\\.]*pyrite.*?\\. "
	m0 <- c(m0, str_extract_all(temp, r0)[[1]])

	r0 <- "[^\\.]*(B|b)ar.*?\\. "
	m0 <- c(m0, str_extract_all(temp, r0)[[1]])

	r0 <- "\\b(?:magnification\\W+(?:\\w+\\W+){1,4}?(μm|𝛍m|nm)|(μm|𝛍m|nm)\\W+(?:\\w+\\W+){1,4}?magnification)\\b"
	m0 <- c(m0, str_extract_all(temp, r0)[[1]])

	r0 <- "\\b(?:photo\\W+(?:\\w+\\W+){1,4}?(μm|𝛍m|nm)|(μm|𝛍m|nm)\\W+(?:\\w+\\W+){1,4}?photo)\\b"
	m0 <- c(m0, str_extract_all(temp, r0)[[1]])

	if (length(m0) > 0) {
		for (i in m0) {
			temp <- gsub(i, "", temp, fixed = TRUE)
		}
	}

	if (grepl("μm|𝛍m|nm", temp)) {

		# Simple decimal, range and unit
		r1 <- "(?:[0-9]{1,3}(?:\\.[0-9]{1,3})?)(( –|– |–|∼|-|−|( to )|( and )|( ± )|(±))(?:[0-9]{1,3}(?:\\.[0-9]{1,3})?))?[ ]?(μm|𝛍m|nm)"
		m1 <- str_extract_all(temp, r1)[[1]]
		diam1 <- m1[1] # small

		# Simple decimal, range, extra dimension and unit
		r2 <- "(?:[0-9]{1,3}(?:\\.[0-9]{1,3})?)(( –|– |–|∼|-|−|( to )|( and )|( ± )|(±))(?:[0-9]{1,3}(?:\\.[0-9]{1,3})?))?[ ]?(μm|𝛍m|nm)?[ ]?(×,|×|(long and)|(wide and)|(in length and)|(and lengths from)|( by )|(; width,)|(in diameter by)|( in length, )|( long, ))[ ]?(?:[0-9]{1,3}(?:\\.[0-9]{1,3})?)?(( –|– |–|∼|-|−|( to )|( and )|( ± )|(±))(?:[0-9]{1,3}(?:\\.[0-9]{1,3})?))?[ ]?(μm|𝛍m|nm)"
		m2 <- str_extract_all(temp, r2)[[1]]
		diam2 <- m2[1] # large

		if (!is.na(diam2)) {
			if (is.na(str_match(diam2, diam1))) {
				flag <- diam1
				diam_text <- diam2
			} else {
				diam_text <- diam2
			}
		} else {
			diam_text <- diam1
		}

		if (grepl("μm|𝛍m", diam_text)) {
			diam_unit <- "μm"
		}
		if (grepl("nm", diam_text)) {
			diam_unit <- "nm"
		}

		# Pull numbers
		t1 <- strsplit(diam_text, "×,|×|(long and)|(wide and)|(in length and)|(and lengths from)|( by )|(; width,)|(in diameter by)|( in length, )|( long, )")[[1]]
		t1 <- trim(gsub("μm|𝛍m|nm", "", t1))

		t2a <- trim(strsplit(t1[1], " –|– |–|∼|-|−|( to )|( and )|( ± )|(±)")[[1]])
		if (grepl("±", t1[1])) {
			d1_lo <- as.numeric(t2a[1]) - as.numeric(t2a[2])
			d1_up <- as.numeric(t2a[1]) + as.numeric(t2a[2])
		} else {
			d1_lo <- t2a[1]
			d1_up <- t2a[2]
		}

		if (length(t1) > 1) {
			t2b <- trim(strsplit(t1[2], " –|– |–|∼|-|−|( to )|( and )|( ± )|(±)")[[1]])

			if (grepl("±", t1[2])) {
				d2_lo <- as.numeric(t2b[1]) - as.numeric(t2b[2])
				d2_up <- as.numeric(t2b[1]) + as.numeric(t2b[2])
			} else {
				d2_lo <- t2b[1]
				d2_up <- t2b[2]
			}
		} 

	}
	return(data.frame(d1_lo=d1_lo, d1_up=d1_up, d2_lo=d2_lo, d2_up=d2_up, diam_text=diam_text, diam_unit=diam_unit))
}

get_doubling <- function(temp) {

	dt_lo <- dt_up <- NA
	dt_unit <- dt_text <- NA

	if(grepl("doubling time", temp)) {

		# temp <- gdat$text[14]
		# temp <- gdat$text[386]

		r1 <- "doubling time"
		m1 <- str_locate_all(tolower(temp), r1)[[1]]

		# Just taking first doubling time for now
		for (i in 1:1) {

			t1 <- tolower(substr(temp, m1[i,1] - 120, m1[i,2] + 120))

			ds <- str_locate_all(t1, "( d )|( d\\.)|( d,)|( d\\))|( days )|( days\\.)|( days,)|( days\\))|( day )|( day\\.)|( day,)|( day\\))")[[1]]
			hs <- str_locate_all(t1, "( h )|( h\\.)|( h,)|( h\\))|( hours )|( hours\\.)|( hours,)|( hours\\))")[[1]]
			ms <- str_locate_all(t1, "( mins )|( mins\\.)|( mins,)|( mins\\))|( min )|( min\\.)|( min,)|( min\\))")[[1]]

			t2 <- ""
			if (nrow(ds) > 0) {
				t2 <- strsplit(t1, "( d )|( d\\.)|( d,)|( d\\))|( days )|( days\\.)|( days,)|( days\\))|( day )|( day\\.)|( day,)|( day\\))")[[1]][1]
				dt_unit <- "days"
			}

			if (nrow(ms) > 0) {
				t2 <- strsplit(t1, "( mins )|( mins\\.)|( mins,)|( mins\\))|( min )|( min\\.)|( min,)|( min\\))")[[1]][1]
				dt_unit <- "minutes"
			}

			if (nrow(hs) > 0) {
				t2 <- strsplit(t1, "( h )|( h\\.)|( h,)|( h\\))|( hours )|( hours\\.)|( hours,)|( hours\\))")[[1]][1]
				dt_unit <- "hours"
			}
			# I've done this in such a way that shorter doubling times are gathered before longer ones

			d3 <- strsplit(t2, " ")[[1]]
			if (length(d3) > 1) {	
				d4 <- trim(d3[length(d3)])

				if (grepl("–|∼|-", d4)) {
					d5 <- strsplit(d4, "–|∼|-")[[1]]
					dt_lo <- gsub("\\)|\\(", "", d5[1])
					dt_up <- gsub("\\)|\\(", "", d5[2])
				} else {
					dt_lo <- gsub("\\)|\\(", "", d4)		
				} 
			}
		}

	}
	return(data.frame(dt_lo=dt_lo, dt_up=dt_up, dt_unit=dt_unit))
}

get_source <- function(temp) {
	if (grepl("Source:", temp)) {
		ss1 <- trim(strsplit(temp, "Source:")[[1]][2])
		ss2 <- trim(strsplit(ss1, "\\.")[[1]][1])

		source <- ss2
	} else {
		source <- NA
	}

	return(data.frame(source=source))
}

# # TESTS
# temp <- sdat$text[sdat$species=="Chryseoglobus frigidaquae"]
# get_accession(temp)
# temp <- sdat$text[sdat$species=="Mycobacterium canariasense"]
# get_accession(temp)
# temp <- sdat$text[sdat$species=="Acidiplasma cupricumulans"]
# get_accession(temp)
# temp <- sdat$text[sdat$species=="Actinomyces neuii subsp. neuii"]
# get_accession(temp)
# temp <- sdat$text[sdat$species=="Methylomarinum vadi"]
# get_accession(temp)
# temp <- sdat$text[sdat$species=="Streptococcus suis"]
# get_accession(temp)
# temp <- sdat$text[sdat$species=="Nocardioides alkalitolerans"]
# get_accession(temp)
# temp <- sdat$text[sdat$species=="Mycobacterium colombiense"]
# get_accession(temp)
# temp <- sdat$text[sdat$species=="Gordonia soli"]
# get_accession(temp)
# temp <- sdat$text[sdat$species=="Pseudoalteromonas haloplanktis"]
# get_accession(temp)
# temp <- sdat$text[sdat$species=="Treponema carateum"]
# get_accession(temp)
# temp <- sdat$text[sdat$species=="Candidatus Mycoplasma haemotarandirangiferis"]
# get_accession(temp)

# str_match(temp, "(((accession).{1,13}?:.{1,13}(16S))|((accession).{1,13}(16S).{1,13}?:)).*?(\\.|\\;)")[1,1]

get_accession <- function(temp) {

	acc_text <- str_match(temp, "(((accession).{1,13}?:.{1,13}(16S))|((accession).{1,13}(16S).{1,13}?:)).*?(\\.|\\;)")[1,1]
	accession <- NA

	if (!is.na(acc_text)) {
		aa1 <- trim(strsplit(acc_text, "\\:")[[1]])
		aa1 <- aa1[length(aa1)]
		aa2 <- trim(strsplit(aa1, "\\(.*?\\)")[[1]])
		aa2 <- aa2[which.max(nchar(aa2))]
		aa3 <- trim(strsplit(aa2, "\\.|,|and|for|Seq|;|–")[[1]])
		if (aa3[1] == "") {
			aa3 <- aa3[which.max(nchar(aa3))]
		} else {
			aa3 <- aa3[1]
		}
		if (nchar(aa3) > 13) {
			aa3 <- trim(strsplit(aa3, " ")[[1]])
			aa3 <- aa3[which.max(nchar(aa3))]			
		}
		if (grepl("(available|reported|determined)", aa3)) {
			aa3 <- NA
		}
		accession <- aa3
	} 
	return(data.frame(accession=accession, acc_text=acc_text))
}

get_shape <- function(temp) {

	bacilloid <- irregular <- coccus <- flattened <- pear_shaped <- polygonal <- prosthecate <- cuboidal <- pyramidal <- 0

	shapes <- list(
		bacilloid=c("bacilloid", "coccobacillus", "spirillum", "bacillus", "cylindrical", "diphtheroid", "vibrioid", "rods", "rod-shaped", "rod-like", "rod shaped", "bacilli", "short rods", "ovoid", "oval", "ellipsoidal", "coccobacilli", "coccobacillary", "barrel-shaped", "barreliform", "club-shaped", "corneform", "diphtheroid", "coiled", "helical", "helix", "spiral", "spirillum", "wavy", "crooked", "curved"),
		irregular=c("irregular", "pleomorphic"),
		coccus=c("coccus", "cocci", "coccoid", "coccoidal", "globose", "isodiametric", "lobed", "polygonal-rounded", "semi-globose", "spherical", "sphere-shaped", "spheres", "spheroidal", "spheroids"),
		flattened=c("flattened", "sub-cylindrical", "hemispherical", "discoid", "flat", "compressed", "disc", "disc-shaped", "discoid", "discoidal", "disk-shaped", "disk", "plate-shaped"),
		pear_shaped=c("pear-shaped", "flask", "flask-shaped", "flaskshaped", "flask shaped", "pearshaped", "pear-shaped", "pear shaped"),
		polygonal=c("polygonal", "polygonal shape"),
		prosthecate=c("prosthecate", "appendaged", "stalked"),
		cuboidal=c("cuboidal"),
		pyramidal=c("pyramidal", "triangles")
		)

	if (any(!is.na(str_match(tolower(temp), shapes$bacilloid)))) {bacilloid=1}
	if (any(!is.na(str_match(tolower(temp), shapes$irregular)))) {irregular=1}
	if (any(!is.na(str_match(tolower(temp), shapes$coccus)))) {coccus=1}
	if (any(!is.na(str_match(tolower(temp), shapes$flattened)))) {flattened=1}
	if (any(!is.na(str_match(tolower(temp), shapes$pear_shaped)))) {pear_shaped=1}
	if (any(!is.na(str_match(tolower(temp), shapes$polygonal)))) {polygonal=1}
	if (any(!is.na(str_match(tolower(temp), shapes$prosthecate)))) {prosthecate=1}
	if (any(!is.na(str_match(tolower(temp), shapes$cuboidal)))) {cuboidal=1}
	if (any(!is.na(str_match(tolower(temp), shapes$pyramidal)))) {pyramidal=1}

	return(data.frame(
		bacilloid=bacilloid,
		irregular=irregular,
		coccus=coccus,
		flattened=flattened,
		pear_shaped=pear_shaped,
		polygonal=polygonal,
		prosthecate=prosthecate,
		cuboidal=cuboidal,
		pyramidal=pyramidal
		))
}

# microeareophil

get_metabolism <- function(temp) {

	# temp <- gdat$text[556]
	r1 <- "((facultatively|obligately|strictly|facultative|obligate|strict)?[ |-]?(aerobic|aerobe|anaerobic|anaerobe))|(microaerophile|microaerophilic)"
	
	m1 <- trim(str_match(tolower(temp), r1)[1,1])
	m1 <- sub("aerobic", "aerobe", m1)
	m1 <- sub("strict|strictly", "obligate", m1)
	m1 <- sub("obligately", "obligate", m1)
	m1 <- sub("facultatively", "facultative", m1)
	m1 <- sub("microaerophile", "microaerophilic", m1)

	return(data.frame(metabolism=m1))

}

# Original,New,Priority,Category
# obligate aerobe,obligate aerobic,2,1
# anaerobic,anaerobic,1,2
# facultative anaerobe,facultative,2,1
# facultative aerobe,facultative,2,1
# microaerophile,microaerophilic,2,1
# aerobe,aerobic,1,1
# aerobic,aerobic,1,1
# NA,NA,0,0
# Aerobe,aerobic,1,1
# Obligate aerobe,obligate aerobic,2,1
# Facultative,facultative,2,1
# Microaerophilic,microaerophilic,2,1
# Anaerobe,anaerobic,1,2
# Obligate anaerobe,obligate anaerobic,2,2
# Facultative anaerobe,facultative,2,1
# Anaerobic,anaerobic,1,2
# obligate anaerobe,obligate anaerobic,2,2
# anaerobe,anaerobic,1,2




get_energy <- function(temp) {

	# temp <- sdat$text[558]
	r1 <- "(chemo|photo|litho|hetero|mixo|organo|auto)(chemo|photo|litho|hetero|mixo|organo|auto)?(chemo|photo|litho|hetero|mixo|organo|auto)?[ |-]?(trophic|troph)"
	
	m1 <- trim(str_match(tolower(temp), r1)[1,1])
	m1 <- sub("trophic", "troph", m1)

	return(data.frame(energy=m1))

}

get_intracellular <- function(temp) {

	intracellular <- 0
	# temp <- gdat$text[558]
	r1 <- "(intra)[ |-]?(cellular)"
	
	m1 <- trim(str_match(tolower(temp), r1)[1,1])

	if (any(!is.na(str_match(tolower(temp), r1)))) {intracellular=1}

	return(data.frame(intracellular=intracellular))

}

get_pathogen <- function(temp) {

	pathogen <- 0
	# temp <- gdat$text[558]
	r1 <- "pathogen"
	
	m1 <- trim(str_match(tolower(temp), r1)[1,1])

	if (any(!is.na(str_match(tolower(temp), r1)))) {pathogen=1}

	return(data.frame(pathogen=pathogen))

}
