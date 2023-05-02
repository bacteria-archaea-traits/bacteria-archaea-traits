# Packages required for pipeline

if (!"tidyverse" %in% installed.packages()) install.packages("tidyverse")
library("tidyverse")

if (!"readxl" %in% installed.packages()) install.packages("readxl")
library("readxl")


# if (!"parallel" %in% installed.packages()) install.packages("parallel")
# library("parallel")

# Online data extractions

if (!"XML" %in% installed.packages()) install.packages("XML")
library("XML")

if (!"RCurl" %in% installed.packages()) install.packages("RCurl")
library("RCurl")

if (!"rlist" %in% installed.packages()) install.packages("rlist")
library("rlist")

# Below from Bergeys, may not be necessary

if (!"pdftools" %in% installed.packages()) install.packages("pdftools")
library("pdftools")

if (!"jsonlite" %in% installed.packages()) install.packages("jsonlite")
library("jsonlite")
