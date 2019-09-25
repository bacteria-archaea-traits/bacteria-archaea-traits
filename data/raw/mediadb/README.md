# MediaDB notes

Media DB MySQL dump was downloaded from https://mediadb.systemsbiology.net/defined_media/downloads/

The MySQL dump file can be piped into a sqlite file using the unix command (if you don't have MySQL installed):

    sqlite3 media_database.sqlite3 < media_database.07Oct2015.sql

Open the file in sqlite:

    sqlite3 media_database.sqlite3
    .schema
  
We were only after growth rate and some environemntal factors:

    select Genus, Species, Strain, Growth_Rate, Growth_Units, pH, Temperature_C from growth_data join organisms on growth_data.StrainID = organisms.StrainID;

Export the select as a csv file with this:

    .mode csv
    .output media_database.csv
     select Genus, Species, Strain, Growth_Rate, Growth_Units, pH, Temperature_C from growth_data join organisms on growth_data.StrainID = organisms.StrainID;
    .output stdout
