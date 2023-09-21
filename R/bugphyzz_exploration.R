if (!require("BiocManager", quietly = TRUE))
  install.packages("BiocManager")

BiocManager::install(c("waldronlab/bugphyzz", "bugsigdbr", "readr"))

## bugphyzz
## get the data
df <- bugphyzz::importBugphyzz()

## bacDive data
bacDiveDf <- bugphyzz:::.getBacDive()

## getting bacDive data: 
## package: https://github.com/jwokaty/BacDiveR
