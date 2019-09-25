# Extract data from KEGG database. The Prokaryotes.html file is simply the saved table from: http://www.genome.jp/kegg-bin/show_organism?category=Prokaryotes

kegg <- readHTMLTable("data/kegg/Prokaryotes.html")
kegg <- list.clean(kegg, fun = is.null, recursive = FALSE)
n.rows <- unlist(lapply(kegg, function(t) dim(t)[1]))
kegg <- kegg[[which.max(n.rows)]]

store <- data.frame()

for (i in 1:length(kegg$link)) {

	acc_url <- paste0("http://www.genome.jp/kegg-bin/show_organism?org=", kegg$link[i])
	acc_get <- getURL(acc_url)

	temp <- readHTMLTable(acc_get)
	temp <- list.clean(temp, fun = is.null, recursive = FALSE)
	temp <- temp[[2]]
	if (is.na(temp$V2[1])) {
		temp <- temp[-1,]
	}

	# Extract statistics
	stats <- temp$V2[temp$V1=="Statistics"]
	if (grepl("Number of nucleotides", stats)) {
		s1 <- trim(strsplit(stats, "Number of nucleotides:")[[1]])[2]
		number_of_nucleotides <- trim(strsplit(s1, " ")[[1]])[1]
	} else {
		number_of_nucleotides <- NA
	}
	if (grepl("Number of protein genes", stats)) {
		s1 <- trim(strsplit(stats, "Number of protein genes:")[[1]])[2]
		number_of_protein_genes <- trim(strsplit(s1, " ")[[1]])[1]
	} else {
		number_of_protein_genes <- NA
	}
	if (grepl("Number of RNA genes", stats)) {
		s1 <- trim(strsplit(stats, "Number of RNA genes:")[[1]])[2]
		number_of_RNA_genes <- trim(strsplit(s1, " ")[[1]])[1]
	} else {
		number_of_RNA_genes <- NA
	}

	# Not all data is recorded all the time
	if (length(temp$V2[temp$V1=="Keywords"]) > 0) {
		keywords <- temp$V2[temp$V1=="Keywords"]
	} else {
		keywords <- NA
	}

	if (length(temp$V2[temp$V1=="Disease"]) > 0) {
		disease <- temp$V2[temp$V1=="Disease"]
	} else {
		disease <- NA
	}

	if (length(temp$V2[temp$V1=="Comment"]) > 0) {
		comment <- temp$V2[temp$V1=="Comment"]
	} else {
		comment <- NA
	}

	types <- temp$V1[temp$V1=="Chromosome" | temp$V1=="Plasmid"]
	details <- temp$V2[temp$V1=="Chromosome" | temp$V1=="Plasmid"]
	sequences <- temp$V2[temp$V1=="Sequence"]
	sequences <- gsub("GB: |RS: ", "", sequences)
	lengths <- temp$V2[temp$V1=="Length"]

	chromplas <- data.frame(type=types, detail=details, accession=sequences, length=lengths)
	if (nrow(chromplas) == 0) {
		chromplas <- data.frame(type=NA, detail=NA, accession=NA, length=NA)
	}

	other <- data.frame(
		t_number=temp$V2[temp$V1=="T number"],
		org_code=temp$V2[temp$V1=="Org code"],
		aliases=temp$V2[temp$V1=="Aliases"],
		full_name=temp$V2[temp$V1=="Full name"],
		definition=temp$V2[temp$V1=="Definition"],
		annotation=temp$V2[temp$V1=="Annotation"],
		taxonomy=temp$V2[temp$V1=="Taxonomy"],
		lineage=temp$V2[temp$V1=="Lineage"],
		data_source=temp$V2[temp$V1=="Data source"],
		keywords=keywords,
		disease=disease,
		comment=comment,

		number_of_nucleotides=number_of_nucleotides,
		number_of_protein_genes=number_of_protein_genes,
		number_of_RNA_genes=number_of_RNA_genes,

		created=temp$V2[temp$V1=="Created"]
	)

	store <- rbind(store, cbind(other, chromplas))
}

store$accession2 <- gsub(" .*", "", store$accession)

store$tax_id <- gsub("TAX: ", "", store$taxonomy)

write.csv(store, "output/processed_data/kegg_full.csv", row.names=FALSE)
