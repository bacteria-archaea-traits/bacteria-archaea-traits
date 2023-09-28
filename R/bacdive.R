#https://github.com/mBiocoder/Bacdiving
#
API_USER_NAME <- "raymond.lesiyon@cuanschutz.edu"
API_PASSWD <- "BacDive23#"

bacdive_access_object <- BacDive::open_bacdive(API_USER_NAME, API_PASSWD)

fetch_bacdive_ids_by_taxonomy <- function(taxon_name, bacdive_access_object){
  query_term <- taxon_name
  results <- BacDive::request(object = bacdive_access_object, query =query_term , search = "taxon")
  if (is.null(results)){
    return(NULL)
  }
  return(unlist(results$results))
}

get_biosafety_level <- function(taxon_name, access_object){
  template_file <- list.files(system.file("extdata", package="BacDiveR"), full.names = T)
  bacDiveIds <- fetch_bacdive_ids_by_taxonomy(taxon_name, access_object)
  if(is_null(bacDiveIds)){
    return("")
  }
  bsl_safety_lvls <- c()
  for (bacDiveId in bacDiveIds){
    bsl <- BacDiveR::getDataByBacDiveId(access_object, bacDiveId, template_file)$Biosafety_level
    if(!is.null(bsl)){
      bsl_safety_lvls <- append(bsl_safety_lvls, bsl)
    }
  }
  return(as.double(max(bsl_safety_lvls)))
}

get_bsl_for_species <- function(condense_spp, access_object){
  bsl <- c()
  cl <- makeCluster(detectCores(), outfile="output.txt")
  clusterExport(cl, c("get_biosafety_level", "fetch_bacdive_ids_by_taxonomy", 
                          "bacdive_access_object", "is_null"), 
                envir=environment())
  f <- function(x) {
    spp_bsl <- get_biosafety_level(x, access_object)
    print(sprintf("%s BSL: %s", x, spp_bsl))
    return(tibble::tibble(species=x, bsl=spp_bsl))
  } 
  bsl_levels <- do.call(rbind, parallel::parLapply(cl, condense_spp, f))
  #for(spp in condense_spp){
  #  spp_bsl <- get_biosafety_level(spp, access_object)
  #  print(sprintf("%s BSL: %s", spp, spp_bsl))
  #  bsl <- append(bsl, spp_bsl)
  #}
  stopCluster(cl)
  return(bsl_levels)
}

