# ProTrais

print("Processing data-set 'protraits'...", quote = FALSE)

prt95 <- read.delim("data/raw/protraits/ProTraits_binaryIntegratedPr0.95.txt", header = TRUE, stringsAsFactors = FALSE, quote = "")

prt95[prt95 == "?"] <- NA

# Collect useful columns based on key names

#groups:
#oxygenreq
#metabolism
#shape

#singles:
#mobility, motility
#gram_stain
#flagellarpresence
#sporulation

#Grab required columns based on key names
single_cols <- c("Organism_name","Tax_ID","motility","mobility","sporulation","gram_stain.positive")

multi_cols <- names(prt95[,grepl("oxygenreq",names(prt95))])
multi_cols <- c(multi_cols, names(prt95[,grepl("shape",names(prt95))]))

#Limit data frame to required columns
df <- prt95[,c(single_cols,multi_cols)]

#Replace 1 with value of column (in multi columns)
for(i in 1:length(multi_cols)) {
  #Remove anything before dot
  value <- gsub(".*\\.","",multi_cols[i])
  #Insert value where 1             
  df[,multi_cols[i]][df[,multi_cols[i]] == 1] <- value
}


#Merge all multi columns into single columns


# Oxygen requirement

#Remove all "0" values from selected columns
cols <- names(df[,grepl("oxygenreq.",names(df))])
for(i in 1:length(cols)) {
  for(a in 1:nrow(df)) {
    if(!is.na(df[a,cols[i]]) & df[a,cols[i]] == "0") {
      df[a,cols[i]] <- NA
    }
  }
}

#Transfer values to one column
df$metabolism <- NA
cols <- names(df[,grepl("oxygenreq.",names(df))])
# Move data from each column into new column
for(a in 1:length(cols)) {
  df[!is.na(df[,cols[a]]),"metabolism"] <- df[!is.na(df[,cols[a]]),cols[a]]
}  
  
# Remove original columns
df <- df[, !grepl("oxygenreq.", names(df))]


# Shape

#Remove all "0" values from selected columns
cols <- names(df[,grepl("shape.",names(df))])
for(i in 1:length(cols)) {
  for(a in 1:nrow(df)) {
    if(!is.na(df[a,cols[i]]) & df[a,cols[i]] == "0") {
      df[a,cols[i]] <- NA
    }
  }
}

names(df[,grepl("shape.",names(df))])
df$cell_shape <- NA
cols <- names(df[,grepl("shape.",names(df))])
# Move data from each column into new column
for(a in 1:length(cols)) {
  df[!is.na(df[,cols[a]]),"cell_shape"] <- df[!is.na(df[,cols[a]]),cols[a]]
} 
# Remove original columns
df <- df[, !grepl("shape.", names(df))]


# motility / mobility

#Rename original columns
colnames(df)[which(names(df) == "motility")] <- "mobility.1"
colnames(df)[which(names(df) == "mobility")] <- "mobility.2"
df$motility <- NA
df$motility <- apply(df[,grepl("mobility.", names(df))], 1, max, na.rm = TRUE)
# Remove original columns
df <- df[, !grepl("mobility.", names(df))]

#We translate motilty here as '0' already represents NA in motility translation table
df$motility[df$motility == 1] <- "yes"
df$motility[df$motility == 0] <- "no"


df2 <- df

#Rename columns
colnames(df2)[which(names(df2) == "Tax_ID")] <- "tax_id"
colnames(df2)[which(names(df2) == "Organism_name")] <- "org_name"
colnames(df2)[which(names(df2) == "gram_stain.positive")] <- "gram_stain"

trait_cols <- names(df2[,3:length(names(df2))])
#Remove all rows with lacking information
df2 <- df2[rowSums(is.na(df2[trait_cols])) != length(trait_cols), ]

df2$ref_type <- "doi"
df2$reference <- "doi.org/10.1093/nar/gkw964"

# Save 
#Save master data
write.csv(df2, "output/prepared_data/protraits.csv", row.names=FALSE, quote=TRUE)

print("Done", quote = FALSE)