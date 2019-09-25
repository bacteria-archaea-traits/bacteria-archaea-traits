# mistdb

library(yaml)

# sig_domains <- read_yaml("https://api.mistdb.caltech.edu/v1/signal_domains")
# sig_domains <- data.frame(matrix(unlist(sig_domains), nrow=487, byrow=T),stringsAsFactors=FALSE)[,c(2, 4, 5)]
# names(sig_domains) <- c("name", "kind", "function")
# 
# length(sig_domains)
# length(unlist(lapply(sig_domains, '[[', 2)))
#
# p <- 1
# genomes <- read_yaml(paste0("https://api.mistdb.caltech.edu/v1/genomes?page=", p))

check_null <- function(x) {
	if (is.null(x)) {
		return(NA)
	} else {
		return(x)
	}
}

store <- data.frame()

for (p in 1:10) {
	genomes <- read_yaml(paste0("https://api.mistdb.caltech.edu/v1/genomes?page=", p))

	for (g in 1:length(genomes)) {
		
		# g <- 1
		gene <- genomes[[g]]	
		tax_id <- gene$taxonomy_id
		vers <- gene$version
		# vers <- "GCF_000006765.1"
		stp <- read_yaml(paste0("https://api.mistdb.caltech.edu/v1/genomes/", vers, "/stp-matrix"))
		counts <- stp$counts
		
		store <- rbind(store, data.frame(tax_id=tax_id, vers=vers, 
			ocp=check_null(counts$ocp), 
			tcp.hk=check_null(counts$`tcp,hk`), 
			tcp.hhk=check_null(counts$`tcp,hhk`), 
			tcp.rr=check_null(counts$`tcp,rr`), 
			tcp.hrr=check_null(counts$`tcp,hrr`), 
			tcp.other=check_null(counts$`tcp,other`), 
			tcp.chemotaxis=check_null(counts$`tcp,chemotaxis`), 
			ecf=check_null(counts$ecf), 
			other=check_null(counts$other), 
			majormodes_total=check_null(stp$numStp),

			chemotaxis.mcp=check_null(counts$`chemotaxis,mcp`), 
			chemotaxis.chew=check_null(counts$`chemotaxis,chew`), 
			chemotaxis.chea=check_null(counts$`chemotaxis,chea`), 
			chemotaxis.cher=check_null(counts$`chemotaxis,cher`), 
			chemotaxis.cheb=check_null(counts$`chemotaxis,cheb`), 
			chemotaxis.checx=check_null(counts$`chemotaxis,checx`), 
			chemotaxis.chev=check_null(counts$`chemotaxis,chev`), 
			chemotaxis.ched=check_null(counts$`chemotaxis,ched`), 
			chemotaxis.chez=check_null(counts$`chemotaxis,chez`),
			chemotaxis.other=check_null(counts$`chemotaxis,other`),

			chemotaxis_total=check_null(stp$numChemotaxis),
			genome_size=check_null(stp$totalLength))
		)		
	}
	write.csv(store, file="output/processed_data/clean_mist.csv", row.names=FALSE)
}
