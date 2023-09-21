# Function to select categorical trait value based on its proportion of the total
# If a decission cannot be made based on simple proportional representation, 
# a set of category and priority rules will be applied using lookup tables
## break the function to components or steps:
## condensed cogem_classification
#' @param strain_level_data
#' @param trait
#' @return
#' @export
#' @author Raymond Lesiyon
#' @description
#' The functions condensed the cogem_classification for pathogenicity. For the 
#' the same classes, a maximum is used instead which means, the species level
#' pathogenicity is assigned to highest BSL level: BSL-1 becomes BSL-2

condensed_cogem_trait <- function(data, trait, minProp){
  
  t3 <- .get_props(data, trait) 
  results <- .get_majority_props(t3, minProp)
  return(results)
}

#' @param data
#' @param trait
#' @return
#' @export
#' @author Raymond Lesiyon
#' @description
#' Getting data proportions for the categorical data.
#' 
.get_props <- function(data, trait, minProp){
  
  # Count occurences of each trait value for each species
  t <- data %>% group_by(species,.data[[trait]]) %>% 
    filter(!is.na(.data[[trait]])) %>% 
    summarise(n = n())
  
  # Count number of different trait values
  t2 <- t %>% group_by(species) %>% 
    summarise(total = sum(n))
  
  # Join total count with per variable count
  t3 <- inner_join(t,t2, by = "species")
  
  # Calculate proportional representation of each trait value out of total
  t3 <- t3 %>% mutate(prop = n / total * 100)
  
  ## get the most dominate group
  return(t3)
}

#' @param data
#' @param trait
#' @return
#' @export
#' @author Raymond Lesiyon
#' @description
#' Make the call for the majority groups. 
.get_majority_props <- function(t3, minProp){
  return (
    t3 %>% group_by(species) %>%
      filter(prop > minProp) %>%
      top_n(n=1,prop) %>% 
      filter(!duplicated(species))
  )
}

.load_category <- function(trait){
  file <- sprintf("renaming_%s.csv",trait)
  #Get file
  cat <- read.csv(sprintf("%s/%s",CONSTANT_LOOKUP_TABLE_PATH ,file), as.is=TRUE)
  return(cat)
}

.ruling_categorical_with_cat <- function(ruling, results, trait, priority) {
  if(nrow(ruling)>0) {
    
    print(sprintf("Data for %s species require processing using category and priority tables",length(unique(ruling$species))))
    
    #Use priority ruling to decide which terms to keep
    #Categories and priorities values are located in the respective
    #traits renaming table
    
    # Get renaming table 
    file <- sprintf("renaming_%s.csv",trait)
    #Get file
    cat <- read.csv(sprintf("%s/%s",CONSTANT_LOOKUP_TABLE_PATH ,file), as.is=TRUE)
    if(nrow(cat)>0) {
      
      print(sprintf("Applying rules to decide %s for remaining species using file %s",trait,file))
      #Remove duplicated rows in lookup table
      cat <- cat[!duplicated(cat$New) ,c("New", "Priority", "Category")]
      
      # Attach grouping cateogories and priorities by the trait value
      # Note: Translated trait values are stored in the lookup table column "New"
      
      var1 <- trait
      var2 <- "New"
      ruling <- ruling %>% inner_join(cat, by = setNames(nm=var1, var2))
      
      # Count number of distinct categories for each species 
      # (if more than one, the data is contradictory)
      inconsistent <- ruling %>% group_by(species) %>% 
        summarise(n_cats = n_distinct(Category)) %>% 
        filter(n_cats >1)
      
      print(sprintf("%s species have inconsistent data, data removed", length(unique(inconsistent$species))))
      
      # Remove all species with multiple categories 
      # (data points contradictory, i.e. both anaerobic and aerobic)
      ruling <- ruling %>% filter(!(species %in% inconsistent$species))
      
      # From here, the ruling table only contains species for which 
      # we should be able to make a decission (if any left)
      
      if(nrow(ruling)>0) {
        
        # There are species with multiple trait values within a category
        # Chose which to keep based on setting
        
        if(priority == "max") {
          #Keep the most stringent (most informative) level (i.e. aerobic = 1, obligate aerobic = 2, keep #2)
          
          print("Chosing terms with MAXIMUM stringency")
          
          ruling <- ruling %>% group_by(species) %>% 
            filter(Priority == max(Priority))
          
        } else if(priority == "min") {
          #Keep the least stringent (least informative) word (i.e. aerobic = 1, obligate aerobic = 2, keep #1)
          
          print("Chosing terms with MININIMUM stringency")
          
          ruling <- ruling %>% group_by(species) %>% 
            filter(Priority == min(Priority))
        }
        
        # If any of the remaining species are recorded with multiple terms at the same priority level
        # (such as for motility "flagella" = 2 and gliding = 2), 
        # simply reduce the term to the lowest stringency level such as "yes" = 1
        
        # Get species still listed with more than one term (duplicated)
        update <- ruling[duplicated(ruling$species),]
        
        if(nrow(update)>0) {
          
          print(sprintf("%s species have multiple terms at same priority level, reducing to lower level priority", length(unique(update$species)))) 
          
          # Get data for these species from the current ruling table
          #update <- ruling %>% inner_join(update, by = "species")
          
          #Get just one row per species
          #update <- update[!(duplicated(update$species)),]
          
          #Update table
          for(i in 1:nrow(update)) {
            update[i,trait] <- as.character(cat[cat$Category == update$Category[i] & cat$Priority == (update$Priority[i]-1),"New"])
            # Since we're changing the data, we remove counts and proportions
            update[i,c("n","prop")] <- NA
          }
          
          #Remove redundant species from ruling table
          ruling <- ruling[!(ruling$species %in% update$species),]
          #Append newly updated species to ruling table
          ruling <- ruling %>% bind_rows(update)
          
        }
        
        # Finally, remove all species that could not be resolved in this process
        remove <- ruling %>% group_by(species) %>% 
          summarise(count = n()) %>% 
          filter(count > 1)
        
        if(nrow(remove)>0) {
          print(sprintf("Data for %s could not be processed, removed",length(unique(remove$species))))
          ruling <- ruling %>% filter(!(species %in% remove$species))
        }
        
        #Remove priority and category columns
        ruling <- subset(ruling, select = -c(Priority, Category))
        
        # Append ruled species to results
        results <- results %>% bind_rows(ruling)
        
      }
    }
  }
  return(results)
}

#' @param data
#' @param trait
#' @return
#' @export
#' @author Raymond Lesiyon
#' @description
#' Getting data proportions for the categorical data.
#' 
.get_props <- function(data, trait, minProp){
  
  # Count occurences of each trait value for each species
  t <- data %>% group_by(species,.data[[trait]]) %>% 
    filter(!is.na(.data[[trait]])) %>% 
    summarise(n = n())
  
  # Count number of different trait values
  t2 <- t %>% group_by(species) %>% 
    summarise(total = sum(n))
  
  # Join total count with per variable count
  t3 <- inner_join(t,t2, by = "species")
  
  # Calculate proportional representation of each trait value out of total
  t3 <- t3 %>% mutate(prop = n / total * 100)
  
  ## get the most dominate group
  return(t3)
}

condensed_cogem_trait <- function(data, trait, minProp){
  t3 <- .get_props(data, trait) 
  results <- .get_majority_props(t3, minProp)
  get_max_cogem_class <- t3 %>% filter(!species %in% results$species) %>%
    group_by(species) %>% top_n(1, cogem_classification)
  
  return(get_max_cogem_class %>%bind_rows(results))
}