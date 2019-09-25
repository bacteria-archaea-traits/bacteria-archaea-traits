source("R/functions.R")
# This code creates the NCBI taxonomy table for merging with datasets. Each row has a tax_id for a species or strain and the corresponding higher level teaxonomic information.

nam <- read.csv("output/taxonomy_names.csv", as.is=TRUE)
nod <- read.csv("output/taxonomy_nodes.csv", as.is=TRUE)

# Bacteria

bac_vec <- c("node_0", "tax_id")
bac <- nod[nod$parent_tax_id==2, c("parent_tax_id", "tax_id")]
names(bac) <- bac_vec

for (i in 1:12) {
  bac <- merge(bac, nod[nod$parent_tax_id %in% bac$tax_id, c("parent_tax_id", "tax_id")], by.x="tax_id", by.y="parent_tax_id", all=TRUE)
  bac_vec <- c(paste0("node_", i), bac_vec)
  names(bac) <- bac_vec
  print(paste("Interation:", i))
}
bac <- bac[,-14]
write.csv(bac,"output/taxmaps/ncbi_bac_nodes.csv", row.names=FALSE)

# Archaea

arc_vec <- c("node_0", "tax_id")
arc <- nod[nod$parent_tax_id==2157, c("parent_tax_id", "tax_id")]
names(arc) <- arc_vec

for (i in 1:9) {
  arc <- merge(arc, nod[nod$parent_tax_id %in% arc$tax_id, c("parent_tax_id", "tax_id")], by.x="tax_id", by.y="parent_tax_id", all=TRUE)
  arc_vec <- c(paste0("node_", i), arc_vec)
  names(arc) <- arc_vec
  print(paste("Interation:", i))
}
arc <- arc[,-11]
write.csv(arc,"output/taxmaps/ncbi_arc_nodes.csv", row.names=FALSE)

get_name <- function(n, rank=FALSE) {
  if (is.na(n)) {
    out <- NA
  } else {
    if (rank) {
      out <- nod$rank[nod$tax_id==n]
    } else {
      out <- nam$name_txt[nam$tax_id==n]
    }
  }
  if (length(out) < 1) {
    out <- NA
  }
  return(out)
}

arc_names <- apply(arc, 1:2, get_name)
write.csv(arc_names,"output/taxmaps/ncbi_arc_names.csv", row.names=FALSE)

arc_ranks <- apply(arc, 1:2, get_name, rank=TRUE)
write.csv(arc_ranks,"output/taxmaps/ncbi_arc_ranks.csv", row.names=FALSE)

bac_names <- apply(bac, 1:2, get_name)
write.csv(bac_names,"output/taxmaps/ncbi_bac_names.csv", row.names=FALSE)

bac_ranks <- apply(bac, 1:2, get_name, rank=TRUE)
write.csv(bac_ranks,"output/taxmaps/ncbi_bac_ranks.csv", row.names=FALSE)

# Processing ARCHAEA. I got lazy and the below code can take a while because I use a loop; however, this shouldn't need to be updated unless you update the NCBI taxonomy files.

arc_nodes <- as.matrix(read.csv("output/taxmaps/ncbi_arc_nodes.csv"))
arc_names <- as.matrix(read.csv("output/taxmaps/ncbi_arc_names.csv"))
arc_ranks <- as.matrix(read.csv("output/taxmaps/ncbi_arc_ranks.csv"))
arc_nodes[is.na(arc_nodes)] <- 0
arc_names[is.na(arc_names)] <- ""
arc_ranks[is.na(arc_ranks)] <- ""

master <- data.frame()

for (i in 1:nrow(arc_nodes)) {
  tnodes <- arc_nodes[i,]
  tranks <- arc_ranks[i,]
  tnames <- arc_names[i,]

  if (any(tranks=="species")) {

    species <- genus <- family <- order <- class <- phylum <- superkingdom <- NA

    if (length(tnames[tranks=="species"]) > 0) {
      species <- tnames[tranks=="species"]
    }
    if (length(tnames[tranks=="genus"]) > 0) {
      genus <- tnames[tranks=="genus"]
    }
    if (length(tnames[tranks=="family"]) > 0) {
      family <- tnames[tranks=="family"]
    }
    if (length(tnames[tranks=="order"]) > 0) {
      order <- tnames[tranks=="order"]
    }
    if (length(tnames[tranks=="class"]) > 0) {
      class <- tnames[tranks=="class"]
    }
    if (length(tnames[tranks=="phylum"]) > 0) {
      phylum <- tnames[tranks=="phylum"]
    }
    if (length(tnames[tranks=="superkingdom"]) > 0) {
      superkingdom <- tnames[tranks=="superkingdom"]
    }

    for (j in 1:which(tranks=="species")) {
      if (tnodes[j] > 0) {
        tax_id <- tnodes[j]
        if (all(master$tax_id!=tax_id)) {
          master <- rbind(master, data.frame(tax_id=tax_id, species=species, genus=genus, family=family, order=order, class=class, phylum=phylum, superkingdom=superkingdom))
        }
      }
    }
  }
}

write.csv(master, "output/taxmaps/ncbi_arc_taxmap.csv", row.names=FALSE)

# Processing BACTERIA

bac_nodes <- as.matrix(read.csv("output/taxmaps/ncbi_bac_nodes.csv"))
bac_names <- as.matrix(read.csv("output/taxmaps/ncbi_bac_names.csv"))
bac_ranks <- as.matrix(read.csv("output/taxmaps/ncbi_bac_ranks.csv"))
bac_nodes[is.na(bac_nodes)] <- 0
bac_names[is.na(bac_names)] <- ""
bac_ranks[is.na(bac_ranks)] <- ""

master <- data.frame()

for (i in 300001:459911) {
  tnodes <- bac_nodes[i,]
  tranks <- bac_ranks[i,]
  tnames <- bac_names[i,]

  if (any(tranks=="species")) {

    species <- genus <- family <- order <- class <- phylum <- superkingdom <- NA

    if (length(tnames[tranks=="species"]) > 0) {
      species <- tnames[tranks=="species"]
    }
    if (length(tnames[tranks=="genus"]) > 0) {
      genus <- tnames[tranks=="genus"]
    }
    if (length(tnames[tranks=="family"]) > 0) {
      family <- tnames[tranks=="family"]
    }
    if (length(tnames[tranks=="order"]) > 0) {
      order <- tnames[tranks=="order"]
    }
    if (length(tnames[tranks=="class"]) > 0) {
      class <- tnames[tranks=="class"]
    }
    if (length(tnames[tranks=="phylum"]) > 0) {
      phylum <- tnames[tranks=="phylum"]
    }
    if (length(tnames[tranks=="superkingdom"]) > 0) {
      superkingdom <- tnames[tranks=="superkingdom"]
    }

    for (j in 1:which(tranks=="species")) {
      if (tnodes[j] > 0) {
        tax_id <- tnodes[j]
        if (all(master$tax_id!=tax_id)) {
          master <- rbind(master, data.frame(tax_id=tax_id, species=species, genus=genus, family=family, order=order, class=class, phylum=phylum, superkingdom=superkingdom))
        }
      }
    }
  }
}

write.csv(master, "output/taxmaps/ncbi_bac_taxmap3.csv", row.names=FALSE)

master1 <- read.csv("output/taxmaps/ncbi_bac_taxmap1.csv")
master2 <- read.csv("output/taxmaps/ncbi_bac_taxmap2.csv")
master3 <- read.csv("output/taxmaps/ncbi_bac_taxmap3.csv")
master4 <- read.csv("output/taxmaps/ncbi_arc_taxmap.csv")

master <- rbind(master1, master2, master3,master4)

write.csv(master, "output/taxmaps/ncbi_taxmap.csv", row.names=FALSE)


# Adding species tax_id as well

dat <- read.csv("output/taxmaps/ncbi_taxmap.csv")

nam <- nam[,c("tax_id", "name_txt")]
names(nam) <- c("species_tax_id", "name_txt")
dat <- merge(dat, nam, by.x="species", by.y="name_txt", all.x=TRUE)
dat <- dat[,c("tax_id", "species_tax_id", "species", "genus", "family", "order", "class", "phylum", "superkingdom")]
dat <- dat[order(dat$species_tax_id),]

write.csv(dat, "output/taxmaps/ncbi_taxmap.csv", row.names=FALSE)