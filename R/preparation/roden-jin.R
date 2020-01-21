# roden-jin.csv

roj <- read.csv("data/raw/roden-jin/roden-jin.csv")

#Fix names via lookup in ncbi. Where strain can not be found 
#taxonomy is reduced to species level:

roj$organism[roj$organism == "Desulfovibrio vulgaris Marburg"] <- "Desulfovibrio vulgaris"
roj$organism[roj$organism == "Desulfovibrio baculatus H.L21"] <- "Desulfomicrobium baculatum"
roj$organism[roj$organism == "Shewanella algae BrY"] <- "Shewanella algae"
roj$organism[roj$organism == "Methanosarcina mazei S6"] <- "Methanosarcina mazei S-6"
roj$organism[roj$organism == "Pseudomonas M-27"] <- "Pseudomonas sp. M27"
roj$organism[roj$organism == "Desulfovibrio vulgaris Madison"] <- "Desulfovibrio vulgaris"
roj$organism[roj$organism == "Methanobacterium bryantii MOH"] <- "Methanobacterium bryantii"
roj$organism[roj$organism == "Clostridium pasteurianum LMG 3285"] <- "Clostridium pasteurianum"
roj$organism[roj$organism == "Desulfovibrio desulfuricans Essex 6"] <- "Desulfovibrio desulfuricans"
roj$organism[roj$organism == "Desulfobacter postgatei D.A41"] <- "Desulfobacter postgatei"
roj$organism[roj$organism == "Desulfosporomusa polytropa STP3"] <- "Desulfosporomusa polytropa"
roj$organism[roj$organism == "Methanotrix soehngenii Opfikon"] <- "Methanothrix soehngenii"
roj$organism[roj$organism == "Methanobrevibacter arboriphilus AZ"] <- "Methanobrevibacter arboriphilus"
roj$organism[roj$organism == "Rhodopseudomonas sheperoides"] <- "Rhodobacter sphaeroides"
roj$organism[roj$organism == "Desulfobulbus propionicus NS.P31"] <- "Desulfobulbus propionicus"
roj$organism[roj$organism == "Desulfosporomusa polytropa STP1"] <- "Desulfosporomusa polytropa"
roj$organism[roj$organism == "Methanotrix concilii GP6"] <- "Methanothrix soehngenii GP6"
roj$organism[roj$organism == "Pseudomonas AM-1"] <- "Methylorubrum extorquens AM1"
roj$organism[roj$organism == "Desolfovibrio strain G11"] <- "Desulfovibrio sp. G11"
roj$organism[roj$organism == "Methanobacterium formicum JF1"] <- "Methanobacterium formicicum"
roj$organism[roj$organism == "Methanobrevibacter arboriphilus DH1"] <- "Methanobrevibacter arboriphilus JCM 13429 = DSM 1125"
roj$organism[roj$organism == "Azotobacter vinilandii"] <- "Azotobacter vinelandii"

#Get tax ids by names
roj2 <- roj %>% inner_join(nam[,c("name_txt","tax_id")], by = c("organism"="name_txt"))
#Get species tax ids
roj3 <- roj2 %>% inner_join(tax[,c("tax_id","species_tax_id")], by = "tax_id")

#Add reference type
roj3$ref_type <- "full_text"

#Reduce to required columns and rename to standard
roj4 <- roj3 %>% select(organism,tax_id,species_tax_id,energy_process,reference,ref_type) %>%
  rename(org_name=organism, processes=energy_process)

#Save master data
write.csv(roj4, "output/prepared_data/roden-jin.csv", row.names=FALSE)